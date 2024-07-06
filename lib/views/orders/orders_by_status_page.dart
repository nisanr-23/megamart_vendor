import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'order_details_page.dart'; // Import the order details page

class OrdersByStatusPage extends StatelessWidget {
  final String status;

  OrdersByStatusPage({required this.status});

  @override
  Widget build(BuildContext context) {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    final FirebaseFirestore _firestore = FirebaseFirestore.instance;

    return Scaffold(
      appBar: AppBar(
        title: Text('$status Orders'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _firestore
            .collection('orders')
            .where('vendorId', isEqualTo: _auth.currentUser!.uid)
            .where('orderStatus', isEqualTo: status)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No orders found.'));
          }

          var orders = snapshot.data!.docs;

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              var order = orders[index];
              var orderData = order.data() as Map<String, dynamic>;
              return ListTile(
                title: Text('Order ID: ${order.id}'),
                subtitle: Text('Total Amount: ${orderData['totalAmount']} ${orderData['currency']}'),
                trailing: Icon(Icons.arrow_forward),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => OrderDetailsPage(orderId: order.id),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
