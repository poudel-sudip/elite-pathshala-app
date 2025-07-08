import 'dart:async';
import 'package:flutter/material.dart';
import 'package:elite_pathshala/src/core/models/free_exam_models.dart';
import 'package:elite_pathshala/src/features/free_exams/services/free_exam_service.dart';
import 'package:elite_pathshala/src/shared/widgets/auth_guard.dart';

class FreeExamAttemptPage extends StatefulWidget {
  final String attemptUrl;

  const FreeExamAttemptPage({super.key, required this.attemptUrl});

  @override
  State<FreeExamAttemptPage> createState() => _FreeExamAttemptPageState();
}

class _FreeExamAttemptPageState extends State<FreeExamAttemptPage> {
  bool _isLoading = true;
  String? _errorMessage;
  FreeExamAttemptData? _examData;
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  bool _showAnswer = false;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  Future<void> _loadExam() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final response = await FreeExamService.getExamAttempt(widget.attemptUrl);
      setState(() {
        _examData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_examData?.exam.name ?? 'Free Exam'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(child: Text(_errorMessage!));
    }
    if (_examData == null) {
      return const Center(child: Text('No exam data found.'));
    }
    return _buildQuestionView();
  }

  Widget _buildQuestionView() {
    final question = _examData!.exam.questionList[_currentQuestionIndex];
    final options = {
      'A': question.optA,
      'B': question.optB,
      'C': question.optC,
      'D': question.optD,
    };

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Question ${_currentQuestionIndex + 1}/${_examData!.exam.questionCount}',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          Text(
            question.question,
            style: const TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          ...options.entries.map((entry) {
            return _buildOption(entry.key, entry.value);
          }),
        ],
      ),
    );
  }

  Widget _buildOption(String optionKey, String optionValue) {
    Color? backgroundColor;
    if (_showAnswer) {
      if (optionKey == _examData!.exam.questionList[_currentQuestionIndex].optCorrect) {
        backgroundColor = Colors.green.withOpacity(0.3);
      } else if (_selectedOption == optionKey) {
        backgroundColor = Colors.red.withOpacity(0.3);
      }
    }

    return GestureDetector(
      onTap: () => _handleOptionSelected(optionKey),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(optionValue),
      ),
    );
  }

  void _handleOptionSelected(String optionKey) {
    if (_showAnswer) return;

    setState(() {
      _selectedOption = optionKey;
      _showAnswer = true;
    });

    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        if (_currentQuestionIndex < _examData!.exam.questionCount - 1) {
          _currentQuestionIndex++;
          _selectedOption = null;
          _showAnswer = false;
        } else {
          // TODO: Navigate to result page
        }
      });
    });
  }
} 