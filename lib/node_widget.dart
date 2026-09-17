import 'package:flutter/material.dart';
import 'models.dart';
import 'pump_painter.dart';
import 'sump_painter.dart';
import 'well_painter.dart';
import 'over_head_tank_painter.dart';
import 'natural_source_painter.dart';

class NodeWidget extends StatelessWidget {
  final PumpNode node;
  final bool isSelected;
  final bool isConnectSource;
  final VoidCallback onTap;
  final VoidCallback onLongPress;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragStartDetails)? onPanStart;

  const NodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    required this.onLongPress,
    required this.onPanUpdate,
    this.onPanStart,
    this.isSelected = false,
    this.isConnectSource = false,
  });

  IconData get _icon {
    switch (node.type) {
      case NodeType.pump:
        return Icons.settings_input_component;
      case NodeType.source:
      case NodeType.naturalSource:
      case NodeType.well:
        return Icons.water;
      case NodeType.tank:
      case NodeType.overheadTank:
        return Icons.propane_tank_outlined;
      case NodeType.sump:
        return Icons.inbox;
      case NodeType.distribution:
        return Icons.call_split;
      case NodeType.junction:
        return Icons.circle;
    }
  }

  Color get _iconColor {
    switch (node.type) {
      case NodeType.pump:
        return node.isOn ? const Color(0xFF1565C0) : Colors.grey;
      case NodeType.source:
      case NodeType.naturalSource:
      case NodeType.well:
        return const Color(0xFF00897B);
      case NodeType.tank:
      case NodeType.overheadTank:
        return const Color(0xFF3949AB);
      case NodeType.sump:
        return const Color(0xFF6D4C41);
      case NodeType.distribution:
        return const Color(0xFF6A1B9A);
      case NodeType.junction:
        return const Color(0xFF455A64);
    }
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = isConnectSource
        ? Colors.orange
        : (isSelected ? Colors.blue : Colors.grey.shade400);

    if (node.type == NodeType.junction) {
      if (!node.showJoints) return const SizedBox.shrink();
      
      // Small pass-through dot representing a pipe-to-pipe (T) joint —
      // no icon/label, just a draggable, tappable marker.
      return Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: node.size.width,
            height: node.size.height,
            decoration: BoxDecoration(
              color: const Color(0xFF37474F),
              shape: BoxShape.circle,
              border: Border.all(
                color: isConnectSource
                    ? Colors.orange
                    : (isSelected ? Colors.blue : Colors.white),
                width: isSelected || isConnectSource ? 3 : 2,
              ),
              boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3)],
            ),
          ),
        ),
      );
    }

    if (node.type == NodeType.pump) {
      return Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: node.size.width,
            height: node.size.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected || isConnectSource
                  ? Border.all(
                      color: isConnectSource ? Colors.orange : Colors.blue,
                      width: 2,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: CustomPaint(
              painter: DetailedPumpPainter(
                isOn: node.isOn,
                showJoints: node.showJoints,
              ),
            ),
          ),
        ),
      );
    }

    if (node.type == NodeType.sump) {
      return Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: node.size.width,
            height: node.size.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected || isConnectSource
                  ? Border.all(
                      color: isConnectSource ? Colors.orange : Colors.blue,
                      width: 2,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: SumpView(
              isOn: node.isOn,
              showJoints: node.showJoints,
              size: node.size,
            ),
          ),
        ),
      );
    }

    if (node.type == NodeType.well) {
      return Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: node.size.width,
            height: node.size.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected || isConnectSource
                  ? Border.all(
                      color: isConnectSource ? Colors.orange : Colors.blue,
                      width: 2,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: WellView(
              isOn: node.isOn,
              showJoints: node.showJoints,
              size: node.size,
            ),
          ),
        ),
      );
    }

    if (node.type == NodeType.overheadTank) {
      return Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: node.size.width,
            height: node.size.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected || isConnectSource
                  ? Border.all(
                      color: isConnectSource ? Colors.orange : Colors.blue,
                      width: 2,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: OverheadTankView(
              isOn: node.isOn,
              showJoints: node.showJoints,
              size: node.size,
            ),
          ),
        ),
      );
    }

    if (node.type == NodeType.naturalSource) {
      return Positioned(
        left: node.position.dx,
        top: node.position.dy,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: onTap,
          onLongPress: onLongPress,
          onPanStart: onPanStart,
          onPanUpdate: onPanUpdate,
          child: Container(
            width: node.size.width,
            height: node.size.height,
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: isSelected || isConnectSource
                  ? Border.all(
                      color: isConnectSource ? Colors.orange : Colors.blue,
                      width: 2,
                    )
                  : null,
            ),
            padding: const EdgeInsets.all(4),
            child: NaturalSourceView(
              isOn: node.isOn,
              showJoints: node.showJoints,
              size: node.size,
            ),
          ),
        ),
      );
    }

    return Positioned(
      left: node.position.dx,
      top: node.position.dy,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onTap,
        onLongPress: onLongPress,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        child: Container(
          width: node.size.width,
          height: node.size.height,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: borderColor,
              width: isSelected || isConnectSource ? 3 : 1.5,
            ),
            boxShadow: const [
              BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(_icon, color: _iconColor, size: 26),
              const SizedBox(height: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Text(
                  node.label,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 10.5, fontWeight: FontWeight.w700),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Small draggable circular handle placed on a pipe bend point (waypoint)
/// or, in read-only style, on a port. Dragging it reshapes the pipe;
/// long-pressing it removes that bend point.
class WaypointHandle extends StatelessWidget {
  final Offset position;
  final void Function(DragUpdateDetails) onPanUpdate;
  final void Function(DragStartDetails)? onPanStart;
  final void Function(DragEndDetails)? onPanEnd;
  final VoidCallback onLongPress;
  final Color color;

  const WaypointHandle({
    super.key,
    required this.position,
    required this.onPanUpdate,
    this.onPanStart,
    this.onPanEnd,
    required this.onLongPress,
    this.color = const Color(0xFFFF9800),
  });

  static const double diameter = 16;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: position.dx - diameter / 2,
      top: position.dy - diameter / 2,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onPanStart: onPanStart,
        onPanUpdate: onPanUpdate,
        onPanEnd: onPanEnd,
        onLongPress: onLongPress,
        child: Container(
          width: diameter,
          height: diameter,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: const [BoxShadow(color: Colors.black38, blurRadius: 3)],
          ),
        ),
      ),
    );
  }
}
