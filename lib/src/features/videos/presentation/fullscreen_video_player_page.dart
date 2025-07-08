import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import 'package:chewie/chewie.dart';
import '../../../core/models/video_models.dart';
import '../../../core/utils/nepal_timezone.dart';
import '../../../shared/widgets/auth_guard.dart';

class FullscreenVideoPlayerPage extends StatefulWidget {
  final VideoFile video;
  final UnitVideosData unitData;

  const FullscreenVideoPlayerPage({
    super.key,
    required this.video,
    required this.unitData,
  });

  @override
  State<FullscreenVideoPlayerPage> createState() => _FullscreenVideoPlayerPageState();
}

class _FullscreenVideoPlayerPageState extends State<FullscreenVideoPlayerPage> {
  YoutubePlayerController? _youtubeController;
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitializing = true;
  String? _errorMessage;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isInitializing = true;
        _errorMessage = null;
      });

      final youTubeVideoId = widget.video.youTubeVideoId;
      
      if (widget.video.isYouTubeVideo && youTubeVideoId != null && youTubeVideoId.isNotEmpty) {
        _initializeYouTubePlayer(youTubeVideoId);
      } else {
        await _initializeDirectVideoPlayer(widget.video.videoPath);
      }

      setState(() {
        _isInitializing = false;
      });
    } catch (e) {
      setState(() {
        _isInitializing = false;
        _errorMessage = 'Failed to load video: ${e.toString()}';
      });
    }
  }

  void _initializeYouTubePlayer(String videoId) {
    try {
      // Dispose existing controller if any
      _youtubeController?.dispose();
      
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
          enableCaption: true,
          captionLanguage: 'en',
          showLiveFullscreenButton: true,
          controlsVisibleAtStart: true,
          hideControls: false,
          hideThumbnail: false,
          disableDragSeek: false,
          useHybridComposition: true, // Better for iOS
        ),
      );

      _youtubeController!.addListener(_youTubeListener);
    } catch (e) {
      throw Exception('YouTube player initialization failed: $e');
    }
  }

  void _youTubeListener() {
    if (_youtubeController != null && mounted) {
      if (_youtubeController!.value.isFullScreen != _isFullscreen) {
        setState(() {
          _isFullscreen = _youtubeController!.value.isFullScreen;
        });
      }
    }
  }

  Future<void> _initializeDirectVideoPlayer(String videoUrl) async {
    try {
      // Dispose existing controllers if any
      _chewieController?.dispose();
      _videoController?.dispose();
      
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      await _videoController!.initialize();
      
      if (!mounted) return;
      
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        aspectRatio: _videoController!.value.aspectRatio,
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.redAccent,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.lightBlue,
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.black,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Video playback error',
                    style: TextStyle(color: Colors.white, fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    errorMessage,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      );
    } catch (e) {
      throw Exception('Direct video player initialization failed: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return AuthGuard(
      child: widget.video.isYouTubeVideo && _youtubeController != null
          ? YoutubePlayerBuilder(
              player: YoutubePlayer(controller: _youtubeController!),
              builder: (context, player) {
                return Scaffold(
                  backgroundColor: Colors.black,
                  appBar: _isFullscreen ? null : AppBar(
                    backgroundColor: Colors.black,
                    foregroundColor: Colors.white,
                    title: Text(
                      widget.video.videoTitle,
                      style: const TextStyle(fontSize: 16),
                    ),
                    elevation: 0,
                  ),
                  body: _buildBody(player),
                );
              },
            )
          : Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                title: Text(
                  widget.video.videoTitle,
                  style: const TextStyle(fontSize: 16),
                ),
                elevation: 0,
              ),
              body: _buildBody(null),
            ),
    );
  }

  Widget _buildBody(Widget? youtubePlayer) {
    if (_isInitializing) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 16),
            Text(
              'Loading video...',
              style: TextStyle(color: Colors.white, fontSize: 16),
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
                color: Colors.white,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load video',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _errorMessage!,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      children: [
        // Video Player
        Expanded(
          child: Center(
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                color: Colors.black,
                child: widget.video.isYouTubeVideo
                    ? youtubePlayer ?? const SizedBox.shrink()
                    : (_chewieController != null
                        ? Chewie(controller: _chewieController!)
                        : const Center(
                            child: CircularProgressIndicator(color: Colors.white),
                          )),
              ),
            ),
          ),
        ),
        
        // Video Info (only show when not in fullscreen)
        if (!_isFullscreen)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            color: Colors.black,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.video.videoTitle,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'By ${widget.video.userName}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _formatDate(widget.video.createdAt),
                  style: const TextStyle(
                    color: Colors.white54,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Unit: ${widget.unitData.name}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Batch: ${widget.unitData.batch.name}',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  String _formatDate(String dateString) {
    return NepalTimezone.formatVideoDetailDate(dateString);
  }

  @override
  void dispose() {
    // Remove listeners before disposing
    if (_youtubeController != null) {
      _youtubeController!.removeListener(_youTubeListener);
      _youtubeController!.dispose();
    }
    _chewieController?.dispose();
    _videoController?.dispose();
    // Reset system UI
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }
} 