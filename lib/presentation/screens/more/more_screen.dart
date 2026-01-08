import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/services/auth_services.dart';
import '../../state/auth_state.dart';
import '../../widgets/app_scaffold.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/custom_alert.dart';
import '../../../core/constants/app_routes.dart';
import 'package:easy_localization/easy_localization.dart';

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
      title: "account".tr(),
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
                        text: "login".tr(),
                        onPressed: () => Navigator.pushNamed(context, '/login'),
                        height: 48,
                        borderRadius: 30,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: CustomButton(
                        text: "signup".tr(),
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
                  "${'hello'.tr()}, ${user.firstName}".trim(),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Membership Card Removed
            const SizedBox(height: 20),

            // Tickets Section
            _sectionTitle("tickets".tr()),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "purchase".tr(),
                  icon: Icons.confirmation_number,
                  route: AppRoutes.purchase,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Languages Section
            _sectionTitle("languages".tr()),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "languages".tr(),
                  icon: Icons.language,
                  route: AppRoutes.languageSettings,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Notifications Section
            _sectionTitle("notifications".tr()),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "notifications".tr(),
                  icon: Icons.notifications,
                  route: AppRoutes.notificationSettings,
                ),
              ],
            ),
            const SizedBox(height: 20),

            // About us Section
            _sectionTitle("about_us".tr()),
            _MenuSection(
              children: [
                _menuTile(
                  context,
                  title: "about_us".tr(),
                  icon: Icons.info,
                  route: AppRoutes.aboutUs,
                ),
                _menuTile(
                  context,
                  title: "contact_us".tr(),
                  icon: Icons.call,
                  route: null,
                ),
                _menuTile(
                  context,
                  title: "privacy_policy".tr(),
                  icon: Icons.privacy_tip,
                  route: AppRoutes.privacyPolicy,
                ),
                _menuTile(
                  context,
                  title: "term_conditions".tr(),
                  icon: Icons.article,
                  route: AppRoutes.termsConditions,
                ),
                if (isLoggedIn)
                  _menuTile(
                    context,
                    title: "logout".tr(),
                    icon: Icons.logout,
                    onTap: () async {
                      if (!context.mounted) return;

                      final shouldLogout = await CustomAlert.showConfirm(
                        context,
                        title: 'logout_confirm_title'.tr(),
                        message: 'logout_confirm_message'.tr(),
                        confirmText: 'logout'.tr(),
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
