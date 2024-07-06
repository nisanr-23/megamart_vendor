import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:megamart_vendor/vendor/views/auth/vendor_auth_screen.dart';
import 'package:megamart_vendor/views/authentications/vendor_login.dart';
import 'package:megamart_vendor/views/authentications/vendor_sign_up.dart';
import 'firebase_options.dart';


import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:megamart_vendor/views/authentications/vendor_login.dart'; // Import your login screen
import 'package:megamart_vendor/views/authentications/vendor_pending_approval.dart'; // Import your pending approval screen
import 'package:megamart_vendor/views/navigations/vendor_dashboard_view.dart'; // Import your dashboard screen


Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp( MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vendor App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      // home: VendorSignUp(),
      home: VendorLogin(),
      debugShowCheckedModeBanner: false,
    );
  }
}


