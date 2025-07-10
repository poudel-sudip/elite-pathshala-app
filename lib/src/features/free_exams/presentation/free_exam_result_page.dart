import 'dart:convert';
import 'package:elite_pathshala/src/core/models/free_exam_models.dart';
import 'package:elite_pathshala/src/features/free_exams/presentation/free_exams_page.dart';
import 'package:flutter/material.dart';

class FreeExamResultPage extends StatefulWidget {
  final ExamResultData resultData;
  final String examName;

  const FreeExamResultPage({
    super.key,
    required this.resultData,
    required this.examName,
  });

  @override
  State<FreeExamResultPage> createState() => _FreeExamResultPageState();
}

class _FreeExamResultPageState extends State<FreeExamResultPage> {
  bool _showCorrectAnswers = false;
  final Map<int, String> _userAnswers = {};

  @override
  void initState() {
    super.initState();
    _parseUserRemarks();
  }

  void _parseUserRemarks() {
    try {
      if (widget.resultData.remarks.isNotEmpty) {
        dynamic remarksData;
        try {
          remarksData = jsonDecode(widget.resultData.remarks);
        } catch (e) {
          remarksData = widget.resultData.remarks;
        }

        if (remarksData is List) {
          for (String remark in remarksData) {
            _parseRemarkItem(remark);
          }
        } else if (remarksData is String) {
          if (remarksData.contains(',')) {
            final remarks = remarksData.split(',');
            for (String remark in remarks) {
              _parseRemarkItem(remark.trim());
            }
          } else {
            _parseRemarkItem(remarksData);
          }
        }
      }
    } catch (e) {
    }
  }

  void _parseRemarkItem(String remark) {
    final parts = remark.split(':');
    if (parts.length == 2) {
      final questionPart = parts[0].replaceAll('q-', '');
      final questionIndex = int.tryParse(questionPart);
      final status = parts[1];
      if (questionIndex != null) {
        _userAnswers[questionIndex] = status;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final totalQuestions = widget.resultData.totalQuestions;
    final fullMarks = widget.resultData.fullMarks;
    final correctQuestions = int.tryParse(widget.resultData.correctQuestions) ?? 0;
    final wrongQuestions = int.tryParse(widget.resultData.wrongQuestions) ?? 0;
    final leavedQuestions = int.tryParse(widget.resultData.leavedQuestions) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.examName),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text('ID: ${widget.resultData.id}', style: const TextStyle(fontSize: 16)),
                Text('Name: ${widget.resultData.name}', style: const TextStyle(fontSize: 16)),
                const SizedBox(height: 24),
                const Text(
                  'Your Result Status is Given Below.',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16),
                _buildResultStatusRow(
                    'Total Questions:', '$totalQuestions', Colors.black),
                _buildResultStatusRow(
                    'Full Marks:', '$fullMarks', Colors.black),
                _buildResultStatusRow(
                    'Correct Questions:', '$correctQuestions', Colors.green),
                _buildResultStatusRow(
                    'Wrong Questions:', '$wrongQuestions', Colors.red),
                _buildResultStatusRow(
                    'Leaved Questions:', '$leavedQuestions', Colors.cyan),
                _buildResultStatusRow('Marks Obtained:',
                    widget.resultData.marksObtained, Colors.blue),
                const SizedBox(height: 24),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 6,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 1.8,
                  ),
                  itemCount: totalQuestions,
                  itemBuilder: (context, index) {
                    final questionNumber = index + 1;
                    final status = _userAnswers[questionNumber] ?? 'l';
                    return _buildQuestionBox(questionNumber, status);
                  },
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    padding:
                        const EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                  ),
                  onPressed: () {
                    setState(() {
                      _showCorrectAnswers = !_showCorrectAnswers;
                    });
                  },
                  child: Text(
                    _showCorrectAnswers
                        ? 'Hide The Correct Answers'
                        : 'Show The Correct Answers',
                    style: const TextStyle(fontSize: 14),
                  ),
                ),
                const SizedBox(height: 8),
                if (_showCorrectAnswers)
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 4,
                      crossAxisSpacing: 8,
                      mainAxisSpacing: 8,
                      childAspectRatio: 3.5,
                    ),
                    itemCount: widget.resultData.correctSolutions.length,
                    itemBuilder: (context, index) {
                      return _buildCorrectAnswerItem(
                          widget.resultData.correctSolutions[index]);
                    },
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultStatusRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 14)),
          Text(value,
              style: TextStyle(
                  fontSize: 14, fontWeight: FontWeight.bold, color: color)),
        ],
      ),
    );
  }

  Widget _buildQuestionBox(int questionNumber, String status) {
    Color color;
    switch (status) {
      case 'c':
        color = Colors.green;
        break;
      case 'w':
        color = Colors.red;
        break;
      case 'l':
      default:
        color = Colors.cyan;
    }
    return Container(
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          'Q-$questionNumber',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
      ),
    );
  }

  Widget _buildCorrectAnswerItem(String solution) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.blue),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          solution,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: Colors.black,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
} 