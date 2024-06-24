

import 'dart:typed_data';

import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class VendorController{
  //pick store image
  final ImagePicker _picker = ImagePicker();

  Future<Uint8List> pickStoreImage(ImageSource source) async {
    final XFile? image = await _picker.pickImage(source: source);
    if (image != null) {
      return await image.readAsBytes();
    }
    throw Exception('No image selected');
  }

  //

}