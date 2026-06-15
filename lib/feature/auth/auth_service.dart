import 'package:ohmie_customer/core/services/api_service.dart';

class AuthService {
  AuthService(this._apiService);

  final ApiService _apiService;

  Future<void> sendOtp(String mobile) async {
    await _apiService.post(
      '/customer/auth/send-otp',
      data: {'mobile': mobile},
    );
  }

  Future<Map<String, dynamic>> verifyOtp({
    required String mobile,
    required String otp,
  }) async {
    final response = await _apiService.post(
      '/customer/auth/verify-otp',
      data: {
        'mobile': mobile,
        'otp': otp,
      },
    );

    if (response is Map<String, dynamic>) {
      if (response['data'] is Map<String, dynamic>) {
        return response['data'] as Map<String, dynamic>;
      }
      return response;
    }

    return <String, dynamic>{};
  }
}
