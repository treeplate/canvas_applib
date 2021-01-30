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
  Size get size => child.size;
  Size paint(Canvas canvas, Size size, Offset position) {
    return child.paint(canvas, size,
        (position + toOffset(size / 2)) - toOffset(child.size / 2));
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
  Size get size => csize ?? child?.size ?? Size(0, 0);
  final Color color;
  Size paint(Canvas canvas, Size size, Offset position) {
    canvas.drawRect(
        Rect.fromLTWH(position.dx, position.dy, csize?.width ?? size.width,
            csize?.height ?? size.height),
        Paint()..color = color);
    child?.paint(canvas, csize ?? size, position);
    return csize ?? size;
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

class RowList extends Drawable {
  RowList({@required this.children});
  final List<Drawable> children;
  Size get size => children.fold(Size(0, 0),
      (previousValue, element) => element.size + toOffset(previousValue));
  bool shouldRepaint(RowList old) => true;
  Size paint(Canvas canvas, Size size, Offset position) {
    double offset = 0;
    double addSize = 0;
    for (Drawable child in children) {
      double chsize = child
          .paint(
              canvas,
              Size((size.width / children.length) + addSize, size.height),
              position + Offset(offset, 0))
          .width;
      addSize += (size.width / children.length) - chsize;
      offset += chsize;
    }
    return toSize(size - Size(addSize, 0));
  }
}

class ColumnList extends Drawable {
  ColumnList({@required this.children});
  final List<Drawable> children;
  Size get size => children.fold(Size(0, 0),
      (previousValue, element) => element.size + toOffset(previousValue));
  bool shouldRepaint(ColumnList old) => true;
  Size paint(Canvas canvas, Size size, Offset position) {
    double offset = 0;
    double addSize = 0;
    for (Drawable child in children) {
      double chsize = child
          .paint(
              canvas,
              Size(size.width, (size.height / children.length) + addSize),
              position + Offset(0, offset))
          .height;
      addSize += (size.height / children.length) - chsize;
      offset += chsize;
    }
    return toSize(size - Size(0, addSize));
  }
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
Size toSize(Offset offset) => Size(offset.dx, offset.dy);
