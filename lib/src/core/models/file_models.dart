// File Units Response Models
class FileUnitsResponse {
  final bool success;
  final String message;
  final FileUnitsData data;

  FileUnitsResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory FileUnitsResponse.fromJson(Map<String, dynamic> json) {
    return FileUnitsResponse(
      success: json['success'],
      message: json['message'],
      data: FileUnitsData.fromJson(json['data']),
    );
  }
}

class FileUnitsData {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final List<FileUnit> fileUnits;
  final FileCourse course;

  FileUnitsData({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.fileUnits,
    required this.course,
  });

  factory FileUnitsData.fromJson(Map<String, dynamic> json) {
    return FileUnitsData(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      image: json['image'],
      status: json['status'],
      fileUnits: (json['file_units'] as List)
          .map((x) => FileUnit.fromJson(x))
          .toList(),
      course: FileCourse.fromJson(json['course']),
    );
  }
}

class FileUnit {
  final int id;
  final int batchId;
  final String name;
  final int fileCount;
  final int subUnitCount;
  final String fileApiLink;

  FileUnit({
    required this.id,
    required this.batchId,
    required this.name,
    required this.fileCount,
    required this.subUnitCount,
    required this.fileApiLink,
  });

  factory FileUnit.fromJson(Map<String, dynamic> json) {
    return FileUnit(
      id: json['id'],
      batchId: json['batch_id'],
      name: json['name'],
      fileCount: json['file_count'],
      subUnitCount: json['sub_unit_count'],
      fileApiLink: json['file_api_link'],
    );
  }
}

class FileCourse {
  final int id;
  final String name;

  FileCourse({
    required this.id,
    required this.name,
  });

  factory FileCourse.fromJson(Map<String, dynamic> json) {
    return FileCourse(
      id: json['id'],
      name: json['name'],
    );
  }
}

// Unit Files Response Models (for sub-units and PDF files)
class UnitFilesResponse {
  final bool success;
  final String message;
  final UnitFilesData data;

  UnitFilesResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory UnitFilesResponse.fromJson(Map<String, dynamic> json) {
    return UnitFilesResponse(
      success: json['success'],
      message: json['message'],
      data: UnitFilesData.fromJson(json['data']),
    );
  }
}

class UnitFilesData {
  final int id;
  final int batchId;
  final String name;
  final FileBatch batch;
  final List<FileUnit> fileUnits; // Sub-units
  final List<PdfFile> pdfFiles;
  final int subUnitCount;
  final int fileCount;

  UnitFilesData({
    required this.id,
    required this.batchId,
    required this.name,
    required this.batch,
    required this.fileUnits,
    required this.pdfFiles,
    required this.subUnitCount,
    required this.fileCount,
  });

  factory UnitFilesData.fromJson(Map<String, dynamic> json) {
    return UnitFilesData(
      id: json['id'],
      batchId: json['batch_id'],
      name: json['name'],
      batch: FileBatch.fromJson(json['batch']),
      fileUnits: (json['file_units'] as List)
          .map((x) => FileUnit.fromJson(x))
          .toList(),
      pdfFiles: (json['pdf_files'] as List)
          .map((x) => PdfFile.fromJson(x))
          .toList(),
      subUnitCount: json['sub_unit_count'],
      fileCount: json['file_count'],
    );
  }

  // Helper method to determine what to show
  bool get hasSubUnits => subUnitCount > 0;
  bool get hasPdfFiles => fileCount > 0;
}

class FileBatch {
  final int id;
  final int courseId;
  final String name;
  final String image;
  final String status;
  final FileCourse course;

  FileBatch({
    required this.id,
    required this.courseId,
    required this.name,
    required this.image,
    required this.status,
    required this.course,
  });

  factory FileBatch.fromJson(Map<String, dynamic> json) {
    return FileBatch(
      id: json['id'],
      courseId: json['course_id'],
      name: json['name'],
      image: json['image'],
      status: json['status'],
      course: FileCourse.fromJson(json['course']),
    );
  }
}

class PdfFile {
  final int id;
  final int batchId;
  final int unitId;
  final int userId;
  final String userName;
  final String fileTitle;
  final String filePath;
  final String? rememberToken;
  final String createdAt;
  final String updatedAt;

  PdfFile({
    required this.id,
    required this.batchId,
    required this.unitId,
    required this.userId,
    required this.userName,
    required this.fileTitle,
    required this.filePath,
    this.rememberToken,
    required this.createdAt,
    required this.updatedAt,
  });

  factory PdfFile.fromJson(Map<String, dynamic> json) {
    return PdfFile(
      id: json['id'],
      batchId: json['batch_id'],
      unitId: json['unit_id'],
      userId: json['user_id'],
      userName: json['user_name'],
      fileTitle: json['fileTitle'],
      filePath: json['filePath'],
      rememberToken: json['remember_token'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
    );
  }

  // Helper method to check if file is a PDF
  bool get isPdf => filePath.toLowerCase().endsWith('.pdf');
  
  // Helper method to get file extension
  String get fileExtension {
    return filePath.split('.').last.toLowerCase();
  }
} 