
import 'package:flutter/material.dart';


import '../widgets/app_scaffold.dart';


class ExampleScreen extends StatelessWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      body: Center(
        child: Text('Example Screen',
          style: const TextStyle(color: Colors.red, fontSize: 24),
        ),
      ),
    );
  }
} 