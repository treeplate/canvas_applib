import 'dart:math';

import 'package:canvas_thing/drawing.dart';

void main() => draw(MyApp());

class MyApp extends Builder {
  double _n = 10;

  @override
  Drawable build() {
    print("objective");

    return RowList(children: [
      Rectangle(
        color: Colors.amber,
      ),
      Rectangle(
        color: Colors.blue,
        size: Size(10, _n),
      ),
      Rectangle(
        color: Colors.amber,
      ),
      Rectangle(
        color: Colors.blue,
        size: Size(10, _n),
      ),
      Rectangle(
        color: Colors.amber,
      ),
      ColoredButton(
          onTap: () {
            print("tap");
            _n++;
            repaint();
          },
          color: Colors.green)
    ]);
  }
}
