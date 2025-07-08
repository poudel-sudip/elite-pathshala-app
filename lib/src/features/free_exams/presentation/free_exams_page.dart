import 'package:flutter/material.dart';
import 'package:elite_pathshala/src/core/models/free_exam_models.dart';
import 'package:elite_pathshala/src/features/free_exams/services/free_exam_service.dart';
import 'package:elite_pathshala/src/shared/widgets/auth_guard.dart';

class FreeExamsPage extends StatefulWidget {
  const FreeExamsPage({super.key});

  @override
  State<FreeExamsPage> createState() => _FreeExamsPageState();
}

class _FreeExamsPageState extends State<FreeExamsPage> {
  List<FreeExamCategoryItem> _exams = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadExams();
  }

  Future<void> _loadExams() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await FreeExamService.getFreeExams();

      if (response.success) {
        setState(() {
          _exams = response.data;
          _isLoading = false;
        });
      } else {
        throw Exception(response.message);
      }
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
        body: _buildBody(),
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
              onPressed: _loadExams,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_exams.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No Free Exams Available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new free exams',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    

    return RefreshIndicator(
      onRefresh: _loadExams,
      child: ListView.builder(
        padding: const EdgeInsets.all(0),
        itemCount: _exams.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildFreeExamsTitle();
          }
          final exam = _exams[index - 1];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(exam.title),
              subtitle: Text('Exam Sets: ${exam.examCount}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to exam list page
              },
            ),
          );
        },
      ),
    );
    
  }

  Widget _buildFreeExamsTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.blue,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'Free Exams',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

} 