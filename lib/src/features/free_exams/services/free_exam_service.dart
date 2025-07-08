import '../../../core/services/api_service.dart';
import '../../../core/models/free_exam_models.dart';

class FreeExamService {
  // Fetch free exam categories
  static Future<FreeExamCategoryResponse> getFreeExams() async {
    try {
      final response = await ApiService.get('api/student/free-exams');
      return FreeExamCategoryResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch free exams: ${e.toString()}');
    }
  }

  // Fetch exam list for a category
  static Future<FreeExamCategoryExamListResponse> getCategoryExamList(int categoryId) async {
    try {
      final response = await ApiService.get('api/student/free-exams/$categoryId');
      return FreeExamCategoryExamListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch category exam list: ${e.toString()}');
    }
  }

  static Future<FreeExamAttemptResponse> getExamAttempt(String attemptUrl) async {
    try {
      final response = await ApiService.get(attemptUrl);
      return FreeExamAttemptResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch exam questions: ${e.toString()}');
    }
  }
} 