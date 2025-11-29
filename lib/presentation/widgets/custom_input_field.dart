import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CustomInputField extends StatelessWidget {
  final TextEditingController controller;
  final String labelText;
  final TextInputType keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final Widget? prefix;
  final bool obscureText;
  final bool quickClear;
  final int? maxLength;

  const CustomInputField({
    super.key,
    required this.controller,
    required this.labelText,
    required this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.prefix,
    this.obscureText = false,
    this.quickClear = true,
    this.maxLength,
  });

  @override
  Widget build(BuildContext context) {

    final formatters = [
      ...?inputFormatters,
      if (maxLength != null) LengthLimitingTextInputFormatter(maxLength),
    ];
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: formatters,
      validator: validator,
      obscureText: obscureText,
      cursorColor: Colors.white70,
      style: const TextStyle(
        color: Colors.white70,
      ),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Colors.white70),
        ),
        labelText: labelText,
        labelStyle: const TextStyle(color: Colors.white70),
        floatingLabelBehavior: FloatingLabelBehavior.auto,
        prefixIconConstraints: const BoxConstraints(minWidth: 0, minHeight: 0),
        prefixIcon: prefix != null
            ? Padding(
                padding: const EdgeInsets.only(left: 12, right: 8),
                child: prefix,
              )
            : null,
        contentPadding: const EdgeInsets.symmetric(vertical: 12, horizontal: 12),
        suffixIcon: controller.text.isNotEmpty && quickClear
        ? IconButton(
            onPressed: () {
              controller.clear();
            },
            icon: const Icon(Icons.close, color: Colors.white),
          )
        : null,
      ),
    );
  }
}
