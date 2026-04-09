import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qizme/utils/http.dart';
import 'package:qizme/views/widgets/styled_menu_button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:qizme/services/auth_service.dart';

// New StatefulWidget for the dialog content
class _EditDialogContent extends StatefulWidget {
  final List<String> fieldLabels;
  final Function(List<String> values) onSave;

  const _EditDialogContent({required this.fieldLabels, required this.onSave});

  @override
  __EditDialogContentState createState() => __EditDialogContentState();
}

class __EditDialogContentState extends State<_EditDialogContent> {
  late final List<TextEditingController> _controllers;

  @override
  void initState() {
    super.initState();
    _controllers = widget.fieldLabels
        .map((_) => TextEditingController())
        .toList();
  }

  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(
        'Edit ${widget.fieldLabels.length > 1 ? "Name" : widget.fieldLabels.first}',
      ),
      content: SingleChildScrollView(
        child: ListBody(
          children: List.generate(widget.fieldLabels.length, (index) {
            return Padding(
              padding: EdgeInsets.only(top: index == 0 ? 0 : 16.0),
              child: TextField(
                controller: _controllers[index],
                decoration: InputDecoration(
                  labelText: widget.fieldLabels[index],
                  border: const OutlineInputBorder(),
                ),
              ),
            );
          }),
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Cancel'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('Save'),
          onPressed: () {
            final values = _controllers
                .map((controller) => controller.text)
                .toList();
            widget.onSave(values);
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}

class EditAccountPage extends StatefulWidget {
  final VoidCallback onBack;
  final Future<void> Function() onProfileUpdated;

  const EditAccountPage({
    super.key,
    required this.onBack,
    required this.onProfileUpdated,
  });

  @override
  State<EditAccountPage> createState() => _EditAccountPageState();
}

class _EditAccountPageState extends State<EditAccountPage> {
  XFile? _selectedImage;
  final ImagePicker _picker = ImagePicker();
  SharedPreferences? _prefs;
  String? _profilePictureUrl;
  bool _darkMode = false;

  @override
  void initState() {
    super.initState();
    _initPrefs();
  }

  Future<void> _initPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _prefs = prefs;
      _profilePictureUrl = prefs.getString('profilePicture');
      _darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> _pickImage(ImageSource source) async {
    try {
      final pickedFile = await _picker.pickImage(source: source);
      if (pickedFile == null) return;

      setState(() {
        _selectedImage = pickedFile;
      });

      final response = await ApiService.postFileRequest(
        'api/users/profile/updatePicture',
        {'email': 'unvlzx.c@gmail.com'},
        pickedFile.path,
      );

      final jsonMap = jsonDecode(response);
      final newPath = jsonMap['data']?['imageUrl'];

      if (newPath == null || newPath.toString().isEmpty) {
        throw Exception('Server returned empty image path');
      }

      await _prefs!.setString('profilePicture', newPath.toString());
      await widget.onProfileUpdated();

      if (!mounted) return;
      Navigator.pop(context); // close sheet

      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Profile picture updated')));
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Upload failed: $e')));
    }
  }

  void _showImagePickerSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) => SizedBox(
        height: 140,
        child: Column(
          children: [
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take Photo'),
              onTap: () => _pickImage(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => _pickImage(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showEditDialog({
    required List<String> fieldLabels,
    required Function(List<String> values) onSave,
  }) async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _EditDialogContent(fieldLabels: fieldLabels, onSave: onSave);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    ImageProvider avatarProvider;

    if (_selectedImage != null) {
      avatarProvider = FileImage(File(_selectedImage!.path));
    } else if (_profilePictureUrl != null && _profilePictureUrl!.isNotEmpty) {
      avatarProvider = NetworkImage(_profilePictureUrl!);
    } else {
      avatarProvider = const AssetImage("assets/images/user.png");
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          SizedBox(
            height: 115,
            width: 115,
            child: Stack(
              clipBehavior: Clip.none,
              fit: StackFit.expand,
              children: [
                CircleAvatar(backgroundImage: avatarProvider),
                Positioned(
                  bottom: 0,
                  right: -25,
                  child: RawMaterialButton(
                    onPressed: _showImagePickerSheet,
                    elevation: 2.0,
                    fillColor: const Color(0xFFF5F6F9),
                    padding: const EdgeInsets.all(15.0),
                    shape: const CircleBorder(),
                    child: const Icon(
                      Icons.camera_alt_outlined,
                      color: Colors.blue,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
          StyledMenuButton(
            label: 'Name',
            onTap: () {
              _showEditDialog(
                fieldLabels: ['First Name', 'Last Name'],
                onSave: (values) {
                  print('Saving Name: ${values[0]} ${values[1]}');
                  try {
                    SharedPreferences.getInstance().then((prefs) {
                      final email = prefs.getString('email') ?? '';
                      AuthService.updateName(
                        email: email,
                        newName: '${values[0]} ${values[1]}',
                      ).then((_) {
                        // update the name in the shared preferences
                        prefs.setString('name', '${values[0]} ${values[1]}');

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Name updated')),
                        );
                      });
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update name')),
                    );
                  }
                },
              );
            },
            darkMode: _darkMode,
          ),
          StyledMenuButton(
            label: 'Username',
            onTap: () {
              _showEditDialog(
                fieldLabels: ['Username'],
                onSave: (values) {
                  try {
                    SharedPreferences.getInstance().then((prefs) {
                      final email = prefs.getString('email') ?? '';
                      AuthService.updateUsername(
                        email: email,
                        newUsername: values[0],
                      ).then((_) {
                        // update the name in the shared preferences
                        prefs.setString('username', values[0]);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Username updated')),
                        );
                      });
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update username'),
                      ),
                    );
                  }
                },
              );
            },
            darkMode: _darkMode,
          ),
          StyledMenuButton(
            label: 'Email',
            onTap: () {
              _showEditDialog(
                fieldLabels: ['Email'],
                onSave: (values) {
                  try {
                    SharedPreferences.getInstance().then((prefs) {
                      final email = prefs.getString('email') ?? '';
                      AuthService.updateEmail(
                        email: email,
                        newEmail: values[0],
                      ).then((_) {
                        // update the name in the shared preferences
                        prefs.setString('email', values[0]);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Email updated')),
                        );
                      });
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Failed to update email')),
                    );
                  }
                },
              );
            },
            darkMode: _darkMode,
          ),
          StyledMenuButton(
            label: 'Password',
            onTap: () {
              _showEditDialog(
                fieldLabels: ['Current Password', 'New Password'],
                onSave: (values) {
                  try {
                    SharedPreferences.getInstance().then((prefs) {
                      final email = prefs.getString('email') ?? '';
                      AuthService.updatePassword(
                        email: email,
                        currentPassword: values[0],
                        newPassword: values[1],
                      ).then((_) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Password updated')),
                        );
                      });
                    });
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Failed to update password'),
                      ),
                    );
                  }
                },
              );
            },
            darkMode: _darkMode,
          ),
        ],
      ),
    );
  }
}
