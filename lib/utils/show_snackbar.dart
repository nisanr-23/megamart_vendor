import 'package:flutter/material.dart';
import '/utils/colors.dart';

void showSnackBar(BuildContext context, String title,{required Color bgColor}) {
  final snackBar = SnackBar(
    content: Text(
      title,
      style: TextStyle(color: Colors.white),
    ),
    backgroundColor: bgColor,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 3),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10),
    ),
  );

  ScaffoldMessenger.of(context).showSnackBar(snackBar);
}
