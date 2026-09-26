import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-fidelity Main Fertilizer Source painter:
/// An industrial bulk fertilizer stock station featuring a heavy-duty chemical
/// spill containment bund (yellow/black hazard rim), a translucent polymer
/// IBC tote container enclosed inside a galvanized tubular steel cage frame,
/// rich vibrant NPK emerald chemical stock solution with animated agitation
/// ripples and bubbles, a top fill neck with screw cap, side volume calibration
/// graduations, an inlet refill pipe, a discharge ball valve with flange
/// joints, and an active chemical glow when active.
///
/// [isOn]       – true while fertilizer dosing/pumping is active: agitation bubbles
///                rise, fluid surface ripples, and the vessel glows softly.
/// [phase]      – 0..1 looping animation driver (bubbles, ripples, flow).
/// [showJoints] – whether flange bolts and mechanical joints are drawn.
class DetailedMainFertilizerSourcePainter extends CustomPainter {
  final bool isOn;
  final double phase;
  final bool showJoints;

  DetailedMainFertilizerSourcePainter({
    required this.isOn,
    this.phase = 0,
    this.showJoints = true,
  });

  // ---------------------------------------------------------------- palette
  static const Color _trayDark = Color(0xFF1E262B);
  static const Color _trayMid = Color(0xFF37474F);
  static const Color _trayLight = Color(0xFF546E7A);
  static const Color _trayHazardYellow = Color(0xFFFFC107);

  static const Color _steelLight = Color(0xFFCFD8DC);
  static const Color _steelMid = Color(0xFF78909C);
  static const Color _steelDark = Color(0xFF37474F);

  static const Color _toteWallLight = Color(0xFDF5F7FA);
  static const Color _toteWallMid = Color(0xE0E0E6ED);
  static const Color _toteWallDark = Color(0xC0B0BEC5);

  // NPK Emerald / Nitrogen Chemical solution
  static const Color _chemTop = Color(0xEE2E7D32);   // Deep Emerald Green
  static const Color _chemMid = Color(0xF01B5E20);   // Dark NPK Green
  static const Color _chemDeep = Color(0xF50B3D0E);  // Forest Chemical Base
  static const Color _chemGlow = Color(0xFF4CAF50);  // Active Green Glow
  static const Color _chemAmber = Color(0xFFFFC107); // Amber Nitrogen highlight

  static const Color _valveBody = Color(0xFFD32F2F); // Safety Red Valve
  static const Color _pipeLight = Color(0xFF4FC3F7);
  static const Color _pipeMid = Color(0xFF0288D1);
  static const Color _pipeDark = Color(0xFF014B7A);

  static const Color _edge = Color(0xFF1C2833);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _drawContainmentTray(canvas, w, h);
    _drawBackCage(canvas, w, h);
    _drawToteAndLiquid(canvas, w, h);
    if (isOn) _drawActiveGlow(canvas, w, h);
    _drawFrontCage(canvas, w, h);
    _drawVolumeScaleAndLabels(canvas, w, h);
    _drawRefillCap(canvas, w, h);
    _drawInletPipe(canvas, w, h);
    _drawDischargeValve(canvas, w, h);
  }

  // -------------------------------------------------------------- helpers

  Paint _fillV(Rect r, List<Color> colors, {List<double>? stops}) {
    return Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: colors,
        stops: stops,
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(r);
  }

  Paint _fillH(Rect r, List<Color> colors, {List<double>? stops}) {
    return Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(
        colors: colors,
        stops: stops,
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(r);
  }

  math.Random _seed(int n) => math.Random(n);

  // --------------------------------------------------- containment bund/tray

  void _drawContainmentTray(Canvas canvas, double w, double h) {
    final Rect trayRect = Rect.fromLTWH(w * 0.10, h * 0.81, w * 0.80, h * 0.15);
    final RRect rtray = RRect.fromRectAndRadius(trayRect, const Radius.circular(6));

    // Base Shadow
    canvas.drawRRect(
      rtray.shift(const Offset(0, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.25),
    );

    // Heavy polymer tray fill
    canvas.drawRRect(rtray, _fillV(trayRect, const [_trayLight, _trayMid, _trayDark]));
    canvas.drawRRect(
      rtray,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _edge,
    );

    // Tray structural strengthening ribs
    final Paint ribPaint = Paint()
      ..color = Colors.black.withValues(alpha: 0.3)
      ..strokeWidth = 1.5;
    for (double x = trayRect.left + 16; x < trayRect.right; x += 20) {
      canvas.drawLine(
        Offset(x, trayRect.top + 12),
        Offset(x, trayRect.bottom - 4),
        ribPaint,
      );
    }

    // Yellow/black hazard stripe along top rim of tray
    final Rect rim = Rect.fromLTWH(w * 0.10, h * 0.81, w * 0.80, h * 0.038);
    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(rim, const Radius.circular(4)));
    canvas.drawRect(rim, Paint()..color = _trayHazardYellow);

    final Paint stripePaint = Paint()
      ..color = const Color(0xFF212121)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    for (double x = rim.left - 12; x < rim.right + 12; x += 10) {
      canvas.drawLine(
        Offset(x, rim.bottom),
        Offset(x + 8, rim.top),
        stripePaint,
      );
    }
    canvas.restore();

    // Rim border line
    canvas.drawRRect(
      RRect.fromRectAndRadius(rim, const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0
        ..color = _edge.withValues(alpha: 0.6),
    );
  }

  // ---------------------------------------------------------- steel cage (back)

  void _drawBackCage(Canvas canvas, double w, double h) {
    final Rect cageRect = Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.64);
    final Paint gridPaint = Paint()
      ..color = _steelDark.withValues(alpha: 0.5)
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    // Horizontal bars behind vessel
    for (double y = cageRect.top + 12; y < cageRect.bottom; y += 14) {
      canvas.drawLine(Offset(cageRect.left, y), Offset(cageRect.right, y), gridPaint);
    }
    // Vertical bars behind vessel
    for (double x = cageRect.left + 14; x < cageRect.right; x += 14) {
      canvas.drawLine(Offset(x, cageRect.top), Offset(x, cageRect.bottom), gridPaint);
    }
  }

  // -------------------------------------------------- tote vessel & solution

  void _drawToteAndLiquid(Canvas canvas, double w, double h) {
    final Rect toteRect = Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.60, h * 0.61);
    final RRect rTote = RRect.fromRectAndRadius(toteRect, const Radius.circular(10));

    // Outer translucent tote polymer background
    canvas.drawRRect(
      rTote,
      _fillH(toteRect, const [
        _toteWallLight,
        _toteWallMid,
        _toteWallLight,
        _toteWallDark,
      ], stops: const [
        0.0,
        0.3,
        0.7,
        1.0
      ]),
    );

    // Chemical Liquid Interior / Liquid level (~72% full)
    final double liquidTopY = toteRect.top + toteRect.height * 0.28;
    final Rect liquidRect = Rect.fromLTRB(
      toteRect.left + 3,
      liquidTopY,
      toteRect.right - 3,
      toteRect.bottom - 3,
    );

    canvas.save();
    canvas.clipRRect(RRect.fromRectAndRadius(toteRect, const Radius.circular(9)));

    // Base Liquid Gradient
    canvas.drawRect(
      liquidRect,
      _fillV(liquidRect, const [_chemTop, _chemMid, _chemDeep]),
    );

    // Subtle & calm liquid surface wave animation
    final Path wavePath = Path();
    wavePath.moveTo(liquidRect.left, liquidRect.top);
    final double waveFreq = 2.0 * math.pi;
    for (double x = liquidRect.left; x <= liquidRect.right; x += 2) {
      final double normalizedX = (x - liquidRect.left) / liquidRect.width;
      final double waveOffset = math.sin(normalizedX * waveFreq + phase * 2 * math.pi) * (isOn ? 1.0 : 0.4);
      wavePath.lineTo(x, liquidRect.top + waveOffset);
    }
    wavePath.lineTo(liquidRect.right, liquidRect.bottom);
    wavePath.lineTo(liquidRect.left, liquidRect.bottom);
    wavePath.close();

    canvas.drawPath(
      wavePath,
      _fillV(liquidRect, const [_chemTop, _chemMid, _chemDeep]),
    );

    // Liquid surface meniscus & foam highlight
    final Paint surfaceLine = Paint()
      ..color = _chemAmber.withValues(alpha: 0.6)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
    canvas.drawPath(wavePath, surfaceLine);

    final Paint surfaceGlow = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..strokeWidth = 0.8
      ..style = PaintingStyle.stroke;
    canvas.drawPath(wavePath, surfaceGlow);

    // Ambient liquid vertical depth reflection/shimmer
    final Rect shimmerRect = Rect.fromLTWH(
      toteRect.left + toteRect.width * 0.15,
      liquidTopY,
      toteRect.width * 0.20,
      toteRect.height * 0.70,
    );
    canvas.drawRect(
      shimmerRect,
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.10),
            Colors.white.withValues(alpha: 0.0),
          ],
          begin: Alignment.centerLeft,
          end: Alignment.centerRight,
        ).createShader(shimmerRect),
    );

    // Gentle micro-bubbles rising when active
    final math.Random rnd = _seed(17);
    final int bubbleCount = isOn ? 8 : 2;
    final Paint bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.5);

    for (int i = 0; i < bubbleCount; i++) {
      final double bx = liquidRect.left + 12 + rnd.nextDouble() * (liquidRect.width - 24);
      final double speed = 0.3 + rnd.nextDouble() * 0.4;
      final double progress = (phase * speed + rnd.nextDouble()) % 1.0;
      final double by = liquidRect.bottom - progress * liquidRect.height * 0.90;

      if (by > liquidTopY && by < liquidRect.bottom) {
        final double r = 0.8 + rnd.nextDouble() * 1.2;
        final Offset bPos = Offset(bx, by);
        canvas.drawCircle(bPos, r, bubblePaint);
      }
    }

    canvas.restore();

    // Blow-molded container plastic glossy specular reflection bar along right edge
    final Rect plasticGloss = Rect.fromLTWH(
      toteRect.right - 12,
      toteRect.top + 8,
      6,
      toteRect.height - 16,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plasticGloss, const Radius.circular(3)),
      Paint()
        ..shader = LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.35),
            Colors.white.withValues(alpha: 0.05),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(plasticGloss),
    );

    // Tote outline and subtle inner shadow
    canvas.drawRRect(
      rTote,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = _edge.withValues(alpha: 0.75),
    );
  }

  // ----------------------------------------------------------- front steel cage

  void _drawFrontCage(Canvas canvas, double w, double h) {
    final Rect cageRect = Rect.fromLTWH(w * 0.18, h * 0.18, w * 0.64, h * 0.64);
    final RRect rCage = RRect.fromRectAndRadius(cageRect, const Radius.circular(8));

    // Outer heavy tubular frame ring
    canvas.drawRRect(
      rCage,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3.8
        ..shader = LinearGradient(
          colors: const [_steelLight, _steelMid, _steelDark, _steelMid, _steelLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ).createShader(cageRect),
    );

    final Paint barPaint = Paint()
      ..strokeWidth = 2.4
      ..shader = LinearGradient(
        colors: const [_steelLight, _steelMid, _steelDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(cageRect);

    // Horizontal cage bars on front
    for (double y = cageRect.top + 14; y < cageRect.bottom - 6; y += 16) {
      canvas.drawLine(Offset(cageRect.left, y), Offset(cageRect.right, y), barPaint);
      // Specular highlight on bar
      canvas.drawLine(
        Offset(cageRect.left, y - 0.6),
        Offset(cageRect.right, y - 0.6),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 0.8,
      );
    }

    // Vertical cage bars on front
    for (double x = cageRect.left + 16; x < cageRect.right - 6; x += 18) {
      canvas.drawLine(Offset(x, cageRect.top), Offset(x, cageRect.bottom), barPaint);
      // Specular highlight on bar
      canvas.drawLine(
        Offset(x - 0.6, cageRect.top),
        Offset(x - 0.6, cageRect.bottom),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.4)
          ..strokeWidth = 0.8,
      );
    }

    // Heavy corner plate brackets
    final Paint cornerPaint = Paint()..color = _steelDark;
    const double cs = 7.0;
    canvas.drawRect(Rect.fromLTWH(cageRect.left, cageRect.top, cs, cs), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(cageRect.right - cs, cageRect.top, cs, cs), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(cageRect.left, cageRect.bottom - cs, cs, cs), cornerPaint);
    canvas.drawRect(Rect.fromLTWH(cageRect.right - cs, cageRect.bottom - cs, cs, cs), cornerPaint);

    if (showJoints) {
      final Paint boltPaint = Paint()..color = _steelLight;
      canvas.drawCircle(Offset(cageRect.left + cs / 2, cageRect.top + cs / 2), 1.2, boltPaint);
      canvas.drawCircle(Offset(cageRect.right - cs / 2, cageRect.top + cs / 2), 1.2, boltPaint);
      canvas.drawCircle(Offset(cageRect.left + cs / 2, cageRect.bottom - cs / 2), 1.2, boltPaint);
      canvas.drawCircle(Offset(cageRect.right - cs / 2, cageRect.bottom - cs / 2), 1.2, boltPaint);
    }
  }

  // ----------------------------------------------- volume scale & side graduations

  void _drawVolumeScaleAndLabels(Canvas canvas, double w, double h) {
    // Side volume graduation ticks on tote front left (Subtle & clean industrial scale)
    final double scaleX = w * 0.215;
    final double startY = h * 0.25;
    final double endY = h * 0.77;
    final double stepY = (endY - startY) / 8;

    final Paint tickPaintMajor = Paint()
      ..color = const Color(0xFF1F2937)
      ..strokeWidth = 1.8;

    final Paint tickPaintMinor = Paint()
      ..color = const Color(0xFF37474F)
      ..strokeWidth = 1.0;

    final List<String> labels = ['1000L', '750L', '500L', '250L', '0L'];

    for (int i = 0; i <= 8; i++) {
      final double y = startY + i * stepY;
      final bool isMajor = (i % 2 == 0);
      final double len = isMajor ? 7.0 : 4.0;

      // Tick line
      canvas.drawLine(
        Offset(scaleX, y),
        Offset(scaleX + len, y),
        isMajor ? tickPaintMajor : tickPaintMinor,
      );

      // Volume scale text for major ticks
      if (isMajor && i ~/ 2 < labels.length) {
        final TextPainter tp = TextPainter(
          text: TextSpan(
            text: labels[i ~/ 2],
            style: const TextStyle(
              color: Color(0xFF1E293B),
              fontSize: 7.5,
              fontWeight: FontWeight.bold,
              letterSpacing: -0.2,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        tp.layout();
        tp.paint(canvas, Offset(scaleX + len + 2, y - tp.height / 2));
      }
    }
  }

  // --------------------------------------------------------------- fill cap

  void _drawRefillCap(Canvas canvas, double w, double h) {
    final Rect capRect = Rect.fromLTWH(w * 0.43, h * 0.145, w * 0.14, h * 0.055);
    final RRect rCap = RRect.fromRectAndRadius(capRect, const Radius.circular(3));

    // Cap base fill
    canvas.drawRRect(rCap, _fillV(capRect, const [_trayLight, _trayMid, _trayDark]));
    canvas.drawRRect(
      rCap,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..color = _edge,
    );

    // Cap threaded ridges for grip texture
    for (double x = capRect.left + 3; x < capRect.right; x += 3.5) {
      canvas.drawLine(
        Offset(x, capRect.top + 2),
        Offset(x, capRect.bottom - 2),
        Paint()
          ..color = Colors.white.withValues(alpha: 0.35)
          ..strokeWidth = 1.0,
      );
    }

    // Top neck ring seal
    final Rect neck = Rect.fromLTWH(w * 0.45, h * 0.19, w * 0.10, h * 0.015);
    canvas.drawRect(neck, Paint()..color = _steelMid);
  }

  // ------------------------------------------------------------- inlet pipe

  void _drawInletPipe(Canvas canvas, double w, double h) {
    final Path path = Path();
    path.moveTo(w * 0.12, h * 0.15);
    path.lineTo(w * 0.37, h * 0.15);
    path.lineTo(w * 0.37, h * 0.185);

    final Paint pipePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [_pipeLight, _pipeMid, _pipeDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.12, h * 0.12, w * 0.28, h * 0.08));

    canvas.drawPath(path, pipePaint);
    canvas.drawPath(
      path,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 5.5
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..color = _edge.withValues(alpha: 0.25),
    );

    if (showJoints) {
      // Flange ring at inlet port
      final Rect flange = Rect.fromLTWH(w * 0.12 - 2, h * 0.15 - 5, 4, 10);
      canvas.drawRect(flange, Paint()..color = _steelLight);
      canvas.drawRect(flange, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = _edge);
    }
  }

  // -------------------------------------------------------- discharge valve

  void _drawDischargeValve(Canvas canvas, double w, double h) {
    // Valve nozzle emerging at bottom right (outputPort)
    final Rect valveRect = Rect.fromLTWH(w * 0.75, h * 0.78, w * 0.10, h * 0.065);

    canvas.drawRect(valveRect, _fillV(valveRect, const [_steelLight, _steelMid, _steelDark]));
    canvas.drawRect(valveRect, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);

    // Valve handle (Safety Red lever)
    final Path lever = Path();
    lever.moveTo(valveRect.center.dx - 2, valveRect.top);
    lever.lineTo(valveRect.center.dx + 9, valveRect.top - 9);
    lever.lineTo(valveRect.center.dx + 14, valveRect.top - 7);
    lever.lineTo(valveRect.center.dx + 3, valveRect.top + 2);
    lever.close();

    canvas.drawPath(lever, Paint()..color = _valveBody);
    canvas.drawPath(lever, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = Colors.black87);

    if (showJoints) {
      // Output flange joint with bolts
      final Rect flange = Rect.fromLTWH(w * 0.85 - 2, h * 0.81 - 6, 4, 12);
      canvas.drawRect(flange, Paint()..color = _steelLight);
      canvas.drawRect(flange, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = _edge);

      canvas.drawCircle(Offset(flange.center.dx, flange.top + 2), 0.8, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(flange.center.dx, flange.bottom - 2), 0.8, Paint()..color = Colors.black87);
    }
  }

  // ----------------------------------------------------------- active glow

  void _drawActiveGlow(Canvas canvas, double w, double h) {
    final Rect toteRect = Rect.fromLTWH(w * 0.20, h * 0.20, w * 0.60, h * 0.61);

    final Paint glowPaint = Paint()
      ..color = _chemGlow.withValues(alpha: 0.22 + 0.04 * math.sin(phase * 2 * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawRRect(RRect.fromRectAndRadius(toteRect, const Radius.circular(10)), glowPaint);
  }

  @override
  bool shouldRepaint(covariant DetailedMainFertilizerSourcePainter oldDelegate) {
    return oldDelegate.isOn != isOn ||
        oldDelegate.phase != phase ||
        oldDelegate.showJoints != showJoints;
  }
}

/// Stateful widget wrapper for DetailedMainFertilizerSourcePainter.
class MainFertilizerSourceView extends StatefulWidget {
  final bool isOn;
  final bool showJoints;
  final Size size;

  const MainFertilizerSourceView({
    super.key,
    required this.isOn,
    this.showJoints = true,
    required this.size,
  });

  @override
  State<MainFertilizerSourceView> createState() => _MainFertilizerSourceViewState();
}

class _MainFertilizerSourceViewState extends State<MainFertilizerSourceView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 8));

  @override
  void initState() {
    super.initState();
    _c.repeat();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (context, child) => CustomPaint(
        size: widget.size,
        painter: DetailedMainFertilizerSourcePainter(
          isOn: widget.isOn,
          phase: _c.value,
          showJoints: widget.showJoints,
        ),
      ),
    );
  }
}
