import 'package:dio/dio.dart';
import 'package:image_picker/image_picker.dart';

import 'package:ohmie_customer/core/network/api_client.dart';
import 'package:ohmie_customer/feature/booking/models/booking_model.dart';

class BookingService {
  BookingService(this._client);

  final ApiClient _client;

  static const List<Map<String, dynamic>> _fallbackCategories = [
    {'id': 1, 'name': 'AC Service', 'icon': 'ac_unit'},
    {'id': 2, 'name': 'Washing Machine', 'icon': 'local_laundry_service'},
    {'id': 3, 'name': 'Refrigerator', 'icon': 'kitchen'},
    {'id': 4, 'name': 'RO Service', 'icon': 'water_drop'},
    {'id': 5, 'name': 'Electrical', 'icon': 'bolt'},
    {'id': 6, 'name': 'Plumbing', 'icon': 'plumbing'},
    {'id': 7, 'name': 'Geyser', 'icon': 'hot_tub'},
    {'id': 8, 'name': 'TV Repair', 'icon': 'tv'},
  ];

  Future<List<BookingCategory>> fetchCategories() async {
    try {
      final response = await _client.get('/customer/categories');
      final body = response.data;

      List<dynamic>? list;
      if (body is List) {
        list = body;
      } else if (body is Map<String, dynamic> && body['data'] is List) {
        list = body['data'] as List<dynamic>;
      }

      if (list == null || list.isEmpty) {
        return _fallbackCategories.map(BookingCategory.fromJson).toList();
      }

      return list
          .whereType<Map>()
          .map((e) => BookingCategory.fromJson(Map<String, dynamic>.from(e)))
          .toList();
    } catch (_) {
      return _fallbackCategories.map(BookingCategory.fromJson).toList();
    }
  }

  Future<BookingResult> submitBooking(
    BookingRequest request, {
    XFile? imageFile,
  }) async {
    if (imageFile != null) {
      try {
        final map = request.toJson();
        map.remove('image');
        map['image'] = await MultipartFile.fromFile(
          imageFile.path,
          filename: _filenameFromPath(imageFile.path),
        );

        final response = await _client.post(
          '/customer/book-service',
          data: FormData.fromMap(map),
        );

        if (response.data is Map<String, dynamic>) {
          return BookingResult.fromJson(response.data as Map<String, dynamic>);
        }
      } on DioException {
        // Fallback to plain JSON flow.
      }
    }

    final fallbackPayload = request.toJson();
    if (imageFile != null) {
      fallbackPayload['image'] = _filenameFromPath(imageFile.path);
    }

    final response = await _client.post(
      '/customer/book-service',
      data: fallbackPayload,
    );

    if (response.data is Map<String, dynamic>) {
      return BookingResult.fromJson(response.data as Map<String, dynamic>);
    }

    return const BookingResult(
      success: true,
      message: 'Service booked successfully',
    );
  }

  String _filenameFromPath(String path) {
    final normalized = path.replaceAll('\\', '/');
    final parts = normalized.split('/');
    return parts.isNotEmpty ? parts.last : 'issue_image.jpg';
  }
}
