import 'package:flutter/material.dart';
import 'package:flutter_otp_text_field/flutter_otp_text_field.dart';

class OtpVerificationScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Enter OTP')),
      body: Center(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: OtpTextField(
            numberOfFields: 6,
            // show as boxes or dashes
            showFieldAsBox: true,
            // Optional styling:
            borderColor: Colors.blue,
            focusedBorderColor: Colors.blueAccent,
            cursorColor: Colors.black,
            textStyle: TextStyle(fontSize: 20, color: Colors.black),
            fieldWidth: 50,
            onCodeChanged: (String code) {
              // optional: respond to each change
              print('Current code: $code');
            },
            onSubmit: (String verificationCode) {
              // user has entered all fields
              print('Entered OTP is: $verificationCode');
              // here you can call your backend or verification logic
            },
          ),
        ),
      ),
    );
  }
}
