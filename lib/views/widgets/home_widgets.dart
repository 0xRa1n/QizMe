import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:qizme/services/card_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/services/streak_service.dart';

// NOTE: The duplicate SettingsPage class has been removed from this file.

Future<String?> getEmailFromPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}

Widget buildSearchBar({required bool darkMode, required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: Container(
      height: 43,
      decoration: BoxDecoration(
        color: darkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
        border: darkMode ? null : Border.all(color: Colors.grey.shade300),
      ),
      child: AbsorbPointer(
        child: TextField(
          style: TextStyle(color: darkMode ? Colors.white70 : Colors.black87),
          decoration: InputDecoration(
            prefixIcon: Icon(
              Icons.search,
              color: darkMode ? Colors.grey[400] : Colors.black54,
            ),
            hintText: 'Search',
            hintStyle: TextStyle(
              color: darkMode ? Colors.grey[400] : Colors.black54,
            ),
            border: InputBorder.none,
          ),
        ),
      ),
    ),
  );
}

Widget buildStreakCard({required bool darkMode, required String userId}) {
  // The Future is now passed directly to the FutureBuilder
  return FutureBuilder<Map<String, dynamic>>(
    future: StreakService.getStreakCount(userId),
    builder: (context, snapshot) {
      String streakText;
      Widget streakContent;

      if (snapshot.connectionState == ConnectionState.waiting) {
        // While the Future is loading, show a loading indicator
        streakContent = const SizedBox(
          height: 28, // Maintain height to avoid layout shifts
          width: 28,
          child: CircularProgressIndicator(
            strokeWidth: 3,
            color: Colors.orange,
          ),
        );
      } else if (snapshot.hasError) {
        // If an error occurs, display an error message
        streakText = 'Error';
        streakContent = Text(
          streakText,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        );
      } else if (snapshot.hasData) {
        // When the Future completes successfully, parse the data
        final streakData = snapshot.data!;
        final streakCount = (streakData['raw']['data']['currentStreak'] as num)
            .toInt();

        if (streakCount > 0) {
          streakText = '$streakCount-day Streak!';
        } else {
          streakText = 'Earn a Streak!';
        }
        streakContent = Text(
          streakText,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        );
      } else {
        // Fallback for an unlikely state (no data, no error)
        streakText = 'Earn a Streak!';
        streakContent = Text(
          streakText,
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        );
      }

      // This is the main container that will be returned in all cases
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 16),
        decoration: BoxDecoration(
          color: darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.circular(16),
          border: darkMode ? null : Border.all(color: Colors.black, width: 1.2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 10),
            // The content (loading indicator or text) is placed here
            streakContent,
          ],
        ),
      );
    },
  );
}

Widget buildCalendarGrid({required bool darkMode, required String userId}) {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

  return FutureBuilder<Map<String, dynamic>>(
    future: StreakService.getReviewHistory(userId),
    builder: (context, snapshot) {
      // While loading, show a placeholder grid or a loading indicator
      if (snapshot.connectionState == ConnectionState.waiting) {
        return GridView.count(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: 7,
          children: List.generate(
            daysInMonth,
            (index) => const SizedBox(),
          ), // Placeholder
        );
      }

      // If there's an error, you could show an error message
      if (snapshot.hasError) {
        return const Center(child: Text('Could not load history'));
      }

      // Once data is loaded, parse the active dates
      Set<int> activeDays = {};
      if (snapshot.hasData) {
        try {
          final List<dynamic> activeDatesList =
              snapshot.data?['raw']?['data']?['activeDates'] ?? [];
          activeDays = activeDatesList
              .map((dateStr) {
                // Add a type check for safety
                if (dateStr is String) {
                  // DateTime.parse handles the full ISO 8601 timestamp
                  final date = DateTime.parse(dateStr);
                  // Check if the date is in the current month and year before adding the day
                  if (date.year == now.year && date.month == now.month) {
                    return date.day;
                  }
                }
                return -1; // Return an invalid day for non-strings or wrong month/year
              })
              .where((day) => day != -1)
              .toSet();
        } catch (e) {
          print('Error parsing active dates: $e');
          // Keep activeDays empty if parsing fails
        }
      }

      return GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 7,
        mainAxisSpacing: 8,
        crossAxisSpacing: 8,
        children: List.generate(daysInMonth, (index) {
          final day = index + 1;
          final isToday = day == now.day;
          final isActiveDay = activeDays.contains(day);

          Color? color;
          Color textColor;

          // Updated Color Logic
          if (isToday) {
            color = const Color.fromARGB(
              255,
              45,
              106,
              79,
            ); // Keep Today's color distinct
            textColor = Colors.white;
          } else if (isActiveDay) {
            color = const Color.fromARGB(
              255,
              45,
              106,
              79,
            ); // Green for active streak days
            textColor = Colors.white;
          } else {
            color = Colors.transparent;
            textColor = darkMode
                ? Colors.white.withOpacity(0.6)
                : Colors.black54;
          }

          return Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              '$day',
              style: TextStyle(
                color: textColor,
                fontSize: 12,
                fontWeight: isToday || isActiveDay
                    ? FontWeight.bold
                    : FontWeight.normal,
              ),
            ),
          );
        }),
      );
    },
  );
}

Widget buildCalendarSection({required bool darkMode}) {
  final now = DateTime.now();
  final monthYear = DateFormat('MMMM yyyy').format(now);

  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: darkMode ? const Color(0xFF1E1E1E) : const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(12),
      border: darkMode ? null : Border.all(color: Colors.black, width: 1),
    ),
    child: Column(
      children: [
        Text(
          monthYear,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: darkMode ? Colors.white : Colors.black,
          ),
        ),
        const SizedBox(height: 15),
        // Use a FutureBuilder to get the userId from SharedPreferences
        FutureBuilder<String?>(
          future: SharedPreferences.getInstance().then(
            (prefs) => prefs.getString('id'),
          ),
          builder: (context, snapshot) {
            // While waiting for the userId, you can show a loading state
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            }

            // If there's an error or no userId, you can handle it gracefully
            if (snapshot.hasError ||
                !snapshot.hasData ||
                snapshot.data == null) {
              return const Text('Could not load user data.');
            }

            // Once you have the userId, build the calendar grid
            final userId = snapshot.data!;
            return buildCalendarGrid(darkMode: darkMode, userId: userId);
          },
        ),
      ],
    ),
  );
}

Widget buildCreateSubjectCard({
  required VoidCallback onAddCardSet,
  required bool darkMode,
  required Function(Map<String, dynamic>) onSubjectTap,
}) {
  final emailFuture = getEmailFromPreferences();

  return FutureBuilder<String?>(
    future: emailFuture,
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        return Text('Error fetching user data: ${snapshot.error}');
      } else {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Mastery Dashboard',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: darkMode ? Colors.white : Colors.black,
              ),
            ),
            const SizedBox(height: 16),
            FutureBuilder<Map<String, dynamic>>(
              future: CardService.getCardSet(email: snapshot.data ?? ""),
              builder: (context, cardSnapshot) {
                if (cardSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (cardSnapshot.hasError) {
                  return Text('Error loading subjects: ${cardSnapshot.error}');
                } else {
                  final cards = cardSnapshot.data?['raw'] as List? ?? [];
                  if (cards.isEmpty) {
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: darkMode
                            ? const Color(0xFF1E1E1E)
                            : const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(16),
                        border: darkMode
                            ? null
                            : Border.all(color: Colors.black, width: 1),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Create a subject to start learning!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: darkMode ? Colors.white : Colors.black,
                            ),
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: onAddCardSet,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color.fromARGB(
                                255,
                                45,
                                106,
                                79,
                              ),
                              minimumSize: const Size(200, 50),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(25),
                              ),
                            ),
                            child: const Text(
                              'Create',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }
                  return ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: cards.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final card = cards[index];
                      return SubjectProgressCard(
                        subject: card,
                        darkMode: darkMode,
                        onTap: () => onSubjectTap(card),
                      );
                    },
                  );
                }
              },
            ),
          ],
        );
      }
    },
  );
}

class SubjectProgressCard extends StatefulWidget {
  final Map<String, dynamic> subject;
  final bool darkMode;
  final VoidCallback onTap;

  const SubjectProgressCard({
    super.key,
    required this.subject,
    required this.darkMode,
    required this.onTap,
  });

  @override
  State<SubjectProgressCard> createState() => _SubjectProgressCardState();
}

class _SubjectProgressCardState extends State<SubjectProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  late double _progress;

  @override
  void initState() {
    super.initState();
    _progress =
        (widget.subject['cardCompletionPercentage'] as num? ?? 0.0) / 100.0;
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _animation = Tween<double>(
      begin: 0.0,
      end: _progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _controller.forward();
  }

  @override
  void didUpdateWidget(SubjectProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    final newProgress =
        (widget.subject['cardCompletionPercentage'] as num? ?? 0.0) / 100.0;
    if (newProgress != _progress) {
      _animation = Tween<double>(
        begin: _progress,
        end: newProgress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
      _progress = newProgress;
      _controller
        ..reset()
        ..forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.amber.shade600;
    if (progress > 0.0) return const Color.fromARGB(255, 45, 106, 79);
    return Colors.transparent;
  }

  @override
  Widget build(BuildContext context) {
    final subjectName = widget.subject['title'] ?? 'No Title';
    final progress =
        (widget.subject['cardCompletionPercentage'] as num? ?? 0.0) / 100.0;

    return InkWell(
      onTap: widget.onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: widget.darkMode ? const Color(0xFF1E1E1E) : Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
          border: widget.darkMode
              ? null
              : Border.all(color: Colors.black54, width: 1),
          boxShadow: widget.darkMode
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  subjectName,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: widget.darkMode ? Colors.white : Colors.black,
                  ),
                ),
                Text(
                  '${(progress * 100).toInt()}% Completed',
                  style: TextStyle(
                    fontSize: 14,
                    color: widget.darkMode
                        ? Colors.white.withOpacity(0.6)
                        : Colors.black54,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return Container(
                  height: 12,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                    color: widget.darkMode
                        ? Colors.black.withOpacity(0.3)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(6),
                    border: widget.darkMode
                        ? null
                        : Border.all(color: Colors.grey.shade400),
                  ),
                  child: FractionallySizedBox(
                    alignment: Alignment.centerLeft,
                    widthFactor: _animation.value,
                    child: Container(
                      decoration: BoxDecoration(
                        color: _getProgressColor(_animation.value),
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
