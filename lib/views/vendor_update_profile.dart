import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker_web/image_picker_web.dart';

class UpdateProfilePage extends StatefulWidget {
  @override
  _UpdateProfilePageState createState() => _UpdateProfilePageState();
}

class _UpdateProfilePageState extends State<UpdateProfilePage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _descriptionController = TextEditingController();
  dynamic _profileImage;

  @override
  void initState() {
    super.initState();
    _loadCurrentVendorInfo();
  }

  Future<void> _loadCurrentVendorInfo() async {
    final vendor = _auth.currentUser!;
    DocumentSnapshot vendorDoc = await _firestore.collection('vendors').doc(vendor.uid).get();
    _descriptionController.text = vendorDoc['shortDescription'] ?? '';
    setState(() {
      _profileImage = vendorDoc['profileImageUrl'];
    });
  }

  Future<void> _pickImage() async {
    var image = await ImagePickerWeb.getImageAsBytes();
    setState(() {
      _profileImage = image;
    });
  }

  Future<void> _uploadProfileImage() async {
    if (_profileImage == null) return;
    final vendor = _auth.currentUser!;
    final storageRef = FirebaseStorage.instance.ref();
    final profileImageRef = storageRef.child('profileImages/${vendor.uid}.jpg');

    await profileImageRef.putBlob(_profileImage);
    final profileImageUrl = await profileImageRef.getDownloadURL();

    await _firestore.collection('vendors').doc(vendor.uid).update({
      'profileImageUrl': profileImageUrl,
    });
  }

  Future<void> _updateProfile() async {
    final vendor = _auth.currentUser!;
    await _firestore.collection('vendors').doc(vendor.uid).update({
      'shortDescription': _descriptionController.text,
    });
    await _uploadProfileImage();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Update Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          scrollDirection: Axis.vertical,
          child: Column(
            children: [
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Short Description'),
              ),
              SizedBox(height: 20),
              _profileImage != null
                  ? _profileImage is String
                  ? Image.network(_profileImage)
                  : Image.memory(_profileImage)
                  : Container(),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Upload Profile Image'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Update Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
