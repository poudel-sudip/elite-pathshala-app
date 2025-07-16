import 'package:flutter/material.dart';
import '../../../core/models/batch_written_exam_models.dart';
import '../../../core/models/course_classroom.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/batch_written_exam_service.dart';
import 'batch_written_exam_attempt_page.dart';
import 'batch_written_exam_questions_page.dart';

class BatchWrittenExamsPage extends StatefulWidget {
  final ClassroomClass classroomClass;

  const BatchWrittenExamsPage({
    super.key,
    required this.classroomClass,
  });

  @override
  State<BatchWrittenExamsPage> createState() => _BatchWrittenExamsPageState();
}

class _BatchWrittenExamsPageState extends State<BatchWrittenExamsPage> {
  BatchWrittenExamListData? _examListData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadBatchWrittenExams();
  }

  Future<void> _loadBatchWrittenExams() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final writtenExamsUrl = widget.classroomClass.links.writtenExams;
      if (writtenExamsUrl == null || writtenExamsUrl.isEmpty) {
        setState(() {
          _errorMessage = 'No written exams available for this class';
          _isLoading = false;
        });
        return;
      }

      final response = await BatchWrittenExamService.getBatchWrittenExams(writtenExamsUrl);
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
          title: Text(_examListData?.name ?? 'Written Exams'),
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
        onRefresh: _loadBatchWrittenExams,
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
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: _loadBatchWrittenExams,
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
        onRefresh: _loadBatchWrittenExams,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: SizedBox(
            height: MediaQuery.of(context).size.height - 200,
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.assignment_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 16),
                  Text(
                    'No written exams available',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadBatchWrittenExams,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _examListData!.examLists.length,
                itemBuilder: (context, index) {
                  final exam = _examListData!.examLists[index];
                  return _buildExamButtons(exam);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildExamButtons(BatchWrittenExamItem exam) {
    List<Widget> buttons = [];

    // View Questions button
    if (exam.questionShowLink != null) {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BatchWrittenExamQuestionsPage(
                    questionsUrl: exam.questionShowLink!,
                    examName: exam.name,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'View Questions',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    // Show Result button
    if (exam.resultLink != null && exam.status.toLowerCase() == 'published') {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              // TODO: Navigate to result page
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Show Result',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    // Attempt Exam button
    if (exam.status.toLowerCase() == 'unsolved' || exam.status.toLowerCase() == 'pending') {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => BatchWrittenExamAttemptPage(
                    attemptUrl: exam.attemptLink,
                    examName: exam.name,
                  ),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Attempt Exam',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    // Under Evaluation button
    if (exam.status.toLowerCase() == 'under evaluation') {
      buttons.add(
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: null,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.purple,
              disabledBackgroundColor: Colors.purple.shade300,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            child: const Text(
              'Under Evaluation',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: buttons
            .map((button) => Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: button,
                ))
            .toList(),
      ),
    );
  }
} 