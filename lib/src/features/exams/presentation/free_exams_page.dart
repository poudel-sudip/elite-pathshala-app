import 'package:flutter/material.dart';

class FreeExamsPage extends StatelessWidget {
  const FreeExamsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Free Exams'),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
        elevation: 1,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAvailableExamsSection(),
              const SizedBox(height: 24),
              _buildExamHistorySection(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvailableExamsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Available Exams',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildExamCard(
          title: 'Mathematics Mock Test',
          duration: '2 hours',
          questions: '50 questions',
          difficulty: 'Medium',
          status: 'Available',
          statusColor: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildExamCard(
          title: 'English Grammar Test',
          duration: '1.5 hours',
          questions: '40 questions',
          difficulty: 'Easy',
          status: 'Available',
          statusColor: Colors.green,
        ),
        const SizedBox(height: 8),
        _buildExamCard(
          title: 'Science Practice Test',
          duration: '3 hours',
          questions: '75 questions',
          difficulty: 'Hard',
          status: 'Coming Soon',
          statusColor: Colors.orange,
        ),
      ],
    );
  }

  Widget _buildExamHistorySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Exam History',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        _buildExamCard(
          title: 'General Knowledge Test',
          duration: '1 hour',
          questions: '30 questions',
          difficulty: 'Easy',
          status: 'Completed - 85%',
          statusColor: Colors.blue,
          showResult: true,
        ),
        const SizedBox(height: 8),
        _buildExamCard(
          title: 'History Mock Test',
          duration: '2 hours',
          questions: '50 questions',
          difficulty: 'Medium',
          status: 'Completed - 72%',
          statusColor: Colors.blue,
          showResult: true,
        ),
      ],
    );
  }

  Widget _buildExamCard({
    required String title,
    required String duration,
    required String questions,
    required String difficulty,
    required String status,
    required Color statusColor,
    bool showResult = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey[300]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  status,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              _buildInfoChip(Icons.access_time, duration),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.quiz, questions),
              const SizedBox(width: 8),
              _buildInfoChip(Icons.trending_up, difficulty),
            ],
          ),
          if (!showResult && status == 'Available') ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () {},
                child: const Text('Start Exam'),
              ),
            ),
          ],
          if (showResult) ...[
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.blue,
                      side: const BorderSide(color: Colors.blue),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('View Results'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onPressed: () {},
                    child: const Text('Retake'),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: Colors.grey[600]),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              fontSize: 12,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
} 