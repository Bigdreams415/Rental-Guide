class TransactionModel {
  final String id;
  final String propertyId;
  final String buyerId;
  final String ownerId;
  final double amount;
  final double platformFee;
  final double ownerAmount;
  final String paystackReference;
  final String? authorizationUrl;
  final String status;
  final String listingType;
  final DateTime? releaseAt;
  final DateTime? paidAt;
  final DateTime? releasedAt;
  final String? notes;
  final String? propertyTitle;
  final String? buyerName;
  final String? ownerName;
  final DateTime createdAt;

  TransactionModel({
    required this.id,
    required this.propertyId,
    required this.buyerId,
    required this.ownerId,
    required this.amount,
    required this.platformFee,
    required this.ownerAmount,
    required this.paystackReference,
    this.authorizationUrl,
    required this.status,
    required this.listingType,
    this.releaseAt,
    this.paidAt,
    this.releasedAt,
    this.notes,
    this.propertyTitle,
    this.buyerName,
    this.ownerName,
    required this.createdAt,
  });

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: json['id'] ?? '',
      propertyId: json['property_id'] ?? '',
      buyerId: json['buyer_id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      platformFee: (json['platform_fee'] ?? 0).toDouble(),
      ownerAmount: (json['owner_amount'] ?? 0).toDouble(),
      paystackReference: json['paystack_reference'] ?? '',
      authorizationUrl: json['authorization_url'],
      status: json['status'] ?? 'pending',
      listingType: json['listing_type'] ?? '',
      releaseAt: json['release_at'] != null
          ? DateTime.tryParse(json['release_at'])
          : null,
      paidAt: json['paid_at'] != null
          ? DateTime.tryParse(json['paid_at'])
          : null,
      releasedAt: json['released_at'] != null
          ? DateTime.tryParse(json['released_at'])
          : null,
      notes: json['notes'],
      propertyTitle: json['property_title'],
      buyerName: json['buyer_name'],
      ownerName: json['owner_name'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isInEscrow => status == 'in_escrow';
  bool get isReleased => status == 'released';
  bool get isRefunded => status == 'refunded';
  bool get isFailed => status == 'failed';

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'in_escrow': return 'In Escrow';
      case 'released': return 'Released';
      case 'refunded': return 'Refunded';
      case 'failed': return 'Failed';
      default: return status;
    }
  }

  String get formattedAmount {
    const symbol = '₦';
    if (amount >= 1000000) {
      return '$symbol${(amount / 1000000).toStringAsFixed(1)}M';
    } else if (amount >= 1000) {
      return '$symbol${(amount / 1000).toStringAsFixed(0)}K';
    }
    return '$symbol${amount.toStringAsFixed(0)}';
  }
}