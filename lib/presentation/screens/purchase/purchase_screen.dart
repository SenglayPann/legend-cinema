import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class PurchaseScreen extends StatelessWidget {
  const PurchaseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const AppScaffold(
      title: 'Purchase',
      body: Center(
        child: Text(
          'Purchase Screen Placeholder',
          style: TextStyle(color: Colors.white, fontSize: 18),
        ),
      ),
    );
  }
}
