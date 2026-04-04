import 'package:qizme/utils/http.dart';

class CardService {
  static Future<Map<String, dynamic>> createCardSet({
    required String name,
  }) async {
    final responseBody = await ApiService.postRequest("api/card/createCard", {
      "title": name,
    });

    return {"raw": responseBody};
  }

  static Future<Map<String, dynamic>> getCardSet({
    required String email,
  }) async {
    print(email);
    final responseBody = await ApiService.postRequest("api/card/", {
      "email": email,
    });

    return {"raw": responseBody};
  }
}
