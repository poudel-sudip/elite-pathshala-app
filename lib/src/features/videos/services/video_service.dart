import '../../../core/services/api_service.dart';
import '../../../core/models/video_models.dart';

class VideoService {
  // Fetch video units for a batch
  static Future<VideoUnitsResponse> getVideoUnits(String videosApiUrl) async {
    try {
      // Extract the endpoint from the full URL
      final uri = Uri.parse(videosApiUrl);
      final endpoint = uri.path.substring(1); // Remove leading slash
      
      final response = await ApiService.get(endpoint);
      return VideoUnitsResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch video units: ${e.toString()}');
    }
  }

  // Fetch videos for a specific unit
  static Future<UnitVideosResponse> getUnitVideos(String unitApiUrl) async {
    try {
      // Extract the endpoint from the full URL
      final uri = Uri.parse(unitApiUrl);
      final endpoint = uri.path.substring(1); // Remove leading slash
      
      final response = await ApiService.get(endpoint);
      return UnitVideosResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch unit videos: ${e.toString()}');
    }
  }
} 