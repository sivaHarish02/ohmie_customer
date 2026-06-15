class HistoryJob {
  final int id;
  final String jobCode;
  final String categoryName;
  final List<String> scopeOfWork;
  final String status;
  final double? amount;
  final String? paymentStatus;
  final String? paymentMethod;
  final HistoryTechnician? technician;
  final String? address;
  final DateTime createdAt;
  final DateTime? completedAt;
  final String? beforeImage;
  final String? afterImage;
  final int? duration; // minutes

  const HistoryJob({
    required this.id,
    required this.jobCode,
    required this.categoryName,
    required this.scopeOfWork,
    required this.status,
    this.amount,
    this.paymentStatus,
    this.paymentMethod,
    this.technician,
    this.address,
    required this.createdAt,
    this.completedAt,
    this.beforeImage,
    this.afterImage,
    this.duration,
  });

  factory HistoryJob.fromJson(Map<String, dynamic> json) {
    final rawScopes = json['scopeOfWork'];
    final scopes = rawScopes is List
        ? rawScopes.map((e) => e.toString()).toList()
        : <String>[];
    return HistoryJob(
      id: (json['id'] as num).toInt(),
      jobCode: json['jobCode'] as String? ?? '',
      categoryName: json['categoryName'] as String? ?? 'Service',
      scopeOfWork: scopes,
      status: json['status'] as String? ?? 'UNKNOWN',
      amount:
          json['amount'] != null ? (json['amount'] as num).toDouble() : null,
      paymentStatus: json['paymentStatus'] as String?,
      paymentMethod: json['paymentMethod'] as String?,
      technician: json['technician'] != null
          ? HistoryTechnician.fromJson(
              json['technician'] as Map<String, dynamic>)
          : null,
      address: json['address'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      completedAt: json['completedAt'] != null
          ? DateTime.tryParse(json['completedAt'] as String)
          : null,
      beforeImage: json['beforeImage'] as String?,
      afterImage: json['afterImage'] as String?,
      duration:
          json['duration'] != null ? (json['duration'] as num).toInt() : null,
    );
  }
}

class HistoryTechnician {
  final String name;

  const HistoryTechnician({required this.name});

  factory HistoryTechnician.fromJson(Map<String, dynamic> json) {
    return HistoryTechnician(name: json['name'] as String? ?? 'Technician');
  }
}
