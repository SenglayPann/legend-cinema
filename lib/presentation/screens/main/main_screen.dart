import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:legend_cinema/presentation/screens/cinema/cinema_screen.dart';
import 'package:legend_cinema/presentation/screens/fnb/fnb_screen.dart';
import 'package:legend_cinema/presentation/screens/home/home_screen.dart';
import 'package:legend_cinema/presentation/screens/more/more_screen.dart';
import 'package:legend_cinema/presentation/screens/offer/offer_screen.dart';
import '../../widgets/bottom_nav.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const OfferScreen(),
    const CinemaScreen(),
    const FnBScreen(),
    const MoreScreen(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
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
          // TODO: Implement action for the ticket button
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
