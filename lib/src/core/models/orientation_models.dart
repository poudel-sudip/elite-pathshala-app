// Orientation List Response Models
class OrientationListResponse {
  final bool success;
  final String message;
  final List<OrientationItem> data;

  OrientationListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrientationListResponse.fromJson(Map<String, dynamic> json) {
    return OrientationListResponse(
      success: json['success'],
      message: json['message'],
      data: (json['data'] as List)
          .map((x) => OrientationItem.fromJson(x))
          .toList(),
    );
  }
}

class OrientationItem {
  final int id;
  final String tutor;
  final String className;
  final String topic;
  final int duration;
  final String durationType;
  final String repeat;
  final String image;
  final String joinLink;
  final String startAt;
  final String endAt;

  OrientationItem({
    required this.id,
    required this.tutor,
    required this.className,
    required this.topic,
    required this.duration,
    required this.durationType,
    required this.repeat,
    required this.image,
    required this.joinLink,
    required this.startAt,
    required this.endAt,
  });

  factory OrientationItem.fromJson(Map<String, dynamic> json) {
    return OrientationItem(
      id: json['id'],
      tutor: json['tutor'],
      className: json['class'],
      topic: json['topic'],
      duration: json['duration'],
      durationType: json['duration_type'],
      repeat: json['repeat'],
      image: json['image'],
      joinLink: json['join_link'],
      startAt: json['start_at'],
      endAt: json['end_at'],
    );
  }
}

// Orientation Join Response Models
class OrientationJoinResponse {
  final bool success;
  final String message;
  final OrientationJoinData data;

  OrientationJoinResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory OrientationJoinResponse.fromJson(Map<String, dynamic> json) {
    return OrientationJoinResponse(
      success: json['success'],
      message: json['message'],
      data: OrientationJoinData.fromJson(json['data']),
    );
  }
}

class OrientationJoinData {
  final String classLink;

  OrientationJoinData({
    required this.classLink,
  });

  factory OrientationJoinData.fromJson(Map<String, dynamic> json) {
    return OrientationJoinData(
      classLink: json['class_link'],
    );
  }
} 