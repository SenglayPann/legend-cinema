import 'dart:developer' as developer;
import 'package:flutter/material.dart';
import 'package:legend_cinema/presentation/screens/home/home_screen.dart';
import 'package:legend_cinema/data/services/auth_services.dart';
import 'package:legend_cinema/presentation/state/auth_state.dart';
import 'package:provider/provider.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _gradientController;
  late AnimationController _logoController;
  late Animation<double> _verticalSlideAnimation;
  late Animation<double> _slideAnimation;
  late Animation<double> _logoSlideAnimation;
  late Animation<double> _logoScaleAnimation;
  final AuthServices _authService = AuthServices();

  @override
  void initState() {
    super.initState();

    // Gradient animation controller
    _gradientController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 3800),
    );

    _verticalSlideAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 700, end: 0)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 70,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );
    _gradientController.addStatusListener((status) async {
      if (status == AnimationStatus.completed && mounted) {
        final auth = context.read<AuthState>();
        dynamic user;

        if (auth.currentUser?.id != null) {
          user = await _authService.getUserById(auth.currentUser?.id ?? '');
        }

        developer.log('-------->> $user', name: 'SplashScreen');
        print('-------->> $user');

        // Small delay (optional) to let animation breathe
        await Future.delayed(const Duration(milliseconds: 1000));

        // ensure the State is still mounted before using the BuildContext
        if (!mounted) return;

        if (user != null) {
          Navigator.of(context).pushNamedAndRemoveUntil('/example', (_) => false);
        } else {
          Navigator.of(context).pushNamedAndRemoveUntil('/signUp', (_) => false);
        }
      }
    });
    // });

    _slideAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 0, end: 150)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 150, end: 150)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 20,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 150, end: -150)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _gradientController,
        curve: const Interval(0.4, 1.0),
      ),
    );

    _gradientController.forward();

    // Logo animation controller
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );

    _logoSlideAnimation = Tween<double>(begin: 700, end: 0).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeOut),
      ),
    );

    _logoScaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.0, end: 1.2)
            .chain(CurveTween(curve: Curves.easeOut)),
        weight: 50,
      ),
      TweenSequenceItem(
        tween: Tween<double>(begin: 1.2, end: 1.0)
            .chain(CurveTween(curve: Curves.easeIn)),
        weight: 50,
      ),
    ]).animate(
      CurvedAnimation(
        parent: _logoController,
        curve: const Interval(0.7, 1.0, curve: Curves.easeInOut),
      ),
    );

    // Start logo animation
    Future.delayed(const Duration(milliseconds: 1000), () {
      _logoController.forward();
    });

    // Navigate to HomeScreen after splash duration (4s)
    Future.delayed(const Duration(milliseconds: 4000), () {
      if (mounted) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    });
  }

  @override
  void dispose() {
    _gradientController.dispose();
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final gradientHeight = screenHeight;
    final gradientWidth = screenWidth * 1.5;

    return Scaffold(
      backgroundColor: Colors.black,
      body: AnimatedBuilder(
        animation: Listenable.merge([_gradientController, _logoController]),
        builder: (context, child) {
          return Stack(
            children: [
              Positioned(
                bottom: 0,
                left: -(230 + _slideAnimation.value),
                child: Transform.translate(
                  offset: Offset(0, _verticalSlideAnimation.value),
                  child: Container(
                    width: gradientWidth,
                    height: gradientHeight,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Colors.blueAccent, Colors.transparent],
                        radius: 1,
                        center: Alignment.bottomLeft,
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                bottom: 0,
                right: (_slideAnimation.value - 230),
                child: Transform.translate(
                  offset: Offset(0, _verticalSlideAnimation.value),
                  child: Container(
                    width: gradientWidth,
                    height: gradientHeight,
                    decoration: const BoxDecoration(
                      gradient: RadialGradient(
                        colors: [Colors.redAccent, Colors.transparent],
                        radius: 1,
                        center: Alignment.bottomRight,
                      ),
                    ),
                  ),
                ),
              ),
              Center(
                child: Transform.translate(
                  offset: Offset(0, _logoSlideAnimation.value),
                  child: Transform.scale(
                    scale: _logoScaleAnimation.value,
                    child: Image.asset(
                      'lib/assets/images/legend_cinema_logo.png',
                      width: 250,
                      height: 500,
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
