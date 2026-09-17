import 'package:flutter/material.dart';

/// Type of equipment a node represents on the canvas.
/// [junction] is a small pass-through point created when a new pipe is
/// branched off an *existing* pipe (a "T" joint) rather than off a node.
enum NodeType { source, pump, tank, sump, distribution, junction }

/// A draggable piece of equipment on the canvas (pump, tank, source, etc).
class PumpNode {
  String id;
  Offset position; // top-left corner in canvas coordinates
  Size size;
  NodeType type;
  String label;
  bool isOn; // relevant for pumps (running / stopped)

  PumpNode({
    required this.id,
    required this.position,
    this.size = const Size(96, 74),
    required this.type,
    required this.label,
    this.isOn = true,
  });

  /// Connection point where pipes coming INTO this node should attach.
  Offset get inputPort {
    if (type == NodeType.junction) return center;
    if (type == NodeType.pump) {
      return Offset(position.dx, position.dy + size.height * 0.525);
    }
    return Offset(position.dx, position.dy + size.height / 2);
  }

  /// Connection point where pipes going OUT of this node should attach.
  Offset get outputPort {
    if (type == NodeType.junction) return center;
    if (type == NodeType.pump) {
      return Offset(position.dx + size.width * 0.255, position.dy + size.height * 0.030);
    }
    return Offset(position.dx + size.width, position.dy + size.height / 2);
  }

  Offset get center =>
      Offset(position.dx + size.width / 2, position.dy + size.height / 2);

  Map<String, dynamic> toJson() => {
        'id': id,
        'dx': position.dx,
        'dy': position.dy,
        'w': size.width,
        'h': size.height,
        'type': type.name,
        'label': label,
        'isOn': isOn,
      };

  factory PumpNode.fromJson(Map<String, dynamic> j) => PumpNode(
        id: j['id'] as String,
        position: Offset((j['dx'] as num).toDouble(), (j['dy'] as num).toDouble()),
        size: Size((j['w'] as num?)?.toDouble() ?? 96, (j['h'] as num?)?.toDouble() ?? 74),
        type: NodeType.values.byName(j['type'] as String),
        label: j['label'] as String,
        isOn: j['isOn'] as bool? ?? true,
      );
}

/// A pipe joining two nodes. [waypoints] are the user-created bend points
/// between the start node's output port and the end node's input port -
/// dragging them bends the pipe, adding/removing them changes its shape
/// and effective length.
class PipeConnection {
  String id;
  String fromNodeId;
  String toNodeId;
  List<Offset> waypoints;
  bool flowActive;

  PipeConnection({
    required this.id,
    required this.fromNodeId,
    required this.toNodeId,
    List<Offset>? waypoints,
    this.flowActive = true,
  }) : waypoints = waypoints ?? <Offset>[];

  Map<String, dynamic> toJson() => {
        'id': id,
        'from': fromNodeId,
        'to': toNodeId,
        'flowActive': flowActive,
        'waypoints':
            waypoints.map((w) => {'dx': w.dx, 'dy': w.dy}).toList(growable: false),
      };

  factory PipeConnection.fromJson(Map<String, dynamic> j) => PipeConnection(
        id: j['id'] as String,
        fromNodeId: j['from'] as String,
        toNodeId: j['to'] as String,
        flowActive: j['flowActive'] as bool? ?? true,
        waypoints: (j['waypoints'] as List)
            .map((w) => Offset(
                ((w as Map)['dx'] as num).toDouble(), (w['dy'] as num).toDouble()))
            .toList(),
      );
}
