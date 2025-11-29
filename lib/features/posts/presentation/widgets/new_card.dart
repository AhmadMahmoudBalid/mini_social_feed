import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:mini_social_feed/features/posts/data/models/post_model.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:path/path.dart' as path;

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class PostNewCard extends StatelessWidget {
  final PostModel post;
  final bool isSowdelet;
  final VoidCallback? onDeletePressed;
  const PostNewCard({
    Key? key,
    required this.post,
    required this.isSowdelet,
    this.onDeletePressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(),
            const SizedBox(height: 12),

            if (post.title.isNotEmpty)
              Text(
                post.title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            if (post.title.isNotEmpty) const SizedBox(height: 8),

            if (post.content.isNotEmpty)
              Text(
                post.content,
                style: const TextStyle(fontSize: 15, height: 1.5),
              ),
            if ((post.content.isNotEmpty || post.title.isNotEmpty) &&
                post.media.isNotEmpty)
              const SizedBox(height: 12),

            if (post.media.isNotEmpty) _buildMediaSection(context),

            const SizedBox(height: 12),
            Text(
              _formatDate(post.createdAt),
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  // ====================== Header ======================
  Widget _buildHeader() {
    return Row(
      children: [
        CircleAvatar(
          radius: 22,
          backgroundColor: Colors.grey.shade300,
          child: Text(
            post.user.name.isNotEmpty ? post.user.name[0].toUpperCase() : '?',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                post.user.name,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '@${post.user.email.split('@').first}',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 13),
              ),
            ],
          ),
        ),
        isSowdelet
            ? IconButton(
                onPressed: onDeletePressed,
                icon: Icon(Icons.delete, color: Colors.red.shade700),
              )
            : SizedBox(width: 0),
      ],
    );
  }

  // ====================== Media Section ======================
  Widget _buildMediaSection(BuildContext context) {
    final images = post.media.where((m) => m.mediaType == 'image').toList();
    final videos = post.media.where((m) => m.mediaType == 'video').toList();
    final audios = post.media.where((m) => m.mediaType == 'audio').toList();
    final documents = post.media
        .where(
          (m) =>
              m.mediaType == 'document' ||
              !['image', 'video', 'audio'].contains(m.mediaType),
        )
        .toList();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (images.isNotEmpty) ...[
          _buildImagesGallery(context, images),
          const SizedBox(height: 12),
        ],
        if (videos.isNotEmpty) ...[
          _buildVideosList(videos),
          const SizedBox(height: 12),
        ],
        if (audios.isNotEmpty) ...[
          _buildAudiosList(audios),
          const SizedBox(height: 12),
        ],
        if (documents.isNotEmpty) _buildDocumentsList(context, documents),
      ],
    );
  }

  // ====================== Images ======================
  Widget _buildImagesGallery(BuildContext context, List<Media> images) {
    if (images.length == 1) {
      return _buildSingleImage(context, images.first.url);
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: images.length,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: GestureDetector(
                onTap: () => _openFullScreenGallery(context, images, index),
                child: CachedNetworkImage(
                  imageUrl: images[index].url,
                  width: 220,
                  height: 220,
                  fit: BoxFit.cover,
                  placeholder: (_, __) => Container(color: Colors.grey[300]),
                  errorWidget: (_, __, ___) => const Icon(Icons.error),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildSingleImage(BuildContext context, String url) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: GestureDetector(
        onTap: () => _openFullScreenGallery(context, [
          Media(id: -1, mediaType: 'image', url: url, filePath: ''),
        ], 0),
        child: CachedNetworkImage(
          imageUrl: url,
          width: double.infinity,
          height: 300,
          fit: BoxFit.cover,
          placeholder: (_, __) =>
              const Center(child: CircularProgressIndicator()),
          errorWidget: (_, __, ___) => const Icon(Icons.error, size: 60),
        ),
      ),
    );
  }

  void _openFullScreenGallery(
    BuildContext context,
    List<Media> images,
    int initialIndex,
  ) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            FullScreenGallery(images: images, initialIndex: initialIndex),
      ),
    );
  }

  // ====================== Videos ======================
  Widget _buildVideosList(List<Media> videos) {
    return Column(
      children: videos.map((video) {
        final fileName = path.basename(video.filePath);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (videos.length > 1)
                Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                ),
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: VideoPlayerWidget(videoUrl: video.url),
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  // ====================== Audios ======================
  Widget _buildAudiosList(List<Media> audios) {
    return Column(
      children: audios.map((audio) {
        final fileName = path.basename(audio.filePath);
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  AudioPlayerWidget(audioUrl: audio.url),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ====================== Documents ======================
  Widget _buildDocumentsList(BuildContext context, List<Media> documents) {
    return Column(
      children: documents.map((doc) {
        final ext = doc.extension.replaceAll('.', '').toLowerCase();
        final icon = _getFileIcon(ext);
        final color = _getFileColor(ext);
        final fileName = path.basename(doc.filePath);

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            borderRadius: BorderRadius.circular(12),
            onTap: () => _openFile(context, doc.url),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Icon(icon, size: 42, color: color),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          fileName,
                          style: const TextStyle(fontWeight: FontWeight.w500),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          '$ext • ملف',
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const Icon(Icons.download_rounded, color: Colors.grey),
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  // ====================== Helpers ======================
  IconData _getFileIcon(String ext) {
    switch (ext) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Icons.table_chart;
      case 'ppt':
      case 'pptx':
        return Icons.present_to_all;
      default:
        return Icons.insert_drive_file;
    }
  }

  Color _getFileColor(String ext) {
    switch (ext) {
      case 'pdf':
        return Colors.red.shade700;
      case 'doc':
      case 'docx':
        return Colors.blue.shade700;
      case 'xls':
      case 'xlsx':
      case 'csv':
        return Colors.green.shade700;
      case 'ppt':
      case 'pptx':
        return Colors.orange.shade700;
      default:
        return Colors.grey.shade700;
    }
  }

  void _openFile(BuildContext context, String url) async {
    // عرض تحميل
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('جاري تحميل الملف...'),
        duration: Duration(seconds: 10),
      ),
    );

    try {
      final dio = Dio();

      // مكان حفظ الملف مؤقتًا
      final tempDir = await getTemporaryDirectory();
      final fileName = url.split('/').last;
      final filePath = '${tempDir.path}/$fileName';

      // تحميل الملف
      await dio.download(
        url,
        filePath,
        options: Options(
          receiveTimeout: const Duration(seconds: 60),
          sendTimeout: const Duration(seconds: 60),
        ),
      );

      // إخفاء الـ SnackBar
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      // فتح الملف
      final result = await OpenFilex.open(filePath);

      if (result.type != ResultType.done) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('فشل فتح الملف: ${result.message}')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('فشل تحميل الملف: $e')));
    }
  }

  String _formatDate(DateTime date) {
    final diff = DateTime.now().difference(date);
    if (diff.inDays >= 1) return '${diff.inDays} يوم مضت';
    if (diff.inHours >= 1) return '${diff.inHours} ساعة مضت';
    if (diff.inMinutes >= 1) return '${diff.inMinutes} دقيقة مضت';
    return 'الآن';
  }
}

// ====================== Full Screen Gallery ======================
class FullScreenGallery extends StatefulWidget {
  final List<Media> images;
  final int initialIndex;
  const FullScreenGallery({
    Key? key,
    required this.images,
    required this.initialIndex,
  }) : super(key: key);

  @override
  State<FullScreenGallery> createState() => _FullScreenGalleryState();
}

class _FullScreenGalleryState extends State<FullScreenGallery> {
  late final PageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(backgroundColor: Colors.transparent),
      body: PageView.builder(
        controller: _controller,
        itemCount: widget.images.length,
        itemBuilder: (_, index) {
          return InteractiveViewer(
            child: Center(
              child: CachedNetworkImage(
                imageUrl: widget.images[index].url,
                fit: BoxFit.contain,
                placeholder: (_, __) =>
                    const CircularProgressIndicator(color: Colors.white),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

// ضع الـ VideoPlayerWidget و AudioPlayerWidget هنا أو في ملف منفصل (نفس  اللي عندك قبل كان ممتاز وما فيه أي خطأ)// ====================== Video Player Widget (مهم جدًا!) ======================
class VideoPlayerWidget extends StatefulWidget {
  final String videoUrl;
  const VideoPlayerWidget({Key? key, required this.videoUrl}) : super(key: key);

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  late VideoPlayerController _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // تأكد أن الرابط HTTPS أو localhost موثوق
      final url = widget.videoUrl;
      if (!url.startsWith('http')) return;

      _videoController = VideoPlayerController.networkUrl(Uri.parse(url));

      await _videoController.initialize();

      if (!mounted) return;

      _chewieController = ChewieController(
        videoPlayerController: _videoController,
        autoPlay: false,
        looping: false,
        allowFullScreen: true,
        allowMuting: true,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.red,
          handleColor: Colors.red,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.white30,
        ),
        placeholder: Container(
          color: Colors.black,
          child: const Center(
            child: CircularProgressIndicator(color: Colors.white),
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error, color: Colors.white, size: 60),
                const SizedBox(height: 16),
                Text(
                  'فشل تحميل الفيديو',
                  style: const TextStyle(color: Colors.white),
                ),
                TextButton(
                  onPressed: () => setState(() => _initializePlayer()),
                  child: const Text(
                    'إعادة المحاولة',
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          );
        },
      );

      setState(() => _isInitialized = true);
    } catch (e) {
      if (mounted) {
        setState(() => _error = e.toString());
      }
      debugPrint('Video Player Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 60),
              const SizedBox(height: 10),
              Text(
                'خطأ: فشل تحميل الفيديو',
                style: TextStyle(color: Colors.white),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    _error = null;
                    _isInitialized = false;
                  });
                  _initializePlayer();
                },
                child: Text(
                  'إعادة المحاولة',
                  style: TextStyle(color: Colors.white),
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
      return Container(
        height: 200,
        decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Center(
          child: CircularProgressIndicator(color: Colors.white),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(12),
      child: AspectRatio(
        aspectRatio: _videoController.value.aspectRatio,
        child: Chewie(controller: _chewieController!),
      ),
    );
  }

  @override
  void dispose() {
    _videoController.dispose();
    _chewieController?.dispose();
    super.dispose();
  }
}

// ====================== Audio Player Widget (مهم جدًا!) ======================
class AudioPlayerWidget extends StatefulWidget {
  final String audioUrl;
  const AudioPlayerWidget({Key? key, required this.audioUrl}) : super(key: key);

  @override
  State<AudioPlayerWidget> createState() => _AudioPlayerWidgetState();
}

class _AudioPlayerWidgetState extends State<AudioPlayerWidget> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  Duration duration = Duration.zero;
  Duration position = Duration.zero;

  @override
  void initState() {
    super.initState();

    // تحميل الصوت
    _audioPlayer.setSourceUrl(widget.audioUrl);

    // تحديث المدة
    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => duration = d);
    });

    // تحديث الموضع
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => position = p);
    });

    // حالة التشغيل
    _audioPlayer.onPlayerStateChanged.listen((state) {
      if (mounted) setState(() => isPlaying = state == PlayerState.playing);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          IconButton(
            icon: Icon(isPlaying ? Icons.pause_circle : Icons.play_circle),
            iconSize: 40,
            onPressed: () {
              isPlaying ? _audioPlayer.pause() : _audioPlayer.resume();
            },
          ),
          Expanded(
            child: Slider(
              min: 0,
              max: duration.inSeconds.toDouble() > 0
                  ? duration.inSeconds.toDouble()
                  : 1,
              value: position.inSeconds.toDouble().clamp(
                0,
                duration.inSeconds.toDouble(),
              ),
              onChanged: (value) {
                final newPosition = Duration(seconds: value.toInt());
                _audioPlayer.seek(newPosition);
              },
            ),
          ),
          Text(
            '${position.inMinutes}:${(position.inSeconds % 60).toString().padLeft(2, '0')}',
            style: const TextStyle(fontSize: 12),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }
}
