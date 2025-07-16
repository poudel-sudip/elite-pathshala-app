// Batch Written Exam List Response Models
class BatchWrittenExamListResponse {
  final bool success;
  final String message;
  final BatchWrittenExamListData data;

  BatchWrittenExamListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchWrittenExamListResponse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamListResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchWrittenExamListData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchWrittenExamListData {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final List<BatchWrittenExamItem> examLists;
  final int examCount;
  final BatchWrittenCourse course;

  BatchWrittenExamListData({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.examLists,
    required this.examCount,
    required this.course,
  });

  factory BatchWrittenExamListData.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamListData(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      examLists: (json['exam_lists'] as List? ?? [])
          .map((e) => BatchWrittenExamItem.fromJson(e))
          .toList(),
      examCount: json['exam_count'] ?? 0,
      course: BatchWrittenCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class BatchWrittenExamItem {
  final int id;
  final int examId;
  final int batchId;
  final String createdAt;
  final String name;
  final String examTime;
  final String status;
  final String attemptLink;
  final String? resultLink;
  final String? questionShowLink;

  BatchWrittenExamItem({
    required this.id,
    required this.examId,
    required this.batchId,
    required this.createdAt,
    required this.name,
    required this.examTime,
    required this.status,
    required this.attemptLink,
    this.resultLink,
    this.questionShowLink,
  });

  factory BatchWrittenExamItem.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamItem(
      id: json['id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      createdAt: json['created_at'] ?? '',
      name: json['name'] ?? '',
      examTime: json['exam_time'] ?? '',
      status: json['status'] ?? '',
      attemptLink: json['attempt_link'] ?? '',
      resultLink: json['result_link'],
      questionShowLink: json['question_show_link'],
    );
  }
}

class BatchWrittenCourse {
  final int id;
  final String name;

  BatchWrittenCourse({
    required this.id,
    required this.name,
  });

  factory BatchWrittenCourse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenCourse(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
    );
  }
}

// Batch Written Exam Attempt Response Models
class BatchWrittenExamAttemptResponse {
  final bool success;
  final String message;
  final BatchWrittenExamAttemptData data;

  BatchWrittenExamAttemptResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchWrittenExamAttemptResponse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamAttemptResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchWrittenExamAttemptData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchWrittenExamAttemptData {
  final int id;
  final int batchId;
  final int examId;
  final String startedAt;
  final String remainingTime;
  final String status;
  final String attemptSubmitLink;
  final BatchWrittenBatch batch;
  final BatchWrittenExam exam;

  BatchWrittenExamAttemptData({
    required this.id,
    required this.batchId,
    required this.examId,
    required this.startedAt,
    required this.remainingTime,
    required this.status,
    required this.attemptSubmitLink,
    required this.batch,
    required this.exam,
  });

  factory BatchWrittenExamAttemptData.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamAttemptData(
      id: json['id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      startedAt: json['started_at'] ?? '',
      remainingTime: json['remaining_time'] ?? '',
      status: json['status'] ?? '',
      attemptSubmitLink: json['attempt_submit_link'] ?? '',
      batch: BatchWrittenBatch.fromJson(json['batch'] ?? {}),
      exam: BatchWrittenExam.fromJson(json['exam'] ?? {}),
    );
  }
}

class BatchWrittenBatch {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final BatchWrittenCourse course;

  BatchWrittenBatch({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.course,
  });

  factory BatchWrittenBatch.fromJson(Map<String, dynamic> json) {
    return BatchWrittenBatch(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      course: BatchWrittenCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class BatchWrittenExam {
  final int id;
  final String name;
  final String? description;
  final String examTime;
  final String status;
  final String fullMarks;
  final String passMarks;
  final List<BatchWrittenQuestionGroup> questionGroups;

  BatchWrittenExam({
    required this.id,
    required this.name,
    this.description,
    required this.examTime,
    required this.status,
    required this.fullMarks,
    required this.passMarks,
    required this.questionGroups,
  });

  factory BatchWrittenExam.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      examTime: json['exam_time'] ?? '',
      status: json['status'] ?? '',
      fullMarks: json['full_marks'] ?? '',
      passMarks: json['pass_marks'] ?? '',
      questionGroups: (json['question_groups'] as List? ?? [])
          .map((e) => BatchWrittenQuestionGroup.fromJson(e))
          .toList(),
    );
  }
}

class BatchWrittenQuestionGroup {
  final int id;
  final String name;
  final String? description;
  final String marks;
  final List<BatchWrittenQuestion> questionList;

  BatchWrittenQuestionGroup({
    required this.id,
    required this.name,
    this.description,
    required this.marks,
    required this.questionList,
  });

  factory BatchWrittenQuestionGroup.fromJson(Map<String, dynamic> json) {
    return BatchWrittenQuestionGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      marks: json['marks'] ?? '',
      questionList: (json['question_list'] as List? ?? [])
          .map((e) => BatchWrittenQuestion.fromJson(e))
          .toList(),
    );
  }
}

class BatchWrittenQuestion {
  final int id;
  final String question;
  final String marks;
  final bool solved;
  final String solutionDetail;

  BatchWrittenQuestion({
    required this.id,
    required this.question,
    required this.marks,
    required this.solved,
    required this.solutionDetail,
  });

  factory BatchWrittenQuestion.fromJson(Map<String, dynamic> json) {
    return BatchWrittenQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      marks: json['marks'] ?? '',
      solved: json['solved'] ?? false,
      solutionDetail: json['solution_detail'] ?? '',
    );
  }
}

// Batch Written Exam Solution Response Models
class BatchWrittenExamSolutionResponse {
  final bool success;
  final String message;
  final BatchWrittenExamSolutionData data;

  BatchWrittenExamSolutionResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchWrittenExamSolutionResponse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamSolutionResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchWrittenExamSolutionData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchWrittenExamSolutionData {
  final int? id;
  final int userId;
  final int batchId;
  final int examId;
  final int questionId;
  final List<BatchWrittenSolutionImage> solutionImages;
  final String addImageLink;
  final BatchWrittenSolutionQuestion question;
  final BatchWrittenSolutionExam exam;
  final BatchWrittenSolutionBatch batch;

  BatchWrittenExamSolutionData({
    this.id,
    required this.userId,
    required this.batchId,
    required this.examId,
    required this.questionId,
    required this.solutionImages,
    required this.addImageLink,
    required this.question,
    required this.exam,
    required this.batch,
  });

  factory BatchWrittenExamSolutionData.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamSolutionData(
      id: json['id'],
      userId: json['user_id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      questionId: json['question_id'] ?? 0,
      solutionImages: (json['solution_images'] as List? ?? [])
          .map((e) => BatchWrittenSolutionImage.fromJson(e))
          .toList(),
      addImageLink: json['add_image_link'] ?? '',
      question: BatchWrittenSolutionQuestion.fromJson(json['question'] ?? {}),
      exam: BatchWrittenSolutionExam.fromJson(json['exam'] ?? {}),
      batch: BatchWrittenSolutionBatch.fromJson(json['batch'] ?? {}),
    );
  }
}

class BatchWrittenSolutionImage {
  final int id;
  final int solutionId;
  final String imgUrl;
  final String deleteLink;

  BatchWrittenSolutionImage({
    required this.id,
    required this.solutionId,
    required this.imgUrl,
    required this.deleteLink,
  });

  factory BatchWrittenSolutionImage.fromJson(Map<String, dynamic> json) {
    return BatchWrittenSolutionImage(
      id: json['id'] ?? 0,
      solutionId: json['solution_id'] ?? 0,
      imgUrl: json['img_url'] ?? '',
      deleteLink: json['delete_link'] ?? '',
    );
  }
}

class BatchWrittenSolutionQuestion {
  final int id;
  final String question;
  final String marks;
  final int groupId;
  final BatchWrittenSolutionGroup group;

  BatchWrittenSolutionQuestion({
    required this.id,
    required this.question,
    required this.marks,
    required this.groupId,
    required this.group,
  });

  factory BatchWrittenSolutionQuestion.fromJson(Map<String, dynamic> json) {
    return BatchWrittenSolutionQuestion(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      marks: json['marks'] ?? '',
      groupId: json['group_id'] ?? 0,
      group: BatchWrittenSolutionGroup.fromJson(json['group'] ?? {}),
    );
  }
}

class BatchWrittenSolutionGroup {
  final int id;
  final String name;
  final String? description;
  final String marks;

  BatchWrittenSolutionGroup({
    required this.id,
    required this.name,
    this.description,
    required this.marks,
  });

  factory BatchWrittenSolutionGroup.fromJson(Map<String, dynamic> json) {
    return BatchWrittenSolutionGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      marks: json['marks'] ?? '',
    );
  }
}

class BatchWrittenSolutionExam {
  final int id;
  final String name;
  final String status;
  final String startAt;

  BatchWrittenSolutionExam({
    required this.id,
    required this.name,
    required this.status,
    required this.startAt,
  });

  factory BatchWrittenSolutionExam.fromJson(Map<String, dynamic> json) {
    return BatchWrittenSolutionExam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      status: json['status'] ?? '',
      startAt: json['start_at'] ?? '',
    );
  }
}

class BatchWrittenSolutionBatch {
  final int id;
  final int courseId;
  final String name;
  final String? image;
  final String status;

  BatchWrittenSolutionBatch({
    required this.id,
    required this.courseId,
    required this.name,
    this.image,
    required this.status,
  });

  factory BatchWrittenSolutionBatch.fromJson(Map<String, dynamic> json) {
    return BatchWrittenSolutionBatch(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'],
      status: json['status'] ?? '',
    );
  }
}

// Batch Written Exam Submit Response Models
class BatchWrittenExamSubmitResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  BatchWrittenExamSubmitResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BatchWrittenExamSubmitResponse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamSubmitResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: json['data'],
    );
  }
}

// Batch Written Exam Add Image Response Models
class BatchWrittenExamAddImageResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  BatchWrittenExamAddImageResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BatchWrittenExamAddImageResponse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamAddImageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: json['data'],
    );
  }
}

// Batch Written Exam Delete Image Response Models
class BatchWrittenExamDeleteImageResponse {
  final bool success;
  final String message;
  final Map<String, dynamic>? data;

  BatchWrittenExamDeleteImageResponse({
    required this.success,
    required this.message,
    this.data,
  });

  factory BatchWrittenExamDeleteImageResponse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamDeleteImageResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: json['data'],
    );
  }
} 

// Batch Written Exam Questions Response Models
class BatchWrittenExamQuestionsResponse {
  final bool success;
  final String message;
  final BatchWrittenExamQuestionsData data;

  BatchWrittenExamQuestionsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory BatchWrittenExamQuestionsResponse.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamQuestionsResponse(
      success: json['success'] ?? false,
      message: json['message'] ?? 'Unknown error',
      data: BatchWrittenExamQuestionsData.fromJson(json['data'] ?? {}),
    );
  }
}

class BatchWrittenExamQuestionsData {
  final int id;
  final int batchId;
  final int examId;
  final BatchWrittenQuestionsExamBatch batch;
  final BatchWrittenQuestionsExam exam;

  BatchWrittenExamQuestionsData({
    required this.id,
    required this.batchId,
    required this.examId,
    required this.batch,
    required this.exam,
  });

  factory BatchWrittenExamQuestionsData.fromJson(Map<String, dynamic> json) {
    return BatchWrittenExamQuestionsData(
      id: json['id'] ?? 0,
      batchId: json['batch_id'] ?? 0,
      examId: json['exam_id'] ?? 0,
      batch: BatchWrittenQuestionsExamBatch.fromJson(json['batch'] ?? {}),
      exam: BatchWrittenQuestionsExam.fromJson(json['exam'] ?? {}),
    );
  }
}

class BatchWrittenQuestionsExamBatch {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final BatchWrittenCourse course;

  BatchWrittenQuestionsExamBatch({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.course,
  });

  factory BatchWrittenQuestionsExamBatch.fromJson(Map<String, dynamic> json) {
    return BatchWrittenQuestionsExamBatch(
      id: json['id'] ?? 0,
      courseId: json['course_id'] ?? 0,
      name: json['name'] ?? '',
      image: json['image'] ?? '',
      status: json['status'] ?? '',
      course: BatchWrittenCourse.fromJson(json['course'] ?? {}),
    );
  }
}

class BatchWrittenQuestionsExam {
  final int id;
  final String name;
  final String? description;
  final String examTime;
  final String status;
  final String fullMarks;
  final String passMarks;
  final List<BatchWrittenQuestionsGroup> questionGroups;

  BatchWrittenQuestionsExam({
    required this.id,
    required this.name,
    this.description,
    required this.examTime,
    required this.status,
    required this.fullMarks,
    required this.passMarks,
    required this.questionGroups,
  });

  factory BatchWrittenQuestionsExam.fromJson(Map<String, dynamic> json) {
    return BatchWrittenQuestionsExam(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      examTime: json['exam_time'] ?? '',
      status: json['status'] ?? '',
      fullMarks: json['full_marks'] ?? '',
      passMarks: json['pass_marks'] ?? '',
      questionGroups: (json['question_groups'] as List? ?? [])
          .map((e) => BatchWrittenQuestionsGroup.fromJson(e))
          .toList(),
    );
  }
}

class BatchWrittenQuestionsGroup {
  final int id;
  final String name;
  final String? description;
  final String marks;
  final List<BatchWrittenQuestionItem> questionList;
  final int questionCount;

  BatchWrittenQuestionsGroup({
    required this.id,
    required this.name,
    this.description,
    required this.marks,
    required this.questionList,
    required this.questionCount,
  });

  factory BatchWrittenQuestionsGroup.fromJson(Map<String, dynamic> json) {
    return BatchWrittenQuestionsGroup(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'],
      marks: json['marks'] ?? '',
      questionList: (json['question_list'] as List? ?? [])
          .map((e) => BatchWrittenQuestionItem.fromJson(e))
          .toList(),
      questionCount: json['question_count'] ?? 0,
    );
  }
}

class BatchWrittenQuestionItem {
  final int id;
  final String question;
  final String marks;

  BatchWrittenQuestionItem({
    required this.id,
    required this.question,
    required this.marks,
  });

  factory BatchWrittenQuestionItem.fromJson(Map<String, dynamic> json) {
    return BatchWrittenQuestionItem(
      id: json['id'] ?? 0,
      question: json['question'] ?? '',
      marks: json['marks'] ?? '',
    );
  }
} 