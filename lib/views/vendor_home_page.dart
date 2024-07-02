import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:megamart_vendor/views/vendor_login.dart';
import 'package:megamart_vendor/views/vendor_update_profile.dart';

import 'vendor_add_product.dart';

class VendorHomePage extends StatelessWidget {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  void _logout(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => VendorLogin(),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Vendor Home Page'),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Welcome, Vendor!'),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (context) => UpdateProfilePage()),
                );
              },
              child: Text('Update Profile'),
            ),
            ElevatedButton(
              onPressed: () {
                // Navigator.of(context).push(
                //   MaterialPageRoute(builder: (context) => AddProductPage()),
                // );
              },
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
