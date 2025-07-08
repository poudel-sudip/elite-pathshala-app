// Notification List Response Models
class NotificationListResponse {
  final bool success;
  final String message;
  final NotificationListData data;

  NotificationListResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NotificationListResponse.fromJson(Map<String, dynamic> json) {
    return NotificationListResponse(
      success: json['success'],
      message: json['message'],
      data: NotificationListData.fromJson(json['data']),
    );
  }
}

class NotificationListData {
  final int currentPage;
  final List<NotificationItem> notifications;
  final String? firstPageUrl;
  final int? from;
  final int lastPage;
  final String? lastPageUrl;
  final String? nextPageUrl;
  final String path;
  final int perPage;
  final String? prevPageUrl;
  final int? to;
  final int total;

  NotificationListData({
    required this.currentPage,
    required this.notifications,
    this.firstPageUrl,
    this.from,
    required this.lastPage,
    this.lastPageUrl,
    this.nextPageUrl,
    required this.path,
    required this.perPage,
    this.prevPageUrl,
    this.to,
    required this.total,
  });

  factory NotificationListData.fromJson(Map<String, dynamic> json) {
    return NotificationListData(
      currentPage: json['current_page'],
      notifications: (json['data'] as List)
          .map((x) => NotificationItem.fromJson(x))
          .toList(),
      firstPageUrl: json['first_page_url'],
      from: json['from'],
      lastPage: json['last_page'],
      lastPageUrl: json['last_page_url'],
      nextPageUrl: json['next_page_url'],
      path: json['path'],
      perPage: json['per_page'],
      prevPageUrl: json['prev_page_url'],
      to: json['to'],
      total: json['total'],
    );
  }
}

class NotificationItem {
  final int id;
  final String title;
  final String date;
  final String read;
  final String detailLink;

  NotificationItem({
    required this.id,
    required this.title,
    required this.date,
    required this.read,
    required this.detailLink,
  });

  factory NotificationItem.fromJson(Map<String, dynamic> json) {
    return NotificationItem(
      id: json['id'],
      title: json['title'],
      date: json['date'],
      read: json['read'],
      detailLink: json['detail_link'],
    );
  }

  bool get isRead => read.toLowerCase() == 'yes';
}

// Notification Detail Response Models
class NotificationDetailResponse {
  final bool success;
  final String message;
  final NotificationDetail data;

  NotificationDetailResponse({
    required this.success,
    required this.message,
    required this.data,
  });

  factory NotificationDetailResponse.fromJson(Map<String, dynamic> json) {
    return NotificationDetailResponse(
      success: json['success'],
      message: json['message'],
      data: NotificationDetail.fromJson(json['data']),
    );
  }
}

class NotificationDetail {
  final int id;
  final String title;
  final String message;
  final String? joinLink;
  final String? image;
  final String author;
  final String createdAt;
  final String updatedAt;
  final String read;

  NotificationDetail({
    required this.id,
    required this.title,
    required this.message,
    this.joinLink,
    this.image,
    required this.author,
    required this.createdAt,
    required this.updatedAt,
    required this.read,
  });

  factory NotificationDetail.fromJson(Map<String, dynamic> json) {
    return NotificationDetail(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      joinLink: json['join_link'],
      image: json['image'],
      author: json['author'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      read: json['read'],
    );
  }

  bool get isRead => read.toLowerCase() == 'yes';
  bool get hasJoinLink => joinLink != null && joinLink!.isNotEmpty;
  bool get hasImage => image != null && image!.isNotEmpty;
} 