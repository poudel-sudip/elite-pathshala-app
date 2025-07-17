// Booking List Response Models
class BookingListResponse {
  final bool success;
  final String message;
  final List<BookingItem> data;

  BookingListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BookingListResponse.fromJson(Map<String, dynamic> json) {
    return BookingListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: (json['data'] as List? ?? [])
          .map((x) => BookingItem.fromJson(x ?? {}))
          .toList(),
    );
  }
}

class BookingItem {
  final int id;
  final int batchId;
  final String? status;
  final int suspended;
  final String? suspendText;
  final String? createdAt;
  final String? detailLink;
  final BookingSalesTeam? salesTeam;
  final BookingBatch batch;

  BookingItem({
    required this.id,
    required this.batchId,
    this.status,
    required this.suspended,
    this.suspendText,
    this.createdAt,
    this.detailLink,
    this.salesTeam,
    required this.batch,
  });

  factory BookingItem.fromJson(Map<String, dynamic> json) {
    return BookingItem(
      id: json['id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      status: json['status'],
      suspended: json['suspended'] ?? 0,
      suspendText: json['suspend_text'],
      createdAt: json['created_at'],
      detailLink: json['detail_link'],
      salesTeam: BookingSalesTeam.fromJson(json['sales_team'] ?? {}),
      batch: BookingBatch.fromJson(json['batch'] ?? {}),
    );
  }

  // Get effective status considering suspension
  String get effectiveStatus {
    try {
      return suspended == 1 ? 'Suspended' : (status ?? 'Unknown');
    } catch (e) {
      return 'Unknown';
    }
  }
}

class BookingBatch {
  final int id;
  final int courseId;
  final String? name;
  final String? status;
  final BookingCourse course;

  BookingBatch({
    required this.id,
    required this.courseId,
    this.name,
    this.status,
    required this.course,
  });

  factory BookingBatch.fromJson(Map<String, dynamic> json) {
    return BookingBatch(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'],
      status: json['status'],
      course: BookingCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class BookingCourse {
  final int id;
  final String? name;

  BookingCourse({
    required this.id,
    this.name,
  });

  factory BookingCourse.fromJson(Map<String, dynamic> json) {
    return BookingCourse(
      id: json['id'] ?? 0,
      name: json['name'],
    );
  }
} 

class BookingSalesTeam {
  final int id;
  final String name;

  BookingSalesTeam({
    required this.id,
    required this.name,
  });

  factory BookingSalesTeam.fromJson(Map<String, dynamic> json) {
    return BookingSalesTeam(
      id: json['id'],
      name: json['name'],
    );
  }
}