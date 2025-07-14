import '../../../core/services/api_service.dart';
import '../../../core/models/batch_mcq_models.dart';

class BatchMcqService {
  // Fetch batch MCQ exam list for a classroom
  static Future<BatchMcqExamListResponse> getBatchMcqExams(String mcqExamsApiUrl) async {
    try {
      // Extract the endpoint from the full URL
      final uri = Uri.parse(mcqExamsApiUrl);
      final endpoint = uri.path.substring(1); // Remove leading slash
      
      final response = await ApiService.get(endpoint);
      return BatchMcqExamListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch batch MCQ exams: ${e.toString()}');
    }
  }

  // Fetch batch MCQ exam attempt data
  static Future<BatchMcqAttemptResponse> getBatchMcqAttempt(String attemptUrl) async {
    try {
      final response = await ApiService.getFromFullUrl(attemptUrl);
      return BatchMcqAttemptResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch batch MCQ exam questions: ${e.toString()}');
    }
  }

  // Submit batch MCQ exam attempt
  static Future<BatchMcqSubmissionResponse> submitBatchMcqExam(
    String submitUrl,
    Map<String, dynamic> payload,
  ) async {
    try {
      final response = await ApiService.postToFullUrl(submitUrl, payload);
      return BatchMcqSubmissionResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit batch MCQ exam: ${e.toString()}');
    }
  }

  // Reset batch MCQ exam
  static Future<BatchMcqResetResponse> resetBatchMcqExam(String resetUrl) async {
    try {
      final response = await ApiService.deleteFromFullUrl(resetUrl);
      return BatchMcqResetResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to reset batch MCQ exam: ${e.toString()}');
    }
  }

  // Fetch batch MCQ exam result
  static Future<BatchMcqResultResponse> getBatchMcqResult(String resultUrl) async {
    try {
      final response = await ApiService.getFromFullUrl(resultUrl);
      return BatchMcqResultResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch batch MCQ exam result: ${e.toString()}');
    }
  }
} 