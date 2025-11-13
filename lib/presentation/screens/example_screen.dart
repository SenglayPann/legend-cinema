import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:legend_cinema/presentation/state/auth_state.dart';
import '../widgets/app_scaffold.dart';

class ExampleScreen extends StatelessWidget {
  const ExampleScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // This line correctly accesses the AuthState instance provided at the root
    final auth = context.watch<AuthState>();

    print('-------> auth');
    print(auth.currentUser?.phone);
    print(auth.currentUser?.dateOfBirth);

    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      body: Center(
        child: Text(
          'Logged in as: ${auth.currentUser?.phone ?? "Guest"}',
          style: const TextStyle(color: Colors.red, fontSize: 24),
        ),
      ),
    );
  }
}
