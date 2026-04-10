import 'dart:developer';
import '../api/api_service.dart';
import '../api/api_url.dart';
import '../model/trip_model.dart';

class NotificationService {
  Future<List<NotificationModel>> getNotifications({
    int page = 1,
    int pageSize = 20,
  }) async {
    try {
      final res = await ApiService.get(
        url: ApiUrl.getUserNotifications,
        queryParameters: {'page': page, 'pageSize': pageSize},
      );
      if (res.statusCode == 200 && res.data != null) {
        final list = res.data['result'] as List? ?? res.data as List? ?? [];
        return list
            .map((e) => NotificationModel.fromJson(e as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      log('getNotifications error: $e');
    }
    return [];
  }

  Future<bool> markAsRead(int notificationId) async {
    try {
      final res = await ApiService.post(
        url: ApiUrl.markNotificationRead,
        data: notificationId,
      );
      return res.statusCode == 200;
    } catch (e) {
      log('markAsRead error: $e');
      return false;
    }
  }

  Future<bool> markAllRead() async {
    try {
      final res = await ApiService.post(
        url: ApiUrl.markAllNotificationsRead,
        data: {},
      );
      return res.statusCode == 200;
    } catch (e) {
      log('markAllRead error: $e');
      return false;
    }
  }
}
