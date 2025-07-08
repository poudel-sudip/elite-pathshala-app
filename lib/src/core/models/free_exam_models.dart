
// Free Exam Category List Response Models
class FreeExamCategoryResponse {
  final bool success;
  final String message;
  final List<FreeExamCategoryItem> data;

  FreeExamCategoryResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FreeExamCategoryResponse.fromJson(Map<String, dynamic> json) {
    return FreeExamCategoryResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: (json['data'] as List? ?? [])
          .map((x) => FreeExamCategoryItem.fromJson(x ?? {}))
          .toList(),
    );
  }
}

class FreeExamCategoryItem {
  final int id;
  final String title;
  final int examCount;
  final String examListLink;

  FreeExamCategoryItem({
    required this.id,
    required this.title,
    required this.examCount,
    required this.examListLink,
  });

  factory FreeExamCategoryItem.fromJson(Map<String, dynamic> json) {
    return FreeExamCategoryItem(
      id: json['id'],
      title: json['title'],
      examCount: json['exam_count'],
      examListLink: json['exam_list_link'],
    );
  }
}
