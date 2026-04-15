import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import '../../../../constants/colors.dart';
import '../../../../utils/validators.dart';

class VideoSection extends StatefulWidget {
  final Function(String?) onVideoAdded;
  final String? initialVideoUrl;

  const VideoSection({
    super.key,
    required this.onVideoAdded,
    this.initialVideoUrl,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  final TextEditingController _videoUrlController = TextEditingController();
  String? _videoUrl;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialVideoUrl != null) {
      _videoUrl = widget.initialVideoUrl;
      _videoUrlController.text = widget.initialVideoUrl!;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(Iconsax.video, size: 18, color: AppColors.primary),
            const SizedBox(width: 8),
            Text(
              'Property Video (Optional)',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Add a YouTube or Vimeo link to showcase your property',
          style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
        ),
        const SizedBox(height: 16),
        
        // Video URL Input
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _errorMessage != null
                  ? AppColors.error
                  : AppColors.greyLight,
            ),
          ),
          child: TextField(
            controller: _videoUrlController,
            onChanged: (value) {
              setState(() {
                _errorMessage = VideoValidator.validateVideoUrl(value);
                if (_errorMessage == null) {
                  _videoUrl = value.isNotEmpty ? value : null;
                  widget.onVideoAdded(_videoUrl);
                } else {
                  widget.onVideoAdded(null);
                }
              });
            },
            decoration: InputDecoration(
              hintText: 'https://youtube.com/watch?v=...',
              hintStyle: TextStyle(
                color: AppColors.grey.withValues(alpha: 0.6),
                fontSize: 14,
              ),
              prefixIcon: Icon(
                _getPlatformIcon(),
                color: _getPlatformColor(),
                size: 20,
              ),
              suffixIcon: _videoUrlController.text.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _videoUrlController.clear();
                        setState(() {
                          _videoUrl = null;
                          _errorMessage = null;
                          widget.onVideoAdded(null);
                        });
                      },
                      icon: Icon(Iconsax.close_circle, color: AppColors.grey),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
            ),
          ),
        ),
        
        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 8, left: 12),
            child: Row(
              children: [
                Icon(Iconsax.info_circle, size: 14, color: AppColors.error),
                const SizedBox(width: 6),
                Text(
                  _errorMessage!,
                  style: TextStyle(fontSize: 12, color: AppColors.error),
                ),
              ],
            ),
          ),
        
        // Video preview
        if (_videoUrl != null && _errorMessage == null)
          Container(
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    _getPlatformIcon(),
                    color: _getPlatformColor(),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getPlatformName(),
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _videoUrl!,
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.green.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    'Valid URL',
                    style: TextStyle(
                      fontSize: 10,
                      color: Colors.green,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  IconData _getPlatformIcon() {
    final url = _videoUrlController.text;
    if (VideoValidator.getVideoPlatform(url) == 'youtube') {
      return Iconsax.video_play;
    } else if (VideoValidator.getVideoPlatform(url) == 'vimeo') {
      return Iconsax.video;
    }
    return Iconsax.link;
  }

  Color _getPlatformColor() {
    final url = _videoUrlController.text;
    if (VideoValidator.getVideoPlatform(url) == 'youtube') {
      return Colors.red;
    } else if (VideoValidator.getVideoPlatform(url) == 'vimeo') {
      return Colors.blue;
    }
    return AppColors.primary;
  }

  String _getPlatformName() {
    final url = _videoUrlController.text;
    if (VideoValidator.getVideoPlatform(url) == 'youtube') {
      return 'YouTube Video';
    } else if (VideoValidator.getVideoPlatform(url) == 'vimeo') {
      return 'Vimeo Video';
    }
    return 'Video Link';
  }

  @override
  void dispose() {
    _videoUrlController.dispose();
    super.dispose();
  }
}