import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:legend_cinema/presentation/widgets/custom_button.dart';
import 'package:legend_cinema/presentation/widgets/custom_date_input_field.dart';
import 'package:legend_cinema/presentation/widgets/custom_input_field.dart';
import '../../widgets/app_scaffold.dart';

class SignUpInformationScreen extends StatefulWidget {
  final String? phoneNumber;

  const SignUpInformationScreen({Key? key, this.phoneNumber}) : super(key: key);

  @override
  State<SignUpInformationScreen> createState() => _SignUpInformationScreenState();
}

class _SignUpInformationScreenState extends State<SignUpInformationScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _birthDateController = TextEditingController();

  bool _isFormValid = false;

   @override
  void initState() {
    super.initState();
    _firstNameController.addListener(_validateForm);
    _lastNameController.addListener(_validateForm);
    _birthDateController.addListener(_validateForm);
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _birthDateController.dispose();
    super.dispose();
  }

  void _validateForm() {
    final isValid = _firstNameController.text.trim().isNotEmpty &&
        _lastNameController.text.trim().isNotEmpty &&
        _birthDateController.text.trim().isNotEmpty;

    if (isValid != _isFormValid) {
      setState(() {
        _isFormValid = isValid;
      });
    }
  }

  void _onContinue() {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();

    if (firstName.isEmpty || lastName.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter both first and last name.')),
      );
      return;
    }

    // TODO: Handle next step (e.g., upload profile, go to next screen)
    debugPrint('Continue with: $firstName $lastName');
  }

  void _onSkip() {
    // TODO: Navigate to next screen or home
    debugPrint('User skipped setup');
  }

  @override
  Widget build(BuildContext context) {
    final displayNumber = widget.phoneNumber ??
        (kDebugMode ? '123456789' : 'Unknown number');
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return AppScaffold(
      backgroundColor: const Color(0xFF090909),
      body: SafeArea(
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 20),

                // 🔹 Profile Image with Camera Icon
                Stack(
                  alignment: Alignment.bottomRight,
                  children: [
                    CircleAvatar(
                      radius: 35,
                      backgroundColor: const Color.fromARGB(255, 225, 222, 222),
                      backgroundImage: null, // Add image if selected
                      child: const Icon(Icons.person, color: Colors.red, size: 45),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 4,
                      child: GestureDetector(
                        onTap: () {
                          // TODO: Implement image picker
                          debugPrint('Pick profile image');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: const BoxDecoration(
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.camera_alt, size: 16, color: Colors.black),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                
                Text(
                  'Set New Profile Picture',
                  style: const TextStyle(color: Colors.red, fontSize: 14),
                ),

                const SizedBox(height: 24),

                // 🔹 Title + Subtitle
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Setup your profile information',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text.rich(
                      TextSpan(
                        children: [
                          const TextSpan(
                            text: 'You have created your account with ',
                            style: TextStyle(color: Colors.white70, fontSize: 14),
                          ),
                          TextSpan(
                            text: '(+855) $displayNumber',
                            style: const TextStyle(color: Colors.red, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 32),

                // 🔹 Input fields with icons
                CustomInputField(
                  controller: _firstNameController,
                  keyboardType: TextInputType.text,
                  quickClear: false,
                  labelText: 'First Name',
                  inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                  prefix: const Icon(Icons.person, size: 18, color: Colors.white54),
                ),
                const SizedBox(height: 16),
                CustomInputField(
                  controller: _lastNameController,
                  keyboardType: TextInputType.text,
                  quickClear: false,
                  labelText: 'Last Name',
                  inputFormatters: [FilteringTextInputFormatter.singleLineFormatter],
                  prefix: const Icon(Icons.person, size: 18, color: Colors.white54),
                ),
                const SizedBox(height: 16),
                CustomDateInputField(
                  controller: _birthDateController,
                  labelText: 'Date of Birth',
                  prefix: const Icon(Icons.cake, size: 18, color: Colors.white54),
                ),
              ],
            ),
          ),
        ),
      ),

      // 🔹 Bottom buttons (like SignUpScreen)
      bottomNavigationBar: SafeArea(
        minimum: EdgeInsets.only(bottom: bottomInset),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: 48,
                width: double.infinity,
                child: CustomButton(
                  text: 'Continue',
                  onPressed: _isFormValid ? _onContinue : null,
                  backgroundColor: Colors.red,
                  textColor: Colors.white,
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                height: 48,
                width: double.infinity,
                child: CustomButton(
                  text: 'Skip',
                  onPressed: _onSkip,
                  backgroundColor: Colors.transparent,
                  textColor: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
