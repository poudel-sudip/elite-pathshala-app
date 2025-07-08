import 'package:flutter/material.dart';
import '../../../core/models/video_models.dart';
import '../../../core/utils/nepal_timezone.dart';
import '../../../shared/widgets/auth_guard.dart';
import '../services/video_service.dart';
import 'fullscreen_video_player_page.dart';

class UnitVideosPage extends StatefulWidget {
  final VideoUnit videoUnit;
  final VideoUnitsData batchInfo;

  const UnitVideosPage({
    super.key,
    required this.videoUnit,
    required this.batchInfo,
  });

  @override
  State<UnitVideosPage> createState() => _UnitVideosPageState();
}

class _UnitVideosPageState extends State<UnitVideosPage> {
  UnitVideosData? _unitData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadUnitVideos();
  }

  Future<void> _loadUnitVideos() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });

      final response = await VideoService.getUnitVideos(widget.videoUnit.videoApiLink);
      setState(() {
        _unitData = response.data;
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
          title: Text(_unitData?.batch.name ?? 'Videos'),
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
              onPressed: _loadUnitVideos,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_unitData == null || _unitData!.videoFiles.isEmpty) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.videocam_off,
              size: 64,
              color: Colors.grey,
            ),
            SizedBox(height: 16),
            Text(
              'No videos available in this unit',
              style: TextStyle(fontSize: 16, color: Colors.grey),
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: _loadUnitVideos,
      child: Column(
        children: [
          // Unit Info Header
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _unitData!.name,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${_unitData!.videoFiles.length} video${_unitData!.videoFiles.length != 1 ? 's' : ''} available',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Videos List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _unitData!.videoFiles.length,
              itemBuilder: (context, index) {
                final video = _unitData!.videoFiles[index];
                return _buildVideoCard(video, index + 1);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoCard(VideoFile video, int index) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(8),
        onTap: () => _navigateToVideoPlayer(video),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              // Video Thumbnail/Index
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: Colors.grey.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Stack(
                  children: [
                    // Thumbnail background
                    if (video.isYouTubeVideo && video.youTubeThumbnail != null)
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: Image.network(
                          video.youTubeThumbnail!,
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildDefaultThumbnail(index);
                          },
                        ),
                      )
                    else
                      _buildDefaultThumbnail(index),
                    // Play icon overlay
                    const Center(
                      child: Icon(
                        Icons.play_circle_outline,
                        color: Colors.white,
                        size: 28,
                        shadows: [
                          Shadow(
                            color: Colors.black54,
                            blurRadius: 4,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Video Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      video.videoTitle,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'By ${video.userName}',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _formatDate(video.createdAt),
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Play arrow indicator
              Icon(
                Icons.play_arrow,
                color: Colors.red,
                size: 28,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDefaultThumbnail(int index) {
    return Container(
      width: 60,
      height: 60,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Center(
        child: Text(
          index.toString(),
          style: TextStyle(
            color: Colors.grey[700],
            fontWeight: FontWeight.bold,
            fontSize: 18,
          ),
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    return NepalTimezone.formatNotificationDate(dateString);
  }

  void _navigateToVideoPlayer(VideoFile video) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayerPage(
          video: video,
          unitData: _unitData!,
        ),
      ),
    );
  }
} 