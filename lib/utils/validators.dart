class VideoValidator {
  // YouTube URL patterns
  static final RegExp _youtubeRegex = RegExp(
    r'^(https?://)?(www\.)?(youtube\.com|youtu\.be)/',
    caseSensitive: false,
  );
  
  // Vimeo URL patterns
  static final RegExp _vimeoRegex = RegExp(
    r'^(https?://)?(www\.)?vimeo\.com/',
    caseSensitive: false,
  );

  static bool isValidVideoUrl(String? url) {
    if (url == null || url.isEmpty) return true; // Optional field
    return _youtubeRegex.hasMatch(url) || _vimeoRegex.hasMatch(url);
  }

  static String? getVideoPlatform(String url) {
    if (_youtubeRegex.hasMatch(url)) return 'youtube';
    if (_vimeoRegex.hasMatch(url)) return 'vimeo';
    return null;
  }

  static String? validateVideoUrl(String? url) {
    if (url == null || url.isEmpty) return null;
    if (!isValidVideoUrl(url)) {
      return 'Please enter a valid YouTube or Vimeo URL';
    }
    return null;
  }
}