import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:legend_cinema/presentation/screens/cinema/cinema_screen.dart';
import 'package:legend_cinema/presentation/screens/fnb/fnb_screen.dart';
import 'package:legend_cinema/presentation/screens/home/home_screen.dart';
import 'package:legend_cinema/presentation/screens/more/more_screen.dart';
import 'package:legend_cinema/presentation/screens/offer/offer_screen.dart';
import '../purchase/purchase_screen.dart';
import '../../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  @override
  State<MainScreen> createState() => MainScreenState();
}

class MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  List<Widget> get _screens => [
    const HomeScreen(),
    const OfferScreen(),
    const CinemaScreen(),
    const FnBScreen(),
    MoreScreen(), // Remove const to ensure rebuild
  ];

  void switchTab(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  void _onItemTapped(int index) {
    switchTab(index);
  }

  @override
  Widget build(BuildContext context) {
    // This line forces a rebuild when locale changes
    context.locale;

    return Scaffold(
      backgroundColor: const Color(0xFF090909),
      extendBody: true, // Important for glass effect
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNav(
        selectedIndex: _currentIndex,
        onTap: _onItemTapped,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const PurchaseScreen()),
          );
        },
        backgroundColor: Colors.red,
        shape: const CircleBorder(),
        child: Transform.rotate(
          angle: -45 * (3.1415926535 / 180), // 45 degrees to radians
          child: const Icon(CupertinoIcons.ticket_fill, color: Colors.white),
        ),
      ),
    );
  }
}
