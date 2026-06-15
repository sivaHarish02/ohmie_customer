class BookingCategory {
  final int id;
  final String name;
  final String icon;

  const BookingCategory({
    required this.id,
    required this.name,
    required this.icon,
  });

  factory BookingCategory.fromJson(Map<String, dynamic> json) {
    return BookingCategory(
      id: int.tryParse((json['id'] ?? 0).toString()) ?? 0,
      name: (json['name'] ?? '').toString(),
      icon: (json['icon'] ?? '').toString(),
    );
  }
}

class BookingRequest {
  final int categoryId;
  final String problemTitle;
  final String description;
  final DateTime preferredTime;
  final double latitude;
  final double longitude;
  final String address;
  final String? image;

  const BookingRequest({
    required this.categoryId,
    required this.problemTitle,
    required this.description,
    required this.preferredTime,
    required this.latitude,
    required this.longitude,
    required this.address,
    this.image,
  });

  Map<String, dynamic> toJson() {
    return {
      'categoryId': categoryId,
      'problemTitle': problemTitle,
      'description': description,
      'preferredTime': preferredTime.toUtc().toIso8601String(),
      'latitude': latitude,
      'longitude': longitude,
      'address': address,
      if (image != null && image!.isNotEmpty) 'image': image,
    };
  }
}

class BookingResult {
  final bool success;
  final String message;
  final int? jobId;

  const BookingResult({
    required this.success,
    required this.message,
    this.jobId,
  });

  factory BookingResult.fromJson(Map<String, dynamic> json) {
    final data = json['data'];
    final source = data is Map<String, dynamic> ? data : json;

    return BookingResult(
      success: (json['success'] ?? true) == true,
      message: (source['message'] ?? json['message'] ?? 'Service booked successfully').toString(),
      jobId: int.tryParse(
        (source['jobId'] ?? source['id'] ?? source['job_id'] ?? '').toString(),
      ),
    );
  }
}
