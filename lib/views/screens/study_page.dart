import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'package:qizme/views/screens/increased_streak_screen.dart';
import 'package:qizme/services/streak_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StudyPage extends StatefulWidget {
  final List<dynamic> flashcards;
  final String subjectTitle;
  final String cardId;
  final int initialCompletionPercentage;

  const StudyPage({
    Key? key,
    required this.flashcards,
    required this.subjectTitle,
    required this.cardId,
    required this.initialCompletionPercentage,
  }) : super(key: key);

  @override
  State<StudyPage> createState() => _StudyPageState();
}

class _StudyPageState extends State<StudyPage> {
  int _currentIndex = 0;
  bool _isFlipped = false;
  bool _streakAlreadyIncreasedToday = false;

  void _nextCard() {
    // Calculate the percentage for the card that was just completed.
    final newPercentage = ((_currentIndex + 1) / widget.flashcards.length * 100)
        .toInt();

    // Only update if the new percentage is valid and the card is not already 100% complete.
    if (widget.initialCompletionPercentage < 100 &&
        _currentIndex < widget.flashcards.length) {
      StreakService.updateStreakPercentage(widget.cardId, newPercentage);
    }

    // Then, move to the next card.
    setState(() {
      _currentIndex++;
      _isFlipped = false;
    });
  }

  void _previousCard() {
    setState(() {
      _currentIndex = max(0, _currentIndex - 1);
      _isFlipped = false;
    });
  }

  void _flipCard() {
    setState(() {
      _isFlipped = !_isFlipped;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final totalCards = widget.flashcards.length;

    // Calculate progress based on current index vs total
    final double progress = totalCards == 0 ? 0.0 : _currentIndex / totalCards;

    // Handle empty flashcards
    if (totalCards == 0) {
      return Scaffold(
        appBar: AppBar(title: Text(widget.subjectTitle)),
        body: const Center(child: Text('No flashcards available to study.')),
      );
    }

    // Handle study completion
    if (_currentIndex >= totalCards) {
      const Color kPrimaryGreen = Color(0xFF6B8E60);
      const Color kButtonGrey = Color(0xFFE0E0E0);

      return Scaffold(
        backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? const Color(0xFF121212) : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(
              Icons.arrow_back,
              color: isDark ? Colors.white : Colors.black,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                Container(
                  height: 180,
                  width: 180,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.grey.shade800
                        : const Color(0xFFEEEEEE),
                    border: Border.all(
                      color: isDark
                          ? Colors.grey.shade600
                          : Colors.grey.shade400,
                    ),
                  ),
                  child: Center(
                    child: Icon(
                      Icons.check,
                      color: isDark ? Colors.grey.shade300 : Colors.grey,
                      size: 120,
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                Text(
                  'Quiz Finished!',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'You have successfully finished the card!',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 20),
                Text(
                  'Score: 100',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black,
                  ),
                ),
                const Spacer(),
                Column(
                  children: [
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () {
                          setState(() {
                            _currentIndex = 0;
                            _isFlipped = false;
                          });
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isDark
                              ? Colors.grey.shade800
                              : kButtonGrey,
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Practice Again',
                          style: TextStyle(fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      height: 55,
                      child: ElevatedButton(
                        onPressed: () async {
                          final prefs = await SharedPreferences.getInstance();
                          final userId = prefs.getString('id');

                          if (userId == null) {
                            print("User ID is null. Cannot proceed.");
                            Navigator.pop(context);
                            return;
                          }

                          try {
                            // Get the streak count *before* recording the review.
                            final initialStreakData =
                                await StreakService.getStreakCount(userId);
                            print(
                              "Initial Streak Data: ${initialStreakData['raw']}",
                            );
                            final initialStreak =
                                initialStreakData['raw']['data']['currentStreak'] ??
                                0;
                            print("Initial Streak Count: $initialStreak");

                            // Record the review.
                            final reviewResponse =
                                await StreakService.recordReview(userId);
                            print("Review Response: ${reviewResponse['raw']}");
                            final newStreak =
                                reviewResponse['raw']['data']['currentStreak'] ??
                                initialStreak;
                            print("New Streak Count from Response: $newStreak");

                            if (newStreak > initialStreak &&
                                !_streakAlreadyIncreasedToday) {
                              print("Streak increased! Showing screen.");
                              setState(() {
                                _streakAlreadyIncreasedToday = true;
                              });
                              if (mounted) {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => StreakIncreasedScreen(
                                      streakCount: newStreak,
                                    ),
                                  ),
                                );
                                // After the streak screen is dismissed, pop the study page.
                                if (mounted) {
                                  Navigator.pop(context);
                                }
                              }
                            } else {
                              print("Streak did not increase. Popping back.");
                              if (mounted) {
                                Navigator.pop(context);
                              }
                            }
                          } catch (e) {
                            print('CRITICAL ERROR during streak logic: $e');
                            if (mounted) {
                              Navigator.pop(context);
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: kPrimaryGreen,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Continue',
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      );
    }

    final currentCard = widget.flashcards[_currentIndex];
    final question = currentCard['question']?.toString();
    final answer = currentCard['answer']?.toString();
    final questionImage = _normalizeImageUrl(currentCard['questionImage']);
    final answerImage = _normalizeImageUrl(currentCard['answerImage']);

    return Scaffold(
      backgroundColor: isDark
          ? const Color(0xFF121212)
          : const Color(0xFFF5F5F5),
      body: SafeArea(
        child: Column(
          children: [
            // Top Bar
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 8.0,
              ),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, size: 28),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 12,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Text(
                    '${(progress * 100).toInt()}%',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            // Card Area
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: GestureDetector(
                  onTap: _flipCard,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 300),
                    transitionBuilder:
                        (Widget child, Animation<double> animation) {
                          final rotate = Tween(
                            begin: pi,
                            end: 0.0,
                          ).animate(animation);
                          return AnimatedBuilder(
                            animation: rotate,
                            child: child,
                            builder: (BuildContext context, Widget? child) {
                              final isUnder =
                                  (ValueKey(_isFlipped) != child?.key);
                              var tilt =
                                  ((animation.value - 0.5).abs() - 0.5) * 0.003;
                              tilt = tilt * (isUnder ? -1.0 : 1.0);
                              final value = isUnder
                                  ? min(rotate.value, pi / 2)
                                  : rotate.value;
                              return Transform(
                                transform: Matrix4.rotationY(value)
                                  ..setEntry(3, 0, tilt),
                                alignment: Alignment.center,
                                child: child,
                              );
                            },
                          );
                        },
                    child: ClipRRect(
                      key: ValueKey<bool>(_isFlipped),
                      borderRadius: BorderRadius.circular(24),
                      child: Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: _isFlipped
                              ? (isDark ? Colors.grey.shade800 : Colors.white)
                              : (isDark ? Colors.grey.shade800 : Colors.white),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              spreadRadius: 2,
                              blurRadius: 10,
                              offset: const Offset(0, 5),
                            ),
                          ],
                        ),
                        child: _isFlipped
                            ? _buildCardFace(
                                text: answer,
                                imageUrl: answerImage,
                                fallbackText: 'No Answer',
                              )
                            : _buildCardFace(
                                text: question,
                                imageUrl: questionImage,
                                fallbackText: 'No Question',
                              ),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            // Bottom Action Buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: AnimatedOpacity(
                opacity: _isFlipped ? 1.0 : 0.0,
                duration: const Duration(milliseconds: 200),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: isDark ? Colors.white : Colors.black,
                          side: BorderSide(
                            color: isDark ? Colors.white54 : Colors.black54,
                          ),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isFlipped ? _previousCard : null,
                        child: Text(
                          'Study Again',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: Colors.white,
                          backgroundColor: Colors.green,
                          side: const BorderSide(color: Colors.green),
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: _isFlipped ? _nextCard : null,
                        child: Text(
                          'I got it',
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildCardFace({
    required String? text,
    required dynamic imageUrl,
    required String fallbackText,
  }) {
    final hasImage = imageUrl is String && imageUrl.trim().isNotEmpty;
    final hasText = text != null && text.trim().isNotEmpty;

    if (!hasImage) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Text(
            hasText ? text : fallbackText,
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w500),
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final imageMaxHeight = hasText
            ? constraints.maxHeight * 0.62
            : constraints.maxHeight * 0.82;

        return Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 20.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: constraints.maxWidth,
                    maxHeight: imageMaxHeight,
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: Image.network(
                      imageUrl.trim(),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        return const SizedBox.shrink();
                      },
                    ),
                  ),
                ),
                if (hasText) const SizedBox(height: 16),
                if (hasText)
                  Text(
                    text,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
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
}
