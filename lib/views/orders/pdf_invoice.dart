// import 'package:flutter/material.dart';
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:intl/intl.dart';
// import 'package:pdf/widgets.dart' as pw;
// import 'package:path_provider/path_provider.dart';
// import 'dart:io';
//
// class OrderDetailsPage extends StatefulWidget {
//   final String orderId;
//
//   OrderDetailsPage({required this.orderId});
//
//   @override
//   _OrderDetailsPageState createState() => _OrderDetailsPageState();
// }
//
// class _OrderDetailsPageState extends State<OrderDetailsPage> {
//   final FirebaseFirestore _firestore = FirebaseFirestore.instance;
//   final _noteController = TextEditingController();
//   String? _selectedStatus;
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Order Details'),
//       ),
//       body: FutureBuilder<DocumentSnapshot>(
//         future: _firestore.collection('orders').doc(widget.orderId).get(),
//         builder: (context, snapshot) {
//           if (!snapshot.hasData) {
//             return Center(child: CircularProgressIndicator());
//           }
//
//           var order = snapshot.data!.data() as Map<String, dynamic>;
//           var orderHistory = order['orderHistory'] as List<dynamic>;
//
//           return Padding(
//             padding: const EdgeInsets.all(16.0),
//             child: ListView(
//               children: [
//                 _buildOrderInfo(order),
//                 SizedBox(height: 20),
//                 _buildOrderStatusDropdown(order['orderStatus']),
//                 SizedBox(height: 20),
//                 _buildAddNoteSection(),
//                 SizedBox(height: 20),
//                 _buildOrderHistory(orderHistory),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => _updateOrderStatus(),
//                   child: Text('Update Status'),
//                 ),
//                 SizedBox(height: 20),
//                 ElevatedButton(
//                   onPressed: () => _generateInvoice(order),
//                   child: Text('Generate Invoice'),
//                 ),
//               ],
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildOrderInfo(Map<String, dynamic> order) {
//     // The same code as in the original implementation
//   }
//
//   String _formatTimestamp(Timestamp timestamp) {
//     return DateFormat.yMMMd().add_jm().format(timestamp.toDate());
//   }
//
//   Widget _buildOrderStatusDropdown(String currentStatus) {
//     // The same code as in the original implementation
//   }
//
//   Widget _buildAddNoteSection() {
//     // The same code as in the original implementation
//   }
//
//   Widget _buildOrderHistory(List<dynamic> history) {
//     // The same code as in the original implementation
//   }
//
//   Future<void> _updateOrderStatus() async {
//     // The same code as in the original implementation
//   }
//
//   Future<void> _generateInvoice(Map<String, dynamic> order) async {
//     try {
//       final pdf = pw.Document();
//
//       pdf.addPage(
//         pw.Page(
//           build: (context) => pw.Column(
//             crossAxisAlignment: pw.CrossAxisAlignment.start,
//             children: [
//               pw.Text('Invoice', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
//               pw.SizedBox(height: 20),
//               pw.Text('Order ID: ${widget.orderId}'),
//               pw.Text('Customer ID: ${order['customerId']}'),
//               pw.Text('Total Amount: ${order['totalAmount']} ${order['currency']}'),
//               pw.Text('Payment Method: ${order['paymentMethod']}'),
//               pw.Text('Payment Status: ${order['paymentStatus']}'),
//               pw.Text('Order Date: ${_formatTimestamp(order['orderDate'])}'),
//               pw.SizedBox(height: 20),
//               pw.Text('Shipping Address:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//               pw.Text('${order['shippingAddress']['fullName']}'),
//               pw.Text('${order['shippingAddress']['phoneNumber']}'),
//               pw.Text('${order['shippingAddress']['country']}, ${order['shippingAddress']['division']}, ${order['shippingAddress']['district']}, ${order['shippingAddress']['upazila']}, ${order['shippingAddress']['postalCode']}'),
//               pw.SizedBox(height: 20),
//               pw.Text('Items:', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
//               ...order['items'].map<pw.Widget>((item) {
//                 return pw.Column(
//                   crossAxisAlignment: pw.CrossAxisAlignment.start,
//                   children: [
//                     pw.Text('${item['productName']} - Quantity: ${item['quantity']} - Total: ${item['totalPrice']}'),
//                   ],
//                 );
//               }).toList(),
//             ],
//           ),
//         ),
//       );
//
//       final directory = await getApplicationDocumentsDirectory();
//       final file = File('${directory.path}/invoice_${widget.orderId}.pdf');
//       await file.writeAsBytes(await pdf.save());
//
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Invoice downloaded as ${file.path}')));
//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error generating invoice: $e')));
//     }
//   }
// }


import 'dart:html';
import 'package:flutter/material.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class PdfGenerator extends StatefulWidget {
  @override
  _PdfGeneratorState createState() => _PdfGeneratorState();
}

class _PdfGeneratorState extends State<PdfGenerator> {
  void _generatePdf() async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4,
        build: (context) {
          return pw.Center(
            child: pw.Text(
              'Hello, World!',
              style: pw.TextStyle(fontSize: 24),
            ),
          );
        },
      ),
    );

    final bytes = await pdf.save();

    // Create a link to download the PDF
    final blob = Blob([bytes]);
    final url = Url.createObjectUrlFromBlob(blob);
    final anchor = AnchorElement(href: url)
      ..download = 'my_document.pdf'
      ..click();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('PDF Generator'),
      ),
      body: Center(
        child: ElevatedButton(
          onPressed: _generatePdf,
          child: Text('Generate PDF'),
        ),
      ),
    );
  }
}