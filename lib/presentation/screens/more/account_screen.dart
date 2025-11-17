import 'package:flutter/material.dart';

class AccountScreen extends StatelessWidget {
  const AccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F0F),
      appBar: AppBar(
        backgroundColor: const Color(0xFFCC0000),
        elevation: 0,
        title: const Text("Account"),
      ),
      bottomNavigationBar: _buildBottomNav(),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Login + Signup
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
                          // Learn more button
                          _LearnMoreButton(),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 80,
                      height: 80,
                      alignment: Alignment.center,
                      child: Icon(Icons.card_giftcard, color: Colors.redAccent, size: 56),
                    )
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Sections
              _sectionTitle("Languages"),
              _menuTile(context, title: "English", icon: Icons.language, route: null),

              _sectionTitle("What's new?"),
              _menuTile(context, title: "News & Activity", icon: Icons.new_releases, route: null),

              _sectionTitle("Notifications"),
              _menuTile(context, title: "Notifications", icon: Icons.notifications, route: null),

              _sectionTitle("About us"),
              _menuTile(context, title: "About us", icon: Icons.info, route: null),
              _menuTile(context, title: "Contact us", icon: Icons.call, route: null),
              _menuTile(context, title: "Privacy Policy", icon: Icons.privacy_tip, route: null),
              _menuTile(context, title: "Term & Conditions", icon: Icons.article, route: null),

              const SizedBox(height: 48),
            ],
          ),
        ),
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(top: 8.0, bottom: 6),
      child: Text(title,
          style: const TextStyle(
              color: Colors.white70, fontSize: 14, fontWeight: FontWeight.bold)),
    );
  }

  Widget _menuTile(BuildContext context,
      {required String title, required IconData icon, String? route}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      decoration: BoxDecoration(
        color: const Color(0xFF151515),
        borderRadius: BorderRadius.circular(8),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 12),
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF2A2A2A),
          child: Icon(icon, color: Colors.redAccent),
        ),
        title: Text(title, style: const TextStyle(color: Colors.white)),
        trailing: const Icon(Icons.arrow_forward_ios, color: Colors.white70, size: 16),
        onTap: route != null ? () => Navigator.pushNamed(context, route) : null,
      ),
    );
  }

  static Widget _roundedButton({required String title, required IconData icon, required VoidCallback onTap}) {
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
              Text(title, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ],
          ),
        ),
      ),
    );
  }

  static Widget _buildBottomNav() {
    return BottomNavigationBar(
      backgroundColor: const Color(0xFF0B0B0B),
      selectedItemColor: Colors.redAccent,
      unselectedItemColor: Colors.grey,
      type: BottomNavigationBarType.fixed,
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), label: "Home"),
        BottomNavigationBarItem(icon: Icon(Icons.local_offer_outlined), label: "Offers"),
        BottomNavigationBarItem(icon: Icon(Icons.location_on_outlined), label: "Cinema"),
        BottomNavigationBarItem(icon: Icon(Icons.fastfood_outlined), label: "F&B"),
        BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: "More"),
      ],
    );
  }
}

class _LearnMoreButton extends StatelessWidget {
  const _LearnMoreButton({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 36,
      padding: const EdgeInsets.symmetric(horizontal: 14),
      decoration: BoxDecoration(
        color: const Color(0xFFCC0000),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: Text("Learn More", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}
