import 'package:elite_pathshala/src/features/auth/auth_service.dart';
import 'package:elite_pathshala/src/features/onboarding/presentation/onboarding_screen.dart';
import 'package:flutter/material.dart';
import '../../../core/services/api_service.dart';
import '../../../core/models/course_classroom.dart';
import '../../../core/utils/nepal_timezone.dart';
import '../../chat/presentation/chat_page.dart';
import '../../videos/presentation/video_units_page.dart';
import '../../files/presentation/file_units_page.dart';
import 'package:url_launcher/url_launcher.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CourseClassroomData? _classroomData;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadClassroomData();
  }

  Future<void> _loadClassroomData() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });
      
      final response = await ApiService.getCourseClassroom();
      final classroomResponse = CourseClassroomResponse.fromJson(response);
      
      if (classroomResponse.success) {
        setState(() {
          _classroomData = classroomResponse.data;
          _isLoading = false;
        });
      } else {
        setState(() {
          _error = classroomResponse.message;
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Failed to load data: $e';
        _isLoading = false;
      });
      
      // If authentication error, redirect to login
      if (e.toString().contains('Authentication failed')) {
        _handleAuthError();
      }
    }
  }

  void _handleAuthError() {
    // Show dialog to inform user about authentication error
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('Session Expired'),
        content: const Text('Your session has expired. Please login again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).pushNamedAndRemoveUntil(
                '/login',
                (route) => false,
              );
            },
            child: const Text('Login'),
          ),
        ],
      ),
    );
  }

  Future<void> _launchUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url));
    }
  }

  void _openChat(ClassroomClass classroomClass) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => ChatPage(
          chatUrl: classroomClass.links.chat ?? '',
          courseName: classroomClass.batch.course.name,
          batchName: classroomClass.batch.name,
          batchId: classroomClass.batchId,
        ),
      ),
    );
  }

  void _openVideos(ClassroomClass classroomClass) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => VideoUnitsPage(
          classroomClass: classroomClass,
        ),
      ),
    );
  }

  void _openFiles(ClassroomClass classroomClass) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => FileUnitsPage(
          classroomClass: classroomClass,
        ),
      ),
    );
  }

  String _getFormattedTime(Schedule schedule, String timeFormat, DateTime startTime) {
    // Always show the repeat field content first
    String repeatText = schedule.repeat ?? 'null';
    
    // If repeat is not "everyday", show full date format
    if (schedule.repeat != null && schedule.repeat!.toLowerCase() != 'everyday') {
      // Format: g:i a (12-hour with AM/PM)
      String timeOnly = timeFormat.split(' - ')[0]; // Get just the start time
      // Format: yyyy-mm-dd
      String dateOnly = '${startTime.year}-${startTime.month.toString().padLeft(2, '0')}-${startTime.day.toString().padLeft(2, '0')}';
      
      return '$timeOnly\n$dateOnly ($repeatText)';
    }
    
    // If repeat is "everyday" or null, show time with repeat value
    return '$timeFormat ($repeatText)';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        top: false, // Top safe area is handled by MainScaffold
        child: Column(
          children: [
            _buildCourseBatchesTitle(),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _error != null
                      ? Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.error_outline,
                                size: 48,
                                color: Colors.red,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Error: $_error',
                                textAlign: TextAlign.center,
                                style: const TextStyle(fontSize: 16),
                              ),
                              const SizedBox(height: 16),
                              ElevatedButton.icon(
                                onPressed: _loadClassroomData,
                                icon: const Icon(Icons.refresh),
                                label: const Text('Retry'),
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.blue,
                                  foregroundColor: Colors.white,
                                ),
                              ),
                            ],
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: _loadClassroomData,
                          color: Colors.blue,
                          child: SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8.0),
                                                            child: Column(
                                children: [
                                  const SizedBox(height: 8),
                                  ..._buildCourseCards(),
                                  const SizedBox(height: 16),
                                  _buildClassScheduleSection(),
                                  const SizedBox(height: 20), // Extra bottom padding
                                ],
                              ),
                            ),
                          ),
                        ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCourseBatchesTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 8),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'My Course Batches',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  List<Widget> _buildCourseCards() {
    if (_classroomData == null || _classroomData!.classes.isEmpty) {
      return [
        const Center(
          child: Text(
            'No courses available',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        ),
      ];
    }

    return _classroomData!.classes.map((classroomClass) {
      return Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.black87),
          borderRadius: BorderRadius.circular(8),
          color: Colors.white,
        ),
        child: Column(
          children: [
            // Danger alert for suspended accounts
            if (classroomClass.suspendText != null && classroomClass.suspendText!.isNotEmpty)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.red.shade50,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(7),
                    topRight: Radius.circular(7),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: Colors.red.shade700,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        classroomClass.suspendText!,
                        style: TextStyle(
                          color: Colors.red.shade700,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            // Main course content
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Course details
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          classroomClass.batch.course.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Colors.green,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          classroomClass.batch.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.blue,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  // Right column - Action buttons
                  Expanded(
                    flex: 1,
                    child: Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      alignment: WrapAlignment.end,
                      children: _buildActionButtons(classroomClass.links, classroomClass),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }).toList();
  }

  List<Widget> _buildActionButtons(ClassroomLinks links, ClassroomClass classroomClass) {
    List<Widget> buttons = [];

    // Chat button first
    if (links.chat != null && links.chat!.isNotEmpty) {
      buttons.add(_buildFileButton('Chats', Colors.orange, () => _openChat(classroomClass)));
    }

    if (links.videos != null && links.videos!.isNotEmpty) {
      buttons.add(_buildFileButton('Videos', Colors.red, () => _openVideos(classroomClass)));
    }

    if (links.files != null && links.files!.isNotEmpty) {
      buttons.add(_buildFileButton('Files', Colors.green, () => _openFiles(classroomClass)));
    }

    if (links.mcqExams != null && links.mcqExams!.isNotEmpty) {
      buttons.add(_buildFileButton('MCQ Exams', Colors.blue, () => _launchUrl(links.mcqExams!)));
    }

    if (links.writtenExams != null && links.writtenExams!.isNotEmpty) {
      buttons.add(_buildFileButton('Written Exams', Colors.purple, () => _launchUrl(links.writtenExams!)));
    }

    return buttons;
  }

  Widget _buildFileButton(String label, Color color, [VoidCallback? onPressed]) {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
        elevation: 0,
        minimumSize: const Size(0, 28),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      onPressed: onPressed,
      child: Text(label),
    );
  }

  Widget _buildClassScheduleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black,
            borderRadius: BorderRadius.circular(4),
          ),
          child: const Center(
            child: Text(
              'My Class Schedules',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 24,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        if (_classroomData != null && _classroomData!.schedules.isNotEmpty)
          ..._classroomData!.schedules.map((schedule) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _buildClassCard(schedule),
              ))
        else
          const Center(
            child: Padding(
              padding: EdgeInsets.all(16.0),
              child: Text(
                'No class schedules available',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildClassCard(Schedule schedule) {
    final startTime = DateTime.parse(schedule.startAt.replaceAll(' ', 'T'));
    final endTime = DateTime.parse(schedule.endAt.replaceAll(' ', 'T'));
    
    // Format time in 12-hour format with AM/PM using Nepal timezone
    String formatTime12Hour(DateTime time) {
      return NepalTimezone.formatScheduleTime(time);
    }
    
    final timeFormat = '${formatTime12Hour(startTime)} - ${formatTime12Hour(endTime)}';
    
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 2),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: Colors.black26),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Content section - 60% width
          Expanded(
            flex: 3,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  schedule.className,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
                const SizedBox(height: 4),
                // Always show topic - display whatever is fetched
                Text(
                  schedule.topic,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.blue,
                  ),
                ),
                const SizedBox(height: 4),
                // Always show tutor - display whatever is fetched
                Text(
                  'By ${schedule.tutor}',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
                const SizedBox(height: 4),
                // Show time based on repeat value
                Text(
                  _getFormattedTime(schedule, timeFormat, startTime),
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                const SizedBox(height: 2),
                Text(
                  'Duration: ${schedule.duration} ${schedule.durationType}',
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          // Buttons section - 40% width
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (schedule.liveLink != null && schedule.liveLink!.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(bottom: 4),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                        elevation: 0,
                        minimumSize: const Size(0, 28),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      onPressed: () => _launchUrl(schedule.liveLink!),
                      child: const Text('Join Live'),
                    ),
                  ),
                if (schedule.classLink != null && schedule.classLink!.isNotEmpty)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11),
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                      elevation: 0,
                      minimumSize: const Size(0, 28),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    onPressed: () => _launchUrl(schedule.classLink!),
                    child: const Text('Join Class'),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
} 