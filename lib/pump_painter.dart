import 'dart:math' as math;
import 'package:flutter/material.dart';

/// A high-fidelity centrifugal monoblock pump — tuned to be more
/// eye-catching than a plain industrial render.
///
/// [isOn]  – running state: saturated casting color, pulsing lamp,
///           breathing halo glow, and animated flow dots on the pipes.
/// [phase] – radians; drives the fan/coupling spin AND the glow pulse.
class DetailedPumpPainter extends CustomPainter {
  final bool isOn;
  final double phase;

  DetailedPumpPainter({required this.isOn, this.phase = 0});

  // ---------------------------------------------------------------- palette
  // Punchier, more saturated than a realistic industrial grey-green so the
  // machine reads clearly at a glance and the on/off states contrast hard.
  Color get _castLight => isOn ? const Color(0xFF7CF29A) : const Color(0xFFB9C6B2);
  Color get _castMid => isOn ? const Color(0xFF17B24E) : const Color(0xFF7C8A6E);
  Color get _castDark => isOn ? const Color(0xFF0A6B2E) : const Color(0xFF4B5740);
  Color get _castDeep => isOn ? const Color(0xFF033316) : const Color(0xFF262E1E);

  // Warm accent used only while running, for the glow / lamp / flow dots.
  static const Color _accentGlow = Color(0xFF4CFF8F);
  static const Color _accentGlowSoft = Color(0x664CFF8F);

  static const Color _edge = Color(0xFF06210E);
  static const Color _steelLight = Color(0xFFEFF3F5);
  static const Color _steelMid = Color(0xFFA7B2B9);
  static const Color _steelDark = Color(0xFF454F55);

  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    _groundShadow(canvas, w, h);
    if (isOn) _ambientHalo(canvas, w, h); // sits behind everything, breathes
    _basePlate(canvas, w, h);
    _feet(canvas, w, h);
    _motorBarrel(canvas, w, h);
    _fanCowl(canvas, w, h);
    _terminalBox(canvas, w, h);
    _coupling(canvas, w, h);
    _volute(canvas, w, h);
    _suction(canvas, w, h);
    _discharge(canvas, w, h);
    if (isOn) {
      _runningGlow(canvas, w, h);
      _flowDots(canvas, w, h);
    }
  }

  // ------------------------------------------------------------- primitives

  Paint _fill(Rect r, List<Color> colors,
      {List<double>? stops, Alignment begin = Alignment.topCenter, Alignment end = Alignment.bottomCenter}) {
    return Paint()
      ..isAntiAlias = true
      ..shader = LinearGradient(colors: colors, stops: stops, begin: begin, end: end).createShader(r);
  }

  /// Cylinder shading: bright band near the top, deep core shadow low down,
  /// plus a bounce-light sliver at the very bottom.
  Paint _cylinder(Rect r) => _fill(
    r,
    [_castDark, _castLight, _castMid, _castDeep, _castMid],
    stops: const [0.0, 0.16, 0.45, 0.86, 1.0],
  );

  Paint get _outline => Paint()
    ..isAntiAlias = true
    ..style = PaintingStyle.stroke
    ..strokeWidth = 1.1
    ..color = _edge;

  Paint _softShadow(double sigma, double opacity) => Paint()
    ..isAntiAlias = true
    ..color = Color.fromRGBO(0, 0, 0, opacity)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

  void _bolts(Canvas canvas, Offset centre, double radius, double boltR, int count, {double startAngle = 0}) {
    final Paint head = Paint()..isAntiAlias = true;
    for (int i = 0; i < count; i++) {
      final double a = startAngle + i * 2 * math.pi / count;
      final Offset p = centre + Offset(math.cos(a) * radius, math.sin(a) * radius);
      final Rect r = Rect.fromCircle(center: p, radius: boltR);
      canvas.drawCircle(p + Offset(0, boltR * 0.35), boltR, Paint()..color = const Color(0x55000000));
      head.shader = LinearGradient(
        colors: const [_steelLight, _steelMid, _steelDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(r);
      canvas.drawCircle(p, boltR, head);
      canvas.drawCircle(p, boltR * 0.45, Paint()..color = const Color(0xFF39434A));
    }
  }

  // ------------------------------------------------------------------ parts

  /// A soft, slowly "breathing" halo behind the whole unit while it runs.
  /// This is the single biggest lever for making the on-state noticeable —
  /// it changes brightness/size continuously instead of being a static glow.
  void _ambientHalo(Canvas canvas, double w, double h) {
    final double breathe = 0.55 + 0.45 * (0.5 + 0.5 * math.sin(phase));
    final Offset c = Offset(w * 0.55, h * 0.5);
    canvas.drawCircle(
      c,
      w * (0.46 + 0.04 * breathe),
      Paint()
        ..color = _accentGlowSoft.withOpacity(0.28 * breathe)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, w * 0.09),
    );
  }

  void _groundShadow(Canvas canvas, double w, double h) {
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.965), width: w * 0.92, height: h * 0.075),
      _softShadow(h * 0.022, 0.30),
    );
    canvas.drawOval(
      Rect.fromCenter(center: Offset(w * 0.50, h * 0.955), width: w * 0.66, height: h * 0.035),
      _softShadow(h * 0.010, 0.35),
    );
  }

  void _basePlate(Canvas canvas, double w, double h) {
    final Rect top = Rect.fromLTRB(w * 0.08, h * 0.885, w * 0.92, h * 0.915);
    final Rect front = Rect.fromLTRB(w * 0.08, h * 0.915, w * 0.92, h * 0.945);

    canvas.drawRect(top, _fill(top, const [_steelLight, _steelMid]));
    canvas.drawRect(front, _fill(front, const [_steelDark, Color(0xFF2B3337)]));
    canvas.drawRect(Rect.fromLTRB(w * 0.08, h * 0.885, w * 0.92, h * 0.945), _outline);

    // Slotted hold-down holes.
    final Paint hole = Paint()..color = const Color(0xFF1B2226);
    for (final double x in const [0.13, 0.85]) {
      final RRect slot = RRect.fromRectAndRadius(
        Rect.fromLTRB(w * x, h * 0.893, w * (x + 0.045), h * 0.907),
        Radius.circular(h * 0.007),
      );
      canvas.drawRRect(slot, hole);
      canvas.drawRRect(slot.shift(Offset(0, -h * 0.002)), Paint()..color = const Color(0x33FFFFFF)..style = PaintingStyle.stroke..strokeWidth = 0.8);
    }
  }

  void _feet(Canvas canvas, double w, double h) {
    for (final List<double> f in const [
      [0.19, 0.36, 0.755],
      [0.62, 0.80, 0.735],
    ]) {
      final Path foot = Path()
        ..moveTo(w * f[0], h * 0.885)
        ..lineTo(w * (f[0] + 0.035), h * f[2])
        ..lineTo(w * (f[1] - 0.035), h * f[2])
        ..lineTo(w * f[1], h * 0.885)
        ..close();
      final Rect b = foot.getBounds();
      canvas.drawPath(foot, _fill(b, [_castMid, _castDeep]));
      canvas.drawPath(foot, _outline);
      // left rim light
      canvas.drawLine(
        Offset(w * f[0] + 1.5, h * 0.885),
        Offset(w * (f[0] + 0.035) + 1.5, h * f[2]),
        Paint()..color = Color.fromRGBO(255, 255, 255, 0.18)..strokeWidth = 1.6,
      );
    }
  }

  void _motorBarrel(Canvas canvas, double w, double h) {
    final Rect barrel = Rect.fromLTRB(w * 0.46, h * 0.30, w * 0.845, h * 0.755);
    final RRect body = RRect.fromRectAndRadius(barrel, Radius.circular(h * 0.045));

    canvas.drawRRect(body.shift(Offset(0, h * 0.012)), _softShadow(h * 0.012, 0.28));
    canvas.drawRRect(body, _cylinder(barrel));

    // Cooling fins: each fin gets its own vertical shading so the ribs read as
    // raised metal rather than flat stripes.
    canvas.save();
    canvas.clipRRect(body);
    const int finCount = 9;
    final double span = barrel.height * 0.86;
    final double step = span / finCount;
    for (int i = 0; i < finCount; i++) {
      final double y = barrel.top + barrel.height * 0.07 + i * step;
      final Rect fin = Rect.fromLTRB(barrel.left + 1, y, barrel.right - 1, y + step * 0.52);
      canvas.drawRect(fin, Paint()..shader = LinearGradient(
        colors: [
          Color.fromRGBO(255, 255, 255, 0.16),
          Color.fromRGBO(0, 0, 0, 0.30),
        ],
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
      ).createShader(fin));
      canvas.drawLine(Offset(fin.left, fin.top), Offset(fin.right, fin.top),
          Paint()..color = Color.fromRGBO(255, 255, 255, 0.22)..strokeWidth = 0.9);
    }
    // Long specular streak down the top of the barrel.
    final Rect glare = Rect.fromLTRB(barrel.left + 4, barrel.top + barrel.height * 0.08, barrel.right - 4, barrel.top + barrel.height * 0.22);
    canvas.drawRRect(
      RRect.fromRectAndRadius(glare, Radius.circular(h * 0.02)),
      Paint()
        ..shader = LinearGradient(
          colors: [Color.fromRGBO(255, 255, 255, 0.34), Color.fromRGBO(255, 255, 255, 0.0)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ).createShader(glare)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.006),
    );
    canvas.restore();
    canvas.drawRRect(body, _outline);

    _nameplate(canvas, w, h);
  }

  void _nameplate(Canvas canvas, double w, double h) {
    final Rect plate = Rect.fromLTRB(w * 0.545, h * 0.475, w * 0.755, h * 0.585);
    canvas.drawRRect(
      RRect.fromRectAndRadius(plate, Radius.circular(h * 0.008)),
      _fill(plate, const [_steelLight, _steelMid, _steelDark], stops: const [0, 0.55, 1]),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(plate, Radius.circular(h * 0.008)),
      Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9..color = const Color(0xFF39434A),
    );
    _bolts(canvas, plate.center, plate.width * 0.44, h * 0.007, 4, startAngle: math.pi / 4);

    // Etched data lines.
    final Paint etch = Paint()..color = const Color(0xFF4A5459)..strokeWidth = 1.0;
    for (int i = 0; i < 3; i++) {
      final double y = plate.top + plate.height * (0.30 + i * 0.22);
      canvas.drawLine(Offset(plate.left + plate.width * 0.14, y),
          Offset(plate.right - plate.width * (i == 2 ? 0.34 : 0.14), y), etch);
    }
  }

  void _fanCowl(Canvas canvas, double w, double h) {
    final Offset c = Offset(w * 0.875, h * 0.5275);
    final double r = h * 0.215;

    // Cowl shell (ring), then the fan seen through its opening.
    final Rect cr = Rect.fromCircle(center: c, radius: r);
    canvas.drawCircle(c + Offset(h * 0.010, h * 0.012), r, _softShadow(h * 0.012, 0.26));
    canvas.drawCircle(
      c,
      r,
      Paint()
        ..isAntiAlias = true
        ..shader = RadialGradient(
          center: const Alignment(-0.45, -0.55),
          radius: 1.05,
          colors: [_castLight, _castMid, _castDeep],
          stops: const [0.0, 0.55, 1.0],
        ).createShader(cr),
    );

    // Recessed opening — kept dark so the pale blades pop against it.
    canvas.drawCircle(c, r * 0.78, Paint()..color = const Color(0xFF060A08));

    // Blades turning inside it.
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: c, radius: r * 0.78)));
    // Faint hub disc behind the blades so the centre doesn't look empty.
    canvas.drawCircle(c, r * 0.16, Paint()..color = const Color(0xFF3A443C));
    canvas.translate(c.dx, c.dy);
    canvas.rotate(phase);
    for (int i = 0; i < 7; i++) {
      canvas.rotate(2 * math.pi / 7);
      final Path p = Path()
        ..moveTo(r * 0.12, -r * 0.03)
        ..quadraticBezierTo(r * 0.42, -r * 0.34, r * 0.76, -r * 0.10)
        ..quadraticBezierTo(r * 0.48, r * 0.02, r * 0.12, r * 0.10)
        ..close();
      final Rect bb = p.getBounds();
      canvas.drawPath(
        p,
        Paint()
          ..shader = LinearGradient(
            colors: const [Color(0xFFF1F5EF), Color(0xFFCDD8C8), Color(0xFF8FA089)],
            stops: const [0.0, 0.55, 1.0],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ).createShader(bb),
      );
      canvas.drawPath(
        p,
        Paint()
          ..style = PaintingStyle.stroke
          ..strokeWidth = r * 0.012
          ..color = const Color(0xFF4A564C),
      );
    }
    canvas.restore();
    // Directional shading so the whole blade pack reads as a shallow cone.
    canvas.drawCircle(
      c,
      r * 0.78,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.4, -0.5),
          radius: 1.1,
          colors: [Color.fromRGBO(0, 0, 0, 0), Color.fromRGBO(0, 0, 0, 0.35)],
          stops: const [0.55, 1.0],
        ).createShader(Rect.fromCircle(center: c, radius: r * 0.78)),
    );

    // Grille bars across the opening.
    final Paint bar = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.007
      ..strokeCap = StrokeCap.round
      ..color = _castDark;
    for (int i = 0; i < 12; i++) {
      final double a = i * 2 * math.pi / 12;
      canvas.drawLine(
        c + Offset(math.cos(a), math.sin(a)) * (r * 0.16),
        c + Offset(math.cos(a), math.sin(a)) * (r * 0.78),
        bar,
      );
    }
    canvas.drawCircle(c, r * 0.78,
        Paint()..style = PaintingStyle.stroke..strokeWidth = h * 0.014..color = _castDeep);
    canvas.drawCircle(c, r * 0.22, Paint()..shader = LinearGradient(
      colors: const [_steelLight, _steelDark],
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
    ).createShader(Rect.fromCircle(center: c, radius: r * 0.22)));
    canvas.drawCircle(c, r, _outline);
    _bolts(canvas, c, r * 0.92, h * 0.011, 6, startAngle: math.pi / 6);
  }

  void _terminalBox(Canvas canvas, double w, double h) {
    final Rect box = Rect.fromLTRB(w * 0.505, h * 0.155, w * 0.775, h * 0.315);
    final RRect rr = RRect.fromRectAndRadius(box, Radius.circular(h * 0.014));
    canvas.drawRRect(rr.shift(Offset(0, h * 0.008)), _softShadow(h * 0.009, 0.30));
    canvas.drawRRect(rr, _fill(box, const [Color(0xFF55606B), Color(0xFF2C3238), Color(0xFF161A1E)], stops: const [0, 0.42, 1]));
    canvas.drawRRect(rr, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = const Color(0xFF0D1114));

    // Lid seam + corner screws.
    canvas.drawLine(Offset(box.left + 2, box.top + box.height * 0.34),
        Offset(box.right - 2, box.top + box.height * 0.34),
        Paint()..color = const Color(0x66000000)..strokeWidth = 1.2);
    _bolts(canvas, box.center, box.width * 0.40, h * 0.008, 4, startAngle: math.pi / 4);

    // Cable gland on the right shoulder.
    final Rect gland = Rect.fromLTRB(w * 0.775, h * 0.195, w * 0.815, h * 0.225);
    canvas.drawRect(gland, _fill(gland, const [_steelLight, _steelMid, _steelDark]));
    canvas.drawRect(gland, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9..color = const Color(0xFF39434A));
    final Path cable = Path()
      ..moveTo(w * 0.815, h * 0.210)
      ..cubicTo(w * 0.90, h * 0.205, w * 0.96, h * 0.245, w * 0.985, h * 0.315);
    canvas.drawPath(cable, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = h * 0.018
      ..strokeCap = StrokeCap.round
      ..color = const Color(0xFF14181B));

    // Status lamp — now with a much bigger, pulsing halo so the running
    // state is unmistakable even at a glance or in a small thumbnail.
    final Offset lamp = Offset(w * 0.545, h * 0.196);
    final double lr = h * 0.018;
    if (isOn) {
      final double pulse = 0.6 + 0.4 * (0.5 + 0.5 * math.sin(phase * 2));
      canvas.drawCircle(lamp, lr * (4.5 + 1.5 * pulse), _softShadowColour(_accentGlow, 0.20 * pulse, h * 0.02));
      canvas.drawCircle(lamp, lr * (2.6 + 0.6 * pulse), _softShadowColour(_accentGlow, 0.45 * pulse, h * 0.012));
    }
    canvas.drawCircle(lamp, lr, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.4),
        colors: isOn
            ? const [Color(0xFFEBFFF1), Color(0xFF35FF7F), Color(0xFF0B7A34)]
            : const [Color(0xFF6E7A70), Color(0xFF3A423C), Color(0xFF1B211D)],
      ).createShader(Rect.fromCircle(center: lamp, radius: lr)));
    canvas.drawCircle(lamp, lr, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9..color = const Color(0xFF0D1114));
  }

  Paint _softShadowColour(Color c, double opacity, double sigma) => Paint()
    ..color = Color.fromRGBO(c.red, c.green, c.blue, opacity)
    ..maskFilter = MaskFilter.blur(BlurStyle.normal, sigma);

  void _coupling(Canvas canvas, double w, double h) {
    final Rect neck = Rect.fromLTRB(w * 0.395, h * 0.435, w * 0.475, h * 0.615);
    canvas.drawRect(neck, _fill(neck, [_castLight, _castMid, _castDeep], stops: const [0, 0.35, 1]));
    canvas.drawRect(neck, _outline);

    // Exposed shaft, turning with the fan.
    final Rect shaft = Rect.fromLTRB(w * 0.415, h * 0.487, w * 0.455, h * 0.563);
    canvas.drawRect(shaft, _fill(shaft, const [_steelLight, _steelMid, _steelDark], stops: const [0, 0.4, 1]));
    final double keyY = shaft.top + shaft.height * (0.5 + 0.34 * math.sin(phase));
    canvas.drawLine(Offset(shaft.left, keyY), Offset(shaft.right, keyY),
        Paint()..color = const Color(0x99323A3F)..strokeWidth = 1.4);
  }

  void _volute(Canvas canvas, double w, double h) {
    final Offset c = Offset(w * 0.265, h * 0.525);
    final double r = h * 0.235;
    final Rect vr = Rect.fromCircle(center: c, radius: r);

    canvas.drawCircle(c + Offset(h * 0.012, h * 0.016), r, _softShadow(h * 0.014, 0.30));

    // Spiral casing body — radial light makes it read as a round casting.
    canvas.drawCircle(c, r, Paint()
      ..isAntiAlias = true
      ..shader = RadialGradient(
        center: const Alignment(-0.5, -0.6),
        radius: 1.1,
        colors: [_castLight, _castMid, _castDark, _castDeep],
        stops: const [0.0, 0.42, 0.78, 1.0],
      ).createShader(vr));

    // Raised front boss + bolt circle.
    canvas.drawCircle(c, r * 0.70, Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.4, -0.5),
        colors: [_castLight, _castMid, _castDark],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(Rect.fromCircle(center: c, radius: r * 0.70)));
    canvas.drawCircle(c, r * 0.70, Paint()..style = PaintingStyle.stroke..strokeWidth = 1.0..color = _edge);
    _bolts(canvas, c, r * 0.85, h * 0.013, 8, startAngle: math.pi / 8);

    // Centre hub cap.
    canvas.drawCircle(c, r * 0.20, Paint()
      ..shader = LinearGradient(
        colors: const [_steelLight, _steelMid, _steelDark],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromCircle(center: c, radius: r * 0.20)));
    canvas.drawCircle(c, r * 0.20, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9..color = _edge);

    // Crescent highlight along the upper-left rim.
    canvas.drawArc(
      Rect.fromCircle(center: c, radius: r * 0.93),
      math.pi * 1.05,
      math.pi * 0.55,
      false,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.012
        ..strokeCap = StrokeCap.round
        ..color = Color.fromRGBO(255, 255, 255, 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.006),
    );
    canvas.drawCircle(c, r, _outline);

    // Drain plug at the bottom of the casing.
    final Offset plug = c + Offset(0, r * 0.88);
    canvas.drawCircle(plug, h * 0.018, Paint()
      ..shader = LinearGradient(colors: const [_steelMid, _steelDark], begin: Alignment.topCenter, end: Alignment.bottomCenter)
          .createShader(Rect.fromCircle(center: plug, radius: h * 0.018)));
    canvas.drawCircle(plug, h * 0.018, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.8..color = _edge);
  }

  /// Bright, saturated pipework shared by suction and discharge — bumped
  /// from a muted blue to an electric cyan so the plumbing reads instantly.
  Paint _pipe(Rect r, {bool horizontal = false}) => _fill(
    r,
    const [Color(0xFF0D5C8C), Color(0xFF5CDBFF), Color(0xFF00A3E0), Color(0xFF014870)],
    stops: const [0.0, 0.22, 0.62, 1.0],
    begin: horizontal ? Alignment.topCenter : Alignment.centerLeft,
    end: horizontal ? Alignment.bottomCenter : Alignment.centerRight,
  );

  void _flange(Canvas canvas, Rect r, double h, {required bool horizontalPipe}) {
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, Radius.circular(h * 0.008)),
      _fill(r, [_castLight, _castMid, _castDeep],
          stops: const [0, 0.35, 1],
          begin: horizontalPipe ? Alignment.topCenter : Alignment.centerLeft,
          end: horizontalPipe ? Alignment.bottomCenter : Alignment.centerRight),
    );
    canvas.drawRRect(RRect.fromRectAndRadius(r, Radius.circular(h * 0.008)), _outline);
  }

  void _suction(Canvas canvas, double w, double h) {
    final Rect pipe = Rect.fromLTRB(0, h * 0.468, w * 0.075, h * 0.582);
    canvas.drawRect(pipe, _pipe(pipe, horizontal: true));
    canvas.drawRect(pipe, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9..color = const Color(0xFF01395E));

    final Rect fl = Rect.fromLTRB(w * 0.075, h * 0.440, w * 0.125, h * 0.610);
    _flange(canvas, fl, h, horizontalPipe: true);
    _bolts(canvas, fl.center, fl.height * 0.36, h * 0.010, 4, startAngle: math.pi / 4);

    final Rect throat = Rect.fromLTRB(w * 0.125, h * 0.462, w * 0.20, h * 0.588);
    canvas.drawRect(throat, _fill(throat, [_castLight, _castMid, _castDeep], stops: const [0, 0.3, 1]));
    canvas.drawRect(throat, _outline);
  }

  void _discharge(Canvas canvas, double w, double h) {
    // Neck rising out of the volute.
    final Rect neck = Rect.fromLTRB(w * 0.185, h * 0.130, w * 0.325, h * 0.330);
    canvas.drawRect(neck, _fill(neck, [_castLight, _castMid, _castDark, _castDeep],
        stops: const [0, 0.24, 0.80, 1], begin: Alignment.centerLeft, end: Alignment.centerRight));
    canvas.drawRect(neck, _outline);

    // Flange.
    final Rect fl = Rect.fromLTRB(w * 0.160, h * 0.095, w * 0.350, h * 0.135);
    _flange(canvas, fl, h, horizontalPipe: false);
    _bolts(canvas, fl.center, fl.width * 0.36, h * 0.010, 4, startAngle: math.pi / 4);

    // Blue riser.
    final Rect riser = Rect.fromLTRB(w * 0.198, h * 0.030, w * 0.312, h * 0.098);
    canvas.drawRect(riser, _pipe(riser));
    canvas.drawRect(riser, Paint()..style = PaintingStyle.stroke..strokeWidth = 0.9..color = const Color(0xFF01395E));
  }

  /// Outline glow hugging the motor — stronger and warmer-colored than the
  /// original so it's obviously "lit up" rather than a faint tint.
  void _runningGlow(Canvas canvas, double w, double h) {
    final double pulse = 0.7 + 0.3 * (0.5 + 0.5 * math.sin(phase));
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromLTRB(w * 0.44, h * 0.28, w * 0.86, h * 0.77),
        Radius.circular(h * 0.05),
      ),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = h * 0.028
        ..color = _accentGlow.withOpacity(0.35 * pulse)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.03),
    );
  }

  /// Small bright dots animated along the suction/discharge pipes, giving a
  /// clear "liquid is flowing" cue that draws the eye — the biggest visual
  /// difference between a static illustration and one that feels alive.
  void _flowDots(Canvas canvas, double w, double h) {
    final Paint dot = Paint()..color = Colors.white.withOpacity(0.9);
    final Paint dotGlow = Paint()
      ..color = Colors.white.withOpacity(0.5)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, h * 0.01);

    // Discharge riser: dots travel upward.
    for (int i = 0; i < 3; i++) {
      final double t = ((phase / (2 * math.pi)) + i / 3) % 1.0;
      final double y = h * 0.098 - t * (h * 0.068);
      final Offset p = Offset(w * 0.255, y);
      canvas.drawCircle(p, h * 0.010, dotGlow);
      canvas.drawCircle(p, h * 0.006, dot);
    }

    // Suction pipe: dots travel rightward, toward the volute.
    for (int i = 0; i < 3; i++) {
      final double t = ((phase / (2 * math.pi)) + i / 3) % 1.0;
      final double x = t * (w * 0.075);
      final Offset p = Offset(x, h * 0.525);
      canvas.drawCircle(p, h * 0.010, dotGlow);
      canvas.drawCircle(p, h * 0.006, dot);
    }
  }

  @override
  bool shouldRepaint(covariant DetailedPumpPainter old) => old.isOn != isOn || old.phase != phase;
}

/// Drop-in widget: keeps the fan spinning (and the glow breathing/flow dots
/// moving) while the pump is running. Also gives the whole unit a small
/// "pop" scale animation when it switches on, which is a cheap but very
/// effective way to draw the user's attention to the state change.
class PumpView extends StatefulWidget {
  final bool isOn;
  final Size size;

  const PumpView({super.key, required this.isOn, this.size = const Size(280, 220)});

  @override
  State<PumpView> createState() => _PumpViewState();
}

class _PumpViewState extends State<PumpView> with SingleTickerProviderStateMixin {
  late final AnimationController _c =
  AnimationController(vsync: this, duration: const Duration(milliseconds: 900));

  @override
  void initState() {
    super.initState();
    if (widget.isOn) _c.repeat();
  }

  @override
  void didUpdateWidget(covariant PumpView old) {
    super.didUpdateWidget(old);
    widget.isOn ? _c.repeat() : _c.stop();
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      key: ValueKey(widget.isOn),
      tween: Tween(begin: widget.isOn ? 0.94 : 1.0, end: 1.0),
      duration: const Duration(milliseconds: 260),
      curve: Curves.easeOutBack,
      builder: (context, scale, child) => Transform.scale(scale: scale, child: child),
      child: AnimatedBuilder(
        animation: _c,
        builder: (_, __) => CustomPaint(
          size: widget.size,
          painter: DetailedPumpPainter(isOn: widget.isOn, phase: _c.value * 2 * math.pi),
        ),
      ),
    );
  }
}