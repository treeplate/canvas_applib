import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
export 'package:flutter/material.dart' show Size, Colors;

// Helpers for drawing Drawables

void draw(Drawable home) {
  runApp(
    DrawableApp(
      home: home,
    ),
  );
}

class DrawableApp extends StatefulWidget {
  DrawableApp({@required this.home});
  final Drawable home;
  @override
  _DrawableAppState createState() => _DrawableAppState();
}

var _painter;
Color c;

class _DrawableAppState extends State<DrawableApp> {
  @override
  Widget build(BuildContext context) {
    _painter = DrawableAppPainter(
      home: widget.home,
    );
    return LayoutBuilder(
      builder: (BuildContext buildContext, BoxConstraints boxConstraints) =>
          MaterialApp(
        home: Scaffold(
          body: Stack(
            children: [
              CustomPaint(
                  size: Size(boxConstraints.maxWidth, boxConstraints.maxHeight),
                  painter: _painter),
              GestureDetector(
                onTapDown: (TapDownDetails t) {
                  widget.home.tap(t);
                },
              )
            ],
          ),
        ),
      ),
    );
  }
}

class DrawableAppPainter extends CustomPainter with ChangeNotifier {
  DrawableAppPainter({@required this.home});
  final Drawable home;

  void repaint() {
    notifyListeners();
  }

  @override
  void paint(Canvas canvas, Size size) {
    home.paint(canvas, size, Offset(0, 0));
  }

  @override
  bool shouldRepaint(DrawableAppPainter old) {
    return home.shouldRepaint(old.home);
  }
}
//Drawables

abstract class Drawable {
  Size paint(Canvas canvas, Size size, Offset position);

  void tap(TapDownDetails details) {}

  Size get size;

  bool shouldRepaint(covariant Drawable old);
}

class Centerer extends Drawable {
  Centerer({@required this.child});
  final Drawable child;
  Size get size => Size.infinite;
  Size paint(Canvas canvas, Size size, Offset position) {
    child.paint(
        canvas,
        size,
        child.size ==
                Size.infinite // TODO: use component logic for each dimension seperatly
            ? position
            : (position + toOffset(size / 2)) - toOffset(child.size / 2));
    return size;
  }

  void tap(TapDownDetails details) => child.tap(details);

  bool shouldRepaint(Centerer old) =>
      old.child.runtimeType != child.runtimeType ||
      child.shouldRepaint(old.child);
}

class Rectangle extends Drawable {
  Rectangle({this.child, Size size, this.color = const Color(0x00000000)})
      : csize = size;
  final Drawable child;
  final Size csize;
  Size get size => csize ?? child?.size ?? Size.infinite;
  final Color color;
  Size paint(Canvas canvas, Size size, Offset position) {
    //print("canvas, $size, $position");
    double sizeW = ((csize?.width ?? double.infinity) == double.infinity
        ? size.width
        : csize.width).clamp(0, size.width);
    double sizeH = ((csize?.height ?? double.infinity) == double.infinity
        ? size.height
        : csize.height).clamp(0, size.height);
    canvas.drawRect(
        Rect.fromLTWH(
          position.dx,
          position.dy,
          sizeW,
          sizeH,
        ),
        Paint()..color = color);
    child?.paint(canvas, csize ?? size, position);
    return Size(sizeW, sizeH);
  }

  void tap(TapDownDetails details) => child.tap(details);

  bool shouldRepaint(Rectangle old) =>
      child.runtimeType != old.child.runtimeType ||
      csize != old.csize ||
      color != old.color ||
      (child?.shouldRepaint(old.child) ?? false);
}

class TransparentButton extends Drawable {
  Rect space;
  static int buttons = 0;
  TransparentButton(this.callback) : n = buttons = buttons + 1;
  final int n;
  final VoidCallback callback;
  Size paint(Canvas canvas, Size size, Offset position) {
    space = Rect.fromLTWH(position.dx, position.dy, size.width, size.height);
    return size;
  }

  Size get size => Size(0, 0);
  void tap(TapDownDetails details) {
    if (space?.contains(details.globalPosition) ??
        (throw "Button tapped before painting #$n")) {
      callback();
    }
  }

  bool shouldRepaint(Drawable old) => false;
}

class CanvasDrawer extends Drawable {
  CanvasDrawer(this.paths, {this.size});
  final List<MapEntry<Path, Paint>> paths;
  final Size size;
  Size paint(Canvas canvas, Size osize, Offset position) {
    for (MapEntry<Path, Paint> m in paths) {
      canvas.drawPath(m.key, m.value);
    }
    return osize;
  }

  bool shouldRepaint(_) => false;
}

abstract class Builder extends Drawable {
  Builder() {
    temp = build();
  }
  Drawable temp;
  Size paint(Canvas canvas, Size size, Offset position) {
    return (temp = build()).paint(canvas, size, position);
  }

  @protected
  void repaint() {
    _painter.repaint();
  }

  void tap(TapDownDetails details) => temp.tap(details);

  Size get size => temp.size;

  Drawable build();

  bool shouldRepaint(Drawable old) => true;
}

abstract class ListDrawer extends Drawable {
  ListDrawer({@required this.children});
  final List<Drawable> children;
  bool get isRow;
  Size get size {
    Offset crossAxisSize = toOffset(
      isRow ? Size(0, double.infinity) : Size(double.infinity, 0),
    );
    Size mainAxisSize = children.fold(
      Size.zero,
      (previousValue, element) => element.size + toOffset(previousValue),
    );
    //print("$mainAxisSize.component + $crossAxisSize ");
    return isRow ? Size(mainAxisSize.width, 0) : Size(0, mainAxisSize.height) +
        crossAxisSize;
  }

  bool shouldRepaint(ListDrawer old) => true;
  Size paint(Canvas canvas, Size size, Offset position) {
    double usedSize = 0;
    int expandedCount = 0;
    for (Drawable drawable in children) {
      if (component(isRow, drawable.size) != double.infinity) {
        usedSize += component(isRow, drawable.size).clamp(0, component(isRow, size));
        //print(
           // "new usedSize: $usedSize (${drawable.runtimeType}.size = ${drawable.size})");
      } else {
        expandedCount++;
      }
    }
    Size listVector = isRow ? Size(1, 0) : Size(0, 1);
    Size crossAxisSize = isRow ? Size(0, size.height) : Size(size.width, 0);
    double totalSize = component(isRow, size) - usedSize;
    Size expandedSize =
        crossAxisSize + toOffset(listVector * (totalSize / expandedCount));
    Size addedPos = Size.zero;
    for (Drawable drawable in children) {
      if (component(isRow, drawable.size) == double.infinity) {
        //print(
           // "${isRow ? "" : "  "}Drawing as-large-as-possible ${drawable.runtimeType}: available size $expandedSize; usedSize: $usedSize list vector $listVector; crossAxisSize: $crossAxisSize; expandedCount: $expandedCount; total size $size (expandeds use $totalSize)");
        addedPos += toOffset(drawable.paint(
          canvas,
          expandedSize,
          position +
              (isRow ? Offset(addedPos.width, 0) : Offset(0, addedPos.height)),
        ));
      } else {
        Size drawableSize = component(!isRow, drawable.size) == double.infinity
            ? (isRow
                ? Size(drawable.size.width.clamp(0, size.width), size.height)
                : Size(size.width, drawable.size.height.clamp(0, size.height)))
            : Size(drawable.size.width.clamp(0, size.width), drawable.size.height.clamp(0, size.height));

        //print(
          //  "Drawing ${drawable.runtimeType}: requested size ${drawable.size}; given size $drawableSize; position ${position + (isRow ? Offset(addedPos.width, 0) : Offset(0, addedPos.height))}");
        addedPos += toOffset(drawable.paint(
          canvas,
          drawableSize,
          position +
              (isRow ? Offset(addedPos.width, 0) : Offset(0, addedPos.height)),
        ));
      }
    }
    return size;
  }
}

class HorizontalList extends ListDrawer {
  HorizontalList({@required List<Drawable> children})
      : super(children: children);
  bool get isRow => true;
}

class VerticalList extends ListDrawer {
  VerticalList({@required List<Drawable> children}) : super(children: children);
  bool get isRow => false;
}

// Builders

class ColoredButton extends Builder {
  ColoredButton({this.color, this.onTap, this.size});
  final Color color;
  final Size size;
  final VoidCallback onTap;
  Drawable build() {
    return Rectangle(
      color: color,
      size: size,
      child: TransparentButton(onTap),
    );
  }
}

// General assets

Offset toOffset(Size size) => Offset(size.width, size.height);
double component(bool isX, Size size) => isX ? size.width : size.height;
