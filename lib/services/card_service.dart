import 'package:qizme/utils/http.dart';

class CardService {
  static Future<Map<String, dynamic>> createCardSet({
    required String email,
    required String name,
  }) async {
    final responseBody = await ApiService.postRequest("api/card/createCard", {
      "email": email,
      "title": name,
    });

    return {"raw": responseBody};
  }

  static Future<Map<String, dynamic>> createFlashcards({
    String? question,
    String? answer,
    String? questionImagePath,
    String? answerImagePath,
    required String flashcardColor,
    required String flashcardID,
  }) async {
    final fields = <String, String>{"flashcardColor": flashcardColor};

    if (question != null && question.trim().isNotEmpty) {
      fields["question"] = question.trim();
    }
    if (answer != null && answer.trim().isNotEmpty) {
      fields["answer"] = answer.trim();
    }

    final hasQuestionImage =
        questionImagePath != null && questionImagePath.trim().isNotEmpty;
    final hasAnswerImage =
        answerImagePath != null && answerImagePath.trim().isNotEmpty;

    final responseBody = (hasQuestionImage || hasAnswerImage)
        ? await ApiService.postMultipartRequest(
            "api/card/$flashcardID/addFlashcard",
            fields: fields,
            files: {
              if (hasQuestionImage) "questionImage": questionImagePath!,
              if (hasAnswerImage) "answerImage": answerImagePath!,
            },
          )
        : await ApiService.postRequest(
            "api/card/$flashcardID/addFlashcard",
            fields,
          );

    return {"raw": responseBody};
  }

  static Future<Map<String, dynamic>> updateFlashcard({
    required String flashcardID,
    required String front,
    required String back,
    required String cardID,
  }) async {
    final responseBody = await ApiService.putRequest(
      "api/card/$cardID/updateFlashcard",
      {"FlashcardID": flashcardID, "front": front, "back": back},
    );

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

  static Future<Map<String, dynamic>> deleteFlashcard({
    required String cardID,
    required String flashcardID,
  }) async {
    final responseBody = await ApiService.deleteRequest(
      "api/card/deleteFlashcard",
      {"CardID": cardID, "FlashcardID": flashcardID},
    );

    return {"raw": responseBody};
  }
}
