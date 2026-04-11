import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qizme/services/card_service.dart';
import 'dart:io';

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
  final ImagePicker _imagePicker = ImagePicker();
  bool _isFrontEmpty = false;
  bool _isBackEmpty = false;
  String? _frontImagePath;
  String? _backImagePath;
  String? _existingQuestionImageUrl;
  String? _existingAnswerImageUrl;
  String? _existingQuestionImagePath;
  String? _existingAnswerImagePath;

  @override
  void initState() {
    super.initState();
    _frontController = TextEditingController(
      text: widget.flashcard['question'] ?? '',
    );
    _backController = TextEditingController(
      text: widget.flashcard['answer'] ?? '',
    );
    _existingQuestionImageUrl = _normalizeImageUrl(
      _pickFirstString(widget.flashcard, const [
        'questionImage',
        'question_image',
        'frontImage',
        'front_image',
      ]),
    );
    _existingAnswerImageUrl = _normalizeImageUrl(
      _pickFirstString(widget.flashcard, const [
        'answerImage',
        'answer_image',
        'backImage',
        'back_image',
      ]),
    );
    _existingQuestionImagePath = _pickFirstString(widget.flashcard, const [
      'questionImagePath',
      'question_image_path',
      'frontImagePath',
      'front_image_path',
    ]);
    _existingAnswerImagePath = _pickFirstString(widget.flashcard, const [
      'answerImagePath',
      'answer_image_path',
      'backImagePath',
      'back_image_path',
    ]);
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
            selectedImagePath: _frontImagePath,
            existingImageUrl: _frontImagePath == null
                ? _existingQuestionImageUrl
                : null,
            existingImagePath: _frontImagePath == null
                ? _existingQuestionImagePath
                : null,
            onImageTap: () => _showImageSourceSheet(isFront: true),
            hideTextFieldWhenImageSelected: true,
            onRemoveImage: () {
              setState(() {
                _frontImagePath = null;
                _existingQuestionImageUrl = null;
                _existingQuestionImagePath = null;
              });
            },
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
            selectedImagePath: _backImagePath,
            existingImageUrl: _backImagePath == null
                ? _existingAnswerImageUrl
                : null,
            existingImagePath: _backImagePath == null
                ? _existingAnswerImagePath
                : null,
            onImageTap: () => _showImageSourceSheet(isFront: false),
            hideTextFieldWhenImageSelected: true,
            onRemoveImage: () {
              setState(() {
                _backImagePath = null;
                _existingAnswerImageUrl = null;
                _existingAnswerImagePath = null;
              });
            },
          ),
          const SizedBox(height: 32),
          ElevatedButton(
            onPressed: () async {
              setState(() {
                _isFrontEmpty =
                    _frontController.text.trim().isEmpty &&
                    _frontImagePath == null &&
                    _existingQuestionImageUrl == null;
                _isBackEmpty =
                    _backController.text.trim().isEmpty &&
                    _backImagePath == null &&
                    _existingAnswerImageUrl == null;
              });

              if (_isFrontEmpty || _isBackEmpty) {
                return;
              }

              final flashcardId = _extractFlashcardId(widget.flashcard);
              final cardId = widget.cardId;

              if (flashcardId == null) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Missing flashcard id.')),
                );
                return;
              }

              try {
                final questionToSend = _frontController.text;
                final answerToSend = _backController.text;

                await CardService.updateFlashcard(
                  flashcardID: flashcardId.toString(),
                  question: questionToSend,
                  answer: answerToSend,
                  questionImagePath: _frontImagePath,
                  answerImagePath: _backImagePath,
                  cardID: cardId,
                );

                if (mounted) {
                  // Update the local flashcard map so the UI reflects changes immediately
                  widget.flashcard['question'] = questionToSend ?? '';
                  widget.flashcard['answer'] = answerToSend ?? '';
                  if (_frontImagePath != null) {
                    widget.flashcard['questionImagePath'] = _frontImagePath;
                    widget.flashcard.remove('questionImage');
                  } else if (_existingQuestionImageUrl == null &&
                      _existingQuestionImagePath == null) {
                    widget.flashcard.remove('questionImage');
                    widget.flashcard.remove('questionImagePath');
                  }
                  if (_backImagePath != null) {
                    widget.flashcard['answerImagePath'] = _backImagePath;
                    widget.flashcard.remove('answerImage');
                  } else if (_existingAnswerImageUrl == null &&
                      _existingAnswerImagePath == null) {
                    widget.flashcard.remove('answerImage');
                    widget.flashcard.remove('answerImagePath');
                  }

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
    required VoidCallback onImageTap,
    required VoidCallback onRemoveImage,
    String? selectedImagePath,
    String? existingImageUrl,
    String? existingImagePath,
    bool hideTextFieldWhenImageSelected = false,
    bool showCheckbox = false,
    bool isError = false,
  }) {
    final hasImage =
        (selectedImagePath != null && selectedImagePath.isNotEmpty) ||
        (existingImageUrl != null && existingImageUrl.isNotEmpty) ||
        (existingImagePath != null && existingImagePath.isNotEmpty);
    final shouldHideTextField = hideTextFieldWhenImageSelected && hasImage;

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
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (selectedImagePath != null &&
                    selectedImagePath.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(selectedImagePath),
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: InkWell(
                            onTap: onRemoveImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else if (existingImagePath != null &&
                    existingImagePath.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.file(
                            File(existingImagePath),
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: InkWell(
                            onTap: onRemoveImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ] else if (existingImageUrl != null &&
                    existingImageUrl.isNotEmpty) ...[
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
                    child: Stack(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            existingImageUrl,
                            width: double.infinity,
                            height: 100,
                            fit: BoxFit.cover,
                          ),
                        ),
                        Positioned(
                          top: 6,
                          right: 6,
                          child: InkWell(
                            onTap: onRemoveImage,
                            child: Container(
                              decoration: const BoxDecoration(
                                color: Colors.black54,
                                shape: BoxShape.circle,
                              ),
                              padding: const EdgeInsets.all(3),
                              child: const Icon(
                                Icons.close,
                                size: 14,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
                if (!shouldHideTextField)
                  Stack(
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
                          contentPadding: const EdgeInsets.fromLTRB(
                            12,
                            12,
                            40,
                            12,
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 4,
                        right: 4,
                        child: IconButton(
                          icon: Icon(Icons.image_outlined, color: hintColor),
                          onPressed: onImageTap,
                          tooltip: 'Add image',
                        ),
                      ),
                    ],
                  )
                else
                  Align(
                    alignment: Alignment.centerRight,
                    child: IconButton(
                      icon: Icon(Icons.image_outlined, color: hintColor),
                      onPressed: onImageTap,
                      tooltip: 'Change image',
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _showImageSourceSheet({required bool isFront}) async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Take Photo'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Choose from Gallery'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
            ],
          ),
        );
      },
    );

    if (source == null) return;

    final pickedFile = await _imagePicker.pickImage(source: source);
    if (pickedFile == null || !mounted) return;

    setState(() {
      if (isFront) {
        _frontImagePath = pickedFile.path;
      } else {
        _backImagePath = pickedFile.path;
      }
    });
  }

  String? _asNonEmptyString(dynamic value) {
    if (value is! String) return null;
    final text = value.trim();
    if (text.isEmpty) return null;
    return text;
  }

  String? _pickFirstString(Map<String, dynamic> map, List<String> keys) {
    for (final key in keys) {
      final value = map[key];
      final text = _asNonEmptyString(value);
      if (text != null) return text;
    }
    return null;
  }

  String? _extractFlashcardId(Map<String, dynamic> flashcard) {
    const idKeys = ['_id', 'id', 'flashcardId', 'flashcardID', 'FlashcardID'];

    for (final key in idKeys) {
      final value = flashcard[key];
      if (value == null) continue;
      final id = value.toString().trim();
      if (id.isNotEmpty) return id;
    }

    return null;
  }

  String? _normalizeImageUrl(dynamic rawUrl) {
    final url = _asNonEmptyString(rawUrl);
    if (url == null) return null;

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
