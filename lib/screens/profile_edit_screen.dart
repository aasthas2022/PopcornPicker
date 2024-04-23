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

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      var userData = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      if (userData.exists) {
        Map<String, dynamic> data = userData.data()!;
        _nameController.text = data['name'] ?? '';
        _ageController.text = data['age'] ?? '';
        _bioController.text = data['bio'] ?? '';
        if (data['imageUrl'] != null && data['imageUrl'] != 'default-image-url') {
          setState(() {
            _profileImage = NetworkImage(data['imageUrl']);
          });
        }
      }
      setState(() {
        _isLoading = false;
      });
    } else {
      print("No user found!");
    }
  }

  Widget _buildProfileImage() {
    return CircleAvatar(
      radius: 60,
      backgroundColor: Colors.grey.shade200,
      backgroundImage: _profileImage != null ? _profileImage : AssetImage('assets/default_profile.jpg'),
    );
  }


  Future<void> _pickImage() async {
    final pickedFile = await _picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      if (kIsWeb) {
        // On the web, load the image as bytes and convert to MemoryImage
        Uint8List imageData = await pickedFile.readAsBytes();
        setState(() {
          _profileImage = MemoryImage(imageData);
        });
      } else {
        // On mobile, use FileImage for local file paths
        File imageFile = File(pickedFile.path);
        setState(() {
          _profileImage = FileImage(imageFile);
        });
      }
    }
  }


  Future<void> _saveProfile() async {
    try {
      setState(() => _isLoading = true);
      String imageUrl = '';
      if (_profileImage != null) {
        final ref = FirebaseStorage.instance
            .ref()
            .child('${FirebaseAuth.instance.currentUser!.uid}.jpg');

        print("Start uploading image to the root folder");

        if (_profileImage is MemoryImage) {
          // Extract bytes from MemoryImage and upload (For web)
          final metadata = SettableMetadata(contentType: 'image/jpeg');
          await ref.putData((_profileImage as MemoryImage).bytes, metadata);
        } else if (_profileImage is FileImage) {
          // Upload file directly (For mobile)
          await ref.putFile((_profileImage as FileImage).file);
        }

        imageUrl = await ref.getDownloadURL();
        print("Image uploaded: $imageUrl"); // Debugging output
      }

      print("Start updating Firestore");
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseFirestore.instance.collection('users').doc(user.uid).set({
          'name': _nameController.text.trim(),
          'age': _ageController.text.trim(),
          'bio': _bioController.text.trim(),
          'imageUrl': imageUrl.isNotEmpty ? imageUrl : 'default-image-url',
        }, SetOptions(merge: true));
      } else {
        print("No user logged in.");
      }

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
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildProfileImage(),
            SizedBox(height: 16),
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
            ElevatedButton(
              onPressed: () => _saveProfile(),
              child: Text('Save Profile'),
            ),
          ],
        ),
      ),
    );
  }
}
