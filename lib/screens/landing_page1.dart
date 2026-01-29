import 'package:flutter/material.dart';
import 'dart:math' as math;

class LandingPage1 extends StatefulWidget {
  const LandingPage1({super.key});

  @override
  State<LandingPage1> createState() => _LandingPage1State();
}

class _LandingPage1State extends State<LandingPage1>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _waveController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    )..repeat();

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _slideController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeIn),
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Background gradient
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color.fromARGB(255, 59, 121, 146),
                Color.fromARGB(255, 210, 173, 88),
                Color.fromARGB(255, 137, 105, 22),
              ],
            ),
          ),
        ),

        // Animated wave texture (blue section)
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: WaveTexturePainter(_waveController.value),
              size: Size.infinite,
            );
          },
        ),

        // Sand dune texture (brown section)
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: SandDunePainter(_waveController.value),
              size: Size.infinite,
            );
          },
        ),

        // Content
        Scaffold(
          backgroundColor: Colors.transparent,
          body: SafeArea(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: SlideTransition(
                position: _slideAnimation,
                child: Center(
                  child: Column(
                    children: [
                      const SizedBox(height: 100),

                      // Title with animated entrance
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 800),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 20 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: const Text(
                          'Welcome to HydraSense!',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                            shadows: [
                              Shadow(
                                blurRadius: 15.0,
                                color: Colors.black38,
                                offset: Offset(0, 3),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Description
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1000),
                        tween: Tween(begin: 0.0, end: 1.0),
                        builder: (context, value, child) {
                          return Opacity(
                            opacity: value,
                            child: Transform.translate(
                              offset: Offset(0, 30 * (1 - value)),
                              child: child,
                            ),
                          );
                        },
                        child: const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 32),
                          child: Text(
                            'HydraSense is a people-powered initiative\n'
                            'using real-time data to build a\n'
                            'global flood awareness network.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              height: 1.6,
                              shadows: [
                                Shadow(
                                  blurRadius: 8.0,
                                  color: Colors.black26,
                                  offset: Offset(0, 2),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      const SizedBox(height: 80),

                      // Image with scale animation
                      TweenAnimationBuilder<double>(
                        duration: const Duration(milliseconds: 1200),
                        tween: Tween(begin: 0.8, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, value, child) {
                          return Transform.scale(
                            scale: value,
                            child: child,
                          );
                        },
                        child: Hero(
                          tag: 'welcome_image',
                          child: Image.asset(
                            'assets/welcome_hydrasense.png',
                            width: MediaQuery.of(context).size.width * 0.85,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Swipe indicator
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: AnimatedBuilder(
                          animation: _waveController,
                          builder: (context, child) {
                            return Opacity(
                              opacity: 0.6 + (0.4 * math.sin(_waveController.value * 2 * math.pi)),
                              child: child,
                            );
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.arrow_forward_ios,
                                color: Colors.white.withValues(alpha:0.7),
                                size: 16,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'Swipe to continue',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 14,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// Wave texture painter for blue section
class WaveTexturePainter extends CustomPainter {
  final double animation;

  WaveTexturePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withValues(alpha:0.08);

    // Multiple wave layers for depth
    for (var i = 0; i < 5; i++) {
      final path = Path();
      final yOffset = size.height * 0.05 + (i * 60);
      final waveHeight = 18.0 - (i * 2);
      final frequency = 150.0 + (i * 30);

      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x++) {
        final y = yOffset +
            math.sin((x / frequency) * 2 * math.pi +
                    (animation * 2 * math.pi) +
                    (i * 0.6)) *
                waveHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, 0);
      path.lineTo(0, 0);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(WaveTexturePainter oldDelegate) => true;
}

// Sand dune painter for brown section
class SandDunePainter extends CustomPainter {
  final double animation;

  SandDunePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(255, 180, 140, 60).withValues(alpha:0.15);

    // Create dune-like shapes in the bottom section
    for (var i = 0; i < 4; i++) {
      final path = Path();
      final yOffset = size.height * 0.65 + (i * 50);
      final duneHeight = 35.0 - (i * 5);
      final frequency = 200.0 + (i * 40);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x++) {
        final y = yOffset +
            math.sin((x / frequency) * math.pi + (animation * math.pi * 0.3) + (i * 0.4)) *
                duneHeight;
        path.lineTo(x, y);
      }

      path.lineTo(size.width, size.height);
      path.lineTo(0, size.height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(SandDunePainter oldDelegate) => true;
}