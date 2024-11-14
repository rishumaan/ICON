import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

          /// Root widget of the app.
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
              Icons.message,  Icons.call,
              Icons.camera,
              Icons.photo,
            ],
            builder: (icon) {
              return Container(
                constraints: const BoxConstraints(minWidth: 48),
                height: 48,
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.primaries[icon.hashCode % Colors.primaries.length],
                ),
                child: Center(child: Icon(icon, color: Colors.white)),
              );
            },
          ),
        ),
      ),
    );
  }
}

     /// A widget that displays a row of draggable items.
class Dock<T extends Object> extends StatefulWidget {
  const Dock({
    super.key,
    required this.items,
    required this.builder,
  });

  final List<T> items;
  final Widget Function(T) builder;

  @override
  State<Dock<T>> createState() => _DockState<T>();
}

/// The state for the Dock widget that manages the drag and drop logic.
class _DockState<T extends Object> extends State<Dock<T>> {
  late List<T> _items = widget.items.toList();
  int? _draggingIndex;

  @override
  Widget
   build(BuildContext context) {
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

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.ease,
            width: _draggingIndex == index ? 0 : 60,
            child: Draggable<T>(
              data: item,
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
                onWillAccept: (data) => data != item,
                onAccept: (data) {
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
                  final isDraggingHere = index == _draggingIndex;
                  return AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: isDraggingHere ? 0.0 : 1.0,
                    child: widget.builder(item),
                  );
                },
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
