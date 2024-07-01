import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddProductPage extends StatefulWidget {
  @override
  _AddProductPageState createState() => _AddProductPageState();
}

class _AddProductPageState extends State<AddProductPage> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final TextEditingController _productNameController = TextEditingController();
  final TextEditingController _regularPriceController = TextEditingController();
  final TextEditingController _offerPriceController = TextEditingController();
  final TextEditingController _stockController = TextEditingController();

  void _addProduct() async {
    final vendor = _auth.currentUser!;
    await _firestore.collection('products').add({
      'vendorId': vendor.uid,
      'productName': _productNameController.text,
      'regularPrice': double.parse(_regularPriceController.text),
      'offerPrice': double.parse(_offerPriceController.text),
      'stock': int.parse(_stockController.text),
      'createdAt': Timestamp.now(),
    });
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Add Product')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextFormField(
              controller: _productNameController,
              decoration: InputDecoration(labelText: 'Product Name'),
            ),
            TextFormField(
              controller: _regularPriceController,
              decoration: InputDecoration(labelText: 'Regular Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _offerPriceController,
              decoration: InputDecoration(labelText: 'Offer Price'),
              keyboardType: TextInputType.number,
            ),
            TextFormField(
              controller: _stockController,
              decoration: InputDecoration(labelText: 'Stock'),
              keyboardType: TextInputType.number,
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _addProduct,
              child: Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
