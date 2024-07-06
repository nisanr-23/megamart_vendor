import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:megamart_vendor/views/navigations/vendor_home.dart';
import 'package:megamart_vendor/views/products/vendor_products.dart';
import 'package:megamart_vendor/views/orders/vendor_orders.dart';
import 'package:megamart_vendor/views/navigations/vendor_account.dart';
import 'package:megamart_vendor/views/authentications/vendor_login.dart';

class VendorDashboard extends StatefulWidget {
  @override
  _VendorDashboardState createState() => _VendorDashboardState();
}

class _VendorDashboardState extends State<VendorDashboard> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _error = '';
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    VendorHomePage(),
    VendorProductsPage(),
    VendorOrdersPage(),
    VendorAccountPage(),
  ];

  void _signOut(BuildContext context) async {
    await _auth.signOut();
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => VendorLogin()),
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    User? user = _auth.currentUser;

    return Scaffold(
      body: user != null
          ? StreamBuilder<DocumentSnapshot>(
        stream: _firestore.collection('vendors').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('Vendor data not found.'));
          }

          var data = snapshot.data!.data() as Map<String, dynamic>;
          String approvalStatus = data['profile']['approved'] ?? 'pending';

          if (approvalStatus == 'pending') {
            return Center(
              child: Text(
                'Your application is pending approval.',
                style: TextStyle(color: Colors.orange, fontSize: 18),
              ),
            );
          }

          if (approvalStatus == 'rejected') {
            return Center(
              child: Text(
                'Your application has been rejected.',
                style: TextStyle(color: Colors.red, fontSize: 18),
              ),
            );
          }

          return _pages[_selectedIndex];
        },
      )
          : Center(child: Text('User not logged in')),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, size: 30),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory, size: 30),
            label: 'Products',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list, size: 30),
            label: 'Orders',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, size: 30),
            label: 'Account',
          ),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        showSelectedLabels: true,
        showUnselectedLabels: true,
        onTap: _onItemTapped,
        backgroundColor: Colors.white,
        elevation: 10,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
