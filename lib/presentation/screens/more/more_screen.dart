import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth_services.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_alert.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Watch AuthState for changes
    final authState = context.watch<AuthState>();
    final isLoggedIn = authState.isLoggedIn;
    final user = authState.currentUser;

    return AppScaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      title: "Account",
      showBackButton: false,
      // Add Avatar to the actions if logged in
      actions: isLoggedIn
          ? [
              Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, '/editProfile');
                  },
                  child: CircleAvatar(
                    radius: 18, // Adjust size as needed
                    backgroundColor: const Color(0xFF2A2A2A),
                    // You could use NetworkImage if user.imageUrl exists
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                ),
              ),
            ]
          : null,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Login + Signup (Hidden if logged in)
            if (!isLoggedIn) ...[
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: CustomButton(
                        text: "Login",
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        height: 48,
                        borderRadius: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "Signup",
                        onPressed: () =>
                            Navigator.pushNamed(context, '/signUp'),
                        height: 48,
                        borderRadius: 30,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Show User Info Greeting if logged in (Optional but nice)
            if (isLoggedIn && user != null) ...[
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                child: Text(
                  "Hello, ${user.firstName}".trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Membership Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF1E1E1E),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.white12,
                    width: 1,
                  ), // Added border
                ),
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text(
                            "Legend Membership",
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            "Getting many benefits from our membership card. Take one now at your nearby Legend Cinema!",
                            style: TextStyle(
                              color: Colors.white70,
                              fontSize: 13,
                            ),
                          ),
                          SizedBox(height: 12),
                          // Learn more button and Activate button
                          Row(
                            children: [
                              _ActivateButton(), // New Activate button
                              SizedBox(width: 10),
                              _LearnMoreButton(),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.card_membership, // Updated icon
                        color: Colors.redAccent,
                        size: 56,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Tickets Section
            _sectionTitle("Tickets"),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "Purchase",
                  icon: Icons.confirmation_number,
                  route: null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Languages Section
            _sectionTitle("Languages"),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "English",
                  icon: Icons.language,
                  route: null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // What's new? Section
            _sectionTitle("What's new?"),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "News & Activity",
                  icon: Icons.new_releases,
                  route: null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notifications Section
            _sectionTitle("Notifications"),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "Notifications",
                  icon: Icons.notifications,
                  route: null,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // About us Section
            _sectionTitle("About us"),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "About us",
                  icon: Icons.info,
                  route: null,
                ),
                _menuTile(
                  context,
                  title: "Contact us",
                  icon: Icons.call,
                  route: null,
                ),
                _menuTile(
                  context,
                  title: "Privacy Policy",
                  icon: Icons.privacy_tip,
                  route: null,
                ),
                _menuTile(
                  context,
                  title: "Term & Conditions",
                  icon: Icons.article,
                  route: null,
                ),
                if (isLoggedIn)
                  _menuTile(
                    context,
                    title: "Logout",
                    icon: Icons.logout,
                    onTap: () async {
                      if (!context.mounted) return;

                      final shouldLogout = await CustomAlert.showConfirm(
                        context,
                        title: 'Logout',
                        message: 'Are you sure you want to logout?',
                        confirmText: 'Logout',
                      );

                      if (shouldLogout && context.mounted) {
                        final authService = AuthServices();
                        await authService.signOut();
                        if (context.mounted) {
                          context.read<AuthState>().clearUserFromStorage();
                        }
                      }
                    },
                  ),
              ],
            ),

            const SizedBox(height: 48),
          ],
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6, left: 16, right: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white70,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _menuTile(
    BuildContext context, {
    required String title,
    required IconData icon,
    String? route,
    VoidCallback? onTap, // Added for custom tap handling
  }) {
    return Container(
      decoration: const BoxDecoration(
        color: Color.fromARGB(255, 34, 34, 34),
        border: Border(bottom: BorderSide(color: Colors.white12, width: 0.5)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2A2A2A),
          child: Icon(icon, color: Colors.redAccent),
        ),
        title: Text(
          title,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ), // Increased font size
        trailing: const Icon(
          Icons.arrow_forward_ios,
          color: Colors.white70,
          size: 16,
        ),
        onTap:
            onTap ??
            (route != null ? () => Navigator.pushNamed(context, route) : null),
      ),
    );
  }
}

// Helper widget to wrap multiple menu tiles and apply border/no margin
class _MenuSection extends StatelessWidget {
  final List<Widget> children;
  const _MenuSection({required this.children});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        // borderRadius: BorderRadius.circular(8), // Removed for full width
      ),
      clipBehavior: Clip.antiAlias, // Clip children to rounded corners
      child: Column(children: children),
    );
  }
}

class _LearnMoreButton extends StatelessWidget {
  const _LearnMoreButton();

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      // Changed to OutlinedButton
      onPressed: () {
        // Handle learn more action
      },
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white, // Text color
        side: const BorderSide(
          color: Colors.white,
          width: 0.8,
        ), // Smaller border width
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 28), // Maintain height
      ),
      child: const Text(
        "Learn More",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}

class _ActivateButton extends StatelessWidget {
  const _ActivateButton();

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      // New button for "Activate"
      onPressed: () {
        // Handle activate action
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFCC0000), // Background color
        foregroundColor: Colors.white, // Text color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 28), // Maintain height
      ),
      child: const Text(
        "Activate",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
