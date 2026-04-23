class InspectionModel {
  final String id;
  final String propertyId;
  final String requesterId;
  final String ownerId;
  final DateTime requestedDate;
  final DateTime? confirmedDate;
  final String status;
  final String? requesterNote;
  final String? ownerNote;
  final String? requesterName;
  final String? ownerName;
  final String? propertyTitle;
  final String? propertyImage;
  final DateTime createdAt;

  InspectionModel({
    required this.id,
    required this.propertyId,
    required this.requesterId,
    required this.ownerId,
    required this.requestedDate,
    this.confirmedDate,
    required this.status,
    this.requesterNote,
    this.ownerNote,
    this.requesterName,
    this.ownerName,
    this.propertyTitle,
    this.propertyImage,
    required this.createdAt,
  });

  factory InspectionModel.fromJson(Map<String, dynamic> json) {
    return InspectionModel(
      id: json['id'] ?? '',
      propertyId: json['property_id'] ?? '',
      requesterId: json['requester_id'] ?? '',
      ownerId: json['owner_id'] ?? '',
      requestedDate: DateTime.tryParse(json['requested_date'] ?? '') ?? DateTime.now(),
      confirmedDate: json['confirmed_date'] != null
          ? DateTime.tryParse(json['confirmed_date'])
          : null,
      status: json['status'] ?? 'pending',
      requesterNote: json['requester_note'],
      ownerNote: json['owner_note'],
      requesterName: json['requester_name'],
      ownerName: json['owner_name'],
      propertyTitle: json['property_title'],
      propertyImage: json['property_image'],
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
    );
  }

  bool get isPending => status == 'pending';
  bool get isConfirmed => status == 'confirmed';
  bool get isRescheduled => status == 'rescheduled';
  bool get isCompleted => status == 'completed';
  bool get isCancelled => status == 'cancelled';

  DateTime get displayDate => confirmedDate ?? requestedDate;

  String get statusLabel {
    switch (status) {
      case 'pending': return 'Pending';
      case 'confirmed': return 'Confirmed';
      case 'rescheduled': return 'Rescheduled';
      case 'completed': return 'Completed';
      case 'cancelled': return 'Cancelled';
      default: return status;
    }
  }
}