import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megamart_vendor/views/vendor_image_upload_aprroval.dart';
import 'package:megamart_vendor/views/vendor_login.dart';
import 'package:megamart_vendor/views/vendor_pending_approval.dart';

class VendorDashboard extends StatefulWidget {
  @override
  _VendorDashboardState createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _approvalStatus = 'pending'; // 'pending', 'approved', 'rejected'
  String? _error;

  @override
  void initState() {
    super.initState();
    _checkApprovalStatus();
  }

  void _checkApprovalStatus() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        DocumentSnapshot vendorSnapshot = await _firestore.collection('vendors').doc(user.uid).get();
        if (vendorSnapshot.exists) {
          var data = vendorSnapshot.data() as Map<String, dynamic>;
          setState(() {
            _approvalStatus = data['profile']['approved'] ?? 'pending';
          });
        }
      } catch (e) {
        setState(() {
          _error = 'Failed to fetch approval status: $e';
        });
      }
    }
  }

  void _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => VendorLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Dashboard'),
        actions: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      ),
      body: Column(
        children: [
          if (_error != null)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                _error!,
                style: TextStyle(color: Colors.red),
              ),
            ),
          if (_approvalStatus == 'pending')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your application is pending approval.',
                style: TextStyle(color: Colors.orange, fontSize: 18),
              ),
            ),
          if (_approvalStatus == 'approved')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your application has been approved.',
                style: TextStyle(color: Colors.green, fontSize: 18),
              ),
            ),
          if (_approvalStatus == 'rejected')
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Your application has been rejected.',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            ),
        ],
      ),
    );
  }
}
