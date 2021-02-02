import 'dart:math';

import 'package:canvas_thing/drawing.dart';

void main() => draw(MyApp());

class MyApp extends Builder {
  @override
  Drawable build() {
    return HorizontalList(
      children: [
        Rectangle(
          color: Colors.yellow,
          size: Size(100, double.infinity),
        ),
        Rectangle(
          color: Colors.green,
        ),
        VerticalList(
          children: [
            Rectangle(
              color: Colors.blue,
              size: Size(double.infinity, double.infinity),
            ),
            Rectangle(
              color: Colors.yellow,
            ),
            Rectangle(
              color: Colors.blue,
              size:  Size(double.infinity, double.infinity),
            ),
          ],
        ),
      ],
    );
  }
}
