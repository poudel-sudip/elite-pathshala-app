// Video Units Response Models
class VideoUnitsResponse {
  final bool success;
  final String message;
  final VideoUnitsData data;

  VideoUnitsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory VideoUnitsResponse.fromJson(Map<String, dynamic> json) {
    return VideoUnitsResponse(
      success: json['success'],
      message: json['message'],
      data: VideoUnitsData.fromJson(json['data']),
    );
  }
}

class VideoUnitsData {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final List<VideoUnit> videoUnits;
  final VideoCourse course;

  VideoUnitsData({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.videoUnits,
    required this.course,
  });

  factory VideoUnitsData.fromJson(Map<String, dynamic> json) {
    return VideoUnitsData(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      image: json['image'],
      status: json['status'],
      videoUnits: (json['video_units'] as List)
          .map((x) => VideoUnit.fromJson(x))
          .toList(),
      course: VideoCourse.fromJson(json['course']),
    );
  }
}

class VideoUnit {
  final int id;
  final int batchId;
  final String name;
  final int videoCount;
  final String videoApiLink;

  VideoUnit({
    required this.id,
    required this.batchId,
    required this.name,
    required this.videoCount,
    required this.videoApiLink,
  });

  factory VideoUnit.fromJson(Map<String, dynamic> json) {
    return VideoUnit(
      id: json['id'],
      batchId: json['batch_id'],
      name: json['name'],
      videoCount: json['video_count'],
      videoApiLink: json['video_api_link'],
    );
  }
}

class VideoCourse {
  final int id;
  final String name;

  VideoCourse({
    required this.id,
    required this.name,
  });

  factory VideoCourse.fromJson(Map<String, dynamic> json) {
    return VideoCourse(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Unit Videos Response Models (to be used for the videos list)
class UnitVideosResponse {
  final bool success;
  final String message;
  final UnitVideosData data;

  UnitVideosResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UnitVideosResponse.fromJson(Map<String, dynamic> json) {
    return UnitVideosResponse(
      success: json['success'],
      message: json['message'],
      data: UnitVideosData.fromJson(json['data']),
    );
  }
}

class UnitVideosData {
  final int id;
  final int batchId;
  final String name;
  final VideoBatch batch;
  final List<VideoFile> videoFiles;

  UnitVideosData({
    required this.id,
    required this.batchId,
    required this.name,
    required this.batch,
    required this.videoFiles,
  });

  factory UnitVideosData.fromJson(Map<String, dynamic> json) {
    return UnitVideosData(
      id: json['id'],
      batchId: json['batch_id'],
      name: json['name'],
      batch: VideoBatch.fromJson(json['batch']),
      videoFiles: (json['video_files'] as List)
          .map((x) => VideoFile.fromJson(x))
          .toList(),
    );
  }
}

class VideoBatch {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final VideoCourse course;

  VideoBatch({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.course,
  });

  factory VideoBatch.fromJson(Map<String, dynamic> json) {
    return VideoBatch(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      image: json['image'],
      status: json['status'],
      course: VideoCourse.fromJson(json['course']),
    );
  }
}

class VideoFile {
  final int id;
  final int batchId;
  final int unitId;
  final int userId;
  final String userName;
  final String videoTitle;
  final String videoPath;
  final String? videoKey; // YouTube video ID if it's a YouTube video
  final String createdAt;
  final String updatedAt;

  VideoFile({
    required this.id,
    required this.batchId,
    required this.unitId,
    required this.userId,
    required this.userName,
    required this.videoTitle,
    required this.videoPath,
    this.videoKey,
    required this.createdAt,
    required this.updatedAt,
  });

  factory VideoFile.fromJson(Map<String, dynamic> json) {
    return VideoFile(
      id: json['id'],
      batchId: json['batch_id'],
      unitId: json['unit_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      videoTitle: json['videoTitle'],
      videoPath: json['videoPath'],
      videoKey: json['videoKey'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Helper method to check if this is a YouTube video
  bool get isYouTubeVideo {
    // Check if videoKey is provided
    if (videoKey != null && videoKey!.isNotEmpty) {
      return true;
    }
    
    // Check if videoPath contains YouTube URL
    return videoPath.contains('youtube.com') || videoPath.contains('youtu.be');
  }

  // Helper method to get YouTube video ID
  String? get youTubeVideoId {
    // First check if videoKey is provided
    if (videoKey != null && videoKey!.isNotEmpty) {
      return videoKey;
    }
    
    // Extract from videoPath if it's a YouTube URL
    if (videoPath.contains('youtube.com') || videoPath.contains('youtu.be')) {
      return _extractYouTubeId(videoPath);
    }
    
    return null;
  }

  // Helper method to extract YouTube video ID from URL
  String? _extractYouTubeId(String url) {
    try {
      // Handle youtube.com URLs
      if (url.contains('youtube.com')) {
        final uri = Uri.parse(url);
        return uri.queryParameters['v'];
      }
      
      // Handle youtu.be URLs
      if (url.contains('youtu.be')) {
        final uri = Uri.parse(url);
        return uri.pathSegments.isNotEmpty ? uri.pathSegments.last : null;
      }
    } catch (e) {
      // Silently handle URL parsing errors
    }
    
    return null;
  }

  // Helper method to get YouTube thumbnail
  String? get youTubeThumbnail {
    final videoId = youTubeVideoId;
    if (videoId != null && videoId.isNotEmpty) {
      return 'https://img.youtube.com/vi/$videoId/hqdefault.jpg';
    }
    return null;
  }
} 