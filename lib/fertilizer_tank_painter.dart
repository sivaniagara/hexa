import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-fidelity Translucent Natural Polyethylene Fertigation Dosing Tank painter:
/// A heavy-duty vertical cylindrical fertigation stock solution tank supported on a
/// stainless steel quad-leg stand with concrete base pads. Features a translucent
/// warm-ivory UV-stabilized polyethylene tank body with a vibrant emerald green NPK
/// fertilizer solution, top-mounted industrial graphite agitator motor drive with cooling
/// fins, central agitator shaft with dual 3-blade mixing impellers, dual-scale chrome analog
/// pressure gauge with operating zones, top pressure-relief safety valve, armored borosilicate
/// sight-glass level tube with high-visibility float, etched volumetric calibration
/// graduations (Liters), a large crystal-clear viewing window revealing vibrant swirling
/// liquid with surface wave animation and rising micro-bubbles when active, an inlet pipe
/// manifold (left) and a discharge dosing ball valve assembly (right) with flange bolt rings,
/// and a soft emerald active glow when running.
///
/// [isOn]       – true while fertigation/dosing is active: motor impeller spins,
///                solution swirls, agitation bubbles rise, and tank glows softly.
/// [phase]      – 0..1 looping animation driver (impeller spin, bubbles, ripples).
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
  // Steel Support & Structural Frame (Polished Metallic Stainless Steel)
  static const Color _steelLight = Color(0xFFF4F6F9);
  static const Color _steelMid = Color(0xFFB0BEC5);
  static const Color _steelDark = Color(0xFF607D8B);
  static const Color _steelDeep = Color(0xFF37474F);

  // Tank Shell (Translucent Warm Ivory Polyethylene / Natural Poly Shell)
  static const Color _shellLight = Color(0xFFFFFDF8);   // Translucent Ivory Highlight
  static const Color _shellMid = Color(0xFFF3EFE7);     // Translucent Poly Body
  static const Color _shellDark = Color(0xFFE2DCD2);    // Natural Poly Shadow
  static const Color _shellShadow = Color(0xFFC7BFB3);  // Deep Edge Shadow

  // Fertigation Solution (Vibrant Emerald Green NPK Crop Liquid Fertilizer)
  static const Color _chemTop = Color(0xFF00E676);     // Bright Lime-Emerald Liquid Highlight
  static const Color _chemMid = Color(0xFF2E7D32);     // Vibrant NPK Emerald Green
  static const Color _chemDeep = Color(0xFF1B5E20);    // Deep Forest Green Base
  static const Color _chemGlow = Color(0xFF00E676);    // Emerald Green Active Glow
  static const Color _amberFloat = Color(0xFFFFD600);   // High-Visibility Bright Yellow Float

  // Agitator Motor & Safety Hardware (Industrial Graphite Drive Motor)
  static const Color _motorBody = Color(0xFF37474F);   // Dark Metallic Graphite Motor
  static const Color _motorFins = Color(0xFF212121);   // Cooling Fins
  static const Color _valveRed = Color(0xFFD32F2F);     // Safety Red Discharge Ball Valve

  // Pipes & Manifold Joints (Stainless / Reinforced Pipe Work)
  static const Color _pipeLight = Color(0xFFE1F5FE);
  static const Color _pipeMid = Color(0xFF0288D1);
  static const Color _pipeDark = Color(0xFF01579B);

  static const Color _edge = Color(0xFF1E272C);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _drawSupportStand(canvas, w, h);
    _drawOutletPipeAndValve(canvas, w, h);
    _drawInletPipeAndFlange(canvas, w, h);
    if (isOn) _drawActiveGlow(canvas, w, h);
    _drawTankShellAndCone(canvas, w, h);
    _drawLiquidAndSwirl(canvas, w, h);
    _drawImpellerAndShaft(canvas, w, h);
    _drawSightGlassAndGraduations(canvas, w, h);
    _drawAgitatorMotorDrive(canvas, w, h);
    _drawPressureGaugeAndReliefValves(canvas, w, h);
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
    final double groundY = h * 0.93;

    // Concrete pad under legs
    final Rect padRect = Rect.fromLTWH(w * 0.16, groundY, w * 0.68, h * 0.05);
    canvas.drawRRect(
      RRect.fromRectAndRadius(padRect, const Radius.circular(3)),
      Paint()..color = Colors.black.withValues(alpha: 0.18),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(padRect, const Radius.circular(3)),
      _fillV(padRect, const [Color(0xFFCFD8DC), Color(0xFF90A4AE), Color(0xFF546E7A)]),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(padRect, const Radius.circular(3)),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge,
    );

    // Quad Leg Struts
    final Paint legPaint = Paint()
      ..strokeWidth = 4.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke
      ..shader = const LinearGradient(
        colors: [_steelLight, _steelMid, _steelDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, h * 0.65, w, h * 0.28));

    // Outer angled support legs
    canvas.drawLine(Offset(w * 0.28, h * 0.68), Offset(w * 0.21, groundY), legPaint);
    canvas.drawLine(Offset(w * 0.72, h * 0.68), Offset(w * 0.79, groundY), legPaint);
    // Inner support legs
    canvas.drawLine(Offset(w * 0.40, h * 0.72), Offset(w * 0.38, groundY), legPaint);
    canvas.drawLine(Offset(w * 0.60, h * 0.72), Offset(w * 0.62, groundY), legPaint);

    // Structural X-bracing struts
    final Paint bracePaint = Paint()
      ..strokeWidth = 2.0
      ..color = _steelDark;

    canvas.drawLine(Offset(w * 0.24, h * 0.81), Offset(w * 0.76, h * 0.81), bracePaint);
    canvas.drawLine(Offset(w * 0.25, h * 0.74), Offset(w * 0.39, h * 0.88), bracePaint);
    canvas.drawLine(Offset(w * 0.75, h * 0.74), Offset(w * 0.61, h * 0.88), bracePaint);

    // Gusset plates at leg joints
    final Paint platePaint = Paint()..color = _steelDeep;
    canvas.drawCircle(Offset(w * 0.50, h * 0.81), 3.5, platePaint);

    // Footpads anchored to concrete
    final Paint footPaint = Paint()..color = _steelDeep;
    canvas.drawRect(Rect.fromLTWH(w * 0.18, groundY - 3, 10, 4), footPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.76, groundY - 3, 10, 4), footPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.35, groundY - 3, 8, 4), footPaint);
    canvas.drawRect(Rect.fromLTWH(w * 0.60, groundY - 3, 8, 4), footPaint);
  }

  // -------------------------------------------------- tank shell & bottom cone

  void _drawTankShellAndCone(Canvas canvas, double w, double h) {
    final Rect mainRect = Rect.fromLTWH(w * 0.26, h * 0.22, w * 0.48, h * 0.48);

    // Main Cylindrical Body Shell
    final RRect rMain = RRect.fromRectAndRadius(mainRect, const Radius.circular(10));

    // Outer drop shadow
    canvas.drawRRect(
      rMain.shift(const Offset(2, 3)),
      Paint()..color = Colors.black.withValues(alpha: 0.15),
    );

    // Translucent warm-ivory cylinder gradient fill with 3D highlight
    canvas.drawRRect(
      rMain,
      _fillH(
        mainRect,
        const [_shellLight, _shellMid, _shellLight, _shellDark, _shellShadow],
        stops: const [0.0, 0.25, 0.45, 0.82, 1.0],
      ),
    );
    canvas.drawRRect(
      rMain,
      Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge,
    );

    // Top Cylindrical Dome
    final Rect topDome = Rect.fromLTWH(w * 0.26, h * 0.15, w * 0.48, h * 0.14);
    canvas.drawArc(
      topDome,
      math.pi,
      math.pi,
      true,
      _fillH(
        topDome,
        const [_shellLight, _shellMid, _shellDark, _shellShadow],
        stops: const [0.0, 0.30, 0.80, 1.0],
      ),
    );
    canvas.drawArc(topDome, math.pi, math.pi, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge);

    // Bottom Conical Collector Drain
    final Path bottomCone = Path();
    bottomCone.moveTo(w * 0.26, h * 0.70);
    bottomCone.lineTo(w * 0.74, h * 0.70);
    bottomCone.lineTo(w * 0.58, h * 0.81);
    bottomCone.lineTo(w * 0.42, h * 0.81);
    bottomCone.close();

    canvas.drawPath(
      bottomCone,
      _fillH(
        mainRect,
        const [_shellLight, _shellMid, _shellDark, _shellShadow],
        stops: const [0.0, 0.30, 0.80, 1.0],
      ),
    );
    canvas.drawPath(bottomCone, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge);

    // Stainless metallic reinforcement clamping bands with tension bolt joints
    final Paint bandPaint = Paint()
      ..shader = const LinearGradient(
        colors: [_steelLight, _steelMid, _steelDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.26, 0, w * 0.48, 10))
      ..strokeWidth = 2.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(w * 0.26, h * 0.22), Offset(w * 0.74, h * 0.22), bandPaint);
    canvas.drawLine(Offset(w * 0.26, h * 0.46), Offset(w * 0.74, h * 0.46), bandPaint);
    canvas.drawLine(Offset(w * 0.26, h * 0.70), Offset(w * 0.74, h * 0.70), bandPaint);

    if (showJoints) {
      // Clamping bolts on bands
      final Paint boltPaint = Paint()..color = _steelDeep;
      canvas.drawCircle(Offset(w * 0.27, h * 0.22), 1.5, boltPaint);
      canvas.drawCircle(Offset(w * 0.73, h * 0.22), 1.5, boltPaint);
      canvas.drawCircle(Offset(w * 0.27, h * 0.46), 1.5, boltPaint);
      canvas.drawCircle(Offset(w * 0.73, h * 0.46), 1.5, boltPaint);
      canvas.drawCircle(Offset(w * 0.27, h * 0.70), 1.5, boltPaint);
      canvas.drawCircle(Offset(w * 0.73, h * 0.70), 1.5, boltPaint);
    }
  }

  // ----------------------------------------------------- liquid & swirl interior

  void _drawLiquidAndSwirl(Canvas canvas, double w, double h) {
    // Crystal-clear curved viewing window in center of vessel
    final Rect cutaway = Rect.fromLTWH(w * 0.31, h * 0.26, w * 0.38, h * 0.42);
    final RRect rCut = RRect.fromRectAndRadius(cutaway, const Radius.circular(8));

    canvas.save();
    canvas.clipRRect(rCut);

    // Dark forest window glass backing
    canvas.drawRect(cutaway, Paint()..color = const Color(0xFF0B2211));

    // Liquid fill level (65% capacity)
    final double liquidTopY = cutaway.top + cutaway.height * 0.35;
    final Rect liquidRect = Rect.fromLTRB(cutaway.left, liquidTopY, cutaway.right, cutaway.bottom);

    // Liquid main body gradient (Vibrant Emerald Green NPK)
    canvas.drawRect(liquidRect, _fillV(liquidRect, const [_chemTop, _chemMid, _chemDeep]));

    // Surface wave animation
    final Path wavePath = Path();
    wavePath.moveTo(liquidRect.left, liquidRect.top);
    final double waveFreq = 2.8 * math.pi;
    for (double x = liquidRect.left; x <= liquidRect.right; x += 1.5) {
      final double normX = (x - liquidRect.left) / liquidRect.width;
      final double waveOffset = math.sin(normX * waveFreq + phase * 2 * math.pi) * (isOn ? 3.0 : 0.8);
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
        ..color = Colors.white.withValues(alpha: 0.85)
        ..strokeWidth = 1.5
        ..style = PaintingStyle.stroke,
    );

    // Swirling vortex currents when active
    if (isOn) {
      final Paint swirlPaint = Paint()
        ..color = Colors.white.withValues(alpha: 0.28)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.2
        ..strokeCap = StrokeCap.round;

      for (int i = 0; i < 4; i++) {
        final double radiusX = (cutaway.width * 0.35) - (i * 3.5);
        final double radiusY = 6.0 + i * 2.0;
        final double swirlY = liquidTopY + 12 + (i * 18);
        final double startAngle = (phase * 2 * math.pi) + (i * 1.2);

        if (swirlY < cutaway.bottom - 8) {
          canvas.drawArc(
            Rect.fromCenter(center: Offset(cutaway.center.dx, swirlY), width: radiusX * 2, height: radiusY * 2),
            startAngle,
            math.pi * 1.2,
            false,
            swirlPaint,
          );
        }
      }

      // Rising micro-bubbles
      final math.Random rnd = _seed(37);
      final Paint bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.80);
      final Paint bubbleRing = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8
        ..color = _chemGlow.withValues(alpha: 0.95);

      for (int i = 0; i < 16; i++) {
        final double bx = cutaway.left + 6 + rnd.nextDouble() * (cutaway.width - 12);
        final double speed = 0.5 + rnd.nextDouble() * 0.7;
        final double progress = (phase * speed + rnd.nextDouble()) % 1.0;
        final double by = cutaway.bottom - progress * (cutaway.height * 0.62);

        if (by > cutaway.top + 8 && by < cutaway.bottom) {
          final double r = 0.9 + rnd.nextDouble() * 1.5;
          canvas.drawCircle(Offset(bx, by), r, bubblePaint);
          canvas.drawCircle(Offset(bx, by), r + 0.5, bubbleRing);
        }
      }
    }

    // Glass glare reflection stripes across window
    final Path glare = Path();
    glare.moveTo(cutaway.left + 4, cutaway.top);
    glare.lineTo(cutaway.left + 16, cutaway.top);
    glare.lineTo(cutaway.left + 6, cutaway.bottom);
    glare.lineTo(cutaway.left + 2, cutaway.bottom);
    glare.close();

    canvas.drawPath(glare, Paint()..color = Colors.white.withValues(alpha: 0.15));

    canvas.restore();

    // Window frame / stainless rim seal
    canvas.drawRRect(
      rCut,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.2
        ..color = _steelDark,
    );
  }

  // ------------------------------------------------- impeller & drive shaft

  void _drawImpellerAndShaft(Canvas canvas, double w, double h) {
    final Rect cutaway = Rect.fromLTWH(w * 0.31, h * 0.26, w * 0.38, h * 0.42);

    // Central stainless agitator shaft
    final double shaftX = cutaway.center.dx;
    canvas.drawLine(
      Offset(shaftX, h * 0.14),
      Offset(shaftX, cutaway.bottom - 6),
      Paint()
        ..strokeWidth = 2.5
        ..shader = const LinearGradient(
          colors: [_steelLight, _steelMid, _steelDark],
        ).createShader(Rect.fromLTWH(shaftX - 2, 0, 4, h)),
    );

    // Dual 3-blade mixing impellers inside liquid
    final double impellerY1 = cutaway.bottom - 12;
    final double impellerY2 = cutaway.center.dy + 6;
    final double bladeAngle = phase * 2 * math.pi;

    void drawImpellerAt(double y) {
      final double span = 16.0 * (isOn ? math.cos(bladeAngle).abs().clamp(0.25, 1.0) : 0.85);
      final Paint bladePaint = Paint()
        ..color = _steelLight
        ..strokeWidth = 3.0
        ..strokeCap = StrokeCap.round;

      canvas.drawLine(Offset(shaftX - span, y - 2), Offset(shaftX + span, y + 2), bladePaint);
      canvas.drawLine(Offset(shaftX - span, y + 2), Offset(shaftX + span, y - 2), bladePaint);

      // Hub collar
      canvas.drawCircle(Offset(shaftX, y), 3.0, Paint()..color = _steelDeep);
      canvas.drawCircle(Offset(shaftX, y), 1.2, Paint()..color = _steelLight);
    }

    drawImpellerAt(impellerY1);
    drawImpellerAt(impellerY2);
  }

  // ---------------------------------------------- sight glass & volume scale

  void _drawSightGlassAndGraduations(Canvas canvas, double w, double h) {
    final Rect tubeRect = Rect.fromLTWH(w * 0.68, h * 0.28, w * 0.038, h * 0.38);
    final RRect rTube = RRect.fromRectAndRadius(tubeRect, const Radius.circular(3));

    // Tube background & borosilicate glass fill
    canvas.drawRRect(rTube, Paint()..color = Colors.white.withValues(alpha: 0.90));
    canvas.drawRRect(rTube, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _steelDark);

    // Liquid in sight glass tube (matching emerald green tank fill)
    final double fillY = tubeRect.bottom - tubeRect.height * 0.62;
    final Rect glassLiquid = Rect.fromLTRB(tubeRect.left + 1, fillY, tubeRect.right - 1, tubeRect.bottom - 1);
    canvas.drawRect(glassLiquid, _fillV(glassLiquid, const [_chemTop, _chemMid]));

    // High-visibility bright yellow indicator float ball
    canvas.drawCircle(
      Offset(tubeRect.center.dx, fillY),
      2.8,
      Paint()..color = _amberFloat,
    );
    canvas.drawCircle(
      Offset(tubeRect.center.dx - 0.8, fillY - 0.8),
      0.8,
      Paint()..color = Colors.white,
    );

    // Mounting armor brackets at top and bottom
    final Paint bracketPaint = Paint()..color = _steelDeep;
    canvas.drawRect(Rect.fromLTWH(tubeRect.left - 2, tubeRect.top - 2, tubeRect.width + 4, 4), bracketPaint);
    canvas.drawRect(Rect.fromLTWH(tubeRect.left - 2, tubeRect.bottom - 2, tubeRect.width + 4, 4), bracketPaint);

    // Etched Liters (L) Calibration Graduations
    final Paint markPaint = Paint()
      ..color = Colors.black87
      ..strokeWidth = 0.9;

    int tickCount = 0;
    for (double y = tubeRect.top + 6; y < tubeRect.bottom - 4; y += 7) {
      final double markLen = (tickCount % 2 == 0) ? 4.0 : 2.5;
      canvas.drawLine(Offset(tubeRect.left - markLen, y), Offset(tubeRect.left, y), markPaint);
      tickCount++;
    }
  }

  // ---------------------------------------------------- agitator motor drive

  void _drawAgitatorMotorDrive(Canvas canvas, double w, double h) {
    // Motor body on top dome
    final Rect motorRect = Rect.fromLTWH(w * 0.41, h * 0.06, w * 0.18, h * 0.10);
    final RRect rMotor = RRect.fromRectAndRadius(motorRect, const Radius.circular(4));

    // Motor body 3D gradient (Industrial Graphite)
    canvas.drawRRect(rMotor, _fillV(motorRect, const [_motorBody, _motorFins, _steelDeep]));
    canvas.drawRRect(rMotor, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge);

    // Cooling fins
    final Paint finPaint = Paint()
      ..color = _motorFins
      ..strokeWidth = 1.2;
    for (double x = motorRect.left + 4; x < motorRect.right - 2; x += 3.5) {
      canvas.drawLine(Offset(x, motorRect.top + 2), Offset(x, motorRect.bottom - 2), finPaint);
    }

    // Top Electrical Conduit Box
    final Rect junctionBox = Rect.fromLTWH(w * 0.38, h * 0.08, w * 0.05, h * 0.05);
    canvas.drawRRect(RRect.fromRectAndRadius(junctionBox, const Radius.circular(2)), Paint()..color = _steelDeep);
    canvas.drawRRect(RRect.fromRectAndRadius(junctionBox, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = Colors.white38);

    // Stainless Drive Mounting Flange Plate
    final Rect flangeRect = Rect.fromLTWH(w * 0.38, h * 0.15, w * 0.24, h * 0.03);
    canvas.drawRRect(RRect.fromRectAndRadius(flangeRect, const Radius.circular(2)), _fillH(flangeRect, const [_steelLight, _steelMid, _steelDark]));
    canvas.drawRRect(RRect.fromRectAndRadius(flangeRect, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);

    if (showJoints) {
      final Paint boltPaint = Paint()..color = _steelDeep;
      canvas.drawCircle(Offset(flangeRect.left + 3, flangeRect.center.dy), 1.2, boltPaint);
      canvas.drawCircle(Offset(flangeRect.right - 3, flangeRect.center.dy), 1.2, boltPaint);
    }
  }

  // ------------------------------------------- pressure gauge & safety valve

  void _drawPressureGaugeAndReliefValves(Canvas canvas, double w, double h) {
    // Analog Pressure Gauge (Left Dome Top)
    final Offset gaugeCenter = Offset(w * 0.32, h * 0.12);
    final double radius = h * 0.048;

    // Stem connecting to dome
    canvas.drawLine(
      gaugeCenter,
      Offset(gaugeCenter.dx, h * 0.18),
      Paint()
        ..strokeWidth = 2.8
        ..color = _steelMid,
    );

    // Chrome Bezel Ring
    canvas.drawCircle(gaugeCenter, radius + 1.5, Paint()..color = _steelLight);
    canvas.drawCircle(gaugeCenter, radius + 1.5, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge);

    // White Dial Face
    canvas.drawCircle(gaugeCenter, radius, Paint()..color = Colors.white);

    // Green / Red Safety Arc Zones
    final Rect dialBounds = Rect.fromCircle(center: gaugeCenter, radius: radius - 2.0);
    canvas.drawArc(dialBounds, -math.pi * 0.75, math.pi * 0.85, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = const Color(0xFF4CAF50));
    canvas.drawArc(dialBounds, math.pi * 0.10, math.pi * 0.35, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 2.0..color = const Color(0xFFE53935));

    // Vibrating Needle Indicator
    final double needleAngle = -math.pi * 0.45 + (isOn ? 0.35 + 0.08 * math.sin(phase * 4 * math.pi) : 0.0);
    final Offset needleEnd = Offset(
      gaugeCenter.dx + (radius - 3) * math.cos(needleAngle),
      gaugeCenter.dy + (radius - 3) * math.sin(needleAngle),
    );

    canvas.drawLine(gaugeCenter, needleEnd, Paint()..color = const Color(0xFFD32F2F)..strokeWidth = 1.5);
    canvas.drawCircle(gaugeCenter, 2.0, Paint()..color = _steelDeep);

    // Pressure Relief Safety Valve (Right Dome Top)
    final Rect valveBounds = Rect.fromLTWH(w * 0.63, h * 0.12, w * 0.05, h * 0.06);
    canvas.drawRRect(RRect.fromRectAndRadius(valveBounds, const Radius.circular(2)), _fillV(valveBounds, const [_steelLight, _steelDark]));
    canvas.drawRRect(RRect.fromRectAndRadius(valveBounds, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = _edge);
  }

  // ------------------------------------------ inlet & outlet pipe manifolds

  void _drawInletPipeAndFlange(Canvas canvas, double w, double h) {
    // Water/chemical inlet on left (inputPort = Offset(w * 0.12, h * 0.35))
    final Path path = Path();
    path.moveTo(w * 0.12, h * 0.35);
    path.lineTo(w * 0.26, h * 0.35);

    final Paint pipePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..shader = const LinearGradient(
        colors: [_pipeLight, _pipeMid, _pipeDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.12, h * 0.32, w * 0.15, h * 0.06));

    canvas.drawPath(path, pipePaint);

    if (showJoints) {
      // Inlet flange bolt ring at attachment point
      final Rect flange = Rect.fromLTWH(w * 0.12 - 2, h * 0.35 - 6, 5, 12);
      canvas.drawRRect(RRect.fromRectAndRadius(flange, const Radius.circular(1)), Paint()..color = _steelLight);
      canvas.drawRRect(RRect.fromRectAndRadius(flange, const Radius.circular(1)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);
      canvas.drawCircle(Offset(flange.center.dx, flange.top + 2), 1.0, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(flange.center.dx, flange.bottom - 2), 1.0, Paint()..color = Colors.black87);
    }
  }

  void _drawOutletPipeAndValve(Canvas canvas, double w, double h) {
    // Solution outlet / injection manifold (outputPort = Offset(w * 0.88, h * 0.75))
    final Path path = Path();
    path.moveTo(w * 0.50, h * 0.80);
    path.lineTo(w * 0.88, h * 0.80);
    path.lineTo(w * 0.88, h * 0.75);

    final Paint pipePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [_pipeLight, _pipeMid, _pipeDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.50, h * 0.72, w * 0.40, h * 0.10));

    canvas.drawPath(path, pipePaint);

    // Chemical Injection Red Ball Valve
    final Rect valveBody = Rect.fromLTWH(w * 0.66, h * 0.80 - 6, 12, 12);
    canvas.drawRRect(RRect.fromRectAndRadius(valveBody, const Radius.circular(2)), Paint()..color = _steelDeep);
    // Red handle
    canvas.drawRect(Rect.fromLTWH(w * 0.68, h * 0.80 - 10, 8, 4), Paint()..color = _valveRed);

    if (showJoints) {
      // Outlet flange bolt ring at attachment point
      final Rect flange = Rect.fromLTWH(w * 0.88 - 2.5, h * 0.75 - 6, 5, 12);
      canvas.drawRRect(RRect.fromRectAndRadius(flange, const Radius.circular(1)), Paint()..color = _steelLight);
      canvas.drawRRect(RRect.fromRectAndRadius(flange, const Radius.circular(1)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);
      canvas.drawCircle(Offset(flange.center.dx, flange.top + 2), 1.0, Paint()..color = Colors.black87);
      canvas.drawCircle(Offset(flange.center.dx, flange.bottom - 2), 1.0, Paint()..color = Colors.black87);
    }
  }

  // ----------------------------------------------------------- active glow

  void _drawActiveGlow(Canvas canvas, double w, double h) {
    final Rect mainRect = Rect.fromLTWH(w * 0.26, h * 0.22, w * 0.48, h * 0.48);

    final Paint glowPaint = Paint()
      ..color = _chemGlow.withValues(alpha: 0.30 + 0.12 * math.sin(phase * 2 * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14);

    canvas.drawRRect(RRect.fromRectAndRadius(mainRect, const Radius.circular(12)), glowPaint);
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
      builder: (_, _) => CustomPaint(
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
