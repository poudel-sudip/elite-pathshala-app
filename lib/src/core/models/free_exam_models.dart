
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

class FreeExamCategoryExamListResponse {
  final bool success;
  final String message;
  final FreeExamCategoryExamListData data;

  FreeExamCategoryExamListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FreeExamCategoryExamListResponse.fromJson(Map<String, dynamic> json) => FreeExamCategoryExamListResponse(
    success: json['success'],
    message: json['message'],
    data: FreeExamCategoryExamListData.fromJson(json['data']),
  );
}

class FreeExamCategoryExamListData {
  final int id;
  final String title;
  final int examCount;
  final List<FreeExamListItem> examLists;

  FreeExamCategoryExamListData({
    required this.id,
    required this.title,
    required this.examCount,
    required this.examLists,
  });

  factory FreeExamCategoryExamListData.fromJson(Map<String, dynamic> json) => FreeExamCategoryExamListData(
    id: json['id'],
    title: json['title'],
    examCount: json['exam_count'],
    examLists: List<FreeExamListItem>.from(json['exam_lists'].map((x) => FreeExamListItem.fromJson(x))),
  );
}

class FreeExamListItem {
  final int id;
  final int categoryId;
  final String name;
  final String status;
  final int questionCount;
  final String attemptLink;
  final String createdAt;

  FreeExamListItem({
    required this.id,
    required this.categoryId,
    required this.name,
    required this.status,
    required this.questionCount,
    required this.attemptLink,
    required this.createdAt,
  });

  factory FreeExamListItem.fromJson(Map<String, dynamic> json) => FreeExamListItem(
    id: json['id'],
    categoryId: json['category_id'],
    name: json['name'],
    status: json['status'],
    questionCount: json['question_count'],
    attemptLink: json['attempt_link'],
    createdAt: json['created_at'],
  );
}
