import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:megamart_vendor/views/vendor_login.dart';

class VendorAccountPage extends StatefulWidget {
  @override
  State<VendorAccountPage> createState() => _VendorAccountPageState();
}

class _VendorAccountPageState extends State<VendorAccountPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  // final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  void _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => VendorLogin()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child:Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: Icon(Icons.exit_to_app),
            onPressed: () => _signOut(context),
          ),
        ],
      )
    );
  }
}
