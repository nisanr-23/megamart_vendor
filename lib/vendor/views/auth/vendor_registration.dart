import 'dart:typed_data';

import 'package:country_state_city_picker/country_state_city_picker.dart';
import 'package:country_state_city_pro/country_state_city_pro.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:image_picker/image_picker.dart';
import 'package:megamart_vendor/utils/custom_text_form_fields.dart';
import 'package:megamart_vendor/utils/location/location_picker.dart';
import 'package:megamart_vendor/vendor/controllers/vendor_register_controller.dart';

import '../../../utils/custom_text_fields.dart';

class VendorRegistrationScreen extends StatefulWidget {
  const VendorRegistrationScreen({super.key});

  @override
  State<VendorRegistrationScreen> createState() => _VendorRegistrationScreenState();
}

class _VendorRegistrationScreenState extends State<VendorRegistrationScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late String countryValue = '';
  late String stateValue = '';
  late String cityValue = '';
  final VendorController _vendorController = VendorController();

  TextEditingController countryController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController cityController = TextEditingController();

  TextEditingController country = TextEditingController();
  TextEditingController state = TextEditingController();
  TextEditingController city = TextEditingController();

  Uint8List? _image;

  Future<void> selectGalleryImage() async {
    try {
      Uint8List im = await _vendorController.pickStoreImage(ImageSource.gallery);
      setState(() {
        _image = im;
      });
    } catch (e) {
      // Handle the error (e.g., no image selected)
      print(e);
    }
  }

  void clearImage() {
    setState(() {
      _image = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: CustomScrollView(
          slivers: [
            SliverAppBar(
              backgroundColor: Colors.blueAccent.shade700,
              toolbarHeight: 200,
              flexibleSpace: LayoutBuilder(
                builder: (context, constraints) {
                  return FlexibleSpaceBar(
                    background: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(colors: [
                          Colors.blueAccent,
                          Colors.yellowAccent,
                        ]),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              height: 90,
                              width: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                              ),
                              child: Stack(
                                alignment: Alignment.center,
                                children: [
                                  if (_image != null)
                                    Image.memory(_image!)
                                  else
                                    IconButton(
                                      onPressed: selectGalleryImage,
                                      icon: Icon(CupertinoIcons.photo_camera),
                                    ),
                                  if (_image != null)
                                    Positioned(
                                      top: 0,
                                      right: 0,
                                      child: IconButton(
                                        onPressed: clearImage,
                                        icon: Icon(Icons.close),
                                      ),
                                    ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    SizedBox(height: 10),
                    CustomTextField(
                      keyboardType: TextInputType.name,
                      labelText: 'Business name',
                      hintText: '',
                      maxwidth: 500,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      keyboardType: TextInputType.emailAddress,
                      labelText: 'Email address',
                      hintText: '',
                      maxwidth: 500,
                    ),
                    SizedBox(height: 10),
                    CustomTextField(
                      keyboardType: TextInputType.phone,
                      labelText: 'Phone number',
                      hintText: '',
                      maxwidth: 500,
                    ),
                    SizedBox(height: 20),
                    LocationPicker(),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        // Handle form submission
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent.shade700,
                        padding: EdgeInsets.symmetric(
                          horizontal: 30.0,
                          vertical: 15.0,
                        ),
                      ),
                      child: Text(
                        'Submit',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
