import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megamart_vendor/views/vendor_dashboard_view.dart';
import 'package:megamart_vendor/views/confirmation_screen.dart';

class VendorPendingApproval extends StatefulWidget {
  @override
  _VendorPendingApprovalState createState() => _VendorPendingApprovalState();
}

class _VendorPendingApprovalState extends State<VendorPendingApproval> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final TextEditingController _phoneNumberController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _businessRegistrationNumberController = TextEditingController();
  final TextEditingController _taxIdController = TextEditingController();
  final TextEditingController _accountNumberController = TextEditingController();
  final TextEditingController _bankNameController = TextEditingController();
  final TextEditingController _ifscController = TextEditingController();
  final TextEditingController _emergencyContactNameController = TextEditingController();
  final TextEditingController _emergencyContactPhoneController = TextEditingController();
  final TextEditingController _linkedinController = TextEditingController();
  final TextEditingController _twitterController = TextEditingController();
  final TextEditingController _facebookController = TextEditingController();
  final TextEditingController _bioController = TextEditingController();

  DateTime? _selectedDate;
  File? _vendorPhoto;
  File? _businessLogo;
  File? _nidPhoto;
  String? _vendorName;

  Timer? _timer; // Timer to periodically refresh token
  bool _isTokenRefreshed = false;

  @override
  void initState() {
    super.initState();
    // Start token refresh process every 5 minutes
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _refreshToken();
    });
    _fetchVendorName();
    _fetchVendorInfo();
  }

  @override
  void dispose() {
    // Cancel the timer when the widget is disposed
    _timer?.cancel();
    super.dispose();
  }

  void _refreshToken() async {
    User? user = _auth.currentUser;
    if (user != null) {
      await user.getIdToken(true); // Refresh the user's token
      setState(() {
        _isTokenRefreshed = true;
      });
    }
  }

  Future<void> _fetchVendorName() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot vendorSnapshot = await _firestore.collection('vendors').doc(user.uid).get();
      setState(() {
        _vendorName = vendorSnapshot['name'];
      });
    }
  }

  Future<void> _fetchVendorInfo() async {
    User? user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot vendorSnapshot = await _firestore.collection('vendors').doc(user.uid).get();
      if (vendorSnapshot.exists) {
        var vendorData = vendorSnapshot.data() as Map<String, dynamic>;
        var profile = vendorData['profile'] as Map<String, dynamic>;

        setState(() {
          _phoneNumberController.text = profile['phone'] ?? '';
          _addressController.text = profile['address'] ?? '';
          _selectedDate = (profile['dateOfBirth'] as Timestamp?)?.toDate();
          _businessRegistrationNumberController.text = profile['businessRegistrationNumber'] ?? '';
          _taxIdController.text = profile['taxId'] ?? '';
          var bankAccountDetails = profile['bankAccountDetails'] as Map<String, dynamic>?;
          if (bankAccountDetails != null) {
            _accountNumberController.text = bankAccountDetails['accountNumber'] ?? '';
            _bankNameController.text = bankAccountDetails['bankName'] ?? '';
            _ifscController.text = bankAccountDetails['IFSC'] ?? '';
          }
          var emergencyContact = profile['emergencyContact'] as Map<String, dynamic>?;
          if (emergencyContact != null) {
            _emergencyContactNameController.text = emergencyContact['name'] ?? '';
            _emergencyContactPhoneController.text = emergencyContact['phone'] ?? '';
          }
          var socialMedia = profile['socialMedia'] as Map<String, dynamic>?;
          if (socialMedia != null) {
            _linkedinController.text = socialMedia['linkedin'] ?? '';
            _twitterController.text = socialMedia['twitter'] ?? '';
            _facebookController.text = socialMedia['facebook'] ?? '';
          }
          _bioController.text = profile['bio'] ?? '';
        });
      }
    }
  }

  Future<String?> _uploadImage(File imageFile, String imageName) async {
    try {
      Reference storageRef = _storage.ref().child('vendor_images').child(imageName);
      UploadTask uploadTask = storageRef.putFile(imageFile);
      TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() => null);
      String downloadUrl = await taskSnapshot.ref.getDownloadURL();
      return downloadUrl;
    } catch (e) {
      print('Error uploading image: $e');
      return null;
    }
  }

  void _submitApplication() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Upload images and get download URLs
        String? vendorPhotoUrl = _vendorPhoto != null
            ? await _uploadImage(_vendorPhoto!, 'vendor_photo_${user.uid}.jpg')
            : null;
        String? businessLogoUrl = _businessLogo != null
            ? await _uploadImage(_businessLogo!, 'business_logo_${user.uid}.jpg')
            : null;
        String? nidPhotoUrl = _nidPhoto != null
            ? await _uploadImage(_nidPhoto!, 'nid_photo_${user.uid}.jpg')
            : null;

        // Retrieve existing data
        DocumentSnapshot vendorSnapshot = await _firestore.collection('vendors').doc(user.uid).get();
        var vendorData = vendorSnapshot.data() as Map<String, dynamic>;

        // Merge with new data
        vendorData['profile'] = {
          ...vendorData['profile'] ?? {},
          'ownerPhotoUrl': vendorPhotoUrl,
          'storeLogoUrl': businessLogoUrl,
          'nidPhotoUrl': nidPhotoUrl,
          'phone': _phoneNumberController.text,
          'address': _addressController.text,
          'dateOfBirth': _selectedDate != null ? Timestamp.fromDate(_selectedDate!) : null,
          'businessRegistrationNumber': _businessRegistrationNumberController.text,
          'taxId': _taxIdController.text,
          'bankAccountDetails': {
            'accountNumber': _accountNumberController.text,
            'bankName': _bankNameController.text,
            'IFSC': _ifscController.text,
          },
          'emergencyContact': {
            'name': _emergencyContactNameController.text,
            'phone': _emergencyContactPhoneController.text,
          },
          'socialMedia': {
            'linkedin': _linkedinController.text,
            'twitter': _twitterController.text,
            'facebook': _facebookController.text,
          },
          'bio': _bioController.text,
        };
        vendorData['updatedAt'] = Timestamp.now();

        // Update vendor information
        await _firestore.collection('vendors').doc(user.uid).set(vendorData, SetOptions(merge: true));

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => ConfirmationScreen()),
        );

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application submitted successfully')),
        );
      } catch (e) {
        print('Error submitting application: $e');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error submitting application')),
        );
      }
    }
  }

  Future<void> _getImage(ImageSource source, Function(File) setImage) async {
    final picker = ImagePicker();
    final pickedFile = await picker.getImage(source: source);
    setState(() {
      if (pickedFile != null) {
        setImage(File(pickedFile.path));
      } else {
        print('No image selected.');
      }
    });
  }

  Future<void> _pickDate() async {
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      setState(() {
        _selectedDate = pickedDate;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Pending Approval'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_vendorName != null)
                Text(
                  'Welcome, $_vendorName!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              SizedBox(height: 20),
              _buildImagePicker('Vendor Photo', _vendorPhoto, (file) => _vendorPhoto = file),
              _buildImagePicker('Business Logo', _businessLogo, (file) => _businessLogo = file),
              _buildImagePicker('NID Photo', _nidPhoto, (file) => _nidPhoto = file),
              SizedBox(height: 20),
              TextFormField(
                controller: _phoneNumberController,
                decoration: InputDecoration(labelText: 'Phone Number'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Address'),
              ),
              SizedBox(height: 20),
              Text('Date of Birth', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Row(
                children: [
                  ElevatedButton(
                    onPressed: _pickDate,
                    child: Text('Pick Date'),
                  ),
                  SizedBox(width: 10),
                  Text(
                    _selectedDate != null ? _selectedDate.toString() : 'No date selected',
                    style: TextStyle(fontSize: 16),
                  ),
                ],
              ),
              Divider(),
              TextFormField(
                controller: _businessRegistrationNumberController,
                decoration: InputDecoration(labelText: 'Business Registration Number'),
              ),
              TextFormField(
                controller: _taxIdController,
                decoration: InputDecoration(labelText: 'Tax ID'),
              ),
              TextFormField(
                controller: _accountNumberController,
                decoration: InputDecoration(labelText: 'Bank Account Number'),
              ),
              TextFormField(
                controller: _bankNameController,
                decoration: InputDecoration(labelText: 'Bank Name'),
              ),
              TextFormField(
                controller: _ifscController,
                decoration: InputDecoration(labelText: 'IFSC Code'),
              ),
              TextFormField(
                controller: _emergencyContactNameController,
                decoration: InputDecoration(labelText: 'Emergency Contact Name'),
              ),
              TextFormField(
                controller: _emergencyContactPhoneController,
                decoration: InputDecoration(labelText: 'Emergency Contact Phone'),
              ),
              TextFormField(
                controller: _linkedinController,
                decoration: InputDecoration(labelText: 'LinkedIn'),
              ),
              TextFormField(
                controller: _twitterController,
                decoration: InputDecoration(labelText: 'Twitter'),
              ),
              TextFormField(
                controller: _facebookController,
                decoration: InputDecoration(labelText: 'Facebook'),
              ),
              TextFormField(
                controller: _bioController,
                decoration: InputDecoration(labelText: 'Bio'),
                maxLines: 3, // Allow multiple lines for bio
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _submitApplication,
                child: Text('Submit Application'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImagePicker(String label, File? imageFile, Function(File) setImage) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 8),
        imageFile != null
            ? Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Image.file(imageFile, height: 150),
            SizedBox(height: 8),
            Text('Image Selected', style: TextStyle(color: Colors.green)),
          ],
        )
            : Placeholder(fallbackHeight: 150, fallbackWidth: double.infinity),
        SizedBox(height: 8),
        Row(
          children: [
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.gallery, setImage),
              child: Text('Pick from Gallery'),
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: () => _getImage(ImageSource.camera, setImage),
              child: Text('Take a Photo'),
            ),
          ],
        ),
        Divider(),
      ],
    );
  }
}
