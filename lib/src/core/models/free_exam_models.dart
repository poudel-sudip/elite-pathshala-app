// To parse this JSON data, do
//
//     final freeExamCategory = freeExamCategoryFromJson(jsonString);

import 'dart:convert';

FreeExamCategory freeExamCategoryFromJson(String str) => FreeExamCategory.fromJson(json.decode(str));

String freeExamCategoryToJson(FreeExamCategory data) => json.encode(data.toJson());

class FreeExamCategory {
    final bool success;
    final String message;
    final List<FreeExamCategoryItem> data;

    FreeExamCategory({
        required this.success,
        required this.message,
        required this.data,
    });

    factory FreeExamCategory.fromJson(Map<String, dynamic> json) => FreeExamCategory(
        success: json["success"],
        message: json["message"],
        data: List<FreeExamCategoryItem>.from(json["data"].map((x) => FreeExamCategoryItem.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "success": success,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
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

    factory FreeExamCategoryItem.fromJson(Map<String, dynamic> json) => FreeExamCategoryItem(
        id: json["id"],
        title: json["title"],
        examCount: json["exam_count"],
        examListLink: json["exam_list_link"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "exam_count": examCount,
        "exam_list_link": examListLink,
    };
} 