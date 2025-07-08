import '../../../core/services/api_service.dart';
import '../../../core/models/free_exam_models.dart';

class FreeExamService {
  // Fetch free exam categories
  static Future<FreeExamCategory> getFreeExams() async {
    try {
      final response = await ApiService.get('api/student/free-exams');
      return FreeExamCategory.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch free exams: ${e.toString()}');
    }
  }
} 