
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

class FreeExamAttemptResponse {
  final bool success;
  final String message;
  final FreeExamAttemptData data;

  FreeExamAttemptResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FreeExamAttemptResponse.fromJson(Map<String, dynamic> json) =>
      FreeExamAttemptResponse(
        success: json['success'],
        message: json['message'],
        data: FreeExamAttemptData.fromJson(json['data']),
      );
}

class FreeExamAttemptData {
  final int id;
  final int categoryId;
  final int examId;
  final String attemptSubmitLink;
  final FreeExamCategoryItem category;
  final ExamDetails exam;

  FreeExamAttemptData({
    required this.id,
    required this.categoryId,
    required this.examId,
    required this.attemptSubmitLink,
    required this.category,
    required this.exam,
  });

  factory FreeExamAttemptData.fromJson(Map<String, dynamic> json) =>
      FreeExamAttemptData(
        id: json['id'],
        categoryId: json['category_id'],
        examId: json['exam_id'],
        attemptSubmitLink: json['attempt_submit_link'],
        category: FreeExamCategoryItem.fromJson(json['category']),
        exam: ExamDetails.fromJson(json['exam']),
      );
}

class ExamDetails {
  final int id;
  final String name;
  final String description;
  final String examTime;
  final String marksPerQuestion;
  final String negativeMarks;
  final String status;
  final int questionCount;
  final List<Question> questionList;

  ExamDetails({
    required this.id,
    required this.name,
    required this.description,
    required this.examTime,
    required this.marksPerQuestion,
    required this.negativeMarks,
    required this.status,
    required this.questionCount,
    required this.questionList,
  });

  factory ExamDetails.fromJson(Map<String, dynamic> json) => ExamDetails(
        id: json['id'],
        name: json['name'],
        description: json['description'],
        examTime: json['exam_time'],
        marksPerQuestion: json['marks_per_question'],
        negativeMarks: json['negative_marks'],
        status: json['status'],
        questionCount: json['question_count'],
        questionList: List<Question>.from(
            json['question_list'].map((x) => Question.fromJson(x))),
      );
}

class Question {
  final int id;
  final String question;
  final String optA;
  final String optB;
  final String optC;
  final String optD;
  final String optCorrect;

  Question({
    required this.id,
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.optCorrect,
  });

  factory Question.fromJson(Map<String, dynamic> json) => Question(
        id: json['id'],
        question: json['question'],
        optA: json['opt_a'],
        optB: json['opt_b'],
        optC: json['opt_c'],
        optD: json['opt_d'],
        optCorrect: json['opt_correct'],
      );
}
