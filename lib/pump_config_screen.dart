import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'models.dart';
import 'node_widget.dart';
import 'pipe_painter.dart';

const double kCanvasWidth = 1900;
const double kCanvasHeight = 1150;
const double kPipeHitTolerance = 14;

class PumpConfigScreen extends StatefulWidget {
  const PumpConfigScreen({super.key});

  @override
  State<PumpConfigScreen> createState() => _PumpConfigScreenState();
}

class _PumpConfigScreenState extends State<PumpConfigScreen> {
  final List<PumpNode> _nodes = [];
  final List<PipeConnection> _pipes = [];

  String? _selectedNodeId;
  String? _selectedPipeId;
  bool _connectMode = false;
  String? _connectFromId;
  Offset? _pendingDragConnectionPos;
  bool _pendingDragIsInput = false;
  double _scale = 1.0;
  int _idCounter = 0;

  bool _isShiftPressed = false;

  final List<Map<String, dynamic>> _undoStack = [];
  final List<Map<String, dynamic>> _redoStack = [];

  Map<String, dynamic> _cloneState() {
    return {
      'nodes': _nodes.map((n) => n.toJson()).toList(),
      'pipes': _pipes.map((p) => p.toJson()).toList(),
      'idCounter': _idCounter,
    };
  }

  void _restoreState(Map<String, dynamic> state) {
    _nodes.clear();
    _pipes.clear();
    for (final n in state['nodes']) {
      _nodes.add(PumpNode.fromJson(n));
    }
    for (final p in state['pipes']) {
      _pipes.add(PipeConnection.fromJson(p));
    }
    _idCounter = state['idCounter'] as int;
    _selectedNodeId = null;
    _selectedPipeId = null;
    _connectFromId = null;
  }

  void _saveToHistory() {
    if (_undoStack.length >= 2) {
      _undoStack.removeAt(0);
    }
    _undoStack.add(_cloneState());
    _redoStack.clear();
  }

  void _undo() {
    if (_undoStack.isNotEmpty) {
      final currentState = _cloneState();
      final previousState = _undoStack.removeLast();
      setState(() {
        _restoreState(previousState);
        if (_redoStack.length >= 2) {
          _redoStack.removeAt(0);
        }
        _redoStack.add(currentState);
      });
    }
  }

  void _redo() {
    if (_redoStack.isNotEmpty) {
      final currentState = _cloneState();
      final nextState = _redoStack.removeLast();
      setState(() {
        _restoreState(nextState);
        if (_undoStack.length >= 2) {
          _undoStack.removeAt(0);
        }
        _undoStack.add(currentState);
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // Start with a fresh page without default layout
  }

  String _nextId(String prefix) => '${prefix}_${_idCounter++}';

  // ---------------------------------------------------------------------
  // Default starter layout (mirrors the multi-source / multi-pump diagram)
  // ---------------------------------------------------------------------
  void _loadDefaultLayout() {
    _nodes.clear();
    _pipes.clear();
    _idCounter = 0;

    PumpNode addNode(NodeType type, String label, double dx, double dy,
        {Size size = const Size(96, 74)}) {
      final n = PumpNode(
        id: _nextId(type.name),
        position: Offset(dx, dy),
        size: size,
        type: type,
        label: label,
      );
      _nodes.add(n);
      return n;
    }

    void connect(PumpNode from, PumpNode to, {List<Offset> bends = const []}) {
      _pipes.add(PipeConnection(
        id: _nextId('pipe'),
        fromNodeId: from.id,
        toNodeId: to.id,
        waypoints: List.of(bends),
      ));
    }

    final source1 = addNode(NodeType.source, 'Source 1\n(Borewell)', 40, 60);
    final source2 = addNode(NodeType.source, 'Source 2\n(Pond)', 40, 260);
    final source3 = addNode(NodeType.source, 'Source 3\n(U/G Tank)', 40, 460);

    final pumpS1A = addNode(NodeType.pump, 'Pump S1A', 230, 60);
    final pumpS2A = addNode(NodeType.pump, 'Pump S2A', 230, 260);
    final pumpS3A = addNode(NodeType.pump, 'Pump S3A', 230, 460);

    final overheadTank = addNode(
        NodeType.tank, 'Overhead Tank', 760, 40,
        size: const Size(120, 130));
    final intermediateTank = addNode(
        NodeType.tank, 'Intermediate Tank', 760, 330,
        size: const Size(120, 130));

    final pumpT1 = addNode(NodeType.pump, 'Transfer\nPump T1', 520, 340);
    final pumpT2 = addNode(NodeType.pump, 'Transfer\nPump T2', 520, 460);

    final dist1 = addNode(NodeType.distribution, 'Distribution\n(Irrigation)', 1080, 60);
    final dist2 = addNode(NodeType.distribution, 'Distribution\n(Users)', 1080, 340);

    final sump = addNode(NodeType.sump, 'Sump /\nCollection Tank', 40, 760);
    final pumpE1 = addNode(NodeType.pump, 'Extraction\nPump E1', 260, 720);
    final pumpE2 = addNode(NodeType.pump, 'Extraction\nPump E2', 260, 840);
    final otherTank = addNode(NodeType.source, 'Other Source\n/ Drain', 500, 780);

    connect(source1, pumpS1A);
    connect(pumpS1A, overheadTank);
    connect(source2, pumpS2A);
    connect(pumpS2A, overheadTank, bends: [const Offset(430, 297), const Offset(430, 105)]);
    connect(source3, pumpS3A);
    connect(pumpS3A, overheadTank, bends: [const Offset(470, 497), const Offset(470, 115)]);

    connect(overheadTank, pumpT1, bends: [const Offset(700, 377)]);
    connect(pumpT1, intermediateTank);
    connect(overheadTank, pumpT2, bends: [const Offset(690, 497)]);
    connect(pumpT2, intermediateTank);

    connect(overheadTank, dist1);
    connect(intermediateTank, dist2);

    connect(sump, pumpE1);
    connect(pumpE1, otherTank);
    connect(sump, pumpE2, bends: [const Offset(150, 877)]);
    connect(pumpE2, otherTank);
  }

  // ---------------------------------------------------------------------
  // Node operations
  // ---------------------------------------------------------------------
  void _addNode(NodeType type) {
    _saveToHistory();
    final rnd = Random();
    final id = _nextId(type.name);
    setState(() {
      _nodes.add(PumpNode(
        id: id,
        position: Offset(300 + rnd.nextInt(200).toDouble(), 550 + rnd.nextInt(150).toDouble()),
        type: type,
        label: _defaultLabelFor(type),
      ));
      _selectedNodeId = id;
      _selectedPipeId = null;
    });
  }

  String _defaultLabelFor(NodeType type) {
    switch (type) {
      case NodeType.pump:
        return 'New Pump';
      case NodeType.source:
        return 'New Source';
      case NodeType.tank:
        return 'New Tank';
      case NodeType.sump:
        return 'New Sump';
      case NodeType.distribution:
        return 'Distribution';
      case NodeType.junction:
        return '';
    }
  }

  void _onNodePanUpdate(PumpNode node, DragUpdateDetails details) {
    setState(() {
      final double dx = (node.position.dx + details.delta.dx / _scale)
          .clamp(0.0, kCanvasWidth - node.size.width)
          .toDouble();
      final double dy = (node.position.dy + details.delta.dy / _scale)
          .clamp(0.0, kCanvasHeight - node.size.height)
          .toDouble();
      node.position = Offset(dx, dy);
    });
  }

  void _onNodeTap(PumpNode node) {
    if (_connectMode) {
      _handleConnectPick(node.id);
      return;
    }
    setState(() {
      _selectedNodeId = node.id;
      _selectedPipeId = null;
    });
  }

  /// Common "connect mode" logic: the first tap (on a node OR on a pipe,
  /// which auto-creates a junction) sets the source endpoint; the second
  /// tap sets the target endpoint and draws the pipe between them. This is
  /// what lets a new pipe originate from, or land on, an existing pipe
  /// instead of only ever a pump/tank/source node.
  void _handleConnectPick(String endpointNodeId) {
    setState(() {
      if (_connectFromId == null) {
        _connectFromId = endpointNodeId;
      } else if (_connectFromId != endpointNodeId) {
        _saveToHistory();
        _pipes.add(PipeConnection(
          id: _nextId('pipe'),
          fromNodeId: _connectFromId!,
          toNodeId: endpointNodeId,
        ));
        _connectFromId = null;
        _connectMode = false; // Turn off connect mode after successful connection
      }
    });
  }

  void _onNodeLongPress(PumpNode node) {
    _showNodeEditor(node);
  }

  void _showNodeEditor(PumpNode node) {
    final controller = TextEditingController(text: node.label);
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text('Edit ${node.type.name}', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 12),
              TextField(
                controller: controller,
                decoration: const InputDecoration(labelText: 'Label', border: OutlineInputBorder()),
              ),
              if (node.type == NodeType.pump) ...[
                const SizedBox(height: 8),
                StatefulBuilder(
                  builder: (ctx, setSheetState) => SwitchListTile(
                    title: const Text('Pump running'),
                    value: node.isOn,
                    onChanged: (v) {
                      _saveToHistory();
                      setSheetState(() => node.isOn = v);
                      setState(() {});
                    },
                  ),
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      label: const Text('Delete', style: TextStyle(color: Colors.red)),
                      onPressed: () {
                        Navigator.pop(ctx);
                        _deleteNode(node.id);
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      onPressed: () {
                        _saveToHistory();
                        setState(() => node.label = controller.text);
                        Navigator.pop(ctx);
                      },
                      child: const Text('Save'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _deleteNode(String nodeId) {
    _saveToHistory();
    final node = _findNode(nodeId);

    // A junction with exactly two pipes attached is just a pass-through
    // point on what was originally one pipe — deleting it should reconnect
    // the two halves into a single pipe again, rather than breaking the run.
    if (node != null && node.type == NodeType.junction) {
      final attached = _pipes.where((p) => p.fromNodeId == nodeId || p.toNodeId == nodeId).toList();
      if (attached.length == 2) {
        PipeConnection? before, after;
        for (final p in attached) {
          if (p.toNodeId == nodeId) before = p;
          if (p.fromNodeId == nodeId) after = p;
        }
        if (before != null && after != null) {
          final merged = PipeConnection(
            id: _nextId('pipe'),
            fromNodeId: before.fromNodeId,
            toNodeId: after.toNodeId,
            waypoints: [...before.waypoints, ...after.waypoints],
            flowActive: before.flowActive,
          );
          setState(() {
            _pipes.removeWhere((p) => p.id == before!.id || p.id == after!.id);
            _pipes.add(merged);
            _nodes.removeWhere((n) => n.id == nodeId);
            if (_selectedNodeId == nodeId) _selectedNodeId = null;
          });
          return;
        }
      }
    }

    setState(() {
      _nodes.removeWhere((n) => n.id == nodeId);
      _pipes.removeWhere((p) => p.fromNodeId == nodeId || p.toNodeId == nodeId);
      if (_selectedNodeId == nodeId) _selectedNodeId = null;
    });
  }

  // ---------------------------------------------------------------------
  // Pipe operations
  // ---------------------------------------------------------------------
  PumpNode? _findNode(String id) {
    for (final n in _nodes) {
      if (n.id == id) return n;
    }
    return null;
  }

  void _onCanvasTapUp(TapUpDetails details) {
    final pos = details.localPosition;

    if (_connectMode) {
      // Tapping empty canvas near an existing pipe branches a new
      // junction off it, so a pipe can start/end on another pipe and not
      // only on a node.
      final hit = _locateNearestPipeSegment(pos, tolerance: kPipeHitTolerance + 4);
      if (hit != null) {
        final junctionId = _splitPipeAtPoint(hit.pipe, hit.segmentIndex, pos);
        _handleConnectPick(junctionId);
      }
      return;
    }

    final hit = _locateNearestPipeSegment(pos, tolerance: kPipeHitTolerance);
    setState(() {
      _selectedPipeId = hit?.pipe.id;
      _selectedNodeId = null;
    });
  }

  /// Finds the pipe segment nearest to [pos], if any is within [tolerance].
  /// Used for: selecting a pipe by tap, adding a bend point by double-tap,
  /// and branching a new pipe off an existing one in connect mode.
  _PipeHit? _locateNearestPipeSegment(Offset pos, {required double tolerance}) {
    PipeConnection? bestPipe;
    int bestSegment = -1;
    double bestDist = tolerance;

    for (final pipe in _pipes) {
      final from = _findNode(pipe.fromNodeId);
      final to = _findNode(pipe.toNodeId);
      if (from == null || to == null) continue;
      final points = <Offset>[from.outputPort, ...pipe.waypoints, to.inputPort];
      for (int i = 0; i < points.length - 1; i++) {
        final d = distanceToSegment(pos, points[i], points[i + 1]);
        if (d < bestDist) {
          bestDist = d;
          bestPipe = pipe;
          bestSegment = i;
        }
      }
    }

    if (bestPipe == null) return null;
    return _PipeHit(pipe: bestPipe, segmentIndex: bestSegment, distance: bestDist);
  }

  void _onCanvasDoubleTapDown(TapDownDetails details) {
    final pos = details.localPosition;
    final hit = _locateNearestPipeSegment(pos, tolerance: kPipeHitTolerance + 4);
    if (hit == null) return;
    _saveToHistory();
    final int clampedIndex = hit.segmentIndex.clamp(0, hit.pipe.waypoints.length).toInt();
    setState(() {
      hit.pipe.waypoints.insert(clampedIndex, pos);
      _selectedPipeId = hit.pipe.id;
    });
  }

  /// Splits [pipe] into two pipes joined by a new small junction node placed
  /// at [point] (which lies on the segment at [segmentIndex]). Returns the
  /// new junction's node id so it can immediately be used as a connect
  /// endpoint. This is how a new pipe gets to "join onto" an existing pipe
  /// rather than only onto a pump/tank/source node.
  String _splitPipeAtPoint(PipeConnection pipe, int segmentIndex, Offset point) {
    _saveToHistory();
    final junctionId = _nextId('junction');
    final junction = PumpNode(
      id: junctionId,
      position: point - const Offset(7, 7),
      size: const Size(14, 14),
      type: NodeType.junction,
      label: '',
    );

    final int splitAt = segmentIndex.clamp(0, pipe.waypoints.length).toInt();
    final beforeWaypoints = pipe.waypoints.sublist(0, splitAt);
    final afterWaypoints = pipe.waypoints.sublist(splitAt);

    final pipeBefore = PipeConnection(
      id: _nextId('pipe'),
      fromNodeId: pipe.fromNodeId,
      toNodeId: junctionId,
      waypoints: beforeWaypoints,
      flowActive: pipe.flowActive,
    );
    final pipeAfter = PipeConnection(
      id: _nextId('pipe'),
      fromNodeId: junctionId,
      toNodeId: pipe.toNodeId,
      waypoints: afterWaypoints,
      flowActive: pipe.flowActive,
    );

    setState(() {
      _nodes.add(junction);
      _pipes.remove(pipe);
      _pipes.addAll([pipeBefore, pipeAfter]);
    });

    return junctionId;
  }

  void _onWaypointPanUpdate(PipeConnection pipe, int index, DragUpdateDetails details) {
    setState(() {
      final current = pipe.waypoints[index];
      double nx = (current.dx + details.delta.dx / _scale).clamp(0.0, kCanvasWidth).toDouble();
      double ny = (current.dy + details.delta.dy / _scale).clamp(0.0, kCanvasHeight).toDouble();

      if (_isShiftPressed) {
        // Find reference points before and after this waypoint to align to
        final fromNode = _findNode(pipe.fromNodeId);
        final toNode = _findNode(pipe.toNodeId);
        if (fromNode != null && toNode != null) {
          final points = <Offset>[fromNode.outputPort, ...pipe.waypoints, toNode.inputPort];
          // index in pipe.waypoints corresponds to index + 1 in points
          final refIndex = index + 1;
          final prevPoint = points[refIndex - 1];
          final nextPoint = points[refIndex + 1];

          // Determine closer reference point
          final refPoint = (nx - prevPoint.dx).abs() + (ny - prevPoint.dy).abs() < 
                           (nx - nextPoint.dx).abs() + (ny - nextPoint.dy).abs()
              ? prevPoint
              : nextPoint;

          if ((nx - refPoint.dx).abs() < (ny - refPoint.dy).abs()) {
            nx = refPoint.dx;
          } else {
            ny = refPoint.dy;
          }
        }
      }

      pipe.waypoints[index] = Offset(nx, ny);
    });
  }

  void _removeWaypoint(PipeConnection pipe, int index) {
    _saveToHistory();
    setState(() {
      pipe.waypoints.removeAt(index);
    });
  }

  void _deletePipe(String pipeId) {
    _saveToHistory();
    setState(() {
      _pipes.removeWhere((p) => p.id == pipeId);
      if (_selectedPipeId == pipeId) _selectedPipeId = null;
    });
  }

  void _onPortPanStart(PumpNode node, {required bool isInput}) {
    _saveToHistory();
    setState(() {
      _connectFromId = node.id;
      _pendingDragIsInput = isInput;
      _pendingDragConnectionPos = isInput ? node.inputPort : node.outputPort;
    });
  }

  void _onPortPanUpdate(DragUpdateDetails details) {
    setState(() {
      _pendingDragConnectionPos = (_pendingDragConnectionPos! + details.delta / _scale);
    });
  }

  void _onPortPanEnd(DragEndDetails details) {
    if (_pendingDragConnectionPos == null || _connectFromId == null) return;
    final pos = _pendingDragConnectionPos!;

    // Check if dropped on a node
    String? targetNodeId;
    for (final node in _nodes) {
      if (node.id == _connectFromId) continue;
      final rect = Rect.fromLTWH(node.position.dx, node.position.dy, node.size.width, node.size.height);
      if (rect.contains(pos)) {
        targetNodeId = node.id;
        break;
      }
    }

    if (targetNodeId != null) {
      setState(() {
        final newPipe = PipeConnection(
          id: _nextId('pipe'),
          fromNodeId: _pendingDragIsInput ? targetNodeId! : _connectFromId!,
          toNodeId: _pendingDragIsInput ? _connectFromId! : targetNodeId!,
        );
        _pipes.add(newPipe);
      });
    } else {
      // Check if dropped on a pipe
      final hit = _locateNearestPipeSegment(pos, tolerance: kPipeHitTolerance + 4);
      if (hit != null) {
        final junctionId = _splitPipeAtPoint(hit.pipe, hit.segmentIndex, pos);
        setState(() {
          final newPipe = PipeConnection(
            id: _nextId('pipe'),
            fromNodeId: _pendingDragIsInput ? junctionId : _connectFromId!,
            toNodeId: _pendingDragIsInput ? _connectFromId! : junctionId,
          );
          _pipes.add(newPipe);
        });
      }
    }

    setState(() {
      _connectFromId = null;
      _pendingDragConnectionPos = null;
      _pendingDragIsInput = false;
    });
  }

  void _deleteSelected() {
    if (_selectedNodeId != null) {
      _deleteNode(_selectedNodeId!);
    } else if (_selectedPipeId != null) {
      _deletePipe(_selectedPipeId!);
    }
  }

  void _toggleConnectMode() {
    setState(() {
      _connectMode = !_connectMode;
      _connectFromId = null;
      _selectedNodeId = null;
      _selectedPipeId = null;
    });
  }

  // ---------------------------------------------------------------------
  // Export / Import
  // ---------------------------------------------------------------------
  void _showExportDialog() {
    final data = {
      'nodes': _nodes.map((n) => n.toJson()).toList(),
      'pipes': _pipes.map((p) => p.toJson()).toList(),
    };
    final jsonStr = const JsonEncoder.withIndent('  ').convert(data);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Configuration JSON'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: SelectableText(jsonStr, style: const TextStyle(fontFamily: 'monospace', fontSize: 12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close')),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pumping System Configuration'),
        actions: [
          IconButton(
            tooltip: 'Zoom out',
            icon: const Icon(Icons.zoom_out),
            onPressed: () => setState(() => _scale = (_scale - 0.1).clamp(0.4, 2.0).toDouble()),
          ),
          Center(child: Text('${(_scale * 100).round()}%')),
          IconButton(
            tooltip: 'Zoom in',
            icon: const Icon(Icons.zoom_in),
            onPressed: () => setState(() => _scale = (_scale + 0.1).clamp(0.4, 2.0).toDouble()),
          ),
          IconButton(
            tooltip: 'Undo',
            icon: const Icon(Icons.undo),
            onPressed: _undoStack.isNotEmpty ? _undo : null,
          ),
          IconButton(
            tooltip: 'Redo',
            icon: const Icon(Icons.redo),
            onPressed: _redoStack.isNotEmpty ? _redo : null,
          ),
          IconButton(
            tooltip: 'Export configuration (JSON)',
            icon: const Icon(Icons.file_download),
            onPressed: _showExportDialog,
          ),
          IconButton(
            tooltip: 'Reset to default layout',
            icon: const Icon(Icons.restart_alt),
            onPressed: () {
              _saveToHistory();
              setState(_loadDefaultLayout);
            },
          ),
        ],
      ),
      body: KeyboardListener(
        focusNode: FocusNode()..requestFocus(),
        onKeyEvent: (KeyEvent event) {
          if (event is KeyDownEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              setState(() => _isShiftPressed = true);
            }
          } else if (event is KeyUpEvent) {
            if (event.logicalKey == LogicalKeyboardKey.shiftLeft ||
                event.logicalKey == LogicalKeyboardKey.shiftRight) {
              setState(() => _isShiftPressed = false);
            }
          }
        },
        child: Column(
          children: [
            _buildToolbar(),
            Expanded(
              child: Container(
                color: const Color(0xFFF3F5F7),
                child: SingleChildScrollView(
                  scrollDirection: Axis.vertical,
                  child: SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Transform.scale(
                      scale: _scale,
                      alignment: Alignment.topLeft,
                      child: SizedBox(
                        width: kCanvasWidth,
                        height: kCanvasHeight,
                        child: GestureDetector(
                          behavior: HitTestBehavior.opaque,
                          onTapUp: _onCanvasTapUp,
                          onDoubleTapDown: _onCanvasDoubleTapDown,
                          onDoubleTap: () {}, // required so onDoubleTapDown fires
                          child: Stack(
                            children: [
                              // grid background
                              Positioned.fill(
                                child: CustomPaint(painter: _GridPainter()),
                              ),
                              // pipes
                              Positioned.fill(
                                child: CustomPaint(
                                  painter: PipePainter(
                                    nodes: _nodes,
                                    pipes: _pipes,
                                    selectedPipeId: _selectedPipeId,
                                    pendingConnectFromId: _connectFromId,
                                    pendingDragPos: _pendingDragConnectionPos,
                                    pendingIsInput: _pendingDragIsInput,
                                  ),
                                ),
                              ),
                              // waypoint drag handles
                              for (final pipe in _pipes)
                                for (int i = 0; i < pipe.waypoints.length; i++)
                                  WaypointHandle(
                                    position: pipe.waypoints[i],
                                    onPanStart: (d) => _saveToHistory(),
                                    onPanUpdate: (d) => _onWaypointPanUpdate(pipe, i, d),
                                    onLongPress: () => _removeWaypoint(pipe, i),
                                    color: pipe.id == _selectedPipeId
                                        ? Colors.deepOrange
                                        : const Color(0xFFFFA726),
                                  ),
                              // port handles for pumps
                              for (final node in _nodes)
                                if (node.type == NodeType.pump) ...[
                                  // Discharge port (Output)
                                  WaypointHandle(
                                    position: node.outputPort,
                                    onPanStart: (d) => _onPortPanStart(node, isInput: false),
                                    onPanUpdate: _onPortPanUpdate,
                                    onPanEnd: _onPortPanEnd,
                                    onLongPress: () {},
                                    color: Colors.blue.withOpacity(0.7),
                                  ),
                                  // Suction port (Input)
                                  WaypointHandle(
                                    position: node.inputPort,
                                    onPanStart: (d) => _onPortPanStart(node, isInput: true),
                                    onPanUpdate: _onPortPanUpdate,
                                    onPanEnd: _onPortPanEnd,
                                    onLongPress: () {},
                                    color: Colors.lightBlue.withOpacity(0.7),
                                  ),
                                ],
                              // nodes
                              for (final node in _nodes)
                                NodeWidget(
                                  node: node,
                                  isSelected: node.id == _selectedNodeId,
                                  isConnectSource: node.id == _connectFromId,
                                  onTap: () => _onNodeTap(node),
                                  onLongPress: () => _onNodeLongPress(node),
                                  onPanStart: (d) => _saveToHistory(),
                                  onPanUpdate: (d) => _onNodePanUpdate(node, d),
                                ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            _buildHint(),
          ],
        ),
      ),
    );
  }

  Widget _buildToolbar() {
    return Material(
      elevation: 2,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Row(
          children: [
            _toolButton(Icons.water, 'Source', () => _addNode(NodeType.source)),
            _toolButton(Icons.settings_input_component, 'Pump', () => _addNode(NodeType.pump)),
            _toolButton(Icons.propane_tank_outlined, 'Tank', () => _addNode(NodeType.tank)),
            _toolButton(Icons.inbox, 'Sump', () => _addNode(NodeType.sump)),
            _toolButton(Icons.call_split, 'Distribution', () => _addNode(NodeType.distribution)),
            const SizedBox(width: 12),
            const VerticalDivider(width: 1),
            const SizedBox(width: 12),
            FilterChip(
              label: const Text('Connect pipe'),
              avatar: const Icon(Icons.timeline, size: 18),
              selected: _connectMode,
              onSelected: (_) => _toggleConnectMode(),
            ),
            const SizedBox(width: 12),
            OutlinedButton.icon(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              label: const Text('Delete selected', style: TextStyle(color: Colors.red)),
              onPressed: (_selectedNodeId != null || _selectedPipeId != null) ? _deleteSelected : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _toolButton(IconData icon, String label, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 18),
        label: Text(label),
      ),
    );
  }

  Widget _buildHint() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFECEFF1),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        _connectMode
            ? 'Connect mode: tap a node or an existing pipe for the start point, then tap another node or pipe for the end point. Tapping a pipe drops a small junction there and branches your new pipe off it.'
            : 'Drag any pump/tank to move it • Double-tap a pipe to add a bend point • Drag an orange handle to bend/reshape a pipe • Long-press a handle to remove it • Long-press a node to rename, toggle on/off, or delete • Deleting a 2-way junction reconnects the pipe automatically.',
        style: const TextStyle(fontSize: 12, color: Colors.black87),
      ),
    );
  }
}

/// Result of a nearest-pipe-segment lookup: which pipe, which segment
/// (0-based, between points[i] and points[i+1] of that pipe's full path),
/// and how far the query point was from it.
class _PipeHit {
  final PipeConnection pipe;
  final int segmentIndex;
  final double distance;

  _PipeHit({required this.pipe, required this.segmentIndex, required this.distance});
}

class _GridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.withOpacity(0.15)
      ..strokeWidth = 1;
    const step = 40.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
