import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';

import '../../data/models/post_model.dart';

class PostCard extends StatefulWidget {
  final PostModel post;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PostCard({
    super.key,
    required this.post,
    this.onTap,
    this.onEdit,
    this.onDelete,
  });

  @override
  State<PostCard> createState() => _PostCardState();
}

class _PostCardState extends State<PostCard> {
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  late bool _isCurrentUser;
  final Map<int, VideoPlayerController> _videoControllers = {};
  final Map<int, ChewieController> _chewieControllers = {};

  @override
  void initState() {
    super.initState();

    _checkIfCurrentUser();
    _initializeVideos();
  }

  Future<void> _checkIfCurrentUser() async {
    if (widget.post.user.id == 3) {
      _isCurrentUser = true;
    } else {
      _isCurrentUser = false;
    }
  }

  void _initializeVideos() {
    for (final media in widget.post.media) {
      if (media.mediaType == 'video') {
        _initializeVideoPlayer(media);
      }
    }
  }

  void _initializeVideoPlayer(Media media) async {
    try {
      final videoController = VideoPlayerController.network(media.url);
      await videoController.initialize();

      final chewieController = ChewieController(
        videoPlayerController: videoController,
        autoPlay: false,
        looping: false,
        showControls: true,
        materialProgressColors: ChewieProgressColors(
          playedColor: Colors.blue,
          handleColor: Colors.blue,
          backgroundColor: Colors.grey,
          bufferedColor: Colors.grey.shade400,
        ),
        placeholder: Container(
          color: Colors.grey[300],
          child: const Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.videocam, size: 40, color: Colors.grey),
              SizedBox(height: 8),
              Text('Loading video...', style: TextStyle(color: Colors.grey)),
            ],
          ),
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
            color: Colors.grey[300],
            child: const Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 40, color: Colors.red),
                SizedBox(height: 8),
                Text(
                  'Failed to load video',
                  style: TextStyle(color: Colors.red),
                ),
              ],
            ),
          );
        },
      );

      setState(() {
        _videoControllers[media.id] = videoController;
        _chewieControllers[media.id] = chewieController;
      });
    } catch (e) {
      print('Error initializing video player for ${media.url}: $e');
    }
  }

  @override
  void dispose() {
    // تنظيف جميع controllers
    for (final controller in _videoControllers.values) {
      controller.dispose();
    }
    for (final controller in _chewieControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      elevation: 2,
      child: InkWell(
        onTap: widget.onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // رأس المنشور
              Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: Colors.blue,
                    child: Text(
                      widget.post.user.name.isNotEmpty
                          ? widget.post.user.name[0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.post.user.name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatDate(widget.post.createdAt),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_isCurrentUser)
                    PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'edit') {
                          widget.onEdit?.call();
                        } else if (value == 'delete') {
                          widget.onDelete?.call();
                        }
                      },
                      itemBuilder: (BuildContext context) => [
                        const PopupMenuItem<String>(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 20),
                              SizedBox(width: 8),
                              Text('Edit'),
                            ],
                          ),
                        ),
                        const PopupMenuItem<String>(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(Icons.delete, color: Colors.red, size: 20),
                              SizedBox(width: 8),
                              Text('Delete'),
                            ],
                          ),
                        ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),

              // عنوان المنشور
              if (widget.post.title.isNotEmpty)
                Text(
                  widget.post.title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                  ),
                ),

              if (widget.post.title.isNotEmpty) const SizedBox(height: 8),

              // محتوى المنشور
              Text(
                widget.post.content,
                style: const TextStyle(fontSize: 14),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),

              const SizedBox(height: 12),

              // الوسائط
              if (widget.post.media.isNotEmpty) _buildMediaGrid(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMediaGrid() {
    // عرض جميع الوسائط (صور وفيديوهات)
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        childAspectRatio: 1,
      ),
      itemCount: widget.post.media.length,
      itemBuilder: (context, index) {
        final media = widget.post.media[index];
        return _buildMediaWidget(media);
      },
    );
  }

  int _getCrossAxisCount() {
    final mediaCount = widget.post.media.length;
    if (mediaCount == 1) return 1;
    if (mediaCount == 2) return 2;
    return 3;
  }

  Widget _buildMediaWidget(Media media) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            // بناء الـ widget المناسب حسب نوع الوسائط
            if (media.mediaType == 'image')
              _buildImageWidget(media)
            else if (media.mediaType == 'video')
              _buildVideoWidget(media)
            else
              _buildUnknownMediaWidget(media),

            // شارة نوع الوسائط
            Positioned(
              top: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  media.mediaType.toUpperCase(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            // زر التشغيل للفيديوهات
            if (media.mediaType == 'video')
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                bottom: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.play_arrow,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWidget(Media media) {
    return CachedNetworkImage(
      imageUrl: media.url,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      placeholder: (context, url) => _buildPlaceholder('Image'),
      errorWidget: (context, url, error) {
        return _buildNetworkImageWithErrorHandling(media.url, 'Image');
      },
    );
  }

  Widget _buildVideoWidget(Media media) {
    final chewieController = _chewieControllers[media.id];

    if (chewieController != null) {
      return Chewie(controller: chewieController);
    } else {
      return _buildPlaceholder('Video');
    }
  }

  Widget _buildUnknownMediaWidget(Media media) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.help_outline, size: 40, color: Colors.grey),
          const SizedBox(height: 8),
          Text(
            'Unknown Type',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
          Text(
            media.mediaType,
            style: const TextStyle(color: Colors.grey, fontSize: 10),
          ),
        ],
      ),
    );
  }

  Widget _buildNetworkImageWithErrorHandling(String imageUrl, String type) {
    return Image.network(
      imageUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return _buildPlaceholder(type);
      },
      errorBuilder: (context, error, stackTrace) {
        return _buildErrorWidget(type);
      },
    );
  }

  Widget _buildPlaceholder(String type) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            type == 'Video' ? Icons.videocam : Icons.image,
            color: Colors.grey,
            size: 40,
          ),
          const SizedBox(height: 8),
          Text(
            'Loading $type...',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(String type) {
    return Container(
      color: Colors.grey[200],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, color: Colors.grey, size: 40),
          const SizedBox(height: 8),
          Text(
            'Failed to load $type',
            style: const TextStyle(color: Colors.grey, fontSize: 12),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${date.day}/${date.month}/${date.year}';
  }
}
