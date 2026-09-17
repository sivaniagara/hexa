import 'dart:math';
import 'package:flutter/material.dart';
import 'models.dart';

class PipePainter extends CustomPainter {
  final List<PumpNode> nodes;
  final List<PipeConnection> pipes;
  final String? selectedPipeId;
  final String? pendingConnectFromId;
  final Offset? pendingDragPos;
  final bool pendingIsInput;

  PipePainter({
    required this.nodes,
    required this.pipes,
    this.selectedPipeId,
    this.pendingConnectFromId,
    this.pendingDragPos,
    this.pendingIsInput = false,
  });

  PumpNode? _findNode(String id) {
    for (final n in nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  @override
  void paint(Canvas canvas, Size size) {
    for (final pipe in pipes) {
      final from = _findNode(pipe.fromNodeId);
      final to = _findNode(pipe.toNodeId);
      if (from == null || to == null) continue;

      final points = <Offset>[from.outputPort, ...pipe.waypoints, to.inputPort];
      final isSelected = pipe.id == selectedPipeId;

      final path = Path()..moveTo(points.first.dx, points.first.dy);
      for (final p in points.skip(1)) {
        path.lineTo(p.dx, p.dy);
      }

      // Outer pipe casing
      canvas.drawPath(
        path,
        Paint()
          ..color = isSelected ? const Color(0xFFFF9800) : const Color(0xFF78909C)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 12 : 10
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      // Inner water/flow colour
      canvas.drawPath(
        path,
        Paint()
          ..color = pipe.flowActive
              ? const Color(0xFF64B5F6)
              : const Color(0xFFCFD8DC)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 6 : 5
          ..strokeCap = StrokeCap.round
          ..strokeJoin = StrokeJoin.round,
      );

      if (pipe.flowActive) {
        _drawArrowsAlong(canvas, points);
      }
    }

    // Rubber-band preview line while user is picking the target node in connect mode.
    if (pendingConnectFromId != null) {
      final from = _findNode(pendingConnectFromId!);
      if (from != null) {
        final dashPaint = Paint()
          ..color = Colors.orange
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3;
        final startPos = pendingIsInput ? from.inputPort : from.outputPort;
        canvas.drawCircle(startPos, 6, dashPaint);
        if (pendingDragPos != null) {
          canvas.drawLine(startPos, pendingDragPos!, dashPaint);
        }
      }
    }
  }

  void _drawArrowsAlong(Canvas canvas, List<Offset> points) {
    final paint = Paint()..color = const Color(0xFF1565C0);
    for (int i = 0; i < points.length - 1; i++) {
      final a = points[i];
      final b = points[i + 1];
      final segLen = (b - a).distance;
      if (segLen < 24) continue; // skip tiny segments
      final mid = Offset((a.dx + b.dx) / 2, (a.dy + b.dy) / 2);
      final angle = atan2(b.dy - a.dy, b.dx - a.dx);
      _arrowHead(canvas, mid, angle, paint);
    }
  }

  void _arrowHead(Canvas canvas, Offset tip, double angle, Paint paint) {
    canvas.save();
    canvas.translate(tip.dx, tip.dy);
    canvas.rotate(angle);
    final tri = Path()
      ..moveTo(7, 0)
      ..lineTo(-5, -5)
      ..lineTo(-5, 5)
      ..close();
    canvas.drawPath(tri, paint);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant PipePainter oldDelegate) => true;
}

/// Shortest distance from [p] to the segment [a]-[b], used for pipe hit
/// testing (tap-to-select) and for locating where to insert a new bend point.
double distanceToSegment(Offset p, Offset a, Offset b) {
  final ab = b - a;
  final abLenSq = ab.dx * ab.dx + ab.dy * ab.dy;
  if (abLenSq == 0) return (p - a).distance;
  double t = ((p.dx - a.dx) * ab.dx + (p.dy - a.dy) * ab.dy) / abLenSq;
  t = t.clamp(0.0, 1.0);
  final proj = Offset(a.dx + ab.dx * t, a.dy + ab.dy * t);
  return (p - proj).distance;
}