import 'package:flutter/material.dart';
import 'package:elite_pathshala/src/core/models/free_exam_models.dart';
import 'package:elite_pathshala/src/features/free_exams/services/free_exam_service.dart';
import 'package:elite_pathshala/src/shared/widgets/auth_guard.dart';
import 'package:elite_pathshala/src/core/utils/nepal_timezone.dart';

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
          backgroundColor: Colors.blue,
          foregroundColor: Colors.white,
          elevation: 0,
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
          return _buildExamListItem(exam);
        },
      ),
    );
  }

  Widget _buildExamListItem(FreeExamListItem exam) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () {
          // TODO: Navigate to exam attempt page
        },
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.blue,
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
                    Row(
                      children: [
                        Icon(
                          Icons.calendar_today,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          _formatDate(exam.createdAt),
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(width: 12),
                        Icon(
                          Icons.help_outline,
                          size: 14,
                          color: Colors.grey[600],
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${exam.questionCount} Questions',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(String date) {
    return NepalTimezone.formatNotificationDate(date);
  }
} 