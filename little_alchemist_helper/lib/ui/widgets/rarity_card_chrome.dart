import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../models/combo_tier.dart';

BoxDecoration _tierPanelDecoration(List<Color> frame) {
  return BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: frame,
    ),
    boxShadow: <BoxShadow>[
      BoxShadow(
        color: frame.last.withValues(alpha: 0.45),
        blurRadius: 6,
        offset: const Offset(0, 2),
      ),
    ],
  );
}

/// Tier-based panel background (bronze...onyx) and subtle glow for fused cards, matching the original style.
class RarityTierPanel extends StatelessWidget {
  const RarityTierPanel({
    super.key,
    required this.tier,
    required this.fusionAnimated,
    required this.borderRadius,
    required this.child,
    this.padding = EdgeInsets.zero,
    this.selectionOverlay,
  });

  final ComboTier tier;
  final bool fusionAnimated;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;

  /// Semi-transparent layer over the gradient (for example, selected-row highlight).
  final Widget? selectionOverlay;

  @override
  Widget build(BuildContext context) {
    final List<Color> frame = _tierGradient(tier);
    if (!fusionAnimated) {
      return ClipRRect(
        borderRadius: borderRadius,
        child: Stack(
          fit: StackFit.passthrough,
          children: <Widget>[
            DecoratedBox(
              decoration: _tierPanelDecoration(frame),
              child: Padding(padding: padding, child: child),
            ),
            if (selectionOverlay != null)
              Positioned.fill(child: IgnorePointer(child: selectionOverlay!)),
          ],
        ),
      );
    }
    return _FusionTierPanel(
      gradientColors: frame,
      borderRadius: borderRadius,
      padding: padding,
      selectionOverlay: selectionOverlay,
      child: child,
    );
  }

  static List<Color> _tierGradient(ComboTier tier) {
    switch (tier) {
      case ComboTier.bronze:
        return <Color>[const Color(0xFF5D4037), const Color(0xFFA1887F)];
      case ComboTier.silver:
        return <Color>[const Color(0xFF546E7A), const Color(0xFFCFD8DC)];
      case ComboTier.gold:
        return <Color>[const Color(0xFFF57F17), const Color(0xFFFFE082)];
      case ComboTier.diamond:
        return <Color>[const Color(0xFF01579B), const Color(0xFF4FC3F7)];
      case ComboTier.onyx:
        return <Color>[const Color(0xFF311B92), const Color(0xFF7E57C2)];
    }
  }
}

/// Fused style: gradient -> magic circle (behind content) -> card row -> overlay -> stripe.
class _FusionTierPanel extends StatefulWidget {
  const _FusionTierPanel({
    required this.gradientColors,
    required this.borderRadius,
    required this.padding,
    required this.child,
    this.selectionOverlay,
  });

  final List<Color> gradientColors;
  final BorderRadius borderRadius;
  final EdgeInsetsGeometry padding;
  final Widget child;
  final Widget? selectionOverlay;

  @override
  State<_FusionTierPanel> createState() => _FusionTierPanelState();
}

class _FusionTierPanelState extends State<_FusionTierPanel>
    with TickerProviderStateMixin {
  late final AnimationController _rotateController;
  late final AnimationController _pulseController;

  @override
  void initState() {
    super.initState();
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 18),
    )..repeat();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 850),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _rotateController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: widget.borderRadius,
      clipBehavior: Clip.hardEdge,
      child: LayoutBuilder(
        builder: (BuildContext context, BoxConstraints constraints) {
          final double maxW =
              constraints.maxWidth.isFinite && constraints.maxWidth > 8
              ? constraints.maxWidth
              : 200.0;
          // Base reduced circle multiplied by -30%, then +20% against current size.
          final double ringSize = maxW * 1.38 * 0.6 * 0.7 * 1.2;
          return Stack(
            clipBehavior: Clip.hardEdge,
            fit: StackFit.passthrough,
            children: <Widget>[
              Positioned.fill(
                child: DecoratedBox(
                  decoration: _tierPanelDecoration(widget.gradientColors),
                ),
              ),
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.all(6),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: <Color>[
                          const Color(0xFF160A2A).withValues(alpha: 0.78),
                          const Color(0xFF2A0D4A).withValues(alpha: 0.72),
                          const Color(0xFF12071F).withValues(alpha: 0.84),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: -ringSize * 0.26,
                left: 0,
                right: 0,
                child: IgnorePointer(
                  child: Center(
                    child: RepaintBoundary(
                      child: SizedBox(
                        width: ringSize,
                        height: ringSize,
                        child: AnimatedBuilder(
                          animation: _rotateController,
                          builder: (BuildContext context, Widget? child) {
                            return CustomPaint(
                              painter: _FusionRuneRingPainter(
                                rotationRadians:
                                    _rotateController.value * 2 * math.pi,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Padding(padding: widget.padding, child: widget.child),
              if (widget.selectionOverlay != null)
                Positioned.fill(
                  child: IgnorePointer(child: widget.selectionOverlay!),
                ),
              Positioned(
                left: 10,
                right: 10,
                bottom: 5,
                child: IgnorePointer(
                  child: AnimatedBuilder(
                    animation: _pulseController,
                    builder: (BuildContext context, Widget? child) {
                      final double o = 0.22 + 0.62 * _pulseController.value;
                      return Opacity(
                        opacity: o,
                        child: Container(
                          height: 3,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(2),
                            gradient: LinearGradient(
                              colors: <Color>[
                                const Color.fromARGB(255, 192, 18, 223).withValues(alpha: 0.15),
                                const Color(0xFFE040FB).withValues(alpha: 0.9),
                                const Color.fromARGB(255, 111, 6, 130).withValues(alpha: 0.15),
                              ],
                            ),
                            boxShadow: <BoxShadow>[
                              BoxShadow(
                                color: const Color(
                                  0xFFE040FB,
                                ).withValues(alpha: 0.35 * o),
                                blurRadius: 5,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
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

/// Rotating ring with runes, center symbols, and a soft outline.
class _FusionRuneRingPainter extends CustomPainter {
  const _FusionRuneRingPainter({required this.rotationRadians});

  final double rotationRadians;

  static const List<String> _segments = <String>[
    'ᚠ',
    'ᚢ',
    'ᚦ',
    'ᚨ',
    'ᚱ',
    '✦',
    '◇',
    '⬡',
    '✧',
    'ᛉ',
    'ᛊ',
    '⁂',
    '⍟',
    '※',
    '✶',
    '◈',
  ];

  static void _paintCenterDecor(Canvas canvas, double r) {
    final Paint thin = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.75
      ..color = const Color.fromARGB(255, 53, 11, 120).withValues(alpha: 0.62);
    canvas.drawCircle(Offset.zero, r * 0.34, thin);

    final Paint thin2 = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.4
      ..color = const Color(0xFFE1BEE7).withValues(alpha: 0.72);
    canvas.drawCircle(Offset.zero, r * 0.22, thin2);

    final double triR = r * 0.26;
    Path triangle(double rotation) {
      final Path p = Path();
      for (int i = 0; i < 3; i++) {
        final double a = rotation + i * 2 * math.pi / 3 - math.pi / 2;
        final Offset o = Offset(math.cos(a) * triR, math.sin(a) * triR);
        if (i == 0) {
          p.moveTo(o.dx, o.dy);
        } else {
          p.lineTo(o.dx, o.dy);
        }
      }
      p.close();
      return p;
    }

    final Paint triPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.05
      ..color = const Color(0xFFB39DDB).withValues(alpha: 0.82);
    canvas.drawPath(triangle(0), triPaint);
    canvas.drawPath(triangle(math.pi), triPaint);

    final Paint dotPaint = Paint()
      ..style = PaintingStyle.fill
      ..color = const Color.fromARGB(255, 118, 37, 92).withValues(alpha: 0.85);
    const int kDots = 8;
    for (int i = 0; i < kDots; i++) {
      final double a = i * math.pi / 4;
      canvas.drawCircle(
        Offset(math.cos(a) * r * 0.30, math.sin(a) * r * 0.30),
        3.6,
        dotPaint,
      );
    }

    final double tickLen = r * 0.075;
    final Paint tickPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.25
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFFE040FB).withValues(alpha: 0.78);
    for (int i = 0; i < 4; i++) {
      final double a = i * math.pi / 2;
      final Offset out = Offset(math.cos(a), math.sin(a));
      canvas.drawLine(out * (r * 0.36), out * (r * 0.36 + tickLen), tickPaint);
    }

    final double core = (r * 0.175).clamp(15.0, 28.0);
    final TextPainter coreTp = TextPainter(
      text: TextSpan(
        text: '⍟',
        style: TextStyle(
          color: const Color(0xFFFFFFFF).withValues(alpha: 0.95),
          fontSize: core,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    coreTp.paint(canvas, Offset(-coreTp.width / 2, -coreTp.height / 2));

    final double mini = core * 0.62;
    final TextPainter orbitTp = TextPainter(
      text: TextSpan(
        text: '✧',
        style: TextStyle(
          color: const Color.fromARGB(255, 131, 51, 147).withValues(alpha: 0.88),
          fontSize: mini,
          fontWeight: FontWeight.w900,
          height: 1,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    for (int i = 0; i < 3; i++) {
      final double a = i * 2 * math.pi / 3 + math.pi / 6;
      canvas.save();
      canvas.translate(math.cos(a) * r * 0.14, math.sin(a) * r * 0.14);
      orbitTp.paint(canvas, Offset(-orbitTp.width / 2, -orbitTp.height / 2));
      canvas.restore();
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double r = size.shortestSide * 0.49;
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(rotationRadians);

    final Paint outerHaze = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4.2
      ..color = const Color(0xFF7E57C2).withValues(alpha: 0.28);
    canvas.drawCircle(Offset.zero, r * 1.02, outerHaze);

    final Paint arcPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.45
      ..shader = SweepGradient(
        startAngle: 0,
        endAngle: math.pi * 2,
        colors: const <Color>[
          Color.fromARGB(255, 57, 30, 138),
          Color.fromARGB(255, 70, 11, 81),
          Color.fromARGB(255, 154, 13, 140),
          Color.fromARGB(255, 102, 31, 218),
        ],
        transform: GradientRotation(rotationRadians * 0.25),
      ).createShader(Rect.fromCircle(center: Offset.zero, radius: r));
    canvas.drawCircle(Offset.zero, r * 0.9, arcPaint);

    final Paint innerRing = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.45
      ..color = const Color.fromARGB(255, 46, 32, 72).withValues(alpha: 0.52);
    canvas.drawCircle(Offset.zero, r * 0.72, innerRing);

    final double fontSize = (r * 0.135).clamp(11.0, 18.0);
    final TextStyle style = TextStyle(
      color: const Color.fromARGB(255, 167, 130, 174).withValues(alpha: 0.95),
      fontSize: fontSize,
      fontWeight: FontWeight.w800,
      height: 1,
    );

    final int n = _segments.length;
    for (int i = 0; i < n; i++) {
      final double a = i * 2 * math.pi / n;
      final TextPainter tp = TextPainter(
        text: TextSpan(text: _segments[i], style: style),
        textDirection: TextDirection.ltr,
      )..layout();
      canvas.save();
      canvas.rotate(a);
      canvas.translate(0, -r * 0.82);
      canvas.rotate(-rotationRadians - a);
      tp.paint(canvas, Offset(-tp.width / 2, -tp.height / 2));
      canvas.restore();
    }

    _paintCenterDecor(canvas, r);

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _FusionRuneRingPainter oldDelegate) {
    return oldDelegate.rotationRadians != rotationRadians;
  }
}
