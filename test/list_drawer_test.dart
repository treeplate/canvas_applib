import 'dart:ui';
import 'package:canvas_thing/drawing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets(
    "$HorizontalList only gives ${Drawable}s as much space as it needs",
    (WidgetTester tester) async {
      List<String> logs = [];
      void log(String x) {
        logs.add(x);
      }
      Canvas canvas = Canvas(PictureRecorder());
      HorizontalList list = HorizontalList(
        children: [
          TestRectangle(Size(30, 30), log),
        ],
      );

      list.paint(canvas, Size(100, 100), Offset.zero);
      expect(logs.length == 1, true);
      expect(logs[0], "Offset(0.0, 0.0) & Size(30.0, 30.0)");
    },
  );
  testWidgets(
    "$HorizontalList only gives ${Drawable}s as much space as it has",
    (WidgetTester tester) async {
      List<String> logs = [];
      void log(String x) {
        logs.add(x);
      }
      Canvas canvas = Canvas(PictureRecorder());
      HorizontalList list = HorizontalList(
        children: [
          TestRectangle(Size(30, 30), log),
        ],
      );

      list.paint(canvas, Size(10, 10), Offset.zero);
      expect(logs.length == 1, true);
      expect(logs[0], "Offset(0.0, 0.0) & Size(10.0, 10.0)");
    },
  );
}

class TestRectangle extends Drawable {
  TestRectangle(this.size, this.log);
  final Size size;
  final void Function(String) log;
  Size paint(Canvas canvas, Size size, Offset offset) {
    log("$offset & $size");
    return this.size;
  }
  bool shouldRepaint(TestRectangle rectangle) => size != rectangle.size || log != rectangle.log;
}
