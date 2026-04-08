import 'package:flutter/material.dart';
import 'package:qizme/services/card_service.dart';

class EditFlashcardPage extends StatefulWidget {
  final bool darkMode;
  final Map<String, dynamic> flashcard;
  final String cardId;
  final VoidCallback onDone;

  const EditFlashcardPage({
    Key? key,
    required this.darkMode,
    required this.flashcard,
    required this.cardId,
    required this.onDone,
  }) : super(key: key);

  @override
  State<EditFlashcardPage> createState() => _EditFlashcardPageState();
}

class _EditFlashcardPageState extends State<EditFlashcardPage> {
  late TextEditingController _frontController;
  late TextEditingController _backController;
  bool _isFrontEmpty = false;
  bool _isBackEmpty = false;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(
      text: widget.flashcard['question'] ?? '',
    );
    _backController = TextEditingController(
      text: widget.flashcard['answer'] ?? '',
    );
  }

  @override
  void dispose() {
    _frontController.dispose();
    _backController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = widget.darkMode;
    final Color textColor = isDark ? Colors.white : Colors.black;
    final Color hintColor = isDark ? Colors.white54 : Colors.black38;
    final Color cardBackgroundColor = isDark
        ? const Color(0xFF2C2C2C)
        : const Color(0xFFE0E0E0);
    final Color textFieldColor = isDark
        ? const Color(0xFF1E1E1E)
        : Colors.white;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _buildCardSide(
            title: 'Front',
            hintText: 'Question',
            controller: _frontController,
            backgroundColor: cardBackgroundColor,
            textFieldColor: textFieldColor,
            textColor: textColor,
            hintColor: hintColor,
            isError: _isFrontEmpty,
          ),
          const SizedBox(height: 16),
          _buildCardSide(
            title: 'Back',
            hintText: 'Definition/Answer',
            controller: _backController,
            backgroundColor: cardBackgroundColor,
            textFieldColor: textFieldColor,
            textColor: textColor,
            hintColor: hintColor,
            showCheckbox: true,
            isError: _isBackEmpty,
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isFrontEmpty = _frontController.text.trim().isEmpty;
                _isBackEmpty = _backController.text.trim().isEmpty;
              });

              if (_isFrontEmpty || _isBackEmpty) {
                return;
              }

              // TODO: Implement actual API call to update the flashcard here
              // You have access to both IDs like this:
              final flashcardId = widget.flashcard['_id'];
              final cardId = widget.cardId;

              try {
                await CardService.updateFlashcard(
                  flashcardID: flashcardId,
                  front: _frontController.text,
                  back: _backController.text,
                  cardID: cardId,
                );

                if (mounted) {
                  // Update the local flashcard map so the UI reflects changes immediately
                  widget.flashcard['question'] = _frontController.text;
                  widget.flashcard['answer'] = _backController.text;

                  await showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: const Text('Success'),
                      content: const Text('Flashcard edited successfully'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('OK'),
                        ),
                      ],
                    ),
                  );

                  if (mounted) {
                    widget.onDone();
                  }
                }
              } catch (e) {
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error updating card: $e')),
                  );
                }
              }
            },
            style: ElevatedButton.styleFrom(
              foregroundColor: textColor,
              backgroundColor: cardBackgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
                side: BorderSide(
                  color: isDark ? Colors.white30 : Colors.black54,
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 12),
            ),
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  Widget _buildCardSide({
    required String title,
    required String hintText,
    required TextEditingController controller,
    required Color backgroundColor,
    required Color textFieldColor,
    required Color textColor,
    required Color hintColor,
    bool showCheckbox = false,
    bool isError = false,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.black54),
      ),
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: textColor,
                ),
              ),
              if (showCheckbox)
                Container(
                  width: 16,
                  height: 16,
                  decoration: BoxDecoration(
                    color: Colors.lightGreenAccent,
                    border: Border.all(color: Colors.black),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: textFieldColor,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isError ? Colors.red : Colors.black38,
                width: isError ? 1.5 : 1.0,
              ),
            ),
            child: Stack(
              children: [
                TextField(
                  controller: controller,
                  maxLines: 4,
                  style: TextStyle(color: textColor),
                  cursorColor: textColor,
                  decoration: InputDecoration(
                    hintText: hintText,
                    hintStyle: TextStyle(color: hintColor),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.all(12),
                  ),
                ),
                Positioned(
                  bottom: 8,
                  right: 8,
                  child: Icon(Icons.image_outlined, color: hintColor),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
