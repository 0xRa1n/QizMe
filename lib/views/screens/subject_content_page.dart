import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:qizme/services/card_service.dart';
import 'package:qizme/services/streak_service.dart';
import 'package:qizme/views/screens/study_page.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:io';

class SubjectContentPage extends StatefulWidget {
  final Map<String, dynamic> subject;
  final void Function(Map<String, dynamic>)? onEditFlashcard;

  const SubjectContentPage({
    Key? key,
    required this.subject,
    this.onEditFlashcard,
  }) : super(key: key);

  @override
  State<SubjectContentPage> createState() => _SubjectContentPageState();
}

class _SubjectContentPageState extends State<SubjectContentPage> {
  late List<dynamic> flashcards;

  @override
  void initState() {
    super.initState();
    flashcards = List.from(widget.subject['flashcards'] ?? []);
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('darkMode') ?? false;
  }

  Future<void> _handleStudyNow() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('id');

    if (userId == null) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Could not identify user.')));
      return;
    }

    try {
      final history = await StreakService.getReviewHistory(userId);
      final activeDates = (history['raw']['data']['activeDates'] as List)
          .map((date) => DateTime.parse(date))
          .toList();

      final today = DateTime.now();
      final isAlreadyStudiedToday = activeDates.any(
        (date) =>
            date.year == today.year &&
            date.month == today.month &&
            date.day == today.day,
      );
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Failed to update streak: $e')));
    }

    if (flashcards.isNotEmpty) {
      if (mounted) {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StudyPage(
              flashcards: flashcards,
              subjectTitle: widget.subject['title'] ?? 'Study',
              cardId: widget.subject['_id'],
              initialCompletionPercentage:
                  widget.subject['cardCompletionPercentage'] ?? 0,
            ),
          ),
        );

        if (result == true) {
          Navigator.pop(context, true);
        }
      }
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No flashcards to study!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: getDarkMode(),
      builder: (context, snapshot) {
        // Check the state of the Future
        if (snapshot.connectionState == ConnectionState.waiting) {
          // While waiting for the data, you can show a loader
          return const Center(child: CircularProgressIndicator());
        }

        // If there's an error, you can show an error message
        if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        }

        // Once the data is available, use it to build the UI
        final darkMode = snapshot.data ?? false;

        return Column(
          children: [
            Expanded(
              child: flashcards.isEmpty
                  ? Center(
                      child: Text(
                        'No flashcards yet. Add one to get started!',
                        style: TextStyle(
                          fontSize: 18,
                          color: darkMode ? Colors.white70 : Colors.black54,
                        ),
                      ),
                    )
                  : ListView.builder(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 8.0,
                      ),
                      itemCount: flashcards.length,
                      itemBuilder: (context, index) {
                        final flashcard = flashcards[index];
                        return FlashcardItem(
                          flashcard: flashcard,
                          onEdit: () {
                            if (widget.onEditFlashcard != null) {
                              widget.onEditFlashcard!(
                                flashcard as Map<String, dynamic>,
                              );
                            }
                          },
                          onDelete: () {
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Delete Flashcard'),
                                content: const Text(
                                  'Are you sure you want to delete this flashcard?',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.pop(context);
                                    },
                                    child: const Text('Cancel'),
                                  ),
                                  TextButton(
                                    onPressed: () async {
                                      final flashcardIndex = index;
                                      final flashcardId = flashcard['_id'];
                                      print(flashcardIndex);
                                      print(
                                        'card ID: ${widget.subject['_id']}, flashcard ID: $flashcardId',
                                      );

                                      if (flashcardId == null) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Could not find flashcard id.',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      try {
                                        await CardService.deleteFlashcard(
                                          cardID: widget.subject['_id'],
                                          flashcardID: flashcardId,
                                        );
                                        setState(() {
                                          flashcards.removeAt(flashcardIndex);
                                        });
                                      } catch (e) {
                                        // show a snackbar
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(content: Text(e.toString())),
                                        );
                                      } finally {
                                        Navigator.pop(context);
                                      }
                                    },
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );
                          },
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color.fromARGB(255, 45, 106, 79),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
                onPressed: _handleStudyNow,
                child: const Text(
                  'Study now',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class FlashcardItem extends StatelessWidget {
  final Map<String, dynamic> flashcard;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  const FlashcardItem({
    Key? key,
    required this.flashcard,
    required this.onEdit,
    required this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor = darkMode ? Colors.grey[800] : Colors.grey[200];
    final question = flashcard['question'];
    final questionImage = _normalizeImageUrl(flashcard['questionImage']);
    final answerImage = _normalizeImageUrl(flashcard['answerImage']);
    final questionImagePath = _getLocalImagePath(
      flashcard['questionImagePath'],
    );
    final answerImagePath = _getLocalImagePath(flashcard['answerImagePath']);
    final hasQuestionImage =
        (questionImage != null && questionImage.isNotEmpty) ||
        questionImagePath != null;
    final hasAnswerImage =
        (answerImage != null && answerImage.isNotEmpty) ||
        answerImagePath != null;

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16.0, 22.0, 52.0, 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (hasQuestionImage)
                  _buildFlashcardImage(
                    networkUrl: questionImage,
                    localPath: questionImagePath,
                  ),
                if (!hasQuestionImage && question != null)
                  Text(
                    question,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                if (!hasAnswerImage) const SizedBox(height: 8),
                if (!hasAnswerImage)
                  Text(
                    flashcard['answer'] ?? '',
                    style: TextStyle(
                      color: darkMode ? Colors.white70 : Colors.black54,
                    ),
                  ),
                if (hasAnswerImage) const SizedBox(height: 8),
                if (hasAnswerImage)
                  _buildFlashcardImage(
                    networkUrl: answerImage,
                    localPath: answerImagePath,
                  ),
              ],
            ),
          ),
          Positioned(
            top: 6,
            right: 6,
            child: PopupMenuButton<String>(
              icon: const Icon(Icons.more_horiz),
              onSelected: (value) {
                if (value == 'edit') {
                  onEdit();
                } else if (value == 'delete') {
                  onDelete();
                }
              },
              itemBuilder: (BuildContext context) {
                return {'Edit', 'Delete'}.map((String choice) {
                  return PopupMenuItem<String>(
                    value: choice.toLowerCase(),
                    child: Text(choice),
                  );
                }).toList();
              },
            ),
          ),
        ],
      ),
    );
  }

  String? _normalizeImageUrl(dynamic rawUrl) {
    if (rawUrl is! String) return null;

    final url = rawUrl.trim();
    if (url.isEmpty) return null;

    final isAndroidDebug =
        kDebugMode &&
        !kIsWeb &&
        defaultTargetPlatform == TargetPlatform.android;
    if (!isAndroidDebug) return url;

    return url
        .replaceFirst(
          RegExp(r'^http://localhost(?=[:/])', caseSensitive: false),
          'http://10.0.2.2',
        )
        .replaceFirst(
          RegExp(r'^https://localhost(?=[:/])', caseSensitive: false),
          'https://10.0.2.2',
        );
  }

  String? _getLocalImagePath(dynamic rawPath) {
    if (rawPath is! String) return null;

    final path = rawPath.trim();
    if (path.isEmpty) return null;

    return path;
  }

  Widget _buildFlashcardImage({String? networkUrl, String? localPath}) {
    if (!kIsWeb && localPath != null && localPath.isNotEmpty) {
      return SizedBox(
        height: 150,
        width: double.infinity,
        child: Image.file(File(localPath), fit: BoxFit.contain),
      );
    }

    return SizedBox(
      height: 150,
      width: double.infinity,
      child: Image.network(networkUrl ?? '', fit: BoxFit.contain),
    );
  }
}
