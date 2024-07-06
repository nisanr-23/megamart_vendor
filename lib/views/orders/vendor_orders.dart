import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'orders_by_status_page.dart'; // Import the orders by status page

class VendorOrdersPage extends StatefulWidget {
  @override
  _VendorOrdersPageState createState() => _VendorOrdersPageState();
}

class _VendorOrdersPageState extends State<VendorOrdersPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Map<String, int> orderStatusCounts = {
    "Pending": 0,
    'Processing':0,
    "Order Confirmed": 0,
    "Order Shipped": 0,
    "Out for Delivery": 0,
    "Order Delivered": 0,
    "Order Cancelled": 0,
    "Order Returned": 0,
    "Order Refunded": 0,
    "Order Processing Failed": 0,
  };

  @override
  void initState() {
    super.initState();
    _fetchOrderCounts();
  }

  Future<void> _fetchOrderCounts() async {
    User? user = _auth.currentUser;

    if (user != null) {
      for (var status in orderStatusCounts.keys) {
        var querySnapshot = await _firestore
            .collection('orders')
            .where('vendorId', isEqualTo: user.uid)
            .where('orderStatus', isEqualTo: status)
            .get();

        setState(() {
          orderStatusCounts[status] = querySnapshot.docs.length;
        });
      }
    }
  }

  void _navigateToOrdersByStatusPage(String status) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OrdersByStatusPage(status: status),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Orders'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: orderStatusCounts.keys.map((status) {
            return Card(
              margin: EdgeInsets.symmetric(vertical: 8.0),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: ListTile(
                  title: Text(status),
                  trailing: Text(orderStatusCounts[status].toString()),
                  onTap: () => _navigateToOrdersByStatusPage(status),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}
