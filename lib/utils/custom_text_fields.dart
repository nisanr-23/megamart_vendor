import 'package:flutter/material.dart';
import '/utils/colors.dart'; // Adjust import as per your project structure

class CustomTextField extends StatelessWidget {
  // Properties
  final String labelText; // Required: Label text for the TextFormField
  final String hintText; // Required: Hint text for the TextFormField
  final IconData? prefixIcon; // Required: Icon displayed before the input field
  final TextEditingController? controller; // Required: Controller for managing the input field's text
  final bool obscureText; // Optional: Whether the text should be obscured (e.g., for passwords). Defaults to false
  final String? Function(String?)? validator; // Optional: Validator function for input validation
  final ValueChanged<String>? onChanged; // Optional: Callback function invoked when the input changes
  final TextInputType keyboardType; // Optional: Type of keyboard to display for input
  final TextInputAction? textInputAction; // Optional: Action button on the keyboard
  final FocusNode? focusNode; // Optional: Manages the focus state of the input field
  final bool autocorrect; // Optional: Whether to enable autocorrection in the input field
  final double maxwidth;
  final IconData? suffixIcon;
  final VoidCallback? suffixIconOnTap;

  // Constructor
  const CustomTextField({
    Key? key,
    required this.labelText,
    required this.hintText,
    this.prefixIcon,
    this.controller,
    this.obscureText = false,
    this.validator, // Optional validator function
    this.onChanged, // Optional callback for onChanged event
    this.keyboardType = TextInputType.text, // Defaults to text input type
    this.textInputAction, // Optional text input action
    this.focusNode, // Optional focus node
    this.autocorrect = true, // Defaults to enabling autocorrect
    required this.maxwidth,
    this.suffixIcon,
    this.suffixIconOnTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ConstrainedBox(
      constraints: BoxConstraints(
        maxWidth: maxwidth,
      ),
      child: TextFormField(
        controller: controller,
        obscureText: obscureText,
        validator: validator, // Pass the validator function to TextFormField
        onChanged: onChanged, // Pass the onChanged callback to TextFormField
        keyboardType: keyboardType,
        textInputAction: textInputAction,
        focusNode: focusNode,
        autocorrect: autocorrect,
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          // labelStyle: TextStyle(
          //   color: Colors.blueAccent,
          //   fontWeight: FontWeight.bold,
          // ),
          hintStyle: TextStyle(
            color: Colors.black.withOpacity(0.6),
            fontStyle: FontStyle.italic,
          ),
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: Colors.blueAccent) : null,
          suffix: suffixIcon != null
              ? GestureDetector(
            onTap: suffixIconOnTap,
            child: Icon(suffixIcon, color: Colors.blueAccent),
          )
              : null,
          // enabledBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Color(0xff879fff),
          //     width: 2.0,
          //   ),
          //   borderRadius: BorderRadius.circular(20),
          // ),
          // focusedBorder: OutlineInputBorder(
          //   borderSide: BorderSide(
          //     color: Colors.blueAccent.shade700,
          //     width: 2.0,
          //   ),
          //   borderRadius: BorderRadius.circular(20),
          // ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
          ),
          filled: true,
          fillColor: Colors.blue[50],
          contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        ),
      ),
    );
  }
}
