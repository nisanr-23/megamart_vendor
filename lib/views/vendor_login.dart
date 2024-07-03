import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megamart_vendor/views/vendor_dashboard_view.dart';
import 'package:megamart_vendor/views/vendor_pending_approval.dart';
import 'package:megamart_vendor/views/vendor_sign_up.dart';

class VendorLogin extends StatefulWidget {
  @override
  _VendorLoginState createState() => _VendorLoginState();
}

class _VendorLoginState extends State<VendorLogin> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Timer? _timer; // Timer to periodically refresh token
  bool _isTokenRefreshed = false;

  @override
  void initState() {
    super.initState();
    // Start token refresh process every 5 minutes
    _timer = Timer.periodic(Duration(minutes: 5), (timer) {
      _refreshToken();
    });
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

  void _loginVendor() async {
    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      User? user = userCredential.user;
      if (user != null) {
        // Retrieve vendor information from Firestore
        DocumentSnapshot doc = await FirebaseFirestore.instance.collection('vendors').doc(user.uid).get();

        if (doc.exists) {
          String approvalStatus = doc['profile']['approved'];

          // Navigate to appropriate screen based on approval status
          if (approvalStatus == 'approved') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => VendorDashboard()),
            );
          } else if (approvalStatus == 'pending') {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(builder: (context) => VendorPendingApproval()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Your application has been rejected.')));
          }
        } else {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('No vendor data found.')));
        }
      }
    } catch (e) {
      print('Error signing in: $e');
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error signing in: ${e.toString()}')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Login'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
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
              onPressed: _loginVendor,
              child: Text('Login'),
            ),
            SizedBox(
              height: 20,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('Don\'t have an account?  '),
                TextButton(onPressed: () {
                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => VendorSignUp()));
                }, child: Text('Sign Up',style: TextStyle(color: Colors.blue),))

              ],
            )
          ],
        ),
      ),
    );
  }
}
