import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-fidelity Natural Source painter (river / pond / open water body):
/// grassy banks on either side, an open water surface with ripples and sun
/// caustics, reeds, a few lily pads, and a submerged intake strainer on a
/// pipe rising up out of frame — the pump's suction point in a natural
/// source, mirroring the sump/well suction riser.
///
/// [isOn]   – true while the pump is drawing water: bubbles and inward-flow
///            chevrons animate near the strainer, and the water gets a
///            soft "active" glow.
/// [phase]  – 0..1 looping animation driver (ripples, flow, bubbles, birds).
class DetailedNaturalSourcePainter extends CustomPainter {
  final bool isOn;
  final double phase;
  final bool showJoints;

  DetailedNaturalSourcePainter({
    required this.isOn,
    this.phase = 0,
    this.showJoints = true,
  });

  // ---------------------------------------------------------------- palette
  static const Color _skyTop = Color(0xFFBFE3F5);
  static const Color _skyBottom = Color(0xFFE7F5EC);

  static const Color _grassLight = Color(0xFF9CCB5A);
  static const Color _grassMid = Color(0xFF6FA83A);
  static const Color _grassDark = Color(0xFF3F7A24);
  static const Color _soil = Color(0xFF6D4C29);

  static const Color _waterTop = Color(0xCC63C7F2);
  static const Color _waterMid = Color(0xCC1F8FD1);
  static const Color _waterDeep = Color(0xE60B4E80);
  static const Color _waterGlow = Color(0xFF7FE3FF);

  static const Color _reed = Color(0xFF4C7A2E);
  static const Color _reedDark = Color(0xFF2F5A1C);
  static const Color _lily = Color(0xFF2E7D32);

  static const Color _steelLight = Color(0xFFECEFF1);
  static const Color _steelMid = Color(0xFF8FA0A8);
  static const Color _steelDark = Color(0xFF37464E);

  static const Color _edge = Color(0xFF262622);

  double _waterTopY(double h) => h * 0.28;
  double _waterBottomY(double h) => h * 0.95;

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _drawSky(canvas, w, h);
    _drawBanks(canvas, w, h);
    if (isOn) _activeGlow(canvas, w, h);
    _drawWater(canvas, w, h);
    _drawLilyPads(canvas, w, h);
    _drawReeds(canvas, w, h);
    _drawIntakePipe(canvas, w, h);
    if (isOn) _drawBirds(canvas, w, h);
  }

  // -------------------------------------------------------------- helpers

  Paint _fillV(Rect r, List<Color> colors, {List<double>? stops}) {
    return Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(colors: colors, stops: stops, begin: Alignment.topCenter, end: Alignment.bottomCenter).createShader(r);
  }

  math.Random _seed(int n) => math.Random(n);

  // -------------------------------------------------------------------- sky

  void _drawSky(Canvas canvas, double w, double h) {
    final double waterTop = _waterTopY(h);
    final Rect sky = Rect.fromLTWH(0, 0, w, waterTop);
    canvas.drawRect(sky, _fillV(sky, const [_skyTop, _skyBottom]));

    // Soft sun glow, upper corner.
    canvas.drawCircle(
      Offset(w * 0.78, h * 0.08),
      w * 0.10,
      Paint()
        ..color = Colors.white.withOpacity(0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 14),
    );

    // A couple of soft clouds.
    final math.Random cRnd = _seed(3);
    for (int i = 0; i < 3; i++) {
      final double cx = w * (0.12 + cRnd.nextDouble() * 0.5);
      final double cy = h * (0.05 + cRnd.nextDouble() * 0.08);
      _drawCloud(canvas, Offset(cx, cy), w * (0.09 + cRnd.nextDouble() * 0.04));
    }
  }

  void _drawCloud(Canvas canvas, Offset center, double size) {
    final Paint p = Paint()..color = Colors.white.withOpacity(0.75);
    canvas.drawCircle(center, size * 0.5, p);
    canvas.drawCircle(center + Offset(size * 0.5, size * 0.05), size * 0.38, p);
    canvas.drawCircle(center - Offset(size * 0.45, -size * 0.08), size * 0.32, p);
  }

  // ------------------------------------------------------------------ banks

  void _drawBanks(Canvas canvas, double w, double h) {
    final double waterTop = _waterTopY(h);

    // Left bank — a grassy slope wedge.
    final Path leftBank = Path()
      ..moveTo(0, 0)
      ..lineTo(w * 0.30, 0)
      ..lineTo(w * 0.10, waterTop + h * 0.05)
      ..lineTo(0, waterTop)
      ..close();
    canvas.drawPath(leftBank, _fillV(leftBank.getBounds(), const [_grassLight, _grassMid, _grassDark]));
    canvas.drawPath(leftBank, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge.withOpacity(0.4));

    // Right bank.
    final Path rightBank = Path()
      ..moveTo(w, 0)
      ..lineTo(w * 0.74, 0)
      ..lineTo(w * 0.92, waterTop + h * 0.03)
      ..lineTo(w, waterTop)
      ..close();
    canvas.drawPath(rightBank, _fillV(rightBank.getBounds(), const [_grassLight, _grassMid, _grassDark]));
    canvas.drawPath(rightBank, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge.withOpacity(0.4));

    // Soil edge right where grass meets water.
    final Paint soilEdge = Paint()..color = _soil.withOpacity(0.6);
    canvas.drawPath(
      Path()
        ..moveTo(0, waterTop - 1)
        ..lineTo(w * 0.10, waterTop + h * 0.05)
        ..lineTo(w * 0.10, waterTop + h * 0.055)
        ..lineTo(0, waterTop + h * 0.005)
        ..close(),
      soilEdge,
    );
    canvas.drawPath(
      Path()
        ..moveTo(w, waterTop - 1)
        ..lineTo(w * 0.92, waterTop + h * 0.03)
        ..lineTo(w * 0.92, waterTop + h * 0.035)
        ..lineTo(w, waterTop + h * 0.005)
        ..close(),
      soilEdge,
    );

    // Grass texture speckle + tufts along both banks.
    final math.Random rnd = _seed(17);
    for (int i = 0; i < 40; i++) {
      final bool left = i.isEven;
      final double t = rnd.nextDouble();
      final double bx = left ? w * (0.02 + t * 0.22) : w * (0.76 + t * 0.22);
      final double by = h * (0.02 + rnd.nextDouble() * (waterTop / h - 0.03));
      _drawGrassTuft(canvas, Offset(bx, by), 3 + rnd.nextDouble() * 4, rnd);
    }
  }

  void _drawGrassTuft(Canvas canvas, Offset base, double size, math.Random rnd) {
    final Paint blade = Paint()
      ..color = _grassDark.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.0
      ..strokeCap = StrokeCap.round;
    for (int i = 0; i < 3; i++) {
      final double lean = (rnd.nextDouble() - 0.5) * size;
      canvas.drawLine(base, Offset(base.dx + lean, base.dy - size), blade);
    }
  }

  void _activeGlow(Canvas canvas, double w, double h) {
    final double pulse = 0.6 + 0.4 * (0.5 + 0.5 * math.sin(phase * 2 * math.pi));
    final Rect water = Rect.fromLTRB(w * 0.02, _waterTopY(h), w * 0.98, _waterBottomY(h));
    canvas.drawRRect(
      RRect.fromRectAndRadius(water, const Radius.circular(8)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3 + 2 * pulse
        ..color = _waterGlow.withOpacity(0.20 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, 10 + 5 * pulse),
    );
  }

  // --------------------------------------------------------------- water

  void _drawWater(Canvas canvas, double w, double h) {
    final Rect waterRect = Rect.fromLTRB(0, _waterTopY(h), w, _waterBottomY(h));

    canvas.save();
    canvas.clipRect(waterRect);

    canvas.drawRect(waterRect, _fillV(waterRect, const [_waterTop, _waterMid, _waterDeep], stops: const [0.0, 0.4, 1.0]));

    // Sun caustic shafts, angled.
    final Paint caustic = Paint()
      ..color = Colors.white.withOpacity(0.12)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 7);
    for (int i = 0; i < 5; i++) {
      final double t = (phase + i / 5) % 1.0;
      final double x = waterRect.left + t * waterRect.width;
      final Path shaft = Path()
        ..moveTo(x, waterRect.top)
        ..lineTo(x + waterRect.width * 0.05, waterRect.top)
        ..lineTo(x - waterRect.width * 0.09, waterRect.bottom)
        ..lineTo(x - waterRect.width * 0.14, waterRect.bottom)
        ..close();
      canvas.drawPath(shaft, caustic);
    }

    // Layered ripples across the whole surface.
    for (int layer = 0; layer < 4; layer++) {
      final Paint ripple = Paint()
        ..color = Colors.white.withOpacity(0.26 - layer * 0.05)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.3 - layer * 0.22;
      final Path path = Path();
      final double amp = h * (0.006 + layer * 0.003);
      final double freq = 2.5 + layer * 1.2;
      final double speed = phase * 2 * math.pi * (layer.isEven ? 1 : -1);
      final double yBase = waterRect.top + layer * h * 0.05 + h * 0.02;
      for (double x = waterRect.left; x <= waterRect.right; x += 3) {
        final double t = (x - waterRect.left) / waterRect.width;
        final double y = yBase + amp * math.sin(t * freq * math.pi + speed);
        if (x == waterRect.left) {
          path.moveTo(x, y);
        } else {
          path.lineTo(x, y);
        }
      }
      canvas.drawPath(path, ripple);
    }

    // A few small fish darting near the bottom for character.
    final math.Random fishRnd = _seed(29);
    for (int i = 0; i < 3; i++) {
      final double seedT = fishRnd.nextDouble();
      final double t = (phase + seedT) % 1.0;
      final double fy = waterRect.top + waterRect.height * (0.6 + 0.15 * math.sin(seedT * 10));
      final double fx = waterRect.left + t * waterRect.width;
      _drawFish(canvas, Offset(fx, fy), 6 + fishRnd.nextDouble() * 3, t > 0.5);
    }

    if (isOn) {
      final math.Random bubbleRnd = _seed(5);
      for (int i = 0; i < 10; i++) {
        final double seedT = bubbleRnd.nextDouble();
        final double t = (phase + seedT) % 1.0;
        final double bx = w * 0.72 + (bubbleRnd.nextDouble() - 0.5) * w * 0.10;
        final double by = waterRect.bottom - t * waterRect.height * 0.7;
        final double r = 1.0 + bubbleRnd.nextDouble() * 1.7;
        final double fade = (1 - t).clamp(0.0, 1.0);
        canvas.drawCircle(Offset(bx, by), r, Paint()..color = Colors.white.withOpacity(0.5 * fade));
      }
    }

    canvas.restore();

    canvas.drawLine(
      Offset(waterRect.left, waterRect.top),
      Offset(waterRect.right, waterRect.top),
      Paint()..color = Colors.white.withOpacity(0.38)..strokeWidth = 1.0,
    );
  }

  void _drawFish(Canvas canvas, Offset pos, double size, bool facingRight) {
    final Paint body = Paint()..color = const Color(0xFFB0742A).withOpacity(0.55);
    final double dir = facingRight ? 1 : -1;
    final Path fish = Path()
      ..moveTo(pos.dx - dir * size, pos.dy)
      ..quadraticBezierTo(pos.dx, pos.dy - size * 0.35, pos.dx + dir * size, pos.dy)
      ..quadraticBezierTo(pos.dx, pos.dy + size * 0.35, pos.dx - dir * size, pos.dy)
      ..close();
    canvas.drawPath(fish, body);
    final Path tail = Path()
      ..moveTo(pos.dx - dir * size, pos.dy)
      ..lineTo(pos.dx - dir * size * 1.5, pos.dy - size * 0.3)
      ..lineTo(pos.dx - dir * size * 1.5, pos.dy + size * 0.3)
      ..close();
    canvas.drawPath(tail, body);
  }

  // ------------------------------------------------------------- lily pads

  void _drawLilyPads(Canvas canvas, double w, double h) {
    final double waterTop = _waterTopY(h);
    final List<Offset> pads = [
      Offset(w * 0.18, waterTop + h * 0.05),
      Offset(w * 0.26, waterTop + h * 0.09),
      Offset(w * 0.14, waterTop + h * 0.12),
    ];
    for (final Offset p in pads) {
      final double r = w * 0.035;
      final Path pad = Path()..addOval(Rect.fromCircle(center: p, radius: r));
      // Notch cut for the classic lily-pad shape.
      final Path notch = Path()
        ..moveTo(p.dx, p.dy)
        ..lineTo(p.dx + r * 1.1, p.dy - r * 0.35)
        ..lineTo(p.dx + r * 1.1, p.dy + r * 0.35)
        ..close();
      final Path finalPad = Path.combine(PathOperation.difference, pad, notch);
      canvas.drawPath(finalPad, Paint()..color = _lily.withOpacity(0.85));
      canvas.drawPath(finalPad, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = _reedDark.withOpacity(0.6));
    }
  }

  // ------------------------------------------------------------------ reeds

  void _drawReeds(Canvas canvas, double w, double h) {
    final double waterTop = _waterTopY(h);
    final math.Random rnd = _seed(23);
    final List<double> clusterX = [w * 0.06, w * 0.12, w * 0.90, w * 0.95];
    for (final double cx in clusterX) {
      final int stalks = 4 + rnd.nextInt(3);
      for (int i = 0; i < stalks; i++) {
        final double baseX = cx + (rnd.nextDouble() - 0.5) * w * 0.03;
        final double baseY = waterTop + h * (0.01 + rnd.nextDouble() * 0.03);
        final double stalkH = h * (0.14 + rnd.nextDouble() * 0.08);
        final double sway = math.sin(phase * 2 * math.pi + i) * w * 0.008;

        final Paint stalk = Paint()
          ..color = Color.lerp(_reed, _reedDark, rnd.nextDouble())!
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.4
          ..strokeCap = StrokeCap.round;
        final Path path = Path()
          ..moveTo(baseX, baseY)
          ..quadraticBezierTo(baseX + sway, baseY - stalkH * 0.6, baseX + sway * 1.6, baseY - stalkH);
        canvas.drawPath(path, stalk);

        // Seed head at the tip.
        canvas.drawOval(
          Rect.fromCenter(center: Offset(baseX + sway * 1.6, baseY - stalkH - 3), width: 3, height: 8),
          Paint()..color = const Color(0xFF8D6E3C),
        );
      }
    }
  }

  // ----------------------------------------------------------- intake pipe

  void _drawIntakePipe(Canvas canvas, double w, double h) {
    final double waterTop = _waterTopY(h);
    // Riser coming down from off the top of the canvas into the water,
    // positioned toward the right so it reads distinct from the reeds.
    final Rect riser = Rect.fromLTWH(w * 0.66, 0, w * 0.06, h * 0.66);
    final Paint pipePaint = Paint()
      ..isAntiAlias = true
      ..shader = const LinearGradient(
        colors: [Color(0xFF4FC3F7), Color(0xFF0288D1), Color(0xFF014B7A)],
        stops: [0, 0.4, 1],
        begin: Alignment.centerLeft,
        end: Alignment.centerRight,
      ).createShader(riser);
    canvas.drawRect(riser, pipePaint);
    canvas.drawRect(riser, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = const Color(0xFF014B7A));

    // Pipe support post driven into the bank, holding it steady.
    final Rect post = Rect.fromLTWH(w * 0.635, waterTop - h * 0.02, w * 0.01, h * 0.10);
    canvas.drawRect(post, Paint()..color = _steelDark);

    // Foot-valve body underwater.
    final Rect valveBody = Rect.fromLTWH(w * 0.635, waterTop + h * 0.30, w * 0.13, h * 0.14);
    canvas.drawRRect(
      RRect.fromRectAndRadius(valveBody, const Radius.circular(6)),
      _fillV(valveBody, const [_steelLight, _steelMid, _steelDark], stops: const [0, 0.5, 1]),
    );
    canvas.drawRRect(RRect.fromRectAndRadius(valveBody, const Radius.circular(6)),
        Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9..color = _steelDark);

    final Rect strainerArea = Rect.fromLTRB(
      valveBody.left + valveBody.width * 0.12,
      valveBody.top + valveBody.height * 0.28,
      valveBody.right - valveBody.width * 0.12,
      valveBody.bottom - valveBody.height * 0.10,
    );
    final Paint slot = Paint()..color = const Color(0xFF1B2226);
    final int slotCount = 4;
    final double slotW = strainerArea.width / (slotCount * 2 - 1);
    for (int i = 0; i < slotCount; i++) {
      final double x = strainerArea.left + i * slotW * 2;
      final RRect r = RRect.fromRectAndRadius(
        Rect.fromLTRB(x, strainerArea.top, x + slotW, strainerArea.bottom),
        Radius.circular(slotW * 0.4),
      );
      canvas.drawRRect(r, slot);
      canvas.drawRRect(r, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.6..color = Colors.white.withOpacity(0.15));
    }

    // A float/buoy near the surface marking the intake, for character.
    final double bob = math.sin(phase * 2 * math.pi) * h * 0.006;
    final Offset buoyCenter = Offset(w * 0.60, waterTop + h * 0.035 + bob);
    canvas.drawCircle(buoyCenter, w * 0.018, Paint()..color = const Color(0xFFE53935));
    canvas.drawCircle(buoyCenter, w * 0.018, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = Colors.black26);
    canvas.drawLine(buoyCenter, Offset(valveBody.center.dx, valveBody.top), Paint()..color = Colors.black26..strokeWidth = 0.7);

    if (isOn) {
      final Paint chevron = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1
        ..strokeCap = StrokeCap.round
        ..color = Colors.white.withOpacity(0.55);
      for (int i = 0; i < 3; i++) {
        final double t = (phase + i / 3) % 1.0;
        final double r = w * (0.085 - t * 0.05);
        final Offset c = Offset(valveBody.center.dx, valveBody.center.dy);
        canvas.drawArc(Rect.fromCircle(center: c, radius: r), math.pi * 0.15, math.pi * 0.7, false, chevron);
      }
    }
  }

  // -------------------------------------------------------------------- birds

  void _drawBirds(Canvas canvas, double w, double h) {
    final Paint bird = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..strokeCap = StrokeCap.round
      ..color = _edge.withOpacity(0.5);
    for (int i = 0; i < 2; i++) {
      final double t = (phase * 0.4 + i / 2) % 1.0;
      final double bx = w * (0.05 + t * 0.35);
      final double by = h * (0.05 + i * 0.03);
      final double flap = math.sin(phase * 10 + i) * 3;
      final Path m = Path()
        ..moveTo(bx - 5, by + flap)
        ..quadraticBezierTo(bx - 2, by - 3, bx, by)
        ..quadraticBezierTo(bx + 2, by - 3, bx + 5, by + flap);
      canvas.drawPath(m, bird);
    }
  }

  @override
  bool shouldRepaint(covariant DetailedNaturalSourcePainter old) =>
      old.isOn != isOn || old.phase != phase || old.showJoints != showJoints;
}

/// Drop-in widget: keeps ripples, bubbles, reeds and flow cues animating.
class NaturalSourceView extends StatefulWidget {
  final bool isOn;
  final bool showJoints;
  final Size size;

  const NaturalSourceView({
    super.key,
    required this.isOn,
    this.showJoints = true,
    this.size = const Size(240, 180),
  });

  @override
  State<NaturalSourceView> createState() => _NaturalSourceViewState();
}

class _NaturalSourceViewState extends State<NaturalSourceView> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(seconds: 4));

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
        painter: DetailedNaturalSourcePainter(
          isOn: widget.isOn,
          phase: _c.value,
          showJoints: widget.showJoints,
        ),
      ),
    );
  }
}