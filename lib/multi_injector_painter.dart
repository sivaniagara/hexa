import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-fidelity, enhanced Industrial Multi-Injector Fertilizer Dosing Skid painter:
/// An aluminum extrusion cage frame housing a 5-channel chemical injection manifold system
/// powered by a prominent foreground inline industrial booster pump.
/// - Intake pipeline draws water from source into the booster pump suction port.
/// - Booster pump (rendered in the foreground over the frame) pressurizes and delivers
///   water into the primary injection manifold feeding all 5 parallel vertical rotameters.
/// - Features dual chrome analog pressure gauges, stainless flange joints, isolation valves,
///   and soft emerald active flow glow when running.
///
/// [isOn]       – true while dosing/injecting is active: booster pump runs, red floats bob,
///                micro-bubbles rise in rotameters, and skid glows softly.
/// [phase]      – 0..1 looping animation driver.
/// [showJoints] – whether flange bolts and mechanical joints are drawn.
class DetailedMultiInjectorPainter extends CustomPainter {
  final bool isOn;
  final double phase;
  final bool showJoints;

  DetailedMultiInjectorPainter({
    required this.isOn,
    this.phase = 0,
    this.showJoints = true,
  });

  // ---------------------------------------------------------------- palette
  // Aluminum Extrusion Frame
  static const Color _alumLight = Color(0xFFF4F8FB);
  static const Color _alumMid = Color(0xFFB0BEC5);
  static const Color _alumDark = Color(0xFF607D8B);
  static const Color _capBlack = Color(0xFF212121);

  // PVC Manifold Piping & Valves
  static const Color _pvcPipeLight = Color(0xFF546E7A);
  static const Color _pvcPipeMid = Color(0xFF37474F);
  static const Color _pvcPipeDark = Color(0xFF263238);
  static const Color _pvcBody = Color(0xFF1C2833);

  // Rotameters & Controls
  static const Color _blueKnob = Color(0xFF1976D2);    // Royal Blue Adjustment Cap
  static const Color _blueKnobDark = Color(0xFF0D47A1);
  static const Color _redFloat = Color(0xFFD32F2F);    // High-visibility Red Float
  static const Color _redValve = Color(0xFFE53935);    // Top Isolation Valve Handle

  // Flow Fluid (Chemical Solution inside Rotameters & Channel)
  static const Color _chemFluidTop = Color(0xEE00E676); // Bright Emerald Green
  static const Color _chemFluidMid = Color(0xF00288D1); // Fertigation Sapphire Blue
  static const Color _chemGlow = Color(0xFF00E5FF);     // Active Flow Glow

  // Booster Pump (High Pressure Industrial Centrifugal Pump)
  static const Color _pumpMotor = Color(0xFF1B5E20);   // Deep Green Booster Motor Body
  static const Color _pumpVolute = Color(0xFF2E7D32);  // Pump Impeller Volute Casing
  static const Color _steelLight = Color(0xFFECEFF1);
  static const Color _steelDark = Color(0xFF455A64);

  static const Color _edge = Color(0xFF151D24);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    if (isOn) _drawActiveGlow(canvas, w, h);
    _drawBackExtrusionFrame(canvas, w, h);
    _drawFrontExtrusionFrame(canvas, w, h); // Frame first
    _drawRotameters(canvas, w, h);
    _drawPvcManifoldsAndBooster(canvas, w, h); // Booster pump & piping drawn in foreground over frame
    _drawPressureGauges(canvas, w, h);
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

  math.Random _seed(int n) => math.Random(n);

  // -------------------------------------------------- aluminum frame back

  void _drawBackExtrusionFrame(Canvas canvas, double w, double h) {
    final Rect backFrame = Rect.fromLTWH(w * 0.12, h * 0.14, w * 0.84, h * 0.82);

    // Rear horizontal rails
    final Paint railPaint = Paint()
      ..shader = const LinearGradient(
        colors: [_alumLight, _alumMid, _alumDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, 14))
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(backFrame.left, backFrame.top), Offset(backFrame.right, backFrame.top), railPaint);
    canvas.drawLine(Offset(backFrame.left, backFrame.center.dy), Offset(backFrame.right, backFrame.center.dy), railPaint);
    canvas.drawLine(Offset(backFrame.left, backFrame.bottom), Offset(backFrame.right, backFrame.bottom), railPaint);

    // Rear vertical struts
    canvas.drawLine(Offset(backFrame.left, backFrame.top), Offset(backFrame.left, backFrame.bottom), railPaint);
    canvas.drawLine(Offset(backFrame.right, backFrame.top), Offset(backFrame.right, backFrame.bottom), railPaint);
    for (int i = 1; i < 5; i++) {
      final double x = backFrame.left + (backFrame.width * i / 5);
      canvas.drawLine(Offset(x, backFrame.top), Offset(x, backFrame.bottom), railPaint);
    }
  }

  // -------------------------------------------- pvc manifolds & booster pump (FOREGROUND)

  void _drawPvcManifoldsAndBooster(Canvas canvas, double w, double h) {
    // Water Intake Pipeline from source (inputPort = Offset(w * 0.05, h * 0.54))
    final Path intakePath = Path();
    intakePath.moveTo(w * 0.05, h * 0.54);
    intakePath.lineTo(w * 0.10, h * 0.54);

    final Paint pipePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..shader = const LinearGradient(
        colors: [_pvcPipeLight, _pvcPipeMid, _pvcPipeDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(w * 0.05, h * 0.30, w * 0.25, h * 0.40));

    canvas.drawPath(intakePath, pipePaint);

    // --- High-Fidelity Foreground Industrial Booster Pump ---
    // Pump Mounting Base Plate on frame floor
    final Rect basePlate = Rect.fromLTWH(w * 0.08, h * 0.65, w * 0.16, h * 0.04);
    canvas.drawRRect(RRect.fromRectAndRadius(basePlate, const Radius.circular(2)), _fillV(basePlate, const [_steelLight, _steelDark]));
    canvas.drawRRect(RRect.fromRectAndRadius(basePlate, const Radius.circular(2)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);

    // Electric Motor Body (back cylindrical housing with cooling fins)
    final Rect motorRect = Rect.fromLTWH(w * 0.14, h * 0.44, w * 0.11, h * 0.22);
    canvas.drawRRect(RRect.fromRectAndRadius(motorRect, const Radius.circular(5)), _fillV(motorRect, const [_pumpMotor, Color(0xFF0F3812), _edge]));
    canvas.drawRRect(RRect.fromRectAndRadius(motorRect, const Radius.circular(5)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge);

    // Motor Cooling Fins
    final Paint finPaint = Paint()..color = Colors.black54..strokeWidth = 1.2;
    for (double x = motorRect.left + 3; x < motorRect.right - 2; x += 3.0) {
      canvas.drawLine(Offset(x, motorRect.top + 3), Offset(x, motorRect.bottom - 3), finPaint);
    }

    // Centrifugal Pump Volute Casing (front circular impeller head with flange)
    final Offset voluteCenter = Offset(w * 0.12, h * 0.55);
    canvas.drawCircle(voluteCenter, h * 0.085, _fillV(Rect.fromCircle(center: voluteCenter, radius: h * 0.085), const [_pumpVolute, _pumpMotor, _edge]));
    canvas.drawCircle(voluteCenter, h * 0.085, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.5..color = _edge);

    // Center Pump Impeller Hub & Locking Nut
    canvas.drawCircle(voluteCenter, 6.0, Paint()..color = _steelLight);
    canvas.drawCircle(voluteCenter, 6.0, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);
    canvas.drawCircle(voluteCenter, 2.5, Paint()..color = _edge);

    // Booster pump discharge line going up into the primary injection manifold
    final Path dischargePath = Path();
    dischargePath.moveTo(voluteCenter.dx, voluteCenter.dy - h * 0.085);
    dischargePath.lineTo(voluteCenter.dx, h * 0.34);
    dischargePath.lineTo(w * 0.26, h * 0.34);

    canvas.drawPath(dischargePath, pipePaint);

    // Top Primary Injection Manifold Pipe across all 5 channels
    final Path topManifold = Path();
    topManifold.moveTo(w * 0.24, h * 0.34);
    topManifold.lineTo(w * 0.92, h * 0.34);

    canvas.drawPath(topManifold, pipePaint);

    // Bottom Dosing Channel Return / Discharge Manifold Pipe (outputPort = Offset(w * 0.94, h * 0.72))
    final Path returnManifold = Path();
    returnManifold.moveTo(w * 0.24, h * 0.72);
    returnManifold.lineTo(w * 0.94, h * 0.72);

    canvas.drawPath(returnManifold, pipePaint);

    // Top isolation valves above each rotameter channel
    for (int i = 0; i < 5; i++) {
      final double rx = w * (0.32 + i * 0.115);
      final Rect valveBox = Rect.fromLTWH(rx - 5, h * 0.31, 10, 10);
      canvas.drawRect(valveBox, Paint()..color = _pvcBody);
      canvas.drawRect(valveBox, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = Colors.white38);
      // Red isolation valve handle
      canvas.drawRect(Rect.fromLTWH(rx - 7, h * 0.29, 14, 3.5), Paint()..color = _redValve);
    }

    if (showJoints) {
      // Inlet and Outlet Flange Rings
      final Rect inletFlange = Rect.fromLTWH(w * 0.05 - 2.5, h * 0.54 - 7, 6, 14);
      canvas.drawRRect(RRect.fromRectAndRadius(inletFlange, const Radius.circular(1.5)), Paint()..color = _steelLight);
      canvas.drawRRect(RRect.fromRectAndRadius(inletFlange, const Radius.circular(1.5)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);

      final Rect outletFlange = Rect.fromLTWH(w * 0.94 - 3.5, h * 0.72 - 7, 6, 14);
      canvas.drawRRect(RRect.fromRectAndRadius(outletFlange, const Radius.circular(1.5)), Paint()..color = _steelLight);
      canvas.drawRRect(RRect.fromRectAndRadius(outletFlange, const Radius.circular(1.5)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);
    }
  }

  // --------------------------------------------------- 5 rotameters / flowmeters

  void _drawRotameters(Canvas canvas, double w, double h) {
    for (int i = 0; i < 5; i++) {
      final double rx = w * (0.32 + i * 0.115);
      final Rect rotameterRect = Rect.fromLTWH(rx - 7, h * 0.41, 14, h * 0.30);

      // Top PVC Fitting
      final Rect topFitting = Rect.fromLTWH(rx - 9, h * 0.37, 18, h * 0.05);
      canvas.drawRRect(RRect.fromRectAndRadius(topFitting, const Radius.circular(2.5)), _fillV(topFitting, const [_pvcPipeLight, _pvcPipeMid, _pvcBody]));

      // Royal Blue Control Knob Cap on top
      final Rect knobRect = Rect.fromLTWH(rx - 7, h * 0.34, 14, h * 0.035);
      canvas.drawRRect(RRect.fromRectAndRadius(knobRect, const Radius.circular(2.5)), _fillV(knobRect, const [_blueKnob, _blueKnobDark]));
      canvas.drawRRect(RRect.fromRectAndRadius(knobRect, const Radius.circular(2.5)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);

      // Bottom PVC Fitting
      final Rect bottomFitting = Rect.fromLTWH(rx - 9, h * 0.71, 18, h * 0.05);
      canvas.drawRRect(RRect.fromRectAndRadius(bottomFitting, const Radius.circular(2.5)), _fillV(bottomFitting, const [_pvcPipeLight, _pvcPipeMid, _pvcBody]));

      // Clear Borosilicate Glass Tube Body
      canvas.drawRRect(
        RRect.fromRectAndRadius(rotameterRect, const Radius.circular(3.5)),
        Paint()..color = Colors.white.withValues(alpha: 0.92),
      );

      // Fluid fill inside rotameter
      final double fluidTopY = rotameterRect.bottom - rotameterRect.height * (isOn ? 0.78 : 0.42);
      final Rect fluidRect = Rect.fromLTRB(rotameterRect.left + 1.2, fluidTopY, rotameterRect.right - 1.2, rotameterRect.bottom - 1.2);

      final Color fluidColor = (i % 2 == 0) ? _chemFluidTop : _chemFluidMid;
      canvas.drawRect(fluidRect, Paint()..color = fluidColor.withValues(alpha: 0.88));

      // Animated Red Float Indicator bobbing inside tube
      final double floatY = fluidTopY + (isOn ? 3.5 * math.sin((phase * 4 * math.pi) + (i * 0.85)) : 0.0);
      final Rect floatRect = Rect.fromLTWH(rx - 5.0, floatY - 3.0, 10, 6);
      canvas.drawRRect(RRect.fromRectAndRadius(floatRect, const Radius.circular(2.0)), Paint()..color = _redFloat);
      canvas.drawRRect(RRect.fromRectAndRadius(floatRect, const Radius.circular(2.0)), Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = Colors.white);

      // Etched Flow Calibration Graduations on glass
      final Paint tickPaint = Paint()
        ..color = Colors.black87
        ..strokeWidth = 0.9;

      for (double y = rotameterRect.top + 5; y < rotameterRect.bottom - 5; y += 6) {
        canvas.drawLine(Offset(rx - 6, y), Offset(rx - 2.5, y), tickPaint);
      }

      // Glass tube outer border & specular glare
      canvas.drawRRect(
        RRect.fromRectAndRadius(rotameterRect, const Radius.circular(3.5)),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _pvcPipeDark,
      );

      final Path glare = Path();
      glare.moveTo(rotameterRect.left + 2, rotameterRect.top);
      glare.lineTo(rotameterRect.left + 6, rotameterRect.top);
      glare.lineTo(rotameterRect.left + 4, rotameterRect.bottom);
      glare.lineTo(rotameterRect.left + 1.5, rotameterRect.bottom);
      glare.close();

      canvas.drawPath(glare, Paint()..color = Colors.white.withValues(alpha: 0.40));

      // Rising micro-bubbles when active
      if (isOn) {
        final math.Random rnd = _seed(i * 13 + 7);
        final Paint bubblePaint = Paint()..color = Colors.white.withValues(alpha: 0.85);

        for (int b = 0; b < 5; b++) {
          final double bx = rx - 3.5 + rnd.nextDouble() * 7;
          final double speed = 0.7 + rnd.nextDouble() * 0.6;
          final double progress = (phase * speed + rnd.nextDouble()) % 1.0;
          final double by = rotameterRect.bottom - progress * rotameterRect.height;

          if (by > rotameterRect.top + 3 && by < rotameterRect.bottom - 3) {
            canvas.drawCircle(Offset(bx, by), 1.0, bubblePaint);
          }
        }
      }
    }
  }

  // -------------------------------------------------- aluminum frame front

  void _drawFrontExtrusionFrame(Canvas canvas, double w, double h) {
    final Rect frontFrame = Rect.fromLTWH(w * 0.12, h * 0.14, w * 0.84, h * 0.82);

    // Front horizontal extruded aluminum rails
    final Paint railPaint = Paint()
      ..shader = const LinearGradient(
        colors: [_alumLight, _alumMid, _alumDark],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(Rect.fromLTWH(0, 0, w, 14))
      ..strokeWidth = 5.0
      ..style = PaintingStyle.stroke;

    canvas.drawLine(Offset(frontFrame.left, frontFrame.top), Offset(frontFrame.right, frontFrame.top), railPaint);
    canvas.drawLine(Offset(frontFrame.left, frontFrame.top + h * 0.18), Offset(frontFrame.right, frontFrame.top + h * 0.18), railPaint);
    canvas.drawLine(Offset(frontFrame.left, frontFrame.bottom), Offset(frontFrame.right, frontFrame.bottom), railPaint);

    // Vertical corner posts
    canvas.drawLine(Offset(frontFrame.left, frontFrame.top), Offset(frontFrame.left, frontFrame.bottom), railPaint);
    canvas.drawLine(Offset(frontFrame.right, frontFrame.top), Offset(frontFrame.right, frontFrame.bottom), railPaint);

    // Corner connecting brackets / black plastic end caps
    final Paint capPaint = Paint()..color = _capBlack;
    canvas.drawRect(Rect.fromLTWH(frontFrame.left - 5, frontFrame.top - 5, 10, 10), capPaint);
    canvas.drawRect(Rect.fromLTWH(frontFrame.right - 5, frontFrame.top - 5, 10, 10), capPaint);
    canvas.drawRect(Rect.fromLTWH(frontFrame.left - 5, frontFrame.bottom - 5, 10, 10), capPaint);
    canvas.drawRect(Rect.fromLTWH(frontFrame.right - 5, frontFrame.bottom - 5, 10, 10), capPaint);

    // Adjustable floor feet pads
    final Paint footPaint = Paint()..color = _pvcPipeDark;
    canvas.drawCircle(Offset(frontFrame.left, frontFrame.bottom + 5), 5.0, footPaint);
    canvas.drawCircle(Offset(frontFrame.right, frontFrame.bottom + 5), 5.0, footPaint);
    canvas.drawCircle(Offset(w * 0.38, frontFrame.bottom + 5), 4.5, footPaint);
    canvas.drawCircle(Offset(w * 0.72, frontFrame.bottom + 5), 4.5, footPaint);
  }

  // ----------------------------------------------------- pressure gauges

  void _drawPressureGauges(Canvas canvas, double w, double h) {
    // Pressure Gauge 1: Booster Pump Discharge Riser
    final Offset g1 = Offset(w * 0.08, h * 0.28);
    _drawSingleGauge(canvas, g1, h * 0.045);

    // Pressure Gauge 2: Top Central Injection Manifold
    final Offset g2 = Offset(w * 0.58, h * 0.24);
    _drawSingleGauge(canvas, g2, h * 0.04);
  }

  void _drawSingleGauge(Canvas canvas, Offset center, double radius) {
    // Connecting stem
    canvas.drawLine(
      center,
      Offset(center.dx, center.dy + radius + 5),
      Paint()
        ..strokeWidth = 2.5
        ..color = _steelDark,
    );

    // Bezel & Dial
    canvas.drawCircle(center, radius + 1.5, Paint()..color = _steelLight);
    canvas.drawCircle(center, radius + 1.5, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.2..color = _edge);
    canvas.drawCircle(center, radius, Paint()..color = Colors.white);

    // Dial arc (Green/Red safety zones)
    final Rect dialBounds = Rect.fromCircle(center: center, radius: radius - 1.8);
    canvas.drawArc(dialBounds, -math.pi * 0.75, math.pi * 0.85, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..color = const Color(0xFF4CAF50));
    canvas.drawArc(dialBounds, math.pi * 0.10, math.pi * 0.35, false, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.8..color = const Color(0xFFE53935));

    // Vibrating needle
    final double needleAngle = -math.pi * 0.40 + (isOn ? 0.35 + 0.07 * math.sin(phase * 4 * math.pi) : 0.0);
    final Offset needleEnd = Offset(
      center.dx + (radius - 3.0) * math.cos(needleAngle),
      center.dy + (radius - 3.0) * math.sin(needleAngle),
    );

    canvas.drawLine(center, needleEnd, Paint()..color = const Color(0xFFD32F2F)..strokeWidth = 1.4);
    canvas.drawCircle(center, 1.8, Paint()..color = _edge);
  }

  // ----------------------------------------------------------- active glow

  void _drawActiveGlow(Canvas canvas, double w, double h) {
    final Rect mainRect = Rect.fromLTWH(w * 0.12, h * 0.14, w * 0.84, h * 0.82);

    final Paint glowPaint = Paint()
      ..color = _chemGlow.withValues(alpha: 0.25 + 0.10 * math.sin(phase * 2 * math.pi))
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 18);

    canvas.drawRRect(RRect.fromRectAndRadius(mainRect, const Radius.circular(16)), glowPaint);
  }

  @override
  bool shouldRepaint(covariant DetailedMultiInjectorPainter oldDelegate) {
    return oldDelegate.isOn != isOn ||
        oldDelegate.phase != phase ||
        oldDelegate.showJoints != showJoints;
  }
}

/// Stateful widget wrapper for DetailedMultiInjectorPainter.
class MultiInjectorView extends StatefulWidget {
  final bool isOn;
  final bool showJoints;
  final Size size;

  const MultiInjectorView({
    super.key,
    required this.isOn,
    this.showJoints = true,
    required this.size,
  });

  @override
  State<MultiInjectorView> createState() => _MultiInjectorViewState();
}

class _MultiInjectorViewState extends State<MultiInjectorView>
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
        painter: DetailedMultiInjectorPainter(
          isOn: widget.isOn,
          phase: _c.value,
          showJoints: widget.showJoints,
        ),
      ),
    );
  }
}
