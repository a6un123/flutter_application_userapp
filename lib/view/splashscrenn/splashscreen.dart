import 'package:flutter/material.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_bloc.dart';
import 'package:flutter_application_userapp/logic/auth/bloc/authbloc_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:go_router/go_router.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late AnimationController _logoController;
  late AnimationController _textController;
  late AnimationController _pulseController;
  late Animation<double> _logoScale;
  late Animation<double> _logoFade;
  late Animation<double> _textFade;
  late Animation<Offset> _textSlide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _startSequence();
  }

  void _setupAnimations() {
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );
    _logoScale = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );
    _logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeIn));

    _textController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _textFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _textController, curve: Curves.easeIn));
    _textSlide = Tween<Offset>(begin: const Offset(0, 0.5), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: _textController, curve: Curves.easeOutCubic),
        );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  Future<void> _startSequence() async {
    await Future.delayed(const Duration(milliseconds: 300));
    if (mounted) _logoController.forward();
    await Future.delayed(const Duration(milliseconds: 700));
    if (mounted) _textController.forward();
    await Future.delayed(const Duration(milliseconds: 2000));
    if (mounted) _navigate();
  }

  void _navigate() {
    final authState = context.read<AuthBloc>().state;
    if (authState is Authenticated) {
      authState.role == 'admin' ? context.go('/admin') : context.go('/home');
    } else {
      context.go('/login');
    }
  }

  @override
  void dispose() {
    _logoController.dispose();
    _textController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is Authenticated || state is Unauthenticated) {
          Future.delayed(const Duration(milliseconds: 1500), () {
            if (mounted) _navigate();
          });
        }
      },
      child: Scaffold(
        backgroundColor: Colors.indigo[900],
        body: Stack(
          children: [
            // Background circles
            Positioned(
              top: -80,
              right: -60,
              child: Container(
                width: 280,
                height: 280,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo[700]!.withOpacity(0.4),
                ),
              ),
            ),
            Positioned(
              bottom: -100,
              left: -80,
              child: Container(
                width: 350,
                height: 350,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.indigo[700]!.withOpacity(0.3),
                ),
              ),
            ),

            // Main content
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Logo
                  FadeTransition(
                    opacity: _logoFade,
                    child: ScaleTransition(
                      scale: _logoScale,
                      child: Container(
                        width: 110,
                        height: 110,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(28),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.25),
                              blurRadius: 30,
                              offset: const Offset(0, 12),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.shopping_bag_rounded,
                          size: 60,
                          color: Colors.indigo,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Text
                  FadeTransition(
                    opacity: _textFade,
                    child: SlideTransition(
                      position: _textSlide,
                      child: Column(
                        children: [
                          const Text(
                            'FEDEX',
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              letterSpacing: 8,
                            ),
                          ),
                          const Text(
                            'E-COMMERCE',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white60,
                              letterSpacing: 6,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Container(
                            width: 40,
                            height: 2,
                            decoration: BoxDecoration(
                              color: Colors.white38,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(height: 8),
                          const Text(
                            'Shop smart. Shop easy.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.white54,
                              letterSpacing: 1,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 80),

                  // Pulsing dots
                  FadeTransition(
                    opacity: _textFade,
                    child: AnimatedBuilder(
                      animation: _pulseController,
                      builder: (context, _) {
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(3, (i) {
                            final delay = i * 0.3;
                            final value = (_pulseController.value - delay)
                                .clamp(0.0, 1.0);
                            final size = 6.0 + (value * 4);
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              width: size,
                              height: size,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: Colors.white.withOpacity(
                                  0.4 + value * 0.6,
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            // Version
            Positioned(
              bottom: 32,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _textFade,
                child: const Text(
                  'v1.0.0',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white24,
                    fontSize: 12,
                    letterSpacing: 2,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
