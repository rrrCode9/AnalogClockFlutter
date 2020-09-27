import 'package:flutter/material.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'dart:async';
import 'package:provider/provider.dart';
import 'package:flutter/foundation.dart';

void main() {
  runApp(AnalogClockAppWithFlutter());
}

class AnalogClockAppWithFlutter extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
          backgroundColor: Colors.blueGrey[800], //Color.fromARGB(255, 39, 43, 51),Colors.red ,
            body: ChangeNotifierProvider(
                create: (_) => TimeState(),
                child: Consumer<TimeState>(builder: (context, timeState, _) {
                  return Clock();
                }))));
  }
}

//data model
class TimeState extends ChangeNotifier {
  Offset origin = Offset(0, 0);
  double secondPathRadius = 70;
  double minutePathRadius = 80;
  double hourPathRadius = 40;
  List<Offset> coordinates = [Offset(0, 0), Offset(0, 0), Offset(0, 0)];
  String timeString = "";

   List<Offset> translateTimeToCoordinates() {
    final time = DateTime.now();

    final hour = time.hour.toDouble();
    final minute = time.minute.toDouble();
    final second = time.second.toDouble();

    final secondAngle = 360 / 60 * second * pi / 180; //radians
    final minuteAngle = 360 / (60 * 60) * (minute * 60 + second) * pi / 180; //radians
    final hourAngle = 360 / (12 * 60 * 60) * ((hour % 12) * 60 * 60 + minute * 60 + second) * pi / 180; //radians

    return [
      convertAngleToCoordinate(radius: secondPathRadius, angle: secondAngle),
      convertAngleToCoordinate(radius: minutePathRadius, angle: minuteAngle),
      convertAngleToCoordinate(radius: hourPathRadius, angle: hourAngle),
    ];
  }

  Offset convertAngleToCoordinate({double radius, double angle}) {
    return Offset(origin.dx + radius * sin(angle), origin.dy - radius * cos(angle));
  }

  updateTimeCoordinates() {
    timeString = DateFormat.yMd().add_jms().format(DateTime.now());
    coordinates = translateTimeToCoordinates();
    notifyListeners();
  }
}

class Clock extends StatefulWidget {
  @override
  _Clock createState() => _Clock();
}

class _Clock extends State<Clock> {
  Timer timer;

  initState() {
    timer = Timer.periodic(Duration(milliseconds: 1000), (t) {
      Provider.of<TimeState>(context, listen: false).updateTimeCoordinates();
    });
    super.initState();
  }

//dispose timer if widget is closed
  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  Widget build(BuildContext context) {
    return Container(
        
        child: Center(
            child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          CustomPaint(
            // size: Size(context.watch<TimeState>().centerX * 2.2, context.watch<TimeState>().centerY * 2.2),
            painter: ClockComponent(
              secondPoint: context.watch<TimeState>().coordinates[0],
              minutePoint: context.watch<TimeState>().coordinates[1],
              hourPoint: context.watch<TimeState>().coordinates[2],
              center: context.watch<TimeState>().origin,
            ),
          ),
          Padding(
            padding: EdgeInsets.only(top: 30),
            child:Text(
            context.watch<TimeState>().timeString,
            style: TextStyle(color: Colors.white38,fontSize: 10),
          ))
        ])));
  }
}

class ClockComponent extends CustomPainter {
  Offset center, hourPoint, minutePoint, secondPoint;

  ClockComponent({
    this.secondPoint,
    this.minutePoint,
    this.hourPoint,
    this.center,
  });

  @override
  void paint(Canvas canvas, Size size) {
    Circle(canvas: canvas, center: center, radius: 100, strokeWidth: 1, fill: true, color: Colors.black.withAlpha(20));
    //hour point
    Line(canvas: canvas, point1: center, point2: hourPoint, color: Colors.lightBlue, strokeWidth: 3);
    //minute point
    Line(canvas: canvas, point1: center, point2: minutePoint, color: Colors.lightBlueAccent, strokeWidth: 2);
    //second point
    Line(canvas: canvas, point1: center, point2: secondPoint, color: Colors.purpleAccent, strokeWidth: 2);
    //center
    Circle(canvas: canvas, center: center, radius: 3, strokeWidth: 2, fill: true, color: Colors.yellowAccent);
  }

  @override
  bool shouldRepaint(CustomPainter old) {
    return true;
  }
}

class Circle {
  Canvas canvas;
  double radius;
  Offset center;
  double strokeWidth;
  bool fill;
  Color color;

  Circle({this.canvas, this.radius, this.center, this.strokeWidth, this.fill, this.color}) {
    final radius = this.radius;
    final paint = Paint()
      ..color = this.color
      ..style = fill ? PaintingStyle.fill : PaintingStyle.stroke
      ..strokeWidth = this.strokeWidth;
    canvas.drawCircle(center, radius, paint);
  }
}

class Line {
  Canvas canvas;
  Offset point1, point2;
  Color color;
  double strokeWidth = 4;

  Line({this.canvas, this.point1, this.point2, this.color, this.strokeWidth}) {
    final paint = Paint()
      ..color = this.color
      ..strokeWidth = this.strokeWidth;

    canvas.drawLine(point1, point2, paint);
  }
}
