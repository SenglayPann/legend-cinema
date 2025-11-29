import 'package:flutter/material.dart';
import '../../widgets/app_scaffold.dart';

class MoreScreen extends StatelessWidget {
  final bool isLoggedIn; // Added to simulate login state
  const MoreScreen({super.key, this.isLoggedIn = false});

  @override
  Widget build(BuildContext context) {
    return AppScaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      title: "Account",
      showBackButton: false,
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Login + Signup (Hidden if logged in)
            if (!isLoggedIn) ...[
              Row(
                children: [
                  Expanded(
                    child: _roundedButton(
                      title: "Login",
                      icon: Icons.login_rounded,
                      onTap: () => Navigator.pushNamed(context, '/login'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _roundedButton(
                      title: "Signup",
                      icon: Icons.person_add_alt_1_outlined,
                      onTap: () => Navigator.pushNamed(context, '/signUp'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
            ],

            // Membership Card
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF1E1E1E),
                borderRadius: BorderRadius.circular(12),
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
                          style: TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        SizedBox(height: 12),
                        // Learn more button and Activate button
                        Row(
                          children: [
                            _LearnMoreButton(),
                            SizedBox(width: 10),
                            _ActivateButton(), // New Activate button
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
                    onTap: () {
                      // Handle logout logic here
                      print("User logged out");
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
      padding: const EdgeInsets.only(top: 8.0, bottom: 6),
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

  static Widget _roundedButton({
    required String title,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: const Color(0xFFCC0000),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: Colors.white),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
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
        borderRadius: BorderRadius.circular(8),
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
        foregroundColor: Colors.redAccent, // Text color
        side: const BorderSide(color: Color(0xFFCC0000)), // Border color
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        padding: const EdgeInsets.symmetric(horizontal: 14),
        minimumSize: const Size(0, 36), // Maintain height
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
        minimumSize: const Size(0, 36), // Maintain height
      ),
      child: const Text(
        "Activate",
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
    );
  }
}
