import 'package:flutter/material.dart';

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
          color: isToday ? Color(0xFF2D6A4F) : Colors.transparent,
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

Widget buildCreateSubjectCard() {
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
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 13),
        ElevatedButton(
          onPressed: () {},
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF2D6A4F),
            minimumSize: const Size(200, 50),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
          ),
          child: const Text(
            'Create',
            style: TextStyle(fontSize: 18, color: Colors.white),
          ),
        ),
      ],
    ),
  );
}
