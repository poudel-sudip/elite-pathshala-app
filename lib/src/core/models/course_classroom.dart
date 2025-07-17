class CourseClassroomResponse {
  final bool success;
  final String message;
  final CourseClassroomData data;

  CourseClassroomResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory CourseClassroomResponse.fromJson(Map<String, dynamic> json) {
    return CourseClassroomResponse(
      success: json['success'],
      message: json['message'],
      data: CourseClassroomData.fromJson(json['data']),
    );
  }
}

class CourseClassroomData {
  final List<ClassroomClass> classes;
  final List<Schedule> schedules;

  CourseClassroomData({
    required this.classes,
    required this.schedules,
  });

  factory CourseClassroomData.fromJson(Map<String, dynamic> json) {
    return CourseClassroomData(
      classes: (json['classes'] as List)
          .map((x) => ClassroomClass.fromJson(x))
          .toList(),
      schedules: (json['schedules'] as List)
          .map((x) => Schedule.fromJson(x))
          .toList(),
    );
  }
}

class ClassroomClass {
  final int id;
  final int batchId;
  final String status;
  final int suspended;
  final String? suspendText;
  final String features;
  final String? dueClearDate;
  final int dueAmount;
  final String discount;
  final int trialMode;
  final int dueDays;
  final ClassroomLinks links;
  final SalesTeam? salesTeam;
  final Batch batch;

  ClassroomClass({
    required this.id,
    required this.batchId,
    required this.status,
    required this.suspended,
    this.suspendText,
    required this.features,
    this.dueClearDate,
    required this.dueAmount,
    required this.discount,
    required this.trialMode,
    required this.dueDays,
    required this.links,
    this.salesTeam,
    required this.batch,
  });

  factory ClassroomClass.fromJson(Map<String, dynamic> json) {
    return ClassroomClass(
      id: json['id'],
      batchId: json['batch_id'],
      status: json['status'],
      suspended: json['suspended'],
      suspendText: json['suspend_text'],
      features: json['features'],
      dueClearDate: json['due_clear_date'],
      dueAmount: json['dueAmount'],
      discount: json['discount'],
      trialMode: json['trial_mode'],
      dueDays: json['due_days'],
      links: ClassroomLinks.fromJson(json['links']),
      salesTeam: SalesTeam.fromJson(json['sales_team']),
      batch: Batch.fromJson(json['batch']),
    );
  }
}

class ClassroomLinks {
  final String? chat;
  final String? files;
  final String? videos;
  final String? mcqExams;
  final String? writtenExams;

  ClassroomLinks({
    this.chat,
    this.files,
    this.videos,
    this.mcqExams,
    this.writtenExams,
  });

  factory ClassroomLinks.fromJson(Map<String, dynamic> json) {
    return ClassroomLinks(
      chat: json['chat'],
      files: json['files'],
      videos: json['videos'],
      mcqExams: json['mcq_exams'],
      writtenExams: json['written_exams'],
    );
  }
}

class Batch {
  final int id;
  final int courseId;
  final String name;
  final String slug;
  final String status;
  final Course course;

  Batch({
    required this.id,
    required this.courseId,
    required this.name,
    required this.slug,
    required this.status,
    required this.course,
  });

  factory Batch.fromJson(Map<String, dynamic> json) {
    return Batch(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      slug: json['slug'],
      status: json['status'],
      course: Course.fromJson(json['course']),
    );
  }
}

class Course {
  final int id;
  final String name;

  Course({
    required this.id,
    required this.name,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['name'],
    );
  }
}

class SalesTeam {
  final int id;
  final String name;

  SalesTeam({
    required this.id,
    required this.name,
  });

  factory SalesTeam.fromJson(Map<String, dynamic> json) {
    return SalesTeam(
      id: json['id'],
      name: json['name'],
    );
  }
}

class Schedule {
  final int id;
  final String tutor;
  final String className;
  final String topic;
  final int duration;
  final String durationType;
  final String? classLink;
  final String? liveLink;
  final String startAt;
  final String endAt;
  final String? repeat;

  Schedule({
    required this.id,
    required this.tutor,
    required this.className,
    required this.topic,
    required this.duration,
    required this.durationType,
    this.classLink,
    this.liveLink,
    required this.startAt,
    required this.endAt,
    this.repeat,
  });

  factory Schedule.fromJson(Map<String, dynamic> json) {
    return Schedule(
      id: json['id'],
      tutor: json['tutor'],
      className: json['class'],
      topic: json['topic'],
      duration: json['duration'],
      durationType: json['duration_type'],
      classLink: json['class_link'],
      liveLink: json['live_link'],
      startAt: json['start_at'],
      endAt: json['end_at'],
      repeat: json['repeat'],
    );
  }
} 