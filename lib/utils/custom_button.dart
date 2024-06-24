import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final Color color;
  final double widthPercentage;
  // final double height;
  final double padding;
  final String buttonText;
  final double textSize;
  final Color textColor;
  final double maxwidth;
  final VoidCallback onTap;

  CustomButton({
    required this.color,
    required this.widthPercentage,
    // required this.height,
    required this.padding,
    required this.buttonText,
    required this.textSize,
    required this.textColor, required this.maxwidth, required this.onTap
});

  @override
  Widget build(BuildContext context) {
    double buttonWidth = MediaQuery.of(context).size.width*widthPercentage;
    double paddingText = padding;
    return ConstrainedBox(
      constraints: BoxConstraints(maxWidth: maxwidth),
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10)
        ),
        
        width: buttonWidth,
        child: InkWell(
          onTap: onTap,
          child: Center(child: Padding(
            padding:  EdgeInsets.all(paddingText),
            child: Text(buttonText,style: TextStyle(fontSize: textSize,color: textColor),),
          )),
        ),
      ),
    );
  }
}
