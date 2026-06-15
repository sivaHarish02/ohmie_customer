enum PaymentMethod { cash, online }

class PaymentInfo {
  final double totalAmount;
  final String? qrCodeUrl;
  final String? upiId;
  final String? upiMobile;

  const PaymentInfo({
    required this.totalAmount,
    this.qrCodeUrl,
    this.upiId,
    this.upiMobile,
  });

  factory PaymentInfo.fromJson(Map<String, dynamic> json) {
    return PaymentInfo(
      totalAmount: (json['totalAmount'] as num).toDouble(),
      qrCodeUrl: json['qrCodeUrl'] as String?,
      upiId: json['upiId'] as String?,
      upiMobile: json['upiMobile'] as String?,
    );
  }
}
