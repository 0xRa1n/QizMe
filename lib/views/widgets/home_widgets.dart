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

Widget buildSearchBar({required bool darkMode}) {
  return Container(
    height: 43,
    decoration: BoxDecoration(
      color: darkMode ? const Color(0xFF1E1E1E) : Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: darkMode ? null : Border.all(color: Colors.grey.shade300),
    ),
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

Widget buildCalendarGrid({required bool darkMode}) {
  final now = DateTime.now();
  final daysInMonth = DateTime(now.year, now.month + 1, 0).day;

  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 7,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    children: List.generate(daysInMonth, (index) {
      final day = index + 1;
      final isToday = day == now.day;
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isToday
              ? const Color.fromARGB(255, 45, 106, 79)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          '$day',
          style: TextStyle(
            color: isToday
                ? Colors.white
                : (darkMode ? Colors.white.withOpacity(0.6) : Colors.black54),
            fontSize: 12,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      );
    }),
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
        buildCalendarGrid(darkMode: darkMode),
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
