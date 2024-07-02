import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class VendorAddProductPage extends StatefulWidget {
  final String vendorId;
  final DocumentSnapshot? product;

  VendorAddProductPage({required this.vendorId, this.product});

  @override
  _VendorAddProductPageState createState() => _VendorAddProductPageState();
}

class _VendorAddProductPageState extends State<VendorAddProductPage> {
  File? _selectedImage;
  String? _imageUrl;
  String? _selectedCategoryId;
  List<Map<String, dynamic>> _fixedFields = [];
  List<Map<String, dynamic>> _additionalFields = [];

  @override
  void initState() {
    super.initState();
    if (widget.product != null) {
      _loadProductData(widget.product!);
    }
  }

  void _loadProductData(DocumentSnapshot product) {
    setState(() {
      _selectedCategoryId = product['categoryId'];
      _fixedFields = List<Map<String, dynamic>>.from(product['fixedFields']);
      _additionalFields = List<Map<String, dynamic>>.from(product['fields']);
      _imageUrl = _fixedFields.firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'];
    });
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  Future<void> _uploadImage() async {
    if (_selectedImage == null) return;
    final storageRef = FirebaseStorage.instance.ref().child('product_images/${DateTime.now().toIso8601String()}.jpg');
    final uploadTask = storageRef.putFile(_selectedImage!);

    final snapshot = await uploadTask.whenComplete(() => {});
    final downloadUrl = await snapshot.ref.getDownloadURL();

    setState(() {
      _imageUrl = downloadUrl;
    });

    // Update the product image URL field
    _fixedFields.firstWhere((field) => field['fieldName'] == 'Product Image URL')['value'] = _imageUrl;
  }

  void _fetchCategoryFields(String categoryId) async {
    final categoryDoc = await FirebaseFirestore.instance.collection('categories').doc(categoryId).get();
    if (categoryDoc.exists) {
      setState(() {
        _fixedFields = List<Map<String, dynamic>>.from(categoryDoc['fixedFields']);
        _additionalFields = List<Map<String, dynamic>>.from(categoryDoc['fields']);
      });
    }
  }

  void _saveProduct() async {
    if (_selectedImage != null) {
      await _uploadImage();
    }

    final productData = {
      'vendorId': widget.vendorId,
      'categoryId': _selectedCategoryId,
      'createdAt': widget.product == null ? FieldValue.serverTimestamp() : widget.product!['createdAt'],
      'updatedAt': FieldValue.serverTimestamp(),
      'fixedFields': _fixedFields.map((field) {
        return {
          'fieldName': field['fieldName'],
          'fieldType': field['fieldType'],
          'value': field['value'],
        };
      }).toList(),
      'fields': _additionalFields.map((field) {
        return {
          'fieldName': field['fieldName'],
          'fieldType': field['fieldType'],
          'value': field['value'],
        };
      }).toList(),
    };

    if (widget.product == null) {
      await FirebaseFirestore.instance.collection('products').add(productData);
    } else {
      await FirebaseFirestore.instance.collection('products').doc(widget.product!.id).update(productData);
    }

    Navigator.of(context).pop();
  }

  Widget _buildFieldItem(Map<String, dynamic> field) {
    return Column(
      children: [
        if (field['fieldType'] == 'text')
          TextFormField(
            initialValue: field['value'],
            onChanged: (value) {
              field['value'] = value;
            },
            decoration: InputDecoration(labelText: field['fieldName']),
          ),
        if (field['fieldType'] == 'number')
          TextFormField(
            initialValue: field['value'],
            onChanged: (value) {
              field['value'] = value;
            },
            decoration: InputDecoration(labelText: field['fieldName']),
            keyboardType: TextInputType.number,
          ),
        if (field['fieldType'] == 'dropdown')
          DropdownButtonFormField<String>(
            value: field['value'],
            items: (field['options'] as List<dynamic>)
                .map((option) => DropdownMenuItem<String>(
              value: option as String,
              child: Text(option),
            ))
                .toList(),
            onChanged: (value) {
              field['value'] = value;
            },
            decoration: InputDecoration(labelText: field['fieldName']),
          ),
        if (field['fieldType'] == 'date')
          TextFormField(
            initialValue: field['value'],
            onTap: () async {
              DateTime? pickedDate = await showDatePicker(
                context: context,
                initialDate: field['value'] != null ? DateTime.parse(field['value']) : DateTime.now(),
                firstDate: DateTime(2000),
                lastDate: DateTime(2101),
              );
              if (pickedDate != null) {
                setState(() {
                  field['value'] = pickedDate.toIso8601String();
                });
              }
            },
            readOnly: true,
            decoration: InputDecoration(labelText: field['fieldName']),
          ),
        Divider(),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.product == null ? 'Add Product' : 'Edit Product'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('categories').snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) return CircularProgressIndicator();
                var categories = snapshot.data!.docs;
                return DropdownButton<String>(
                  value: _selectedCategoryId,
                  onChanged: (String? newValue) {
                    setState(() {
                      _selectedCategoryId = newValue!;
                      _fetchCategoryFields(newValue);
                    });
                  },
                  hint: Text('Select Category'),
                  items: categories.map((category) {
                    return DropdownMenuItem<String>(
                      value: category.id,
                      child: Text(category['name']),
                    );
                  }).toList(),
                );
              },
            ),
            SizedBox(height: 20),
            Text('Fixed Fields', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._fixedFields.map((field) => _buildFieldItem(field)).toList(),
            SizedBox(height: 20),
            Text('Additional Fields', style: TextStyle(fontWeight: FontWeight.bold)),
            ..._additionalFields.map((field) => _buildFieldItem(field)).toList(),
            SizedBox(height: 20),
            if (_selectedImage != null)
              Image.file(
                _selectedImage!,
                height: 200,
              )
            else if (_imageUrl != null)
              Image.network(
                _imageUrl!,
                height: 200,
              ),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image'),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveProduct,
              child: Text(widget.product == null ? 'Save Product' : 'Update Product'),
            ),
          ],
        ),
      ),
    );
  }
}
