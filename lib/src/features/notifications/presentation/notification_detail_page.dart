import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/notification_models.dart';
import '../../../core/utils/nepal_timezone.dart';
import '../../../shared/widgets/auth_guard.dart';

class NotificationDetailPage extends StatefulWidget {
  final int notificationId;
  final String title;

  const NotificationDetailPage({
    super.key,
    required this.notificationId,
    required this.title,
  });

  @override
  State<NotificationDetailPage> createState() => _NotificationDetailPageState();
}

class _NotificationDetailPageState extends State<NotificationDetailPage> {
  NotificationDetail? _notification;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadNotificationDetail();
  }

  Future<void> _loadNotificationDetail() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await ApiService.getNotificationDetail(widget.notificationId);
      
      if (response['success'] == true) {
        final notificationResponse = NotificationDetailResponse.fromJson(response);
        setState(() {
          _notification = notificationResponse.data;
          _isLoading = false;
        });
      } else {
        throw Exception(response['message'] ?? 'Failed to load notification detail');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _launchJoinLink() async {
    if (_notification?.hasJoinLink == true) {
      try {
      final url = Uri.parse(_notification!.joinLink!);
      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
          throw Exception('Could not open join link');
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to open link: ${e.toString()}'),
              backgroundColor: Colors.red,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
      }
    }
  }

  String _formatDate(String dateString) {
    return NepalTimezone.formatNotificationDetailDate(dateString);
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Notification Details',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
          ),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
          elevation: 2,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              color: Colors.red,
            ),
            SizedBox(height: 16),
            Text(
              'Loading notification...',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                Icons.error_outline,
                size: 64,
                  color: Colors.red.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load notification',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _loadNotificationDetail,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_notification == null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey.shade100,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.notifications_off_outlined,
                  size: 64,
                  color: Colors.grey.shade400,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Notification not found',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey.shade800,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadNotificationDetail,
      color: Colors.blue,
      backgroundColor: Colors.white,
      strokeWidth: 2.5,
      displacement: 40,
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
                    // Unified Content Container
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title
          Text(
            _notification!.title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
                    color: Colors.black87,
                    height: 1.3,
            ),
          ),
                const SizedBox(height: 16),
          
                // Author and Date (separate lines)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          Row(
            children: [
              Icon(
                            Icons.person_outline,
                size: 16,
                            color: Colors.grey.shade600,
              ),
                          const SizedBox(width: 6),
              Text(
                            _notification!.author,
                style: TextStyle(
                  fontSize: 14,
                              color: Colors.grey.shade700,
                              fontWeight: FontWeight.w500,
                ),
                          ),
                        ],
              ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
              Icon(
                Icons.access_time,
                size: 16,
                            color: Colors.grey.shade600,
              ),
                          const SizedBox(width: 6),
                          Text(
                  _formatDate(_notification!.createdAt),
                  style: TextStyle(
                    fontSize: 14,
                              color: Colors.grey.shade700,
                ),
              ),
            ],
          ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                
                // Body Content Container
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade200),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
          // Image (if present)
          if (_notification!.hasImage) ...[
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
                          child: Container(
                            width: double.infinity,
                            constraints: const BoxConstraints(
                              maxWidth: double.infinity,
                            ),
              child: Image.network(
                _notification!.image!,
                width: double.infinity,
                              fit: BoxFit.fitWidth,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                  return Container(
                                  width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                      borderRadius: BorderRadius.circular(8),
                    ),
                                  child: Center(
                                    child: CircularProgressIndicator(
                                      value: loadingProgress.expectedTotalBytes != null
                                          ? loadingProgress.cumulativeBytesLoaded /
                                              loadingProgress.expectedTotalBytes!
                                          : null,
                                      color: Colors.red,
                      ),
                    ),
                  );
                },
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  width: double.infinity,
                                  height: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.grey.shade200,
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.image_not_supported_outlined,
                                        size: 48,
                                        color: Colors.grey.shade400,
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        'Failed to load image',
                                        style: TextStyle(
                                          color: Colors.grey.shade600,
                                          fontSize: 14,
                                        ),
                                      ),
                                    ],
                                  ),
                                );
                              },
                            ),
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Message Content
                      Text(
              _notification!.message,
              style: const TextStyle(
                fontSize: 16,
                          height: 1.6,
                          color: Colors.black87,
            ),
          ),
          
          // Join Button (if join link is present)
                  if (_notification!.hasJoinLink) ...[
                    const SizedBox(height: 20),
                    Align(
                      alignment: Alignment.centerLeft,
                      child: ElevatedButton.icon(
                onPressed: _launchJoinLink,
                        icon: const Icon(Icons.open_in_new, size: 16),
                        label: const Text(
                          'Join Now',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                          elevation: 2,
                ),
              ),
            ),
        ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Bottom padding
          const SizedBox(height: 20),
        ],
        ),
      ),
    );
  }
} 