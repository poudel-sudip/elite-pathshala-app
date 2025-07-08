import '../../../core/services/api_service.dart';
import '../../../core/models/orientation_models.dart';

class OrientationService {
  // Fetch orientations list
  static Future<OrientationListResponse> getOrientations() async {
    try {
      final response = await ApiService.get('api/student/course/orientations');
      return OrientationListResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch orientations: ${e.toString()}');
    }
  }

  // Join orientation class
  static Future<OrientationJoinResponse> joinOrientation(String joinUrl) async {
    try {
      // Extract the endpoint from the full URL
      final uri = Uri.parse(joinUrl);
      final endpoint = uri.path.substring(1); // Remove leading slash
      
      final response = await ApiService.get(endpoint);
      return OrientationJoinResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to join orientation: ${e.toString()}');
    }
  }
} 