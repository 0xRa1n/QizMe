import 'package:qizme/utils/http.dart';

class StreakService {
  static Future<Map<String, dynamic>> getReviewHistory(String userId) async {
    final responseBody = await ApiService.getRequest(
      'api/users/reviewHistory/$userId',
    );
    return {'raw': responseBody};
  }

  static Future<Map<String, dynamic>> recordReview(String userId) async {
    final responseBody = await ApiService.postRequest(
      'api/users/recordReview',
      {'userId': userId},
    );
    return {'raw': responseBody};
  }
}
