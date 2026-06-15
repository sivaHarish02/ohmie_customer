import 'package:ohmie_customer/core/services/api_service.dart';
import 'package:ohmie_customer/feature/history/models/history_model.dart';

class HistoryService {
  HistoryService(this._api);

  final ApiService _api;

  Future<_HistoryPage> fetchHistory({
    int page = 1,
    int limit = 10,
    String? status,
    String? search,
  }) async {
    final params = <String, dynamic>{
      'page': page,
      'limit': limit,
      if (status != null && status.isNotEmpty) 'status': status,
      if (search != null && search.isNotEmpty) 'search': search,
    };
    final res = await _api.get('/customer/history', queryParameters: params);
    final data = res as Map<String, dynamic>;
    final rawList = data['jobs'] as List<dynamic>? ?? [];
    return _HistoryPage(
      total: (data['total'] as num?)?.toInt() ?? 0,
      page: (data['page'] as num?)?.toInt() ?? page,
      jobs: rawList
          .map((e) => HistoryJob.fromJson(e as Map<String, dynamic>))
          .toList(),
    );
  }
}

class _HistoryPage {
  final int total;
  final int page;
  final List<HistoryJob> jobs;

  const _HistoryPage({
    required this.total,
    required this.page,
    required this.jobs,
  });
}
