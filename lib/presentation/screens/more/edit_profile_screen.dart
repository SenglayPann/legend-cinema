import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:legend_cinema/presentation/state/auth_state.dart';
import 'package:legend_cinema/presentation/widgets/custom_button.dart';
import 'package:legend_cinema/presentation/widgets/custom_date_input_field.dart';
import 'package:legend_cinema/presentation/widgets/custom_input_field.dart';
import 'package:legend_cinema/presentation/widgets/custom_alert.dart';
import '../../widgets/app_scaffold.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  late TextEditingController _firstNameController;
  late TextEditingController _lastNameController;
  late TextEditingController _birthDateController;

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthState>().currentUser;
    _firstNameController = TextEditingController(text: user?.firstName ?? '');
    _lastNameController = TextEditingController(text: user?.lastName ?? '');

    String dobText = '';
    if (user?.dateOfBirth != null) {
      // Assuming basic ISO string or handled by CustomDateInputField logic
      dobText = user!.dateOfBirth!.toDate().toString();
    }
    _birthDateController = TextEditingController(text: dobText);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  Future<void> _onSave() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      CustomAlert.show(
        context,
        title: 'Missing Info',
        message: 'Please enter first and last name.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Parse date if needed, assuming controller holds valid date string
      // For simplicity, we might trust the DatePicker widget logic or try parsing
      DateTime? dob;
      if (_birthDateController.text.isNotEmpty) {
        dob = DateTime.tryParse(_birthDateController.text);
      }

      await context.read<AuthState>().updateUserProfile(
        firstName: firstName,
        lastName: lastName,
        dob: dob,
      );

      if (mounted) {
        await CustomAlert.show(
          context,
          title: 'Success',
          message: 'Profile updated successfully.',
        );
        if (mounted) Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        CustomAlert.show(
          context,
          title: 'Error',
          message: 'Failed to update profile: $e',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      title: 'Edit Profile',
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Avatar Placeholder (non-functional for now as per plan focus on simple edit)
            const CircleAvatar(
              radius: 40,
              backgroundColor: Color(0xFF2A2A2A),
              child: Icon(Icons.person, size: 50, color: Colors.white54),
            ),
            const SizedBox(height: 24),

            CustomInputField(
              controller: _firstNameController,
              keyboardType: TextInputType.text,
              labelText: 'First Name',
              prefix: const Icon(Icons.person, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            CustomInputField(
              controller: _lastNameController,
              keyboardType: TextInputType.text,
              labelText: 'Last Name',
              prefix: const Icon(Icons.person, color: Colors.white54),
            ),
            const SizedBox(height: 16),
            CustomDateInputField(
              controller: _birthDateController,
              labelText: 'Date of Birth',
              prefix: const Icon(Icons.cake, color: Colors.white54),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: CustomButton(
                text: _isLoading ? 'Saving...' : 'Save Changes',
                onPressed: _isLoading ? null : _onSave,
                backgroundColor: Colors.red,
                textColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
