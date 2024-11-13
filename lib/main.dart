import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

/// Main widget for the application.
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: Dock(
            items: const [
              Icons.person,
              Icons.message,
              Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (e) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[e.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(e, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Dock widget with draggable, reorderable items.
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    this.items = const [],
    required this.builder,
  });

  /// Initial items to display.
  final List<T> items;

  /// Builder to display each item.
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// State for the Dock widget to manage drag-and-drop interactions.
class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  int? _draggingIndex;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.black12,
      ),
      padding: const EdgeInsets.all(4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: _items.asMap().entries.map((entry) {
          final index = entry.key;
          final item = entry.value;

          return LongPressDraggable<T>(
            data: item,
            dragAnchorStrategy: pointerDragAnchorStrategy,
            feedback: Material(
              color: Colors.transparent,
              child: widget.builder(item),
            ),
            childWhenDragging: const SizedBox.shrink(),
            onDragStarted: () {
              setState(() {
                _draggingIndex = index;
              });
            },
            onDragCompleted: () {
              setState(() {
                _draggingIndex = null;
              });
            },
            onDraggableCanceled: (_, __) {
              setState(() {
                _draggingIndex = null;
              });
            },
            child: DragTarget<T>(
              onWillAcceptWithDetails: (data) => data != item,
              onAcceptWithDetails: (data) {
                setState(() {
                  final fromIndex = _items.indexOf(data);
                  if (fromIndex != -1) {
                    _items.removeAt(fromIndex);
                    _items.insert(index, data);
                  }
                  _draggingIndex = null;
                });
              },
              builder: (context, candidateData, rejectedData) {
                // Ensure other icons fill in the space when dragging
                final isDraggingHere = index == _draggingIndex;
                return AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: isDraggingHere
                      ? const SizedBox.shrink()  // Hide the dragged icon
                      : widget.builder(item),
                );
              },
            ),
          );
        }).toList(),
      ),
    );
  }
}
