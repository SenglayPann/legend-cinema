import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:legend_cinema/core/constants/app_routes.dart';
import 'package:legend_cinema/presentation/state/auth_state.dart';
import 'package:provider/provider.dart';

class HomeAppBar extends StatelessWidget {
  final ValueListenable<bool> isScrolledListenable;

  const HomeAppBar({super.key, required this.isScrolledListenable});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<bool>(
      valueListenable: isScrolledListenable,
      builder: (context, isScrolled, child) {
        return AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          color: Colors.black.withOpacity(isScrolled ? 1.0 : 0.0),
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: child,
        );
      },
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 0),
            child: SizedBox(
              height: 55,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Center(
                    child: Image.asset(
                      "lib/assets/images/legend_cinema_logo_crop.png",
                      height: 35,
                      fit: BoxFit.contain,
                    ),
                  ),
                  Positioned(
                    right: 0,
                    child: Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(context, AppRoutes.search);
                          },
                          child: const Icon(Icons.search, color: Colors.white),
                        ),
                        const SizedBox(width: 16),
                        GestureDetector(
                          onTap: () {
                            Navigator.pushNamed(
                              context,
                              AppRoutes.notificationList,
                            );
                          },
                          child: Stack(
                            children: [
                              const Padding(
                                padding: EdgeInsets.all(4.0),
                                child: Icon(
                                  Icons.notifications_none,
                                  color: Colors.white,
                                ),
                              ),
                              // Notification Badge
                              StreamBuilder<QuerySnapshot>(
                                stream: () {
                                  try {
                                    final userId = Provider.of<AuthState>(
                                      context,
                                      listen: false,
                                    ).currentUser?.id;
                                    if (userId == null) {
                                      return const Stream<
                                        QuerySnapshot
                                      >.empty();
                                    }
                                    return FirebaseFirestore.instance
                                        .collection('notifications')
                                        .where('userId', isEqualTo: userId)
                                        .where('isRead', isEqualTo: false)
                                        .snapshots();
                                  } catch (e) {
                                    return const Stream<QuerySnapshot>.empty();
                                  }
                                }(),
                                builder: (context, snapshot) {
                                  if (!snapshot.hasData ||
                                      snapshot.data!.docs.isEmpty) {
                                    return const SizedBox.shrink();
                                  }
                                  final count = snapshot.data!.docs.length;
                                  return Positioned(
                                    right: 0,
                                    top: 0,
                                    child: Container(
                                      padding: const EdgeInsets.all(4),
                                      decoration: const BoxDecoration(
                                        color: Colors.red,
                                        shape: BoxShape.circle,
                                      ),
                                      constraints: const BoxConstraints(
                                        minWidth: 16,
                                        minHeight: 16,
                                      ),
                                      child: Text(
                                        count > 9 ? '9+' : count.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
