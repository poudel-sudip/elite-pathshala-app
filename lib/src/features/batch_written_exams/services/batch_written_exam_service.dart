import 'dart:io';
import '../../../core/services/api_service.dart';
import '../../../core/models/batch_written_exam_models.dart';

class BatchWrittenExamService {
  // Fetch batch written exam list for a classroom
  static Future<BatchWrittenExamListResponse> getBatchWrittenExams(String writtenExamsApiUrl) async {
    try {
      // Extract the endpoint from the full URL
      final uri = Uri.parse(writtenExamsApiUrl);
      final endpoint = uri.path.substring(1); // Remove leading slash
      
      final response = await ApiService.get(endpoint);
      return BatchWrittenExamListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch batch written exams: ${e.toString()}');
    }
  }

  // Fetch batch written exam attempt data
  static Future<BatchWrittenExamAttemptResponse> getBatchWrittenExamAttempt(String attemptUrl) async {
    try {
      final response = await ApiService.getFromFullUrl(attemptUrl);
      return BatchWrittenExamAttemptResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch batch written exam questions: ${e.toString()}');
    }
  }

  // Fetch batch written exam solution data
  static Future<BatchWrittenExamSolutionResponse> getBatchWrittenExamSolution(String solutionUrl) async {
    try {
      final response = await ApiService.getFromFullUrl(solutionUrl);
      return BatchWrittenExamSolutionResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch batch written exam solution: ${e.toString()}');
    }
  }

  // Submit batch written exam attempt
  static Future<BatchWrittenExamSubmitResponse> submitBatchWrittenExam(String submitUrl) async {
    try {
      final response = await ApiService.postToFullUrl(submitUrl, {});
      return BatchWrittenExamSubmitResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to submit batch written exam: ${e.toString()}');
    }
  }

  // Add image to written exam solution
  static Future<BatchWrittenExamAddImageResponse> addImageToSolution(
    String addImageUrl, 
    List<File> images,
  ) async {
    try {
      final response = await ApiService.postMultipartToFullUrl(
        addImageUrl,
        {},
        files: {'answer_image': images},
      );
      return BatchWrittenExamAddImageResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to add image to solution: ${e.toString()}');
    }
  }

  // Delete image from written exam solution
  static Future<BatchWrittenExamDeleteImageResponse> deleteImageFromSolution(String deleteUrl) async {
    try {
      final response = await ApiService.deleteFromFullUrl(deleteUrl);
      return BatchWrittenExamDeleteImageResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to delete image from solution: ${e.toString()}');
    }
  }
} 