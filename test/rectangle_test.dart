import 'dart:ui';
import 'package:canvas_thing/drawing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets("$Rectangle by itself is as big as possible", (WidgetTester tester) async {
    Rectangle rect = Rectangle();
    Canvas canvas = Canvas(PictureRecorder());
    expect(rect.paint(canvas, Size(10, 10), Offset.zero), Size(10, 10));
  });

  testWidgets("$Rectangle with size specified is that size", (WidgetTester tester) async {
    Rectangle rect = Rectangle(size: Size(3, 3));
    Canvas canvas = Canvas(PictureRecorder());
    expect(rect.paint(canvas, Size(10, 10), Offset.zero), Size(3, 3));
  });

  testWidgets("$Rectangle truncates to fit size", (WidgetTester tester) async {
    Rectangle rect = Rectangle(size: Size(13, 13));
    Canvas canvas = Canvas(PictureRecorder());
    expect(rect.paint(canvas, Size(10, 10), Offset.zero), Size(10, 10));
  });

  testWidgets("$Rectangle extends in side lengths of double.infinity", (WidgetTester tester) async {
    Rectangle rect = Rectangle(size: Size(3, double.infinity));
    Canvas canvas = Canvas(PictureRecorder());
    expect(rect.paint(canvas, Size(10, 10), Offset.zero), Size(3, 10));
  });
}