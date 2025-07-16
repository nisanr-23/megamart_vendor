import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:pdf/pdf.dart';
import 'package:path_provider/path_provider.dart';
// import 'dart:io';
import 'dart:html' as html;

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
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => _generateInvoice(order),
                  child: Text('Generate Invoice'),
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
      child: Container(
        color: Colors.white, // Set the container color
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Order ID: ${widget.orderId}', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text('Total Amount: ${order['totalAmount']} ${order['currency']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Payment Method: ${order['paymentMethod']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Payment Status: ${order['paymentStatus']}', style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text('Order Date: ${_formatTimestamp(order['orderDate'])}', style: TextStyle(fontSize: 16)), // Added order date
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

  Future<void> _generateInvoice(Map<String, dynamic> order) async {
    try {
      final pdf = pw.Document();

      final baseColor = PdfColor.fromHex('#3A3D98');
      final accentColor = PdfColor.fromHex('#EAEAFF');
      final whiteColor = PdfColors.white;
      final grayColor = PdfColors.grey300;

      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd – kk:mm').format(now);

      final orderPlacedDate = _formatTimestamp(order['orderDate']); // Format order placed date
      final deliveryCharge = 120;
      final totalPayable = order['totalAmount'] + deliveryCharge;

      // Adding a logo
      final logo = await rootBundle.load('assets/logo.png'); // Replace with your logo asset
      final logoImage = pw.MemoryImage(logo.buffer.asUint8List());

      pdf.addPage(
        pw.Page(
          margin: pw.EdgeInsets.all(0),
          build: (context) => pw.Container(
            color: accentColor,
            padding: pw.EdgeInsets.all(24 + 16 + 10),
            child: pw.Column(
              crossAxisAlignment: pw.CrossAxisAlignment.stretch,
              children: [
                // Header Section
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: pw.CrossAxisAlignment.center,
                  children: [
                    pw.Image(logoImage, width: 80),
                    pw.Text(
                      'Megamart Invoice',
                      style: pw.TextStyle(
                        fontSize: 24,
                        fontWeight: pw.FontWeight.bold,
                        color: baseColor,
                      ),
                    ),
                  ],
                ),
                pw.Divider(color: baseColor, thickness: 2),
                pw.SizedBox(height: 16),

                // Order and Customer Details
                pw.Row(
                  mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                  children: [
                    pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text('Order ID: $totalPayable${order['currency']}2836536', style: pw.TextStyle(color: baseColor, fontSize: 14)),
                        // pw.Text('Customer ID: ${order['customerId']}', style: pw.TextStyle(color: baseColor, fontSize: 14)),
                        pw.Text('Order Placed Date: $orderPlacedDate', style: pw.TextStyle(color: baseColor, fontSize: 14)), // Added order placed date
                      ],
                    ),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Shipping and Billing Address
                pw.Row(
                  crossAxisAlignment: pw.CrossAxisAlignment.start,
                  children: [
                    _buildAddressSection('Shipping Address', order['shippingAddress'], baseColor),
                    pw.SizedBox(width: 16),
                    _buildAddressSection('Billing Address', order['billingAddress'], baseColor),
                  ],
                ),
                pw.SizedBox(height: 16),

                // Items Table
                pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: baseColor, fontSize: 16)),
                pw.Table.fromTextArray(
                  headers: ['Product Name', 'Quantity', 'Total Price'],
                  data: order['items']
                      .map<List>((item) => [
                    item['productName'],
                    item['quantity'].toString(),
                    item['totalPrice'].toString(),
                  ])
                      .toList(),
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: whiteColor, fontSize: 14),
                  headerDecoration: pw.BoxDecoration(color: baseColor),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: pw.TextStyle(color: baseColor, fontSize: 14),
                  cellHeight: 30,
                  rowDecoration: pw.BoxDecoration(color: grayColor),
                ),
                pw.SizedBox(height: 16),

                // Payment Summary
                pw.Text('Payment Summary:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: baseColor, fontSize: 16)),
                pw.Table.fromTextArray(
                  headers: ['Description', 'Amount'],
                  data: [
                    ['Total Amount', '${order['totalAmount']} ${order['currency']}'],
                    ['Delivery Charge', '$deliveryCharge ${order['currency']}'],
                    ['Total Payable', '$totalPayable ${order['currency']}'],
                  ],
                  headerStyle: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: whiteColor, fontSize: 14),
                  headerDecoration: pw.BoxDecoration(color: baseColor),
                  cellAlignment: pw.Alignment.centerLeft,
                  cellStyle: pw.TextStyle(color: baseColor, fontSize: 14),
                  cellHeight: 30,
                  rowDecoration: pw.BoxDecoration(color: grayColor),
                ),
                pw.SizedBox(height: 16),

                // Footer Note
                pw.Text(
                  'Note: This order is Cash on Delivery. Please collect the payment upon delivery.',
                  style: pw.TextStyle(color: PdfColors.red, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.SizedBox(height: 16),
                pw.Text(
                  'Thank you for your order!',
                  style: pw.TextStyle(color: baseColor, fontSize: 14, fontWeight: pw.FontWeight.bold),
                ),
                pw.Spacer(),
                pw.Text(
                  'Invoice Generated on: $formattedDate',
                  style: pw.TextStyle(color: PdfColors.black, fontSize: 12),
                ),
              ],
            ),
          ),
        ),
      );

      final bytes = await pdf.save();
      final blob = html.Blob([bytes], 'application/pdf');
      final url = html.Url.createObjectUrlFromBlob(blob);
      final anchor = html.AnchorElement(href: url)
        ..setAttribute('download', 'invoice_${order['orderId']}_$formattedDate.pdf')
        ..click();
      html.Url.revokeObjectUrl(url);

      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice downloaded')));
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating invoice: $e')));
    }
  }
// Helper function for address section
  pw.Widget _buildAddressSection(String title, Map<String, dynamic> address, PdfColor baseColor) {
    return pw.Expanded(
      child: pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(title, style: pw.TextStyle(fontWeight: pw.FontWeight.bold, color: baseColor, fontSize: 16)),
          pw.Text('${address['fullName']}', style: pw.TextStyle(color: baseColor, fontSize: 14)),
          pw.Text('${address['phoneNumber']}', style: pw.TextStyle(color: baseColor, fontSize: 14)),
          pw.Text('${address['country']}, ${address['division']}, ${address['district']}, ${address['upazila']}, ${address['postalCode']}',
              style: pw.TextStyle(color: baseColor, fontSize: 14)),
        ],
      ),
    );
  }

}