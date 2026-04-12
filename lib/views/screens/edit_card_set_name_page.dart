import 'package:flutter/material.dart';

class EditCardSetNamePage extends StatefulWidget {
  final bool darkMode;
  final Map<String, dynamic> cardSet;
  final ValueChanged<String> onSave;
  final VoidCallback onCancel;

  const EditCardSetNamePage({
    super.key,
    required this.darkMode,
    required this.cardSet,
    required this.onSave,
    required this.onCancel,
  });

  @override
  State<EditCardSetNamePage> createState() => _EditCardSetNamePageState();
}

class _EditCardSetNamePageState extends State<EditCardSetNamePage> {
  late final TextEditingController _nameController;
  bool _showNameError = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(
      text: (widget.cardSet['title'] ?? '').toString(),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
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
            'Edit card set name',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            decoration: BoxDecoration(
              color: cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.black54),
            ),
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Card set name',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: textColor,
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  decoration: BoxDecoration(
                    color: textFieldColor,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _showNameError ? Colors.red : Colors.black38,
                      width: _showNameError ? 1.5 : 1.0,
                    ),
                  ),
                  child: TextField(
                    controller: _nameController,
                    style: TextStyle(color: textColor),
                    cursorColor: textColor,
                    onChanged: (value) {
                      if (_showNameError && value.trim().isNotEmpty) {
                        setState(() {
                          _showNameError = false;
                        });
                      }
                    },
                    decoration: InputDecoration(
                      hintText: 'Enter a card set name',
                      hintStyle: TextStyle(color: hintColor),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
                if (_showNameError) ...[
                  const SizedBox(height: 8),
                  const Text(
                    'Please enter a card set name',
                    style: TextStyle(color: Colors.red, fontSize: 12),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              ElevatedButton(
                onPressed: widget.onCancel,
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
                child: const Text('Cancel'),
              ),
              ElevatedButton(
                onPressed: () {
                  final newName = _nameController.text.trim();
                  if (newName.isEmpty) {
                    setState(() {
                      _showNameError = true;
                    });
                    return;
                  }
                  widget.onSave(newName);
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
                child: const Text('Save'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
