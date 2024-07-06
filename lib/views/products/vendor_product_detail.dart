import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class VendorProductDetailPage extends StatelessWidget {
  final DocumentSnapshot product;

  VendorProductDetailPage({required this.product});

  @override
  Widget build(BuildContext context) {
    var fixedFields = List<Map<String, dynamic>>.from(product['fixedFields']);
    var additionalFields = List<Map<String, dynamic>>.from(product['fields']);
    String imageUrl = fixedFields.firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];

    return Scaffold(
      appBar: AppBar(
        title: Text(fixedFields.firstWhere((field) => field['fieldName'] == 'Product Name')['value']),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Image.network(imageUrl, height: 200),
            SizedBox(height: 20),
            Text('Fixed Fields', style: TextStyle(fontWeight: FontWeight.bold)),
            ...fixedFields.map((field) => ListTile(
              title: Text(field['fieldName']),
              subtitle: Text(field['value']),
            )),
            SizedBox(height: 20),
            Text('Additional Fields', style: TextStyle(fontWeight: FontWeight.bold)),
            ...additionalFields.map((field) => ListTile(
              title: Text(field['fieldName']),
              subtitle: Text(field['value']),
            )),
          ],
        ),
      ),
    );
  }
}
