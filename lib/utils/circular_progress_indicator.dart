import 'package:flutter/material.dart';

class CustomCircularProgressIndicator extends StatefulWidget {
  const CustomCircularProgressIndicator({super.key});

  @override
  State<CustomCircularProgressIndicator> createState() => _CustomCircularProgressIndicatorState();
}

class _CustomCircularProgressIndicatorState extends State<CustomCircularProgressIndicator> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      width: 150,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey)

      ),
      child: const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}
