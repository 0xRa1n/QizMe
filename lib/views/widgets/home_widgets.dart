import 'package:flutter/material.dart';
import 'package:qizme/services/card_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<String?> getEmailFromPreferences() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('email');
}

Widget buildSearchBar() {
  return Container(
    height: 43,
    decoration: BoxDecoration(
      color: Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.grey.shade300),
    ),
    child: const TextField(
      decoration: InputDecoration(
        prefixIcon: Icon(Icons.search, color: Colors.black54),
        hintText: 'Search',
        border: InputBorder.none,
      ),
    ),
  );
}

Widget buildStreakCard() {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 16),
    decoration: BoxDecoration(
      color: const Color(0xFFE0E0E0),
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Colors.black, width: 1.2),
    ),
    child: Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: const [
        Text('🔥', style: TextStyle(fontSize: 24)),
        SizedBox(width: 10),
        Text(
          'Earn a Streak!',
          style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
      ],
    ),
  );
}

Widget buildCalendarGrid() {
  return GridView.count(
    shrinkWrap: true,
    physics: const NeverScrollableScrollPhysics(),
    crossAxisCount: 7,
    mainAxisSpacing: 8,
    crossAxisSpacing: 8,
    children: List.generate(31, (index) {
      final isToday = (index + 1) == 19;
      return Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isToday ? const Color(0xFF2D6A4F) : Colors.transparent,
          borderRadius: BorderRadius.circular(4),
          border: isToday ? Border.all(color: Colors.black) : null,
        ),
        child: Text(
          '${index + 1}',
          style: TextStyle(
            color: isToday ? Colors.white : Colors.black,
            fontSize: 12,
          ),
        ),
      );
    }),
  );
}

Widget buildCalendarSection() {
  return Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFFF0F0F0),
      borderRadius: BorderRadius.circular(12),
      border: Border.all(color: Colors.black, width: 1),
    ),
    child: Column(
      children: [
        const Text("March 2026", style: TextStyle(fontWeight: FontWeight.bold)),
        const SizedBox(height: 15),
        buildCalendarGrid(),
      ],
    ),
  );
}

// This function constructs the Mastery Dashboard. It's a classic example of
// "lifting state up" by accepting a `VoidCallback`. This decouples the widget
// from the navigation logic, which is managed by its parent (`_QizMeState`).
// This makes `buildCreateSubjectCard` more reusable and testable.
Widget buildCreateSubjectCard({required VoidCallback onAddCardSet}) {
  // Kicking off an async operation directly in a build method is generally safe
  // for one-time fetches that are idempotent, like getting preferences.
  final emailFuture = getEmailFromPreferences();

  // The outer FutureBuilder resolves the user's email. This pattern creates a
  // dependency waterfall: this future must complete before the next one can start.
  // For more complex scenarios, consider a dedicated state management solution
  // (like Riverpod or Provider) to manage and provide such dependencies more cleanly.
  return FutureBuilder<String?>(
    future: emailFuture,
    builder: (context, snapshot) {
      // Standard boilerplate for handling a Future's lifecycle.
      if (snapshot.connectionState == ConnectionState.waiting) {
        return const Center(child: CircularProgressIndicator());
      } else if (snapshot.hasError) {
        // In a production app, you'd want to log this error to a monitoring service.
        return Text('Error fetching user data: ${snapshot.error}');
      } else {
        // The main layout for the dashboard.
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
                Text(
                  'Mastery Dashboard',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 16),
            // This nested FutureBuilder fetches the actual subject data. It depends
            // on the result of the parent FutureBuilder (the email).
            FutureBuilder<Map<String, dynamic>>(
              future: CardService.getCardSet(email: snapshot.data ?? ""),
              builder: (context, cardSnapshot) {
                if (cardSnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (cardSnapshot.hasError) {
                  return Text('Error loading subjects: ${cardSnapshot.error}');
                } else {
                  // Defensive programming: Safely access the 'raw' data and default to an
                  // empty list if it's null. This prevents runtime crashes from unexpected API responses.
                  final cards = cardSnapshot.data?['raw'] as List? ?? [];
                  if (cards.isEmpty) {
                    // This is the "empty state" UI. It's a crucial UX pattern that
                    // guides the user on what to do next instead of showing a blank screen.
                    return Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: const Color(0xFFD9D9D9),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: Colors.black, width: 1),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Create a subject to start learning!',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 13),
                          ElevatedButton(
                            onPressed:
                                onAddCardSet, // Trigger the callback passed from the parent.
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF2D6A4F),
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
                  // If we have data, render the list of subjects.
                  return Column(
                    children: [
                      const SizedBox(height: 8),
                      // Using ListView inside a Column requires `shrinkWrap: true` to give the
                      // ListView a bounded height. `NeverScrollableScrollPhysics` is used because
                      // the parent `SingleChildScrollView` in `_buildHomePage` handles the scrolling.
                      // This prevents nested scrolling conflicts.
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: cards.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final card = cards[index];
                          // Data transformation: The progress is assumed to be a percentage (0-100)
                          // from the backend, so we normalize it to a 0.0-1.0 scale for the UI.
                          // The key 'cardCompletionPercentage' must match the API response exactly.
                          final progress =
                              (card['cardCompletionPercentage'] as num? ??
                                  0.0) /
                              100.0;
                          return SubjectProgressCard(
                            subjectName: card['title'] ?? 'No Title',
                            progress: progress,
                          );
                        },
                      ),
                    ],
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

// This StatefulWidget encapsulates the animated progress bar. Making it a separate
// widget improves performance because only this small part of the UI rebuilds
// during the animation, not the entire dashboard.
class SubjectProgressCard extends StatefulWidget {
  final String subjectName;
  final double progress; // Normalized to a 0.0 to 1.0 scale.

  const SubjectProgressCard({
    super.key,
    required this.subjectName,
    required this.progress,
  });

  @override
  State<SubjectProgressCard> createState() => _SubjectProgressCardState();
}

// Using `SingleTickerProviderStateMixin` provides the `Ticker` that drives the animation.
// It's "single" because we're only using one AnimationController.
class _SubjectProgressCardState extends State<SubjectProgressCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    // The AnimationController is the conductor of our animation.
    _controller = AnimationController(
      duration: const Duration(
        milliseconds: 800,
      ), // A pleasant, not-too-fast duration.
      vsync:
          this, // `vsync` is crucial for performance; it pauses the animation when the widget is off-screen.
    );

    // A `Tween` defines the start and end points of an animation. Here, we animate from 0 to the target progress.
    // `CurvedAnimation` with `Curves.easeInOut` gives the animation a smooth acceleration and deceleration.
    _animation = Tween<double>(
      begin: 0.0,
      end: widget.progress,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

    // Launch the animation.
    _controller.forward();
  }

  // This lifecycle method is critical for handling cases where the widget is rebuilt
  // with new data (e.g., progress updates from a data refresh).
  @override
  void didUpdateWidget(SubjectProgressCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only re-animate if the progress value has actually changed.
    if (widget.progress != oldWidget.progress) {
      // Create a new animation that tweens from the *old* progress value to the new one.
      // This ensures a smooth transition rather than jumping back to 0.
      _animation = Tween<double>(
        begin: oldWidget.progress,
        end: widget.progress,
      ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));

      // Resetting and forwarding the controller restarts the animation with the new tween.
      _controller
        ..reset()
        ..forward();
    }
  }

  // Proper resource management: dispose of the controller to prevent memory leaks.
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  // A utility method to map a data value (progress) to a UI property (color).
  // This keeps the logic separate from the build method.
  Color _getProgressColor(double progress) {
    if (progress >= 1.0) return Colors.yellow.shade700;
    if (progress > 0.4) return Colors.green;
    return Colors.lightGreen;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.black54, width: 1),
        boxShadow: [
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
                widget.subjectName,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
              Text(
                '${(widget.progress * 100).toInt()}% Completed',
                style: const TextStyle(fontSize: 14, color: Colors.black54),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // `AnimatedBuilder` is a performance-optimized widget that rebuilds only its
          // `builder` closure when the animation's value changes.
          AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              // The outer container is the track of the progress bar.
              return Container(
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: Colors.grey.shade400),
                ),
                // `FractionallySizedBox` is an efficient way to size a child as a
                // fraction of the available space. Here, we use the animation's
                // current value to set the width of the progress indicator.
                child: FractionallySizedBox(
                  alignment: Alignment.centerLeft,
                  widthFactor: _animation.value,
                  // The inner container is the "fill" of the progress bar.
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
    );
  }
}
