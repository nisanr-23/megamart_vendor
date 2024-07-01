import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path/path.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorImageUploadScreen extends StatefulWidget {
  @override
  _VendorImageUploadScreenState createState() => _VendorImageUploadScreenState();
}

class _VendorImageUploadScreenState extends State<VendorImageUploadScreen> {
  File? _nidImageFile;
  File? _ownerImageFile;
  String? _nidImageUrl;
  String? _ownerImageUrl;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _nidDescriptionController = TextEditingController();
  final TextEditingController _ownerDescriptionController = TextEditingController();

  Future<void> _pickImage(ImageSource source, bool isNID) async {
    final pickedFile = await _picker.pickImage(source: source);
    if (pickedFile != null) {
      setState(() {
        if (isNID) {
          _nidImageFile = File(pickedFile.path);
        } else {
          _ownerImageFile = File(pickedFile.path);
        }
      });
      await _uploadImage(isNID);
    }
  }

  Future<void> _uploadImage(bool isNID) async {
    File? imageFile = isNID ? _nidImageFile : _ownerImageFile;
    if (imageFile != null) {
      String fileName = basename(imageFile.path);
      Reference storageReference = FirebaseStorage.instance.ref().child('vendor_images/$fileName');
      UploadTask uploadTask = storageReference.putFile(imageFile);
      await uploadTask.whenComplete(() async {
        String downloadUrl = await storageReference.getDownloadURL();
        setState(() {
          if (isNID) {
            _nidImageUrl = downloadUrl;
          } else {
            _ownerImageUrl = downloadUrl;
          }
        });
      });
    }
  }

  void _saveVendorImages() async {
    // Assuming the vendor ID is stored in the Firestore document
    String vendorId = "vendor_id"; // Replace this with the actual vendor ID

    await FirebaseFirestore.instance.collection('vendors').doc(vendorId).update({
      'nidImageUrl': _nidImageUrl,
      'nidDescription': _nidDescriptionController.text,
      'ownerImageUrl': _ownerImageUrl,
      'ownerDescription': _ownerDescriptionController.text,
    });

    ScaffoldMessenger.of(context as BuildContext).showSnackBar(SnackBar(content: Text('Images and descriptions uploaded successfully')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Upload NID and Owner Pictures'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _nidImageFile != null
                ? Image.file(_nidImageFile!)
                : (_nidImageUrl != null
                ? Image.network(_nidImageUrl!)
                : Placeholder(
              fallbackHeight: 200.0,
              fallbackWidth: double.infinity,
            )),
            TextFormField(
              controller: _nidDescriptionController,
              decoration: InputDecoration(labelText: 'NID Description'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery, true),
              child: Text('Pick NID Image'),
            ),
            SizedBox(height: 20),
            _ownerImageFile != null
                ? Image.file(_ownerImageFile!)
                : (_ownerImageUrl != null
                ? Image.network(_ownerImageUrl!)
                : Placeholder(
              fallbackHeight: 200.0,
              fallbackWidth: double.infinity,
            )),
            TextFormField(
              controller: _ownerDescriptionController,
              decoration: InputDecoration(labelText: 'Owner Description'),
            ),
            ElevatedButton(
              onPressed: () => _pickImage(ImageSource.gallery, false),
              child: Text('Pick Owner Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveVendorImages,
              child: Text('Save Images and Descriptions'),
            ),
          ],
        ),
      ),
    );
  }
}
