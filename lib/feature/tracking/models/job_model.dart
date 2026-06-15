class JobModel {
  final String id;
  final String status;
  final String categoryName;
  final String description;
  final String address;
  final double latitude;
  final double longitude;

  // Technician info (nullable — only present when assigned)
  final String? technicianName;

  /// Masked phone, e.g. "+91 98765 XXXXX"
  final String? technicianPhone;

  final DateTime scheduledTime;

  /// Final amount in the smallest currency unit (paise / cents)
  final double? amount;

  final String paymentStatus;
  final DateTime createdAt;

  /// OTP shared with the technician to start the job (present when WAITING_OTP)
  final String? otp;

  const JobModel({
    required this.id,
    required this.status,
    required this.categoryName,
    required this.description,
    required this.address,
    required this.latitude,
    required this.longitude,
    this.technicianName,
    this.technicianPhone,
    required this.scheduledTime,
    this.amount,
    required this.paymentStatus,
    required this.createdAt,
    this.otp,
  });

  // ── fromJson ──────────────────────────────────────────────────────────────
  factory JobModel.fromJson(Map<String, dynamic> json) {
    final data = json['data'] is Map<String, dynamic>
        ? json['data'] as Map<String, dynamic>
        : json;

    return JobModel(
      id: (data['id'] ?? data['_id'] ?? '').toString(),
      status: (data['status'] ?? 'PENDING').toString().toUpperCase(),
      categoryName: (data['category_name'] ??
              data['categoryName'] ??
              data['category']?['name'] ??
              '')
          .toString(),
      description: (data['description'] ?? '').toString(),
      address: (data['address'] ?? '').toString(),
      latitude: _toDouble(data['latitude'] ?? data['lat'] ?? 0),
      longitude: _toDouble(data['longitude'] ?? data['lng'] ?? 0),
      technicianName: data['technician_name']?.toString() ??
          data['technicianName']?.toString(),
      technicianPhone: data['technician_phone']?.toString() ??
          data['technicianPhone']?.toString(),
      scheduledTime:
          _parseDate(data['scheduled_time'] ?? data['scheduledTime']),
      amount: data['amount'] != null ? _toDouble(data['amount']) : null,
      paymentStatus:
          (data['payment_status'] ?? data['paymentStatus'] ?? 'PENDING')
              .toString()
              .toUpperCase(),
      createdAt: _parseDate(data['created_at'] ?? data['createdAt']),
      otp: data['otp']?.toString(),
    );
  }

  // ── toJson ────────────────────────────────────────────────────────────────
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status,
      'category_name': categoryName,
      'description': description,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'technician_name': technicianName,
      'technician_phone': technicianPhone,
      'scheduled_time': scheduledTime.toIso8601String(),
      'amount': amount,
      'payment_status': paymentStatus,
      'created_at': createdAt.toIso8601String(),
      'otp': otp,
    };
  }

  // ── Helpers ───────────────────────────────────────────────────────────────
  static double _toDouble(dynamic value) {
    if (value == null) return 0.0;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    return double.tryParse(value.toString()) ?? 0.0;
  }

  static DateTime _parseDate(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    return DateTime.tryParse(value.toString()) ?? DateTime.now();
  }

  /// Returns a masked phone string like "+91 98765 XXXXX"
  static String maskPhone(String phone) {
    if (phone.length < 5) return phone;
    return '${phone.substring(0, phone.length - 5)}XXXXX';
  }

  @override
  String toString() =>
      'JobModel(id: $id, status: $status, category: $categoryName)';
}
