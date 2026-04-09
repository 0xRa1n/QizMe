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
    // Assuming the response contains the updated user document or at least the new streak.
    // Let's return the whole data part of the response.
    return {'raw': responseBody};
  }

  static Future<Map<String, dynamic>> updateStreakPercentage(
    String flashcardID,
    int newPercentage,
  ) async {
    final responseBody = await ApiService.putRequest(
      'api/card/$flashcardID/updateFlashcardPercentage',
      {'newPercentage': newPercentage},
    );
    return {'raw': responseBody};
  }

  static Future<Map<String, dynamic>> getStreakCount(String userId) async {
    final responseBody = await ApiService.getRequest(
      'api/users/streak/$userId',
    );
    return {'raw': responseBody};
  }

  static Future<Map<String, dynamic>> getStreakHistory(String userId) async {
    final responseBody = await ApiService.getRequest(
      'api/users/reviewHistory/$userId',
    );
    return {'raw': responseBody};
  }
}
