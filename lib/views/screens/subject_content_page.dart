import 'package:flutter/material.dart';
import 'package:qizme/services/card_service.dart';
import 'package:qizme/services/streak_service.dart';
import 'package:qizme/views/screens/study_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

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

      if (!isAlreadyStudiedToday) {
        await StreakService.recordReview(userId);
      }
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
                                      print(
                                        'card ID: ${widget.subject['_id']}, flashcard ID: ${flashcard['_id']}',
                                      );
                                      try {
                                        await CardService.deleteFlashcard(
                                          cardID: widget.subject['_id'],
                                          flashcardID: flashcard['_id'],
                                        );
                                        setState(() {
                                          flashcards.removeAt(index);
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

    return Card(
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      child: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  flashcard['question'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  flashcard['answer'] ?? '',
                  style: TextStyle(
                    color: darkMode ? Colors.white70 : Colors.black54,
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 0,
            right: 0,
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
}
