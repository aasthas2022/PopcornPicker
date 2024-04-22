// screens/profile_edit_screen.dart

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb; // For platform checks
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ProfileEditScreen extends StatefulWidget {
  @override
  _ProfileEditScreenState createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();
  dynamic _profileImage; // Can be File or Uint8List
  final ImagePicker _picker = ImagePicker();
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      dynamic newImage;
      if (kIsWeb) {
        // Load the image as bytes if it's the web
        newImage = await pickedFile.readAsBytes();
      } else {
        // Load the image as a file if it's mobile
        newImage = File(pickedFile.path);
      }
      setState(() {
        _profileImage = newImage;
      });
    }
  }

  Future<void> _saveProfile() async {
    try {
      setState(() => _isLoading = true);
      String imageUrl = '';
      if (_profileImage != null) {
        // File name example: Using the user's UID with a JPG extension for uniqueness.
        final ref = FirebaseStorage.instance
            .ref()
            .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');

        print("Start uploading image to the root folder");
        if (kIsWeb) {
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          await ref.putData(_profileImage, metadata);
        } else {
          await ref.putFile(_profileImage);
        }

        imageUrl = await ref.getDownloadURL();
        print("Image uploaded: $imageUrl"); // Debugging output
      }

      print("Start updating Firestore");
      await FirebaseFirestore.instance.collection('users').doc(FirebaseAuth.instance.currentUser!.uid).set({
        'name': _nameController.text.trim(),
        'age': _ageController.text.trim(),
        'bio': _bioController.text.trim(),
        'imageUrl': imageUrl.isNotEmpty ? imageUrl : 'default-image-url',
      });

      print("Profile saved"); // Debugging output
      Navigator.of(context).pushReplacementNamed('/main');
    } catch (e) {
      print("An error occurred: $e"); // Output error
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving profile: ${e.toString()}'))
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundImage: _profileImage != null
                  ? (kIsWeb
                  ? MemoryImage(_profileImage as Uint8List) as ImageProvider
                  : FileImage(_profileImage as File) as ImageProvider)
                  : AssetImage('assets/default_profile.jpg') as ImageProvider,
            ),
            TextButton.icon(
              icon: Icon(Icons.image),
              label: Text('Change Picture'),
              onPressed: _pickImage,
            ),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _ageController,
              keyboardType: TextInputType.number,
              decoration: InputDecoration(labelText: 'Age'),
            ),
            TextField(
              controller: _bioController,
              decoration: InputDecoration(labelText: 'Bio'),
            ),
            SizedBox(height: 20),
            _isLoading
                ? CircularProgressIndicator()
                : ElevatedButton(
              onPressed: _saveProfile,
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
