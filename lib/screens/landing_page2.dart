import 'package:flutter/material.dart';
import '../painters/location_painter.dart';
import 'dart:math' as math;

class LandingPage2 extends StatefulWidget {
  const LandingPage2({super.key});

  @override
  State<LandingPage2> createState() => _LandingPage2State();
}

class _LandingPage2State extends State<LandingPage2>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _waveController;
  late AnimationController _pulseController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _waveController = AnimationController(
      duration: const Duration(seconds: 5),
      vsync: this,
    )..repeat();

    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);

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

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ),
    );

    _slideController.forward();
  }

  @override
  void dispose() {
    _slideController.dispose();
    _waveController.dispose();
    _pulseController.dispose();
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
                Color.fromARGB(255, 9, 82, 109),
                Color.fromRGBO(78, 145, 174, 1),
                Color.fromARGB(255, 210, 173, 88),
              ],
            ),
          ),
        ),

        // Animated wave texture
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: LocationWavePainter(_waveController.value),
              size: Size.infinite,
            );
          },
        ),

        // Sand texture for bottom
        AnimatedBuilder(
          animation: _waveController,
          builder: (context, child) {
            return CustomPaint(
              painter: LocationSandPainter(_waveController.value),
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

                      // Title
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
                          'Enable Location',
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
                            'Enable location services to quickly share\n'
                            'your location during emergencies and\n'
                            'let loved ones know youre safe.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
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

                      // Image with pulsing animation
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          // Outer pulsing ring
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              return Container(
                                width: 200 * _pulseAnimation.value,
                                height: 200 * _pulseAnimation.value,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                      0.3 * (1 - _pulseController.value),
                                    ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Second pulsing ring (delayed)
                          AnimatedBuilder(
                            animation: _pulseController,
                            builder: (context, child) {
                              final delayedValue = (_pulseController.value + 0.5) % 1.0;
                              final scale = 1.0 + (delayedValue * 0.1);
                              return Container(
                                width: 200 * scale,
                                height: 200 * scale,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: Colors.white.withOpacity(
                                      0.2 * (1 - delayedValue),
                                    ),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          ),

                          // Main image
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
                              tag: 'location_image',
                              child: Image.asset(
                                'assets/location.png',
                                width: MediaQuery.of(context).size.width * 0.7,
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                        ],
                      ),

                      const Spacer(),

                      // Page indicator dots
                      Padding(
                        padding: const EdgeInsets.only(bottom: 30),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            _buildDot(false),
                            const SizedBox(width: 8),
                            _buildDot(true),
                            const SizedBox(width: 8),
                            _buildDot(false),
                          ],
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

  Widget _buildDot(bool isActive) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      width: isActive ? 24 : 8,
      height: 8,
      decoration: BoxDecoration(
        color: isActive ? Colors.white : Colors.white.withOpacity(0.4),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}

// Wave painter for location page
class LocationWavePainter extends CustomPainter {
  final double animation;

  LocationWavePainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = Colors.white.withOpacity(0.06);

    for (var i = 0; i < 6; i++) {
      final path = Path();
      final yOffset = size.height * 0.1 + (i * 50);
      final waveHeight = 15.0 - (i * 1.5);
      final frequency = 180.0 + (i * 25);

      path.moveTo(0, yOffset);

      for (double x = 0; x <= size.width; x++) {
        final y = yOffset +
            math.sin((x / frequency) * 2 * math.pi +
                    (animation * 2 * math.pi) +
                    (i * 0.7)) *
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
  bool shouldRepaint(LocationWavePainter oldDelegate) => true;
}

// Sand painter for bottom section
class LocationSandPainter extends CustomPainter {
  final double animation;

  LocationSandPainter(this.animation);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(255, 190, 150, 70).withOpacity(0.12);

    for (var i = 0; i < 3; i++) {
      final path = Path();
      final yOffset = size.height * 0.7 + (i * 40);
      final duneHeight = 30.0 - (i * 6);
      final frequency = 220.0 + (i * 35);

      path.moveTo(0, size.height);

      for (double x = 0; x <= size.width; x++) {
        final y = yOffset +
            math.sin((x / frequency) * math.pi + 
                    (animation * math.pi * 0.25) + 
                    (i * 0.5)) *
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
  bool shouldRepaint(LocationSandPainter oldDelegate) => true;
}