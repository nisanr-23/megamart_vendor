import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class OrderDetailsPage extends StatefulWidget {
  final String orderId;

  OrderDetailsPage({required this.orderId});

  @override
  _OrderDetailsPageState createState() => _OrderDetailsPageState();
}

class _OrderDetailsPageState extends State<OrderDetailsPage> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final _noteController = TextEditingController();
  String? _selectedStatus;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Order Details'),
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _firestore.collection('orders').doc(widget.orderId).get(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var order = snapshot.data!.data() as Map<String, dynamic>;
          var orderHistory = order['orderHistory'] as List<dynamic>;

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView(
              children: [
                _buildOrderInfo(order),
                SizedBox(height: 20),
                _buildOrderStatusDropdown(order['orderStatus']),
                SizedBox(height: 20),
                _buildAddNoteSection(),
                SizedBox(height: 20),
                _buildOrderHistory(orderHistory),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _updateOrderStatus(),
                  child: Text('Update Status'),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildOrderInfo(Map<String, dynamic> order) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.orderId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Customer ID: ${order['customerId']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Total Amount: ${order['totalAmount']} ${order['currency']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Payment Method: ${order['paymentMethod']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Payment Status: ${order['paymentStatus']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Order Date: ${_formatTimestamp(order['orderDate'])}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Shipping Method: ${order['shippingMethod']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            _buildAddressInfo('Shipping Address', order['shippingAddress']),
            SizedBox(height: 10),
            _buildAddressInfo('Billing Address', order['billingAddress']),
            SizedBox(height: 10),
            _buildOrderItems(order['items'] as List<dynamic>),
          ],
        ),
      ),
    );
  }

  String _formatTimestamp(Timestamp timestamp) {
    return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
  }

  Widget _buildAddressInfo(String title, Map<String, dynamic> address) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        SizedBox(height: 5),
        Text('Name: ${address['fullName']}', style: TextStyle(fontSize: 14)),
        Text('Phone: ${address['phoneNumber']}', style: TextStyle(fontSize: 14)),
        Text('Country: ${address['country']}', style: TextStyle(fontSize: 14)),
        Text('Division: ${address['division']}', style: TextStyle(fontSize: 14)),
        Text('District: ${address['district']}', style: TextStyle(fontSize: 14)),
        Text('Upazila: ${address['upazila']}', style: TextStyle(fontSize: 14)),
        Text('Postal Code: ${address['postalCode']}', style: TextStyle(fontSize: 14)),
      ],
    );
  }

  Widget _buildOrderItems(List<dynamic> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Items', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...items.map((item) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 5.0),
            child: Row(
              children: [
                Image.network(item['productImageUrl'], width: 50, height: 50, fit: BoxFit.cover),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(item['productName'], style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                    Text('Quantity: ${item['quantity']}', style: TextStyle(fontSize: 14)),
                    Text('Total Price: ${item['totalPrice']}', style: TextStyle(fontSize: 14)),
                  ],
                ),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Widget _buildOrderStatusDropdown(String currentStatus) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(
        labelText: 'Order Status',
        border: OutlineInputBorder(),
      ),
      value: currentStatus,
      items: [
        'Pending',
        'Processing',
        'Order Confirmed',
        'Order Shipped',
        'Out for Delivery',
        'Order Delivered',
        'Order Cancelled',
        'Order Returned',
        'Order Refunded',
        'Order Processing Failed',
      ].map((status) {
        return DropdownMenuItem(
          value: status,
          child: Text(status),
        );
      }).toList(),
      onChanged: (value) {
        setState(() {
          _selectedStatus = value;
        });
      },
    );
  }

  Widget _buildAddNoteSection() {
    return TextField(
      controller: _noteController,
      decoration: InputDecoration(
        labelText: 'Add Note',
        border: OutlineInputBorder(),
      ),
      maxLines: 3,
    );
  }

  Widget _buildOrderHistory(List<dynamic> history) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Order History', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
        ...history.map((entry) {
          return ListTile(
            title: Text('Status: ${entry['status']}'),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Notes: ${entry['notes']}'),
                Text('Timestamp: ${_formatTimestamp(entry['timestamp'])}'),
              ],
            ),
          );
        }).toList(),
      ],
    );
  }

  Future<void> _updateOrderStatus() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Please select a status')));
      return;
    }

    var note = _noteController.text.trim();
    var timestamp = Timestamp.now();

    await _firestore.collection('orders').doc(widget.orderId).update({
      'orderStatus': _selectedStatus,
      'orderHistory': FieldValue.arrayUnion([{
        'status': _selectedStatus,
        'notes': note,
        'timestamp': timestamp,
      }]),
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Order status updated')));
    _noteController.clear();
  }
}
