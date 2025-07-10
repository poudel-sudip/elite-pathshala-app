import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:elite_pathshala/src/core/models/free_exam_models.dart';
import 'package:elite_pathshala/src/features/free_exams/services/free_exam_service.dart';
import 'package:elite_pathshala/src/shared/widgets/auth_guard.dart';
import 'package:elite_pathshala/src/core/services/api_service.dart';
import 'package:elite_pathshala/src/features/free_exams/presentation/exam_result_page.dart';
import 'package:elite_pathshala/src/features/free_exams/presentation/free_exams_page.dart';

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
  Map<int, String> _selectedAnswers = {}; // Track selected answers by question index
  
  // Timer related variables
  Timer? _examTimer;
  Duration _remainingTime = Duration.zero;
  bool _timeUp = false;

  @override
  void initState() {
    super.initState();
    _loadExam();
  }

  @override
  void dispose() {
    _examTimer?.cancel();
    super.dispose();
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
      _startTimer();
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  void _startTimer() {
    if (_examData == null) return;
    
    // Parse exam time (format: "00:25" for 25 minutes)
    final examTimeStr = _examData!.exam.examTime;
    final timeParts = examTimeStr.split(':');
    final hours = int.tryParse(timeParts[0]) ?? 0;
    final minutes = int.tryParse(timeParts[1]) ?? 0;
    
    _remainingTime = Duration(hours: hours, minutes: minutes);
    
    _examTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_remainingTime.inSeconds > 0) {
          _remainingTime = _remainingTime - const Duration(seconds: 1);
        } else {
          _timeUp = true;
          timer.cancel();
          _submitExam();
        }
      });
    });
  }

  String _formatTime(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$hours:$minutes:$seconds';
  }

  void _selectAnswer(String optionKey) {
    if (_timeUp) return;
    
    setState(() {
      _selectedAnswers[_currentQuestionIndex] = optionKey;
    });

    // Wait 1 second then move to next question
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        if (_currentQuestionIndex < _examData!.exam.questionCount - 1) {
          _nextQuestion();
        } else {
          // Last question - auto submit after delay
          _submitExam();
        }
      }
    });
  }

  void _navigateToQuestion(int index) {
    if (index >= 0 && index < _examData!.exam.questionCount) {
      setState(() {
        _currentQuestionIndex = index;
      });
    }
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _examData!.exam.questionCount - 1) {
      _navigateToQuestion(_currentQuestionIndex + 1);
    }
  }

  void _previousQuestion() {
    if (_currentQuestionIndex > 0) {
      _navigateToQuestion(_currentQuestionIndex - 1);
    }
  }

  Future<void> _submitExam() async {
    _examTimer?.cancel();
    
    try {
      // Calculate results
      int correctAnswers = 0;
      int wrongAnswers = 0;
      int leavedQuestions = 0;
      int totalQuestions = _examData!.exam.questionCount;
      List<String> remarksList = [];
      
      double marksPerQuestion = double.tryParse(_examData!.exam.marksPerQuestion) ?? 0;
      double negativeMarks = double.tryParse(_examData!.exam.negativeMarks) ?? 0;
      int totalMarks = 0;

      for (int i = 0; i < totalQuestions; i++) {
        final correctAnswer = _examData!.exam.questionList[i].optCorrect;
        final selectedAnswer = _selectedAnswers[i];
        final questionIndex = i + 1; // 1-indexed for API
        
        if (selectedAnswer == null) {
          // Question left unanswered
          leavedQuestions++;
          remarksList.add('q-$questionIndex:l');
        } else if (selectedAnswer == correctAnswer) {
          // Correct answer
          correctAnswers++;
          totalMarks += marksPerQuestion.toInt();
          remarksList.add('q-$questionIndex:c');
        } else {
          // Wrong answer
          wrongAnswers++;
          totalMarks -= negativeMarks.toInt();
          remarksList.add('q-$questionIndex:w');
        }
      }

      // Create remarks as encoded JSON string
      final remarksJson = jsonEncode(remarksList);

      // Prepare API payload
      final payload = {
        'leaved_questions': leavedQuestions,
        'correct_questions': correctAnswers,
        'wrong_questions': wrongAnswers,
        'remarks': remarksJson,
      };


      // Submit to API
      final response = await ApiService.postToFullUrl(_examData!.attemptSubmitLink, payload);
      
      // Parse the response and navigate to result page
      if (mounted) {
        try {
          final resultResponse = ExamResultSubmissionResponse.fromJson(response);
          if (resultResponse.success) {
            // Navigate to exam result page
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => ExamResultPage(
                  resultData: resultResponse.data,
                  examName: _examData!.exam.name,
                ),
              ),
            );
          } else {
            // Show error dialog if submission failed
            _showResultDialog(correctAnswers, totalQuestions, totalMarks, 
                hasSubmissionError: true, errorMessage: resultResponse.message);
          }
        } catch (e) {
          // Show results dialog with submission error
          _showResultDialog(correctAnswers, totalQuestions, totalMarks, 
              hasSubmissionError: true, errorMessage: 'Failed to parse server response: $e');
        }
      }
    } catch (e) {
      
      // Still show results dialog even if API fails
      if (mounted) {
        // Calculate basic results for display
        int correctAnswers = 0;
        int totalQuestions = _examData!.exam.questionCount;
        double marksPerQuestion = double.tryParse(_examData!.exam.marksPerQuestion) ?? 0;
        double negativeMarks = double.tryParse(_examData!.exam.negativeMarks) ?? 0;
        int totalMarks = 0;

        for (int i = 0; i < totalQuestions; i++) {
          final correctAnswer = _examData!.exam.questionList[i].optCorrect;
          final selectedAnswer = _selectedAnswers[i];
          
          if (selectedAnswer == correctAnswer) {
            correctAnswers++;
            totalMarks += marksPerQuestion.toInt();
          } else if (selectedAnswer != null) {
            totalMarks -= negativeMarks.toInt();
          }
        }

        _showResultDialog(correctAnswers, totalQuestions, totalMarks, hasSubmissionError: true);
      }
    }
  }

  void _showResultDialog(int correctAnswers, int totalQuestions, int totalMarks, 
      {bool hasSubmissionError = false, String? errorMessage}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Exam Completed'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Correct Answers: $correctAnswers/$totalQuestions'),
            Text('Accuracy: ${((correctAnswers / totalQuestions) * 100).toStringAsFixed(1)}%'),
            Text('Total Marks: $totalMarks'),
            if (_timeUp) const Text('Time Up!', style: TextStyle(color: Colors.red)),
            if (hasSubmissionError) 
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  errorMessage ?? 'Note: Results could not be submitted to server',
                  style: const TextStyle(color: Colors.orange, fontSize: 12),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to exam list
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_examData?.exam.name ?? 'Free Exam'),
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          actions: [
            if (!_isLoading && _examData != null && !_timeUp)
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _remainingTime.inMinutes < 5 ? Colors.red : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      _formatTime(_remainingTime),
                      style: TextStyle(
                        color: _remainingTime.inMinutes < 5 ? Colors.white : Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        body: _buildBody(),
        bottomNavigationBar: _buildNavigationBar(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExam,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
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
          // Question info
          Row(
            children: [
              Expanded(
                child: Text(
                  'Question ${_currentQuestionIndex + 1}/${_examData!.exam.questionCount}',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: _selectedAnswers.containsKey(_currentQuestionIndex) 
                      ? Colors.green.withValues(alpha: 0.2) 
                      : Colors.orange.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  _selectedAnswers.containsKey(_currentQuestionIndex) ? 'Answered' : 'Not Answered',
                  style: const TextStyle(fontSize: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Question text
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    question.question,
                    style: const TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 24),
                  
                  // Options
                  ...options.entries.map((entry) {
                    return _buildOption(entry.key, entry.value);
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOption(String optionKey, String optionValue) {
    final isSelected = _selectedAnswers[_currentQuestionIndex] == optionKey;
    
    return GestureDetector(
      onTap: () => _selectAnswer(optionKey),
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue.withValues(alpha: 0.1) : null,
          border: Border.all(
            color: isSelected ? Colors.blue : Colors.grey.shade300,
            width: isSelected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: isSelected ? Colors.blue : Colors.grey,
                  width: 2,
                ),
                color: isSelected ? Colors.blue : Colors.transparent,
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 12),
            Text(
              '$optionKey. ',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.blue : null,
              ),
            ),
            Expanded(
              child: Text(
                optionValue,
                style: TextStyle(
                  color: isSelected ? Colors.blue : null,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNavigationBar() {
    if (_isLoading || _examData == null) return const SizedBox.shrink();
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
                 boxShadow: [
           BoxShadow(
             color: Colors.grey.withValues(alpha: 0.3),
             spreadRadius: 1,
             blurRadius: 5,
             offset: const Offset(0, -3),
           ),
         ],
      ),
      child: Row(
        children: [
          // Previous button
          Expanded(
            child: ElevatedButton(
              onPressed: _currentQuestionIndex > 0 ? _previousQuestion : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey.shade200,
                foregroundColor: Colors.black,
              ),
              child: const Text('Previous'),
            ),
          ),
          const SizedBox(width: 16),
          
          // Submit/Next button
          Expanded(
            child: ElevatedButton(
              onPressed: _currentQuestionIndex == _examData!.exam.questionCount - 1
                  ? _submitExam
                  : _nextQuestion,
              style: ElevatedButton.styleFrom(
                backgroundColor: _currentQuestionIndex == _examData!.exam.questionCount - 1
                    ? Colors.green
                    : Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: Text(
                _currentQuestionIndex == _examData!.exam.questionCount - 1
                    ? 'Submit Exam'
                    : 'Next',
              ),
            ),
          ),
        ],
      ),
    );
  }
} 