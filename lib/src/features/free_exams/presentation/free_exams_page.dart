import 'package:flutter/material.dart';
import 'package:elite_pathshala/src/core/models/free_exam_models.dart';
import 'package:elite_pathshala/src/features/free_exams/services/free_exam_service.dart';
import 'package:elite_pathshala/src/shared/widgets/auth_guard.dart';
import 'package:elite_pathshala/src/features/free_exams/presentation/free_exam_category_page.dart';

class FreeExamsPage extends StatelessWidget {
  const FreeExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Free Exams'),
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    return FutureBuilder<FreeExamCategoryResponse>(
      future: FreeExamService.getFreeExams(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (snapshot.hasError) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Error: ${snapshot.error}'),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _loadExams(),
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        }

        if (snapshot.data == null || snapshot.data!.data.isEmpty) {
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
                  'No Free Exam Categories Available',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  'Check back later for new free exam categories',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () => _loadExams(),
          child: ListView.builder(
            padding: const EdgeInsets.all(0),
            itemCount: snapshot.data!.data.length + 1,
            itemBuilder: (context, index) {
              if (index == 0) {
                return _buildFreeExamsTitle();
              }
              final category = snapshot.data!.data[index - 1];
              return _buildFreeExamCategoryCard(category);
            },
          ),
        );
      },
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
          'Free Exam Categories',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildFreeExamCategoryCard(FreeExamCategoryItem category) {
    return Builder(
      builder: (context) => Card(
        margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(8),
          onTap: () => _navigateToCategoryExams(context, category),
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
                        category.title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.folder,
                            size: 16,
                            color: Colors.grey[600],
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Exam Sets: ${category.examCount}',
                            style: TextStyle(
                              fontSize: 14,
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
      ),
    );
  }

  void _navigateToCategoryExams(BuildContext context, FreeExamCategoryItem category) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FreeExamCategoryPage(
          categoryId: category.id,
          categoryTitle: category.title,
        ),
      ),
    );
  }

  Future<FreeExamCategoryResponse> _loadExams() {
    return FreeExamService.getFreeExams();
  }
} 