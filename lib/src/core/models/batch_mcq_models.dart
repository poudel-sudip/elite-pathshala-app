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

// Batch MCQ Exam Reset Response Model
class BatchMcqResetResponse {
  final bool success;
  final String message;
  final dynamic data; // Can be null

  BatchMcqResetResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BatchMcqResetResponse.fromJson(Map<String, dynamic> json) {
    return BatchMcqResetResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: json['data'],
    );
  }
}

// Batch MCQ Exam Result Response Models
class BatchMcqResultResponse {
  final bool success;
  final String message;
  final BatchMcqResultData data;

  BatchMcqResultResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchMcqResultResponse.fromJson(Map<String, dynamic> json) {
    return BatchMcqResultResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchMcqResultData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchMcqResultData {
  final int id;
  final int userId;
  final int batchId;
  final int examId;
  final int attempt;
  final int totalQuestions;
  final int leavedQuestions;
  final int correctQuestions;
  final int wrongQuestions;
  final String? marksObtained;
  final String createdAt;
  final String updatedAt;
  final BatchMcqResultBatch batch;
  final BatchMcqResultExam exam;
  final List<BatchMcqResultSolution> solutions;

  BatchMcqResultData({
    required this.id,
    required this.userId,
    required this.batchId,
    required this.examId,
    required this.attempt,
    required this.totalQuestions,
    required this.leavedQuestions,
    required this.correctQuestions,
    required this.wrongQuestions,
    this.marksObtained,
    required this.createdAt,
    required this.updatedAt,
    required this.batch,
    required this.exam,
    required this.solutions,
  });

  factory BatchMcqResultData.fromJson(Map<String, dynamic> json) {
    return BatchMcqResultData(
      id: json['id'] ?? 0,
      userId: json['user_id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      attempt: json['attempt'] ?? 0,
      totalQuestions: json['total_questions'] ?? 0,
      leavedQuestions: json['leaved_questions'] ?? 0,
      correctQuestions: json['correct_questions'] ?? 0,
      wrongQuestions: json['wrong_questions'] ?? 0,
      marksObtained: json['marks_obtained']?.toString(),
      createdAt: json['created_at'] ?? '',
      updatedAt: json['updated_at'] ?? '',
      batch: BatchMcqResultBatch.fromJson(json['batch'] ?? {}),
      exam: BatchMcqResultExam.fromJson(json['exam'] ?? {}),
      solutions: (json['solutions'] as List<dynamic>? ?? [])
          .map((e) => BatchMcqResultSolution.fromJson(e))
          .toList(),
    );
  }
}

class BatchMcqResultBatch {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final BatchMcqResultCourse course;

  BatchMcqResultBatch({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.course,
  });

  factory BatchMcqResultBatch.fromJson(Map<String, dynamic> json) {
    return BatchMcqResultBatch(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      course: BatchMcqResultCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class BatchMcqResultCourse {
  final int id;
  final String name;

  BatchMcqResultCourse({
    required this.id,
    required this.name,
  });

  factory BatchMcqResultCourse.fromJson(Map<String, dynamic> json) {
    return BatchMcqResultCourse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

class BatchMcqResultExam {
  final int id;
  final String name;
  final String? description;
  final String examTime;
  final String marksPerQuestion;
  final String negativeMarks;
  final String status;

  BatchMcqResultExam({
    required this.id,
    required this.name,
    this.description,
    required this.examTime,
    required this.marksPerQuestion,
    required this.negativeMarks,
    required this.status,
  });

  factory BatchMcqResultExam.fromJson(Map<String, dynamic> json) {
    return BatchMcqResultExam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      examTime: json['exam_time'] ?? '',
      marksPerQuestion: json['marks_per_question'] ?? '0',
      negativeMarks: json['negative_marks'] ?? '0',
      status: json['status'] ?? '',
    );
  }
}

class BatchMcqResultSolution {
  final int id;
  final int questionId;
  final String correctAns;
  final String yourAns;
  final BatchMcqResultQuestion question;

  BatchMcqResultSolution({
    required this.id,
    required this.questionId,
    required this.correctAns,
    required this.yourAns,
    required this.question,
  });

  factory BatchMcqResultSolution.fromJson(Map<String, dynamic> json) {
    return BatchMcqResultSolution(
      id: json['id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      correctAns: json['correct_ans'] ?? '',
      yourAns: json['your_ans'] ?? '',
      question: BatchMcqResultQuestion.fromJson(json['question'] ?? {}),
    );
  }
}

class BatchMcqResultQuestion {
  final int id;
  final String question;
  final String optA;
  final String optB;
  final String optC;
  final String optD;

  BatchMcqResultQuestion({
    required this.id,
    required this.question,
    required this.optA,
    required this.optB,
    required this.optC,
    required this.optD,
  });

  factory BatchMcqResultQuestion.fromJson(Map<String, dynamic> json) {
    return BatchMcqResultQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      optA: json['opt_a'] ?? '',
      optB: json['opt_b'] ?? '',
      optC: json['opt_c'] ?? '',
      optD: json['opt_d'] ?? '',
    );
  }
} 