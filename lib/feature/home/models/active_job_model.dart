class ActiveJobModel {
  final String id;
  final String status;
  final String categoryName;
  final String? technicianName;
  final String scheduledTime;
  final String address;

  const ActiveJobModel({
    required this.id,
    required this.status,
    required this.categoryName,
    this.technicianName,
    required this.scheduledTime,
    required this.address,
  });

  factory ActiveJobModel.fromJson(Map<String, dynamic> json) {
    return ActiveJobModel(
      id: json['id']?.toString() ?? '',
      status: json['status']?.toString() ?? 'PENDING',
      categoryName: json['categoryName']?.toString() ?? '',
      technicianName: json['technicianName']?.toString(),
      scheduledTime: json['scheduledTime']?.toString() ?? '',
      address: json['address']?.toString() ?? '',
    );
  }
}
