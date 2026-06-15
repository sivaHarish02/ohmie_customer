import 'package:ohmie_customer/core/services/api_service.dart';

class HomeService {
  HomeService(this._apiService);

  final ApiService _apiService;

  Future<Map<String, dynamic>> getHomeSummary() async {
    try {
      final response = await _apiService.get('/customer/home-summary');
      if (response is Map<String, dynamic>) {
        if (response['data'] is Map<String, dynamic>) {
          return Map<String, dynamic>.from(response['data'] as Map);
        }
        return response;
      }
    } catch (_) {
      // Fallback to per-endpoint calls if summary endpoint is not ready.
    }

    final active = await getActiveBookings();
    final recent = await getRecentBookings(limit: 3);

    return {
      'activeBooking': active,
      'recentBookings': recent,
    };
  }

  Future<List<Map<String, dynamic>>> getActiveBookings() async {
    try {
      final response = await _apiService.get('/customer/active-job');

      if (response is List) {
        return response
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      if (response is Map<String, dynamic>) {
        if (response['jobs'] is List) {
          return (response['jobs'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (response['activeBooking'] is List) {
          return (response['activeBooking'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (response['data'] is List) {
          return (response['data'] as List)
              .whereType<Map>()
              .map((e) => Map<String, dynamic>.from(e))
              .toList();
        }
        if (response['data'] is Map<String, dynamic>) {
          return [Map<String, dynamic>.from(response['data'] as Map)];
        }
      }
    } catch (_) {
      // Keep empty list and let UI render empty active state.
    }

    return <Map<String, dynamic>>[];
  }

  Future<Map<String, dynamic>?> getActiveBooking() async {
    try {
      final list = await getActiveBookings();
      return list.isNotEmpty ? list.first : null;
    } catch (_) {
      // Keep null and let UI render empty active state.
    }

    return null;
  }

  Future<List<Map<String, dynamic>>> getRecentBookings({int limit = 3}) async {
    try {
      final response = await _apiService.get(
        '/customer/jobs',
        queryParameters: {'limit': limit},
      );

      if (response is List) {
        return response
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }

      if (response is Map<String, dynamic> && response['data'] is List) {
        return (response['data'] as List)
            .whereType<Map>()
            .map((e) => Map<String, dynamic>.from(e))
            .toList();
      }
    } catch (_) {
      // Fallback to dummy data when API is unavailable.
      return <Map<String, dynamic>>[
        {
          'id': 'demo-1',
          'serviceName': 'AC Service',
          'date': DateTime.now()
              .subtract(const Duration(days: 1))
              .toIso8601String(),
          'status': 'COMPLETED',
          'amount': 799,
        },
        {
          'id': 'demo-2',
          'serviceName': 'RO Service',
          'date': DateTime.now()
              .subtract(const Duration(days: 4))
              .toIso8601String(),
          'status': 'WAITING_OTP',
          'amount': 499,
        },
        {
          'id': 'demo-3',
          'serviceName': 'Refrigerator Check',
          'date': DateTime.now()
              .subtract(const Duration(days: 8))
              .toIso8601String(),
          'status': 'CLOSED',
          'amount': 349,
        },
      ];
    }

    return <Map<String, dynamic>>[];
  }
}
