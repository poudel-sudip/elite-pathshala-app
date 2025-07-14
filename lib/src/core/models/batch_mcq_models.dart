// Batch MCQ Exam List Response Models
class BatchMcqExamListResponse {
  final bool success;
  final String message;
  final BatchMcqExamListData data;

  BatchMcqExamListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchMcqExamListResponse.fromJson(Map<String, dynamic> json) {
    return BatchMcqExamListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchMcqExamListData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchMcqExamListData {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final List<BatchMcqExamItem> examLists;
  final int examCount;
  final BatchMcqCourse course;

  BatchMcqExamListData({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.examLists,
    required this.examCount,
    required this.course,
  });

  factory BatchMcqExamListData.fromJson(Map<String, dynamic> json) {
    return BatchMcqExamListData(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      examLists: (json['exam_lists'] as List? ?? [])
          .map((x) => BatchMcqExamItem.fromJson(x ?? {}))
          .toList(),
      examCount: json['exam_count'] ?? 0,
      course: BatchMcqCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class BatchMcqExamItem {
  final int id;
  final int examId;
  final int batchId;
  final String createdAt;
  final int questionCount;
  final String name;
  final String attemptLink;
  final String? resultLink;
  final String? resetLink;

  BatchMcqExamItem({
    required this.id,
    required this.examId,
    required this.batchId,
    required this.createdAt,
    required this.questionCount,
    required this.name,
    required this.attemptLink,
    this.resultLink,
    this.resetLink,
  });

  factory BatchMcqExamItem.fromJson(Map<String, dynamic> json) {
    return BatchMcqExamItem(
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      questionCount: json['question_count'] ?? 0,
      name: json['name'] ?? '',
      attemptLink: json['attempt_link'] ?? '',
      resultLink: json['result_link'],
      resetLink: json['reset_link'],
    );
  }

  // Helper methods to check which buttons to show
  bool get hasAttemptLink => attemptLink.isNotEmpty;
  bool get hasResultLink => resultLink != null && resultLink!.isNotEmpty;
  bool get hasResetLink => resetLink != null && resetLink!.isNotEmpty;
}

class BatchMcqCourse {
  final int id;
  final String name;

  BatchMcqCourse({
    required this.id,
    required this.name,
  });

  factory BatchMcqCourse.fromJson(Map<String, dynamic> json) {
    return BatchMcqCourse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// Batch MCQ Exam Attempt Response Models
class BatchMcqAttemptResponse {
  final bool success;
  final String message;
  final BatchMcqAttemptData data;

  BatchMcqAttemptResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchMcqAttemptResponse.fromJson(Map<String, dynamic> json) {
    return BatchMcqAttemptResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchMcqAttemptData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchMcqAttemptData {
  final int id;
  final int batchId;
  final int examId;
  final String createdAt;
  final String updatedAt;
  final String attemptSubmitLink;
  final BatchMcqBatch batch;
  final BatchMcqExam exam;

  BatchMcqAttemptData({
    required this.id,
    required this.batchId,
    required this.examId,
    required this.createdAt,
    required this.updatedAt,
    required this.attemptSubmitLink,
    required this.batch,
    required this.exam,
  });

  factory BatchMcqAttemptData.fromJson(Map<String, dynamic> json) {
    return BatchMcqAttemptData(
      id: json['id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      attemptSubmitLink: json['attempt_submit_link'] ?? '',
      batch: BatchMcqBatch.fromJson(json['batch'] ?? {}),
      exam: BatchMcqExam.fromJson(json['exam'] ?? {}),
    );
  }
}

class BatchMcqBatch {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final BatchMcqCourse course;

  BatchMcqBatch({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.course,
  });

  factory BatchMcqBatch.fromJson(Map<String, dynamic> json) {
    return BatchMcqBatch(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      course: BatchMcqCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class BatchMcqExam {
  final int id;
  final String name;
  final String? description;
  final String examTime;
  final String marksPerQuestion;
  final String negativeMarks;
  final String status;
  final int questionCount;
  final List<BatchMcqQuestion> questionList;

  BatchMcqExam({
    required this.id,
    required this.name,
    this.description,
    required this.examTime,
    required this.marksPerQuestion,
    required this.negativeMarks,
    required this.status,
    required this.questionCount,
    required this.questionList,
  });

  factory BatchMcqExam.fromJson(Map<String, dynamic> json) {
    return BatchMcqExam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      examTime: json['exam_time'] ?? '00:30',
      marksPerQuestion: json['marks_per_question'] ?? '1',
      negativeMarks: json['negative_marks'] ?? '0',
      status: json['status'] ?? 'Active',
      questionCount: json['question_count'] ?? 0,
      questionList: (json['question_list'] as List? ?? [])
          .map((x) => BatchMcqQuestion.fromJson(x ?? {}))
          .toList(),
    );
  }
}

class BatchMcqQuestion {
  final int id;
  final String question;
  final String optA;
  final String optB;
  final String optC;
  final String optD;
  final String optCorrect;

  BatchMcqQuestion({
    required this.id,
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
    required this.optCorrect,
  });

  factory BatchMcqQuestion.fromJson(Map<String, dynamic> json) {
    return BatchMcqQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      optA: json['opt_a'] ?? '',
      optB: json['opt_b'] ?? '',
      optC: json['opt_c'] ?? '',
      optD: json['opt_d'] ?? '',
      optCorrect: json['opt_correct'] ?? '',
    );
  }
}

// Batch MCQ Exam Submission Response Models
class BatchMcqSubmissionResponse {
  final bool success;
  final String message;
  final BatchMcqSubmissionData data;

  BatchMcqSubmissionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchMcqSubmissionResponse.fromJson(Map<String, dynamic> json) {
    return BatchMcqSubmissionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchMcqSubmissionData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchMcqSubmissionData {
  final String resultLink;

  BatchMcqSubmissionData({
    required this.resultLink,
  });

  factory BatchMcqSubmissionData.fromJson(Map<String, dynamic> json) {
    return BatchMcqSubmissionData(
      resultLink: json['result_link'] ?? '',
    );
  }
} 