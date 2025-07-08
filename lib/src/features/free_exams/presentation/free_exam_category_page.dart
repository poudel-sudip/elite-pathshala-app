import 'package:flutter/material.dart';
import 'package:elite_pathshala/src/core/models/free_exam_models.dart';
import 'package:elite_pathshala/src/features/free_exams/services/free_exam_service.dart';
import 'package:elite_pathshala/src/shared/widgets/auth_guard.dart';

class FreeExamCategoryPage extends StatefulWidget {
  final int categoryId;
  final String categoryTitle;
  const FreeExamCategoryPage({super.key, required this.categoryId, required this.categoryTitle});

  @override
  State<FreeExamCategoryPage> createState() => _FreeExamCategoryPageState();
}

class _FreeExamCategoryPageState extends State<FreeExamCategoryPage> {
  bool _isLoading = true;
  String? _errorMessage;
  List<FreeExamListItem> _examList = [];

  @override
  void initState() {
    super.initState();
    _loadExamList();
  }

  Future<void> _loadExamList() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final response = await FreeExamService.getCategoryExamList(widget.categoryId);
      setState(() {
        _examList = response.data.examLists;
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
          title: Text(widget.categoryTitle),
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(_errorMessage!),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadExamList,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }
    if (_examList.isEmpty) {
      return const Center(child: Text('No exams found in this category.'));
    }
    return RefreshIndicator(
      onRefresh: _loadExamList,
      child: ListView.builder(
        itemCount: _examList.length,
        itemBuilder: (context, index) {
          final exam = _examList[index];
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: ListTile(
              title: Text(exam.name),
              subtitle: Text('Questions: ${exam.questionCount} | Status: ${exam.status}'),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                // TODO: Navigate to exam attempt page
              },
            ),
          );
        },
      ),
    );
  }
} 