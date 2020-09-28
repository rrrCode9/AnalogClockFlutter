import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:async';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
          backgroundColor: Colors.blueGrey[800],
          body: ChangeNotifierProvider(
              create: (_) => TimeState(),
              child: Consumer<TimeState>(builder: (context, timeState, _) {
                return Clock();
              }))),
    );
  }
}

class TimeState extends ChangeNotifier {
  Offset origin = Offset(0, 0);
  double secondRadius = 70;
  double minuteRadius = 80;
  double hourradius = 50;
  List<Offset> coordinates = [Offset(0, 0), Offset(0, 0), Offset(0, 0)];
  String timeString = ""; //for digital display

  List<Offset> translatTimeToCoordinates() {
    final time = DateTime.now();
    final second = time.second.toDouble();
    final minute = time.minute.toDouble();
    final hour = time.hour.toDouble();

    final secondAngle = 360 / 60 * second * pi / 180;
    final minuteAngle = 360 / (60 * 60) * (minute * 60 + second) * pi / 180;
    final hourAngle = 360 / (12 * 60 * 60) * ((hour % 12) * 60 * 60 + minute * 60 + second) * pi / 180;

    return [
      convertPolarToRect(radius: secondRadius, angle: secondAngle),
      convertPolarToRect(radius: minuteRadius, angle: minuteAngle),
      convertPolarToRect(radius: hourradius, angle: hourAngle),
    ];
  }

  Offset convertPolarToRect({double radius, double angle}) {
    return Offset(origin.dx + radius * sin(angle), origin.dy - radius * cos(angle));
  }

  void updateTimeCoordinates() {
    timeString = DateFormat.yMd().add_jms().format(DateTime.now());
    coordinates = translatTimeToCoordinates();
    notifyListeners();
  }
}

//Clock
class Clock extends StatefulWidget {
  Clock({Key key}) : super(key: key);

  @override
  _Clock createState() => _Clock();
}

class _Clock extends State<Clock> {
  // TimeState timeState;
  Timer timer;
  @override
  void initState() {
    // timeState = TimeState();
    // timeState.updateTimeCoordinates();

    timer = Timer.periodic(Duration(milliseconds: 1000), (timer) {
      Provider.of<TimeState>(context, listen: false).updateTimeCoordinates();
    });
    super.initState();
  }

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      child: Container(
          child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CustomPaint(
              painter: ClockComponent(
                center: context.watch<TimeState>().origin,
                secondPoint: context.watch<TimeState>().coordinates[0],
                minutePoint: context.watch<TimeState>().coordinates[1],
                hourPoint: context.watch<TimeState>().coordinates[2],
              ),
            ),
            Padding(padding: EdgeInsets.only(top: 30), child: Text(context.watch<TimeState>().timeString, style: TextStyle(color: Colors.white38, fontSize: 10))),
          ],
        ),
      )),
    );
  }
}

class ClockComponent extends CustomPainter {
  Offset center, secondPoint, minutePoint, hourPoint;
  ClockComponent({this.center, this.hourPoint, this.minutePoint, this.secondPoint});

  @override
  void paint(Canvas canvas, Size size) {
    //clockArea
    Circle(canvas: canvas, center: center, radius: 100, strokeWidth: 1, fill: true, color: Colors.black.withAlpha(20));

    //Hourhand
    Line(canvas: canvas, point1: center, point2: hourPoint, strokeWidth: 3, color: Colors.blueAccent);

    //MinuteHand
    Line(canvas: canvas, point1: center, point2: minutePoint, strokeWidth: 2, color: Colors.lightBlueAccent);

    //SecondHand
    Line(canvas: canvas, point1: center, point2: secondPoint, strokeWidth: 1, color: Colors.purpleAccent);

    //center circle
    Circle(canvas: canvas, center: center, radius: 4, strokeWidth: 1, fill: true, color: Colors.yellowAccent);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

//Circle
class Circle {
  Canvas canvas;
  double radius;
  Offset center;
  double strokeWidth;
  bool fill;
  Color color;

  Circle({this.canvas, this.center, this.color, this.fill, this.radius, this.strokeWidth}) {
    final paint = Paint()
      ..color = color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = strokeWidth;

    canvas.drawCircle(center, radius, paint);
  }
}

//Line
class Line {
  Canvas canvas;
  Offset point1, point2;
  double strokeWidth;
  Color color;

  Line({this.canvas, this.point1, this.point2, this.strokeWidth, this.color}) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth;

    canvas.drawLine(point1, point2, paint);
  }
}
