import 'package:flutter/material.dart';

// ─── Sub-models ───────────────────────────────────────────────────────────────

class PropertyImage {
  final String id;
  final String imageUrl;
  final bool isMain;
  final String? caption;
  final int displayOrder;

  PropertyImage({
    required this.id,
    required this.imageUrl,
    required this.isMain,
    this.caption,
    required this.displayOrder,
  });

  factory PropertyImage.fromJson(Map<String, dynamic> json) {
    return PropertyImage(
      id: json['id'] ?? '',
      imageUrl: json['image_url'] ?? '',
      isMain: json['is_main'] ?? false,
      caption: json['caption'],
      displayOrder: json['display_order'] ?? 0,
    );
  }
}

class PropertyVideo {
  final String id;
  final String videoUrl;
  final String? thumbnailUrl;
  final String? title;
  final int? duration;

  PropertyVideo({
    required this.id,
    required this.videoUrl,
    this.thumbnailUrl,
    this.title,
    this.duration,
  });

  factory PropertyVideo.fromJson(Map<String, dynamic> json) {
    return PropertyVideo(
      id: json['id'] ?? '',
      videoUrl: json['video_url'] ?? '',
      thumbnailUrl: json['thumbnail_url'],
      title: json['title'],
      duration: json['duration'],
    );
  }

  /// Converts a YouTube or Vimeo URL into an embeddable thumbnail URL
  String? get thumbnailFromUrl {
    if (thumbnailUrl != null && thumbnailUrl!.isNotEmpty) return thumbnailUrl;

    // YouTube: extract video ID and build thumbnail URL
    final ytRegex = RegExp(
      r'(?:youtube\.com/watch\?v=|youtu\.be/|youtube\.com/embed/)([a-zA-Z0-9_-]{11})',
    );
    final ytMatch = ytRegex.firstMatch(videoUrl);
    if (ytMatch != null) {
      return 'https://img.youtube.com/vi/${ytMatch.group(1)}/hqdefault.jpg';
    }

    return null;
  }

  String get platformName {
    if (videoUrl.contains('youtube') || videoUrl.contains('youtu.be')) {
      return 'YouTube';
    }
    if (videoUrl.contains('vimeo')) return 'Vimeo';
    return 'Video';
  }
}

// ─── Main Property Model ──────────────────────────────────────────────────────

class Property {
  final String id;
  final String title;
  final String description;
  final String propertyType;
  final String listingType;
  final String status;
  final String
  verificationStatus; // raw value: "verified", "pending_verification", "rejected"
  final String address;
  final String city;
  final String state;
  final String lga;
  final String? landmark;
  final double price;
  final int? bedrooms;
  final int? bathrooms;
  final int? toilets;
  final double? squareMeters;
  final String? plotSize;
  final int? totalUnits;
  final int? availableUnits;
  final List<String> features;
  final String? mainImage;
  final List<PropertyImage> images; // ← all uploaded images
  final List<PropertyVideo> videos; // ← video URLs
  final String ownerId;
  final String? ownerPhone;
  final int viewCount;
  final bool isFeatured;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Property({
    required this.id,
    required this.title,
    required this.description,
    required this.propertyType,
    required this.listingType,
    required this.status,
    required this.verificationStatus,
    required this.address,
    required this.city,
    required this.state,
    required this.lga,
    this.landmark,
    required this.price,
    this.bedrooms,
    this.bathrooms,
    this.toilets,
    this.squareMeters,
    this.plotSize,
    this.totalUnits,
    this.availableUnits,
    required this.features,
    this.mainImage,
    required this.images,
    required this.videos,
    required this.ownerId,
    this.ownerPhone,
    required this.viewCount,
    required this.isFeatured,
    required this.createdAt,
    this.updatedAt,
  });

  factory Property.fromJson(Map<String, dynamic> json) {
    return Property(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      propertyType: json['property_type'] ?? '',
      listingType: json['listing_type'] ?? '',
      status: json['status'] ?? '',
      // ── FIX: backend sends verification_status string, not a bool ──────────
      verificationStatus: json['verification_status'] ?? 'pending_verification',
      address: json['address'] ?? '',
      city: json['city'] ?? '',
      state: json['state'] ?? '',
      lga: json['lga'] ?? '',
      landmark: json['landmark'],
      price: (json['price'] ?? 0).toDouble(),
      bedrooms: json['bedrooms'],
      bathrooms: json['bathrooms'],
      toilets: json['toilets'],
      squareMeters: json['square_meters']?.toDouble(),
      plotSize: json['plot_size'],
      totalUnits: json['total_units'],
      availableUnits: json['available_units'],
      features: List<String>.from(json['features'] ?? []),
      mainImage: json['main_image'],
      // ── NEW: parse images and videos arrays ────────────────────────────────
      images:
          (json['images'] as List<dynamic>? ?? [])
              .map((e) => PropertyImage.fromJson(e as Map<String, dynamic>))
              .toList()
            ..sort((a, b) => a.displayOrder.compareTo(b.displayOrder)),
      videos: (json['videos'] as List<dynamic>? ?? [])
          .map((e) => PropertyVideo.fromJson(e as Map<String, dynamic>))
          .toList(),
      ownerId: json['owner_id'] ?? '',
      ownerPhone: json['owner_phone'],
      viewCount: json['view_count'] ?? 0,
      isFeatured: json['is_featured'] ?? false,
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      updatedAt: json['updated_at'] != null
          ? DateTime.tryParse(json['updated_at'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'property_type': propertyType,
      'listing_type': listingType,
      'status': status,
      'verification_status': verificationStatus,
      'address': address,
      'city': city,
      'state': state,
      'lga': lga,
      'landmark': landmark,
      'price': price,
      'bedrooms': bedrooms,
      'bathrooms': bathrooms,
      'toilets': toilets,
      'square_meters': squareMeters,
      'plot_size': plotSize,
      'total_units': totalUnits,
      'available_units': availableUnits,
      'features': features,
      'main_image': mainImage,
      'owner_id': ownerId,
      'owner_phone': ownerPhone,
      'view_count': viewCount,
      'is_featured': isFeatured,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
    };
  }

  // ── Computed helpers ────────────────────────────────────────────────────────

  /// True only when the backend has confirmed verification
  bool get verified => verificationStatus == 'verified';

  /// Best available image URL — prefers mainImage, falls back to first in list
  String? get bestImage {
    if (mainImage != null && mainImage!.isNotEmpty) return mainImage;
    if (images.isNotEmpty) return images.first.imageUrl;
    return null;
  }

  bool get hasImages => bestImage != null;
  bool get hasVideos => videos.isNotEmpty;

  bool get isMultiUnit => totalUnits != null && totalUnits! > 1;

  String get unitsDisplay {
    if (!isMultiUnit) return '';
    final available = availableUnits ?? totalUnits!;
    return '$available of $totalUnits units available';
  }

  String get formattedPrice {
    const nairaSymbol = '₦';
    if (price >= 1000000) {
      return '$nairaSymbol${(price / 1000000).toStringAsFixed(price % 1000000 == 0 ? 0 : 1)}M';
    } else if (price >= 1000) {
      return '$nairaSymbol${(price / 1000).toStringAsFixed(0)}K';
    }
    return '$nairaSymbol${price.toStringAsFixed(0)}';
  }

  String get fullLocation => '$city, $state';

  String get priceWithPeriod {
    if (listingType.toLowerCase() == 'rent') return '$formattedPrice/yr';
    if (listingType.toLowerCase() == 'shortlet') return '$formattedPrice/night';
    return formattedPrice;
  }

  String get displayBedrooms =>
      (bedrooms == null || bedrooms == 0) ? 'N/A' : bedrooms.toString();

  String get displayBathrooms =>
      (bathrooms == null || bathrooms == 0) ? 'N/A' : bathrooms.toString();

  String get displayArea {
    if (squareMeters != null) return '${squareMeters!.toStringAsFixed(0)} sq m';
    if (plotSize != null) return plotSize!;
    return 'N/A';
  }

  Color get typeColor {
    switch (listingType.toLowerCase()) {
      case 'rent':
      case 'shortlet':
        return const Color(0xFF00BFA5);
      case 'sale':
      case 'lease':
        return const Color(0xFF0066B2);
      default:
        return const Color(0xFF0066B2);
    }
  }

  String get displayType {
    switch (listingType.toLowerCase()) {
      case 'shortlet':
        return 'Short Stay';
      case 'sale':
        return 'For Sale';
      case 'rent':
        return 'For Rent';
      case 'lease':
        return 'For Lease';
    }
    switch (propertyType.toLowerCase()) {
      case 'land':
        return 'Land';
      case 'commercial':
        return 'Commercial';
      case 'shop':
        return 'Shop';
    }
    return listingType;
  }

  String get timeAgo {
    final diff = DateTime.now().difference(createdAt);
    if (diff.inDays > 30) {
      final m = (diff.inDays / 30).floor();
      return '$m ${m == 1 ? 'month' : 'months'} ago';
    } else if (diff.inDays > 0) {
      return '${diff.inDays} ${diff.inDays == 1 ? 'day' : 'days'} ago';
    } else if (diff.inHours > 0) {
      return '${diff.inHours} ${diff.inHours == 1 ? 'hour' : 'hours'} ago';
    } else if (diff.inMinutes > 0) {
      return '${diff.inMinutes} ${diff.inMinutes == 1 ? 'minute' : 'minutes'} ago';
    }
    return 'Just now';
  }
}
