import 'package:flutter/material.dart';
import '../../../core/models/batch_mcq_models.dart';
import '../../../core/models/course_classroom.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/batch_mcq_service.dart';
import 'batch_mcq_attempt_page.dart';
import 'package:url_launcher/url_launcher.dart';

class BatchMcqExamsPage extends StatefulWidget {
  final ClassroomClass classroomClass;

  const BatchMcqExamsPage({
    super.key,
    required this.classroomClass,
  });

  @override
  State<BatchMcqExamsPage> createState() => _BatchMcqExamsPageState();
}

class _BatchMcqExamsPageState extends State<BatchMcqExamsPage> {
  BatchMcqExamListData? _examListData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBatchMcqExams();
  }

  Future<void> _loadBatchMcqExams() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final mcqExamsUrl = widget.classroomClass.links.mcqExams;
      if (mcqExamsUrl == null || mcqExamsUrl.isEmpty) {
        setState(() {
          _errorMessage = 'No MCQ exams available for this class';
          _isLoading = false;
        });
        return;
      }

      final response = await BatchMcqService.getBatchMcqExams(mcqExamsUrl);
      setState(() {
        _examListData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_examListData?.name ?? 'MCQ Exams'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
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
      return RefreshIndicator(
        onRefresh: _loadBatchMcqExams,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: Center(
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
                    style: const TextStyle(fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBatchMcqExams,
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    if (_examListData == null || _examListData!.examLists.isEmpty) {
      return RefreshIndicator(
        onRefresh: _loadBatchMcqExams,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.quiz_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No MCQ exams available',
                    style: TextStyle(fontSize: 16, color: Colors.grey),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBatchMcqExams,
      child: Column(
        children: [
          // Batch Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _examListData!.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _examListData!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _examListData!.course.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _examListData!.status == 'Running' 
                                  ? Colors.green 
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _examListData!.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // MCQ Exams List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _examListData!.examLists.length,
              itemBuilder: (context, index) {
                final exam = _examListData!.examLists[index];
                return _buildMcqExamCard(exam);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMcqExamCard(BatchMcqExamItem exam) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.red.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.quiz,
                    color: Colors.red,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        exam.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${exam.questionCount} question${exam.questionCount != 1 ? 's' : ''}',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // Action Buttons
            Row(
              children: [
                if (exam.hasAttemptLink) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _navigateToExamAttempt(exam),
                      icon: const Icon(Icons.play_arrow, size: 18),
                      label: const Text('Attempt'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (exam.hasResultLink) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openResultLink(exam.resultLink!),
                      icon: const Icon(Icons.assessment, size: 18),
                      label: const Text('Result'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                ],
                if (exam.hasResetLink) ...[
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => _openResetLink(exam.resetLink!),
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Reset'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 8),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToExamAttempt(BatchMcqExamItem exam) async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BatchMcqAttemptPage(
          attemptUrl: exam.attemptLink,
        ),
      ),
    );
    
    // Refresh the exam list when returning from attempt page
    if (mounted) {
      _loadBatchMcqExams();
    }
  }

  Future<void> _openResultLink(String resultLink) async {
    // For now, open in browser. Later we can implement a result page
    final uri = Uri.parse(resultLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open result link'),
          ),
        );
      }
    }
  }

  Future<void> _openResetLink(String resetLink) async {
    // For now, open in browser. Later we can implement proper reset functionality
    final uri = Uri.parse(resetLink);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open reset link'),
          ),
        );
      }
    }
  }
} 