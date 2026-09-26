import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-fidelity Fertilizer Tank (Dosing/Injecting Vessel) painter:
/// A vertical cylindrical fertigation mixing tank supported on a metallic quad-leg
/// stand, featuring a top-mounted agitator motor, an analog pressure gauge with
/// safety dial, a vertical sight glass level tube with float indicator, a cutaway
/// view of the chemical fertilizer solution with rotating impeller blades and
/// agitation bubbles when active, inlet (left) and outlet/dosing (right) pipes
/// with flange bolt joints, and a soft active glow when active.
///
/// [isOn]   – true while fertigation/dosing is active: motor impeller spins,
///            solution swirls, agitation bubbles rise, and tank glows softly.
/// [phase]  – 0..1 looping animation driver (impeller spin, bubbles, ripples).
/// [showJoints] – whether flange bolts and mechanical joints are drawn.
class DetailedFertilizerTankPainter extends CustomPainter {
  final bool isOn;
  final double phase;
  final bool showJoints;

  DetailedFertilizerTankPainter({
    required this.isOn,
    this.phase = 0,
    this.showJoints = true,
  });

  // ---------------------------------------------------------------- palette
  static const Color _tankShellLight = Color(0xFFE0E0E0);
  static const Color _tankShellMid = Color(0xFFBDBDBD);
  static const Color _tankShellDark = Color(0xFF757575);

  static const Color _steelLight = Color(0xFFCFD8DC);
  static const Color _steelMid = Color(0xFF90A4AE);
  static const Color _steelDark = Color(0xFF455A64);

  static const Color _motorBody = Color(0xFF1E88E5); // Industrial Blue Motor
  static const Color _motorFins = Color(0xFF0D47A1);

  // Fertigation Solution (Vibrant Nitrogen Cyan / Blue Gradient)
  static const Color _chemTop = Color(0xDD00B0FF);   // Bright Cyan Liquid
  static const Color _chemMid = Color(0xE60288D1);   // Fertigation Blue
  static const Color _chemDeep = Color(0xF201579B);  // Deep Blue Base
  static const Color _chemGlow = Color(0xFF40C4FF);  // Cyan Active Glow
  static const Color _amberFloat = Color(0xFFFF9100); // Level Indicator Float

  static const Color _pipeLight = Color(0xFF81D4FA);
  static const Color _pipeMid = Color(0xFF0288D1);
  static const Color _pipeDark = Color(0xFF01579B);

  static const Color _edge = Color(0xFF212121);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _drawSupportStand(canvas, w, h);
    _drawOutletPipe(canvas, w, h);
    _drawInletPipe(canvas, w, h);
    if (isOn) _drawActiveGlow(canvas, w, h);
    _drawTankBody(canvas, w, h);
    _drawLiquidInterior(canvas, w, h);
    _drawImpellerAndAgitation(canvas, w, h);
    _drawSightGlass(canvas, w, h);
    _drawAgitatorMotor(canvas, w, h);
    _drawPressureGauge(canvas, w, h);
  }

  // -------------------------------------------------------------- helpers

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

  math.Random _seed(int n) => math.Random(n);

  // ---------------------------------------------------------- support stand

  void _drawSupportStand(Canvas canvas, double w, double h) {
    final double groundY = h * 0.94;
    final Paint legPaint = Paint()
      ..strokeWidth = 3.5
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [_steelLight, _steelMid, _steelDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.70, w, h * 0.25));

    // Outer angled legs
    canvas.drawLine(Offset(w * 0.30, h * 0.70), Offset(w * 0.22, groundY), legPaint);
    canvas.drawLine(Offset(w * 0.70, h * 0.70), Offset(w * 0.78, groundY), legPaint);
    // Inner vertical legs
    canvas.drawLine(Offset(w * 0.42, h * 0.72), Offset(w * 0.40, groundY), legPaint);
    canvas.drawLine(Offset(w * 0.58, h * 0.72), Offset(w * 0.60, groundY), legPaint);

    // Leg cross bracing
    final Paint bracePaint = Paint()
      ..strokeWidth = 1.8
      ..color = _steelDark;
    canvas.drawLine(Offset(w * 0.25, h * 0.82), Offset(w * 0.75, h * 0.82), bracePaint);

    // Foot pads on ground
    final Paint footPaint = Paint()..color = _steelDark;
    canvas.drawRect(Rect.fromLTWH(w * 0.20, groundY - 2, 8, 4), footPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.76, groundY - 2, 8, 4), footPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.38, groundY - 2, 6, 4), footPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.58, groundY - 2, 6, 4), footPaint);
  }

  // ------------------------------------------------------------- tank body

  void _drawTankBody(Canvas canvas, double w, double h) {
    final Rect mainRect = Rect.fromLTWH(w * 0.26, h * 0.25, w * 0.48, h * 0.48);

    // Main cylinder body background shell
    final RRect rMain = RRect.fromRectAndRadius(mainRect, const Radius.circular(10));
    canvas.drawRRect(rMain, _fillH(mainRect, const [_tankShellLight, _tankShellMid, _tankShellDark]));

    // Top dome
    final Rect topDome = Rect.fromLTWH(w * 0.26, h * 0.19, w * 0.48, h * 0.12);
    canvas.drawArc(topDome, math.pi, math.pi, true, _fillH(topDome, const [_tankShellLight, _tankShellMid, _tankShellDark]));

    // Bottom cone
    final Path bottomCone = Path();
    bottomCone.moveTo(w * 0.26, h * 0.73);
    bottomCone.lineTo(w * 0.74, h * 0.73);
    bottomCone.lineTo(w * 0.58, h * 0.82);
    bottomCone.lineTo(w * 0.42, h * 0.82);
    bottomCone.close();

    canvas.drawPath(bottomCone, _fillH(mainRect, const [_tankShellLight, _tankShellMid, _tankShellDark]));
    canvas.drawPath(bottomCone, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);

    // Seam rings / metallic bands
    final Paint bandPaint = Paint()
      ..color = _steelDark.withOpacity(0.8)
      ..strokeWidth = 1.8;
    canvas.drawLine(Offset(w * 0.26, h * 0.25), Offset(w * 0.74, h * 0.25), bandPaint);
    canvas.drawLine(Offset(w * 0.26, h * 0.73), Offset(w * 0.74, h * 0.73), bandPaint);
  }

  // ------------------------------------------------------- liquid interior

  void _drawLiquidInterior(Canvas canvas, double w, double h) {
    // Semi-translucent cutaway viewing window in center of tank
    final Rect cutaway = Rect.fromLTWH(w * 0.32, h * 0.29, w * 0.36, h * 0.40);
    final RRect rCut = RRect.fromRectAndRadius(cutaway, const Radius.circular(6));

    canvas.save();
    canvas.clipRRect(rCut);

    // Liquid fill level (65% full)
    final double liquidTopY = cutaway.top + cutaway.height * 0.35;
    final Rect liquidRect = Rect.fromLTRB(cutaway.left, liquidTopY, cutaway.right, cutaway.bottom);

    // Liquid body
    canvas.drawRect(liquidRect, _fillV(liquidRect, const [_chemTop, _chemMid, _chemDeep]));

    // Surface wave animation
    final Path wavePath = Path();
    wavePath.moveTo(liquidRect.left, liquidRect.top);
    final double waveFreq = 2.5 * math.pi;
    for (double x = liquidRect.left; x <= liquidRect.right; x += 2) {
      final double normX = (x - liquidRect.left) / liquidRect.width;
      final double waveOffset = math.sin(normX * waveFreq + phase * 2 * math.pi) * (isOn ? 2.8 : 0.8);
      wavePath.lineTo(x, liquidRect.top + waveOffset);
    }
    wavePath.lineTo(liquidRect.right, liquidRect.bottom);
    wavePath.lineTo(liquidRect.left, liquidRect.bottom);
    wavePath.close();

    canvas.drawPath(wavePath, _fillV(liquidRect, const [_chemTop, _chemMid, _chemDeep]));

    // Surface foam highlight line
    canvas.drawPath(
      wavePath,
      Paint()
        ..color = Colors.white.withOpacity(0.7)
        ..strokeWidth = 1.2
        ..style = PaintingStyle.stroke,
    );

    canvas.restore();

    // Window rim / seal border
    canvas.drawRRect(
      rCut,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0
        ..color = _steelDark,
    );
  }

  // ------------------------------------------------ impeller & agitation

  void _drawImpellerAndAgitation(Canvas canvas, double w, double h) {
    final Rect cutaway = Rect.fromLTWH(w * 0.32, h * 0.29, w * 0.36, h * 0.40);

    // Central agitator shaft running down
    final double shaftX = cutaway.center.dx;
    canvas.drawLine(
      Offset(shaftX, h * 0.18),
      Offset(shaftX, cutaway.bottom - 8),
      Paint()
        ..strokeWidth = 2.2
        ..color = _steelLight,
    );

    // Impeller blades inside liquid
    final double impellerY1 = cutaway.bottom - 12;
    final double impellerY2 = cutaway.center.dy + 8;
    final double bladeAngle = phase * 2 * math.pi;

    void drawBladesAt(double y) {
      final double span = 14.0 * (isOn ? math.cos(bladeAngle).abs().clamp(0.2, 1.0) : 0.8);
      final Paint bladePaint = Paint()
        ..color = _steelLight
        ..strokeWidth = 2.5
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(shaftX - span, y - 2), Offset(shaftX + span, y + 2), bladePaint);
      canvas.drawLine(Offset(shaftX - span, y + 2), Offset(shaftX + span, y - 2), bladePaint);
    }

    drawBladesAt(impellerY1);
    drawBladesAt(impellerY2);

    // Rising micro bubbles & swirling vortex lines when active
    if (isOn) {
      final math.Random rnd = _seed(23);
      final Paint bubblePaint = Paint()..color = Colors.white.withOpacity(0.7);

      for (int i = 0; i < 14; i++) {
        final double bx = cutaway.left + 4 + rnd.nextDouble() * (cutaway.width - 8);
        final double speed = 0.6 + rnd.nextDouble() * 0.6;
        final double progress = (phase * speed + rnd.nextDouble()) % 1.0;
        final double by = cutaway.bottom - progress * (cutaway.height * 0.62);

        if (by > cutaway.top + 8 && by < cutaway.bottom) {
          canvas.drawCircle(Offset(bx, by), 0.8 + rnd.nextDouble() * 1.4, bubblePaint);
        }
      }
    }
  }

  // -------------------------------------------------------- sight glass tube

  void _drawSightGlass(Canvas canvas, double w, double h) {
    final Rect tubeRect = Rect.fromLTWH(w * 0.69, h * 0.32, w * 0.035, h * 0.34);
    final RRect rTube = RRect.fromRectAndRadius(tubeRect, const Radius.circular(3));

    // Glass tube body
    canvas.drawRRect(rTube, Paint()..color = Colors.white.withOpacity(0.85));
    canvas.drawRRect(rTube, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _steelDark);

    // Liquid in sight glass
    final double fillY = tubeRect.bottom - tubeRect.height * 0.62;
    final Rect glassLiquid = Rect.fromLTRB(tubeRect.left + 1, fillY, tubeRect.right - 1, tubeRect.bottom - 1);
    canvas.drawRect(glassLiquid, Paint()..color = _chemMid);

    // Float ball indicator
    canvas.drawCircle(
      Offset(tubeRect.center.dx, fillY),
      2.5,
      Paint()..color = _amberFloat,
    );

    // Calibration graduation marks along side
    final Paint markPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 0.8;
    for (double y = tubeRect.top + 4; y < tubeRect.bottom; y += 6) {
      canvas.drawLine(Offset(tubeRect.left - 2, y), Offset(tubeRect.left, y), markPaint);
    }
  }

  // ---------------------------------------------------- agitator motor top

  void _drawAgitatorMotor(Canvas canvas, double w, double h) {
    // Motor body on top dome
    final Rect motorRect = Rect.fromLTWH(w * 0.42, h * 0.08, w * 0.16, h * 0.10);
    final RRect rMotor = RRect.fromRectAndRadius(motorRect, const Radius.circular(3));

    canvas.drawRRect(rMotor, _fillV(motorRect, const [_motorBody, _motorFins]));
    canvas.drawRRect(rMotor, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);

    // Motor cooling fins
    for (double x = motorRect.left + 3; x < motorRect.right; x += 3.5) {
      canvas.drawLine(
        Offset(x, motorRect.top + 2),
        Offset(x, motorRect.bottom - 2),
        Paint()
          ..color = _motorFins
          ..strokeWidth = 1.0,
      );
    }

    // Top electrical terminal box
    final Rect junctionBox = Rect.fromLTWH(w * 0.40, h * 0.10, w * 0.04, h * 0.05);
    canvas.drawRect(junctionBox, Paint()..color = Colors.black87);
  }

  // ------------------------------------------------------ pressure gauge

  void _drawPressureGauge(Canvas canvas, double w, double h) {
    final Offset center = Offset(w * 0.33, h * 0.14);
    final double radius = h * 0.05;

    // Gauge stem
    canvas.drawLine(
      center,
      Offset(center.dx, h * 0.20),
      Paint()
        ..strokeWidth = 2.5
        ..color = _steelMid,
    );

    // Gauge face
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);
    canvas.drawCircle(center, radius, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge);

    // Green/Red arc zone
    final Rect dialBounds = Rect.fromCircle(center: center, radius: radius - 1.5);
    canvas.drawArc(dialBounds, -math.pi * 0.75, math.pi * 0.8, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..color = Colors.green);
    canvas.drawArc(dialBounds, math.pi * 0.05, math.pi * 0.4, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..color = Colors.red);

    // Needle indicator
    final double needleAngle = -math.pi * 0.5 + (isOn ? 0.35 + 0.08 * math.sin(phase * 4 * math.pi) : 0.0);
    final Offset needleEnd = Offset(
      center.dx + (radius - 3) * math.cos(needleAngle),
      center.dy + (radius - 3) * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, Paint()..color = Colors.red.shade800..strokeWidth = 1.2);
    canvas.drawCircle(center, 1.5, Paint()..color = Colors.black87);
  }

  // -------------------------------------------------------- inlet & outlet pipes

  void _drawInletPipe(Canvas canvas, double w, double h) {
    // Water/chemical inlet on left (inputPort = Offset(w * 0.12, h * 0.35))
    final Path path = Path();
    path.moveTo(w * 0.12, h * 0.35);
    path.lineTo(w * 0.26, h * 0.35);

    final Paint pipePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [_pipeLight, _pipeMid, _pipeDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.12, h * 0.32, w * 0.15, h * 0.06));

    canvas.drawPath(path, pipePaint);

    if (showJoints) {
      // Inlet flange bolt ring
      final Rect flange = Rect.fromLTWH(w * 0.12 - 2, h * 0.35 - 5, 4, 10);
      canvas.drawRect(flange, Paint()..color = _steelLight);
      canvas.drawRect(flange, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = _edge);
      canvas.drawCircle(Offset(flange.center.dx, flange.top + 2), 0.8, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(flange.center.dx, flange.bottom - 2), 0.8, Paint()..color = Colors.black87);
    }
  }

  void _drawOutletPipe(Canvas canvas, double w, double h) {
    // Solution outlet on bottom right (outputPort = Offset(w * 0.88, h * 0.75))
    final Path path = Path();
    path.moveTo(w * 0.50, h * 0.78);
    path.lineTo(w * 0.88, h * 0.78);
    path.lineTo(w * 0.88, h * 0.75);

    final Paint pipePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [_pipeLight, _pipeMid, _pipeDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.50, h * 0.72, w * 0.40, h * 0.10));

    canvas.drawPath(path, pipePaint);

    if (showJoints) {
      // Outlet flange bolt ring
      final Rect flange = Rect.fromLTWH(w * 0.88 - 2, h * 0.75 - 5, 4, 10);
      canvas.drawRect(flange, Paint()..color = _steelLight);
      canvas.drawRect(flange, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = _edge);
      canvas.drawCircle(Offset(flange.center.dx, flange.top + 2), 0.8, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(flange.center.dx, flange.bottom - 2), 0.8, Paint()..color = Colors.black87);
    }
  }

  // ----------------------------------------------------------- active glow

  void _drawActiveGlow(Canvas canvas, double w, double h) {
    final Rect mainRect = Rect.fromLTWH(w * 0.26, h * 0.25, w * 0.48, h * 0.48);

    final Paint glowPaint = Paint()
      ..color = _chemGlow.withOpacity(0.32 + 0.15 * math.sin(phase * 2 * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);

    canvas.drawRRect(RRect.fromRectAndRadius(mainRect, const Radius.circular(10)), glowPaint);
  }

  @override
  bool shouldRepaint(covariant DetailedFertilizerTankPainter oldDelegate) {
    return oldDelegate.isOn != isOn ||
        oldDelegate.phase != phase ||
        oldDelegate.showJoints != showJoints;
  }
}

/// Stateful widget wrapper for DetailedFertilizerTankPainter.
class FertilizerTankView extends StatefulWidget {
  final bool isOn;
  final bool showJoints;
  final Size size;

  const FertilizerTankView({
    super.key,
    required this.isOn,
    this.showJoints = true,
    required this.size,
  });

  @override
  State<FertilizerTankView> createState() => _FertilizerTankViewState();
}

class _FertilizerTankViewState extends State<FertilizerTankView>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c =
      AnimationController(vsync: this, duration: const Duration(seconds: 3));

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
      builder: (_, __) => CustomPaint(
        size: widget.size,
        painter: DetailedFertilizerTankPainter(
          isOn: widget.isOn,
          phase: _c.value,
          showJoints: widget.showJoints,
        ),
      ),
    );
  }
}
