import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../core/models/orientation_models.dart';
import '../../../core/utils/nepal_timezone.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/orientation_service.dart';

class OrientationsPage extends StatefulWidget {
  const OrientationsPage({super.key});

  @override
  State<OrientationsPage> createState() => _OrientationsPageState();
}

class _OrientationsPageState extends State<OrientationsPage> {
  List<OrientationItem> _orientations = [];
  bool _isLoading = true;
  String? _errorMessage;
  final Map<int, bool> _joiningStates = {};

  @override
  void initState() {
    super.initState();
    _loadOrientations();
  }

  Future<void> _loadOrientations() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await OrientationService.getOrientations();
      
      if (response.success) {
        setState(() {
          _orientations = response.data;
          _isLoading = false;
        });
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  Future<void> _joinOrientation(OrientationItem orientation) async {
    try {
      setState(() {
        _joiningStates[orientation.id] = true;
      });

      final response = await OrientationService.joinOrientation(orientation.joinLink);
      
      if (response.success) {
        // Show success message
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(response.message),
              backgroundColor: Colors.green,
              behavior: SnackBarBehavior.floating,
            ),
          );
        }

        // Launch the class link
        await _launchClassLink(response.data.classLink);
      } else {
        throw Exception(response.message);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to join orientation: ${e.toString().replaceFirst('Exception: ', '')}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _joiningStates[orientation.id] = false;
        });
      }
    }
  }

  Future<void> _launchClassLink(String url) async {
    try {
      final uri = Uri.parse(url);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Could not open class link');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to open class link: ${e.toString()}'),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  String _formatDateTime(String dateTimeString) {
    return NepalTimezone.formatNotificationDate(dateTimeString);
  }

  String _formatStartTime(String dateTimeString) {
    try {
      final dateTime = DateTime.parse(dateTimeString);
      final hour = dateTime.hour;
      final minute = dateTime.minute;
      
      // Convert to 12-hour format
      String period = hour >= 12 ? 'PM' : 'AM';
      int displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
      
      // Format: "Jan 15 02:30 PM"
      final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 
                     'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
      final monthName = months[dateTime.month - 1];
      
      return '${monthName} ${dateTime.day}, ${displayHour.toString().padLeft(2, '0')}:${minute.toString().padLeft(2, '0')} $period';
    } catch (e) {
      return dateTimeString; // fallback to original string if parsing fails
    }
  }

  bool _canJoinOrientation(OrientationItem orientation) {
    try {
      final now = DateTime.now();
      final startTime = DateTime.parse(orientation.startAt);
      final endTime = DateTime.parse(orientation.endAt);
      
      // Allow joining 30 minutes before start time and 30 minutes after end time
      final joinStartTime = startTime.subtract(const Duration(minutes: 30));
      final joinEndTime = endTime.add(const Duration(minutes: 30));
      
      // Check if current time is within join window
      return now.isAfter(joinStartTime) && now.isBefore(joinEndTime);
    } catch (e) {
      // If there's an error parsing dates, don't show join button
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
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
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text(
              'Loading orientations...',
              style: TextStyle(fontSize: 16),
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
              const Icon(
                Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load orientations',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.grey, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadOrientations,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_orientations.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.school_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No orientations available',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.grey,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Check back later for new orientation classes',
              style: TextStyle(color: Colors.grey, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
    
    return RefreshIndicator(
      onRefresh: _loadOrientations,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _orientations.length + 1,
        itemBuilder: (context, index) {
          if (index == 0) {
            return _buildOrientationsTitle();
          }
          final orientation = _orientations[index - 1];
          return _buildOrientationCard(orientation);
        },
      ),
    );
  }

  Widget _buildOrientationsTitle() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.green,
        borderRadius: BorderRadius.circular(4),
      ),
      child: const Center(
        child: Text(
          'Free Classes & Orientations',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildOrientationCard(OrientationItem orientation) {
    final isJoining = _joiningStates[orientation.id] ?? false;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header with class name and topic
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Class image - 40% width
                Expanded(
                  flex: 40,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image.network(
                        orientation.image,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.school,
                              color: Colors.grey,
                              size: 40,
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Class details - 60% width
                Expanded(
                  flex: 60,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        orientation.className,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        orientation.topic,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.blue,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'By ${orientation.tutor}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.grey,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Duration: ${orientation.duration} ${orientation.durationType}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'Start: ${_formatStartTime(orientation.startAt)}',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            
            // Only show spacing and join button if within join window
            if (_canJoinOrientation(orientation)) ...[
              const SizedBox(height: 16),
              
              // Join button - only show if within join window
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isJoining ? null : () => _joinOrientation(orientation),
                  icon: isJoining
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.play_arrow, size: 20),
                  label: Text(
                    isJoining ? 'Joining...' : 'Join Orientation',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
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
    );
  }


} 