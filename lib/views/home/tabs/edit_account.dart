import 'dart:io';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:qizme/utils/http.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
          const _FieldBox(label: 'Name'),
          const SizedBox(height: 10),
          const _FieldBox(label: 'Username'),
          const SizedBox(height: 10),
          const _FieldBox(label: 'Email'),
          const SizedBox(height: 10),
          const _FieldBox(label: 'Password'),
        ],
      ),
    );
  }
}

class _FieldBox extends StatelessWidget {
  final String label;
  const _FieldBox({required this.label});

  @override
  Widget build(BuildContext context) {
    return TextField(
      decoration: InputDecoration(
        labelText: label,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }
}
