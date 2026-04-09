import 'package:flutter/material.dart';
import 'package:qizme/views/screens/subject_content_page.dart';

class SubjectPage extends StatelessWidget {
  final Map<String, dynamic> subject;
  final VoidCallback onBack;
  final Function(Map<String, dynamic> flashcard) onEditFlashcard;

  const SubjectPage({
    Key? key,
    required this.subject,
    required this.onBack,
    required this.onEditFlashcard,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final darkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        title: Text(subject['title'] ?? 'Subject'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: onBack,
        ),
        backgroundColor: darkMode ? Colors.grey[900] : Colors.white,
        foregroundColor: darkMode ? Colors.white : Colors.black,
        elevation: 1,
      ),
      body: SubjectContentPage(
        subject: subject,
        onEditFlashcard: onEditFlashcard,
      ),
    );
  }
}
