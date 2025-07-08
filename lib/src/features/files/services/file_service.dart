import '../../../core/services/api_service.dart';
import '../../../core/models/file_models.dart';

class FileService {
  // Fetch file units for a batch (top-level units)
  static Future<FileUnitsResponse> getFileUnits(String filesApiUrl) async {
    try {
      // Extract the endpoint from the full URL
      final uri = Uri.parse(filesApiUrl);
      final endpoint = uri.path.substring(1); // Remove leading slash
      
      final response = await ApiService.get(endpoint);
      return FileUnitsResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch file units: ${e.toString()}');
    }
  }

  // Fetch files and sub-units for a specific unit
  static Future<UnitFilesResponse> getUnitFiles(String unitApiUrl) async {
    try {
      // Extract the endpoint from the full URL
      final uri = Uri.parse(unitApiUrl);
      final endpoint = uri.path.substring(1); // Remove leading slash
      
      final response = await ApiService.get(endpoint);
      return UnitFilesResponse.fromJson(response);
    } catch (e) {
      throw Exception('Failed to fetch unit files: ${e.toString()}');
    }
  }
} 