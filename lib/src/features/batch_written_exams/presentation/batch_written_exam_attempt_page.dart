import 'package:flutter/material.dart';
import 'dart:async';
import '../../../core/models/batch_written_exam_models.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/batch_written_exam_service.dart';
import 'batch_written_exam_solution_page.dart';

class BatchWrittenExamAttemptPage extends StatefulWidget {
  final String attemptUrl;
  final String examName;

  const BatchWrittenExamAttemptPage({
    super.key,
    required this.attemptUrl,
    required this.examName,
  });

  @override
  State<BatchWrittenExamAttemptPage> createState() => _BatchWrittenExamAttemptPageState();
}

class _BatchWrittenExamAttemptPageState extends State<BatchWrittenExamAttemptPage> {
  BatchWrittenExamAttemptData? _attemptData;
  bool _isLoading = true;
  String? _errorMessage;
  Timer? _timer;
  Duration _remainingTime = Duration.zero;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _loadExamAttempt();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _loadExamAttempt() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await BatchWrittenExamService.getBatchWrittenExamAttempt(widget.attemptUrl);
      setState(() {
        _attemptData = response.data;
        _isLoading = false;
      });

      // Start timer if exam is active
      if (_attemptData != null) {
        _parseAndStartTimer(_attemptData!.remainingTime);
      }
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  void _parseAndStartTimer(String remainingTime) {
    try {
      final parts = remainingTime.split(':');
      if (parts.length == 3) {
        final hours = int.parse(parts[0]);
        final minutes = int.parse(parts[1]);
        final seconds = int.parse(parts[2]);
        
        _remainingTime = Duration(hours: hours, minutes: minutes, seconds: seconds);
        
        _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
          if (_remainingTime.inSeconds > 0) {
            setState(() {
              _remainingTime = _remainingTime - const Duration(seconds: 1);
            });
          } else {
            timer.cancel();
            _autoSubmitExam();
          }
        });
      }
    } catch (e) {
      print('Error parsing remaining time: $e');
    }
  }

  Future<void> _autoSubmitExam() async {
    if (_attemptData != null && !_isSubmitting) {
      await _submitExam();
    }
  }

  Future<void> _submitExam() async {
    if (_attemptData == null || _isSubmitting) return;

    try {
      setState(() {
        _isSubmitting = true;
      });

      final response = await BatchWrittenExamService.submitBatchWrittenExam(
        _attemptData!.attemptSubmitLink,
      );

      if (response.success) {
        _timer?.cancel();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.of(context).pop();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(response.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() {
        _isSubmitting = false;
      });
    }
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String hours = twoDigits(duration.inHours);
    String minutes = twoDigits(duration.inMinutes.remainder(60));
    String seconds = twoDigits(duration.inSeconds.remainder(60));
    return "$hours:$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.examName),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          actions: [
            if (_attemptData != null && _remainingTime.inSeconds > 0)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Chip(
                  label: Text(
                    _formatTime(_remainingTime),
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  backgroundColor: _remainingTime.inMinutes < 5 ? Colors.red : Colors.blue,
                ),
              ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildSubmitButton(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExamAttempt,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_attemptData == null) {
      return const Center(
        child: Text('No exam data available'),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildExamInfo(),
            const SizedBox(height: 24),
            _buildQuestionGroups(),
          ],
        ),
      ),
    );
  }

  Widget _buildExamInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _attemptData!.exam.name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _attemptData!.batch.name,
              style: const TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Started At: ${_attemptData!.startedAt}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Text(
                      'Time: ${_attemptData!.exam.examTime}',
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Full Marks: ${_attemptData!.exam.fullMarks}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                    Text(
                      'Pass Marks: ${_attemptData!.exam.passMarks}',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionGroups() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: _attemptData!.exam.questionGroups.map((group) => _buildQuestionGroup(group)).toList(),
    );
  }

  Widget _buildQuestionGroup(BatchWrittenQuestionGroup group) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  group.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.red,
                  ),
                ),
                Text(
                  '(${group.marks} Marks)',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            if (group.description != null && group.description!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                group.description!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.grey,
                ),
              ),
            ],
            const SizedBox(height: 16),
            ...group.questionList.asMap().entries.map((entry) {
              final index = entry.key;
              final question = entry.value;
              return _buildQuestionItem(question, index + 1);
            }).toList(),
          ],
        ),
      ),
    );
  }

  Widget _buildQuestionItem(BatchWrittenQuestion question, int questionNumber) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  questionNumber.toString(),
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      question.question,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '(${question.marks})',
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BatchWrittenExamSolutionPage(
                        solutionUrl: question.solutionDetail,
                        question: question,
                        onSolutionUpdated: _loadExamAttempt,
                      ),
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: question.solved ? Colors.orange : Colors.green,
                  foregroundColor: Colors.white,
                ),
                child: Text(question.solved ? 'Edit Answer' : 'Upload Answer'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSubmitButton() {
    if (_attemptData == null) return const SizedBox.shrink();

    final status = _attemptData!.status.toLowerCase();
    final isSubmittable = status == 'pending' || status == 'unsolved';

    if (!isSubmittable) {
      return Container(
        padding: const EdgeInsets.all(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: _getStatusColor(status),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            _getStatusMessage(status),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _getStatusTextColor(status),
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitExam,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50),
        ),
        child: _isSubmitting
            ? const CircularProgressIndicator(color: Colors.white)
            : const Text(
                'Submit The Answers For Exam Evaluation',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'under evaluation':
        return Colors.purple.shade100;
      case 'published':
        return Colors.green.shade100;
      default:
        return Colors.grey.shade100;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status.toLowerCase()) {
      case 'under evaluation':
        return Colors.purple;
      case 'published':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  String _getStatusMessage(String status) {
    switch (status.toLowerCase()) {
      case 'under evaluation':
        return 'Exam is Under Evaluation';
      case 'published':
        return 'Exam Results Published';
      default:
        return 'Exam Not Available';
    }
  }
} 