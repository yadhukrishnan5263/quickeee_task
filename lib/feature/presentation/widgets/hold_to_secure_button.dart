import 'dart:math' as math;
import 'dart:ui';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

enum ButtonState { idle, holding, loading, success }


class HoldButton extends StatefulWidget {
  const HoldButton({super.key});

  @override
  State<HoldButton> createState() => _HoldButtonState();
}

class _HoldButtonState extends State<HoldButton> with TickerProviderStateMixin {
  late AnimationController _holdController;
  late AnimationController _fluidController;
  late AnimationController _loadingController;
  late AnimationController _successController;

  bool _isComplete = false;
  bool _isHolding = false;
  ButtonState _currentState = ButtonState.idle;

  @override
  void initState() {
    super.initState();

    _holdController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );

    _fluidController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();


    _loadingController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _holdController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _currentState = ButtonState.loading;
        });
        _loadingController.forward().then((_) {
          setState(() {
            _currentState = ButtonState.success;
          });
          _successController.forward();
        });
        HapticFeedback.heavyImpact();
      }
    });
  }

  @override
  void dispose() {
    _holdController.dispose();
    _fluidController.dispose();
    _loadingController.dispose();
    _successController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        if (_currentState == ButtonState.success) {
          setState(() {
            _currentState = ButtonState.idle;
            _isComplete = false;
            _isHolding = false;
          });
          _holdController.reset();
          _loadingController.reset();
          _successController.reset();
          HapticFeedback.selectionClick();
          return;
        }
        if (_currentState != ButtonState.idle) return;
        setState(() => _isHolding = true);
        _holdController.forward();
        HapticFeedback.selectionClick();
      },
      onTapUp: (_) {
        if (_currentState != ButtonState.idle) return;
        setState(() => _isHolding = false);
        _holdController.reverse();
      },
      onTapCancel: () {
        if (_currentState != ButtonState.idle) return;
        setState(() => _isHolding = false);
        _holdController.reverse();
      },
      child: AnimatedScale(
        scale: _isHolding && _currentState == ButtonState.idle ? 1.04 : 1.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutCubic,
        child: Stack(
          alignment: Alignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              width: 280,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(40),
                color: Colors.white.withOpacity(0.1), // White Glass Base
                border: Border.all(
                  color: Colors.white.withOpacity(_currentState == ButtonState.success ? 0 : 0.2),
                  width: 1,
                ),
                boxShadow: [
                  BoxShadow(
                    color:  Colors.black.withOpacity(0.3),
                    blurRadius: 30,
                    spreadRadius:  -5,
                  )
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(40),
                child: BackdropFilter(
                  filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _fluidController,
                          builder: (context, child) {
                            return CustomPaint(
                              painter: NebulaPainter(animationValue: _fluidController.value),
                            );
                          },
                        ),
                      ),

                      if (_currentState == ButtonState.loading)
                        Center(
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                        ),

                      if (_currentState == ButtonState.success)
                        Center(
                          child: AnimatedBuilder(
                            animation: _successController,
                            builder: (context, child) {
                              return Transform.scale(
                                scale: _successController.value,
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 32,
                                ),
                              );
                            },
                          ),
                        ),

                      if (_currentState == ButtonState.idle || _currentState == ButtonState.holding)
                        Center(
                          child: AnimatedDefaultTextStyle(
                            duration: const Duration(milliseconds: 300),
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1.2,
                              shadows: [
                                const Shadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 2))
                              ],
                            ),
                            child: Text(_currentState == ButtonState.holding ? "Hold..." : "Hold to Secure"),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),

            if (_currentState == ButtonState.idle || _currentState == ButtonState.holding)
              IgnorePointer(
                child: CustomPaint(
                  size: const Size(280, 80),
                  painter: BorderProgressPainter(
                    progress: _holdController,
                    color: Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class NebulaPainter extends CustomPainter {
  final double animationValue;
  NebulaPainter({required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = Offset.zero & size;

    void drawOrb(Color color, double radiusMult, double speedMult, double phase) {
      final double angle = (animationValue * 2 * math.pi * speedMult) + phase;
      final Offset center = Offset(
        size.width / 2 + math.cos(angle) * (size.width / 4),
        size.height / 2 + math.sin(angle) * (size.height / 3),
      );

      final Paint paint = Paint()
        ..shader = RadialGradient(
          colors: [color.withOpacity(0.6), color.withOpacity(0)],
        ).createShader(Rect.fromCircle(center: center, radius: size.width * radiusMult));

      canvas.drawRect(rect, paint);
    }

    drawOrb(const Color(0xFF64FF00), 0.9, 1.0, 0);
    drawOrb(const Color(0xFF64FF00), 0.7, -0.8, math.pi / 2);
    drawOrb(Colors.white, 0.6, 1.2, math.pi);

    final Paint shimmer = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          Colors.white.withOpacity(0.2),
          Colors.transparent,
          Colors.white.withOpacity(0.1),
        ],
      ).createShader(rect);
    canvas.drawRect(rect, shimmer);
  }

  @override
  bool shouldRepaint(NebulaPainter oldDelegate) => true;
}

class BorderProgressPainter extends CustomPainter {
  final Animation<double> progress;
  final Color color;

  BorderProgressPainter({required this.progress, required this.color}) : super(repaint: progress);

  @override
  void paint(Canvas canvas, Size size) {
    if (progress.value == 0) return;

    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final path = Path();
    final rrect = RRect.fromLTRBR(0, 0, size.width, size.height, Radius.circular(size.height / 2));
    path.addRRect(rrect);

    final metrics = path.computeMetrics().first;
    final extractPath = metrics.extractPath(0, metrics.length * progress.value);

    canvas.drawPath(extractPath, paint..maskFilter = const MaskFilter.blur(BlurStyle.solid, 0));
    canvas.drawPath(extractPath, paint..maskFilter = null);
  }

  @override
  bool shouldRepaint(BorderProgressPainter oldDelegate) => true;
}