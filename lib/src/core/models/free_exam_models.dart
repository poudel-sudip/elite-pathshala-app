
import 'dart:convert';

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
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      examCount: json['exam_count'] ?? 0,
      examListLink: json['exam_list_link'] ?? '',
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
    success: json['success'] ?? false,
    message: json['message'] ?? 'Unknown error',
    data: FreeExamCategoryExamListData.fromJson(json['data'] ?? {}),
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
    id: json['id'] ?? 0,
    title: json['title'] ?? '',
    examCount: json['exam_count'] ?? 0,
    examLists: (json['exam_lists'] as List? ?? [])
        .map((x) => FreeExamListItem.fromJson(x ?? {}))
        .toList(),
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
    id: json['id'] ?? 0,
    categoryId: json['category_id'] ?? 0,
    name: json['name'] ?? '',
    status: json['status'] ?? 'Unknown',
    questionCount: json['question_count'] ?? 0,
    attemptLink: json['attempt_link'] ?? '',
    createdAt: json['created_at'] ?? '',
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
        success: json['success'] ?? false,
        message: json['message'] ?? 'Unknown error',
        data: FreeExamAttemptData.fromJson(json['data'] ?? {}),
      );
}

class FreeExamAttemptData {
  final int id;
  final int categoryId;
  final int examId;
  final String attemptSubmitLink;
  final ExamCategory category;
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
        id: json['id'] ?? 0,
        categoryId: json['category_id'] ?? 0,
        examId: json['exam_id'] ?? 0,
        attemptSubmitLink: json['attempt_submit_link'] ?? '',
        category: ExamCategory.fromJson(json['category'] ?? {}),
        exam: ExamDetails.fromJson(json['exam'] ?? {}),
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
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        description: json['description'] ?? '',
        examTime: json['exam_time'] ?? '00:30',
        marksPerQuestion: json['marks_per_question'] ?? '1',
        negativeMarks: json['negative_marks'] ?? '0',
        status: json['status'] ?? 'Active',
        questionCount: json['question_count'] ?? 0,
        questionList: (json['question_list'] as List? ?? [])
            .map((x) => Question.fromJson(x ?? {}))
            .toList(),
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
        id: json['id'] ?? 0,
        question: json['question'] ?? '',
        optA: json['opt_a'] ?? '',
        optB: json['opt_b'] ?? '',
        optC: json['opt_c'] ?? '',
        optD: json['opt_d'] ?? '',
        optCorrect: json['opt_correct'] ?? '',
      );
}

// Simple category model for exam attempt response
class ExamCategory {
  final int id;
  final String title;

  ExamCategory({
    required this.id,
    required this.title,
  });

  factory ExamCategory.fromJson(Map<String, dynamic> json) => ExamCategory(
        id: json['id'] ?? 0,
        title: json['title'] ?? '',
      );
}

// Exam result submission response models
class ExamResultSubmissionResponse {
  final bool success;
  final String message;
  final ExamResultData data;

  ExamResultSubmissionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory ExamResultSubmissionResponse.fromJson(Map<String, dynamic> json) =>
      ExamResultSubmissionResponse(
        success: json['success'] ?? false,
        message: json['message'] ?? '',
        data: ExamResultData.fromJson(json['data'] ?? {}),
      );
}

class ExamResultData {
  final int examId;
  final String name;
  final String email;
  final String contact;
  final String courses;
  final int totalQuestions;
  final String leavedQuestions;
  final String correctQuestions;
  final String wrongQuestions;
  final String marksObtained;
  final String remarks;
  final String updatedAt;
  final String createdAt;
  final int id;
  final int? fullMarks;
  final List<String> correctSolutions;

  ExamResultData({
    required this.examId,
    required this.name,
    required this.email,
    required this.contact,
    required this.courses,
    required this.totalQuestions,
    required this.leavedQuestions,
    required this.correctQuestions,
    required this.wrongQuestions,
    required this.marksObtained,
    required this.remarks,
    required this.updatedAt,
    required this.createdAt,
    required this.id,
    this.fullMarks,
    required this.correctSolutions,
  });

  factory ExamResultData.fromJson(Map<String, dynamic> json) => ExamResultData(
        examId: json['exam_id'] ?? 0,
        name: json['name'] ?? '',
        email: json['email'] ?? '',
        contact: json['contact'] ?? '',
        courses: json['courses'] ?? '',
        totalQuestions: json['total_questions'] ?? 0,
        leavedQuestions: (json['leaved_questions'] ?? 0).toString(),
        correctQuestions: (json['correct_questions'] ?? 0).toString(),
        wrongQuestions: (json['wrong_questions'] ?? 0).toString(),
        marksObtained: (json['marks_obtained'] ?? 0).toString(),
        remarks: json['remarks'] is List 
            ? jsonEncode(json['remarks']) 
            : (json['remarks'] ?? '').toString(),
        updatedAt: json['updated_at'] ?? '',
        createdAt: json['created_at'] ?? '',
        id: json['id'] ?? 0,
        fullMarks: json['full_marks'],
        correctSolutions: (json['correct_solutions'] as List? ?? [])
            .map((x) => x.toString())
            .toList(),
      );
}
