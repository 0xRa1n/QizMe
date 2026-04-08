import 'package:flutter/material.dart';
import 'package:qizme/services/card_service.dart';

class CreateFlashcardPage extends StatefulWidget {
  final bool darkMode;
  final String cardId;
  final void Function(Map<String, dynamic>)? onFlashcardAdded;
  final VoidCallback? onDone;

  const CreateFlashcardPage({
    Key? key,
    required this.darkMode,
    required this.cardId,
    this.onFlashcardAdded,
    this.onDone,
  }) : super(key: key);

  @override
  State<CreateFlashcardPage> createState() => _CreateFlashcardPageState();
}

class _CreateFlashcardPageState extends State<CreateFlashcardPage> {
  final TextEditingController _frontController = TextEditingController();
  final TextEditingController _backController = TextEditingController();
  final List<Map<String, String>> _addedCards = [];
  bool _isLoading = false;
  bool _isFrontEmpty = false;
  bool _isBackEmpty = false;

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
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Cards: ${_addedCards.length}',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
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
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: _isLoading
                    ? null
                    : () async {
                        setState(() {
                          _isFrontEmpty = _frontController.text.trim().isEmpty;
                          _isBackEmpty = _backController.text.trim().isEmpty;
                        });

                        if (_isFrontEmpty || _isBackEmpty) {
                          return;
                        }

                        setState(() {
                          _isLoading = true;
                        });

                        try {
                          await CardService.createFlashcards(
                            question: _frontController.text,
                            answer: _backController.text,
                            flashcardColor: "#FFFFFF",
                            flashcardID: widget.cardId,
                          );

                          if (mounted) {
                            // notify the user by having a dialog
                            showDialog(
                              context: context,
                              builder: (context) => AlertDialog(
                                title: const Text('Success'),
                                content: const Text(
                                  'Flashcard added successfully',
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.pop(context),
                                    child: const Text('OK'),
                                  ),
                                ],
                              ),
                            );

                            setState(() {
                              final newCard = {
                                'question': _frontController.text,
                                'answer': _backController.text,
                              };
                              _addedCards.insert(0, newCard);
                              _frontController.clear();
                              _backController.clear();
                              _isFrontEmpty = false;
                              _isBackEmpty = false;

                              if (widget.onFlashcardAdded != null) {
                                widget.onFlashcardAdded!(newCard);
                              }
                            });
                          }
                        } catch (e) {
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error adding card: $e')),
                            );
                          }
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isLoading = false;
                            });
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Add'),
              ),
              ElevatedButton(
                onPressed: () {
                  if (widget.onDone != null) {
                    widget.onDone!();
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
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                ),
                child: const Text('Done'),
              ),
            ],
          ),
          if (_addedCards.isNotEmpty) ...[
            const SizedBox(height: 24),
            Text(
              'Added cards',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: textColor,
              ),
            ),
            const SizedBox(height: 12),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _addedCards.length,
              itemBuilder: (context, index) {
                final card = _addedCards[index];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: cardBackgroundColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.black54),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        card['question'] ?? '',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        card['answer'] ?? '',
                        style: TextStyle(fontSize: 14, color: hintColor),
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
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
