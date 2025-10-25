import 'package:flutter/material.dart';

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double width;
  final double height;
  final Color backgroundColor;
  final Color disabledColor;
  final Color textColor;
  final double borderRadius;
  final double fontSize;

  const CustomButton({
    Key? key,
    required this.text,
    required this.onPressed,
    this.width = double.infinity,
    this.height = 48,
    this.backgroundColor = Colors.red,
    this.disabledColor = const Color.fromARGB(255, 46, 47, 48),
    this.textColor = Colors.white,
    this.borderRadius = 24,
    this.fontSize = 16,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.resolveWith<Color>(
            (states) {
              if (states.contains(MaterialState.disabled)) {
                return disabledColor;
              }
              return backgroundColor;
            },
          ),
          foregroundColor: MaterialStateProperty.all(textColor),
          shape: MaterialStateProperty.all(
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(borderRadius)),
          ),
        ),
        child: Text(
          text,
          style: TextStyle(fontSize: fontSize, color: onPressed != null ? textColor : const Color(0xFF8D9192)),
        ),
      ),
    );
  }
}
