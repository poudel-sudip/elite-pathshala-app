import 'package:flutter/material.dart';
import '../../../core/models/video_models.dart';
import '../../../core/models/course_classroom.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/video_service.dart';
import 'unit_videos_page.dart';

class VideoUnitsPage extends StatefulWidget {
  final ClassroomClass classroomClass;

  const VideoUnitsPage({
    super.key,
    required this.classroomClass,
  });

  @override
  State<VideoUnitsPage> createState() => _VideoUnitsPageState();
}

class _VideoUnitsPageState extends State<VideoUnitsPage> {
  VideoUnitsData? _videoUnitsData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadVideoUnits();
  }

  Future<void> _loadVideoUnits() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final videosUrl = widget.classroomClass.links.videos;
      if (videosUrl == null || videosUrl.isEmpty) {
        setState(() {
          _errorMessage = 'No videos available for this class';
          _isLoading = false;
        });
        return;
      }

      final response = await VideoService.getVideoUnits(videosUrl);
      setState(() {
        _videoUnitsData = response.data;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceAll('Exception: ', '');
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: Scaffold(
        appBar: AppBar(
          title: Text(_videoUnitsData?.name ?? 'Video Units'),
          backgroundColor: Colors.red,
          foregroundColor: Colors.white,
        ),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadVideoUnits,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_videoUnitsData == null || _videoUnitsData!.videoUnits.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No video units available',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadVideoUnits,
      child: Column(
        children: [
          // Batch Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        _videoUnitsData!.image,
                        width: 60,
                        height: 60,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 60,
                            height: 60,
                            decoration: BoxDecoration(
                              color: Colors.grey[300],
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.image, color: Colors.grey),
                          );
                        },
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _videoUnitsData!.name,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _videoUnitsData!.course.name,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: _videoUnitsData!.status == 'Running' 
                                  ? Colors.green 
                                  : Colors.orange,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              _videoUnitsData!.status,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // Video Units List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _videoUnitsData!.videoUnits.length,
              itemBuilder: (context, index) {
                final unit = _videoUnitsData!.videoUnits[index];
                return _buildVideoUnitCard(unit);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoUnitCard(VideoUnit unit) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToUnitVideos(unit),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: Colors.red.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.play_circle_outline,
                  color: Colors.red,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      unit.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${unit.videoCount} video${unit.videoCount != 1 ? 's' : ''}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                color: Colors.grey,
                size: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToUnitVideos(VideoUnit unit) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => UnitVideosPage(
          videoUnit: unit,
          batchInfo: _videoUnitsData!,
        ),
      ),
    );
  }
} 