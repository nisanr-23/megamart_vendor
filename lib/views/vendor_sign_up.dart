import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megamart_vendor/views/vendor_login.dart';
import 'package:megamart_vendor/views/vendor_pending_approval.dart';

class VendorSignUp extends StatefulWidget {
  @override
  _VendorSignUpState createState() => _VendorSignUpState();
}

class _VendorSignUpState extends State<VendorSignUp> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _businessNameController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _signUpVendor() async {
    try {
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Store vendor information in Firestore
        await FirebaseFirestore.instance.collection('vendors').doc(user.uid).set({
          'name': _nameController.text,
          'email': _emailController.text,
          'profile': {
            'storeName': _businessNameController.text,
            'approved': 'pending', // initially set to pending
            'phone': '',
            'address': '',
            'dateOfBirth': null,
            'ownerPhotoUrl': '',
            'storeLogoUrl': '',
            'nidPhotoUrl': '',
            'businessRegistrationNumber': '',
            'taxId': '',
            'bankAccountDetails': {
              'accountNumber': '',
              'bankName': '',
              'IFSC': '',
            },
            'ratings': 0,
            'dateJoined': Timestamp.now(),
            'lastLogin': null,
            'emergencyContact': {
              'name': '',
              'phone': '',
            },
            'socialMedia': {
              'linkedin': '',
              'twitter': '',
              'facebook': '',
            },
            'bio': '',
            'additionalInfo': {},
          },
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (context) => VendorPendingApproval()),
        );
      }
    } catch (e) {
      print('Error signing up: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing up')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Sign-Up'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextFormField(
              controller: _businessNameController,
              decoration: InputDecoration(labelText: 'Business Name'),
            ),
            TextFormField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextFormField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _signUpVendor,
              child: Text('Sign Up'),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Already have an account?  '),
                TextButton(onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VendorLogin(),));
                }, child:Text('Log In',style: TextStyle(
                  color: Colors.blue
                ),))
              ],
            )
          ],
        ),
      ),
    );
  }
}
