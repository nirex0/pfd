library pfd;

import 'package:flutter/material.dart';
import 'dart:math' as math;

class PFD extends StatelessWidget {
  final double roll;
  final double pitch;
  final double yaw;

  final double altitude;
  final double airSpeed;

  final double height;
  final double width;

  const PFD(
      {Key? key,
      required this.roll,
      required this.pitch,
      required this.yaw,
      required this.altitude,
      required this.airSpeed,
      this.height = 350,
      this.width = 350})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(width * 0.15, 0, 0, 0),
          child: Stack(
            children: [
              SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  painter: BackgroundAndPitchPainter(roll: roll, pitch: pitch),
                ),
              ),
              SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  painter: YawCompassPainter(yaw: yaw),
                ),
              ),
              SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  painter: RollTickBarPainter(roll: roll),
                ),
              ),
              SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  painter: RPYPainter(roll: roll, pitch: pitch, yaw: yaw),
                ),
              ),
              SizedBox(
                height: height,
                width: width,
                child: CustomPaint(
                  painter: VehicleIndicatorPainter(),
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: CustomPaint(
            painter: AltitudeIndicatorPainter(altitude: altitude),
          ),
        ),
        SizedBox(
          height: height,
          width: width,
          child: CustomPaint(
            painter: AirSpeedIndicatorPainter(airSpeed: airSpeed),
          ),
        ),
      ],
    );
  }
}

class RollTickBarPainter extends CustomPainter {
  final double roll;
  final double maxAngle = math.pi / 3; // 60 degrees
  final double fontSize = 13.0;
  RollTickBarPainter({required this.roll});
  @override
  void paint(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 1.5;
    double radius = math.min(centerX, centerY);

    Paint linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    final TextPainter textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // Draw tick lines and text labels
    for (int angle = -60; angle <= 60; angle += 5) {
      final double radians = math.pi * 1.5 - (angle * (math.pi / 180));
      final double startX = centerX + radius * math.cos(radians);
      final double startY = centerY + radius * math.sin(radians);
      double endX = centerX + (radius - fontSize * 1.5) * math.cos(radians);
      double endY = centerY + (radius - fontSize * 1.5) * math.sin(radians);

      if (angle % 15 == 0) {
        linePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 2.0;
        endX = centerX + (radius / 1.02 - fontSize * 1.5) * math.cos(radians);
        endY = centerY + (radius / 1.02 - fontSize * 1.5) * math.sin(radians);
      } else {
        linePaint = Paint()
          ..color = Colors.white
          ..strokeWidth = 1.0;
      }

      canvas.drawLine(Offset(startX, startY), Offset(endX, endY), linePaint);

      var text = '${-angle}°';
      if (-angle > 0) {
        text = '+${-angle}°';
      }

      textPainter.text = TextSpan(
        text: text,
        style: TextStyle(fontSize: fontSize, fontWeight: FontWeight.bold),
      );
      textPainter.layout();
      final double textX = centerX +
          (radius / 1.02 - fontSize * 2.5) * math.cos(radians) -
          textPainter.width / 2;
      final double textY = centerY +
          (radius / 1.02 - fontSize * 2.5) * math.sin(radians) -
          textPainter.height / 2;
      if (angle % 15 == 0) {
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }

    // Define the length of the indicator line (adjust as needed)
    const double indicatorLength = 25.0;

// Determine the angle for the indicator line

    double indicatorRadians = math.pi * 1.5 - (-roll * (math.pi / 180));
    final double indicatorStartX =
        centerX + (radius / 1.04 - fontSize * 1.5) * math.cos(indicatorRadians);
    final double indicatorStartY =
        centerY + (radius / 1.04 - fontSize * 1.5) * math.sin(indicatorRadians);
    final double indicatorEndX =
        indicatorStartX + indicatorLength * math.cos(indicatorRadians);
    final double indicatorEndY =
        indicatorStartY + indicatorLength * math.sin(indicatorRadians);

// Draw the indicator line
    Paint indicatorPaint = Paint()
      ..color =
          const Color.fromARGB(255, 255, 0, 0) // Replace with the desired color
      ..strokeWidth = 4.0; // Adjust the line width as needed
    canvas.drawLine(
      Offset(indicatorStartX, indicatorStartY),
      Offset(indicatorEndX, indicatorEndY),
      indicatorPaint,
    );
  }

  @override
  bool shouldRepaint(RollTickBarPainter oldDelegate) {
    return oldDelegate.roll != roll;
  }
}

class RPYPainter extends CustomPainter {
  final double roll;
  final double pitch;
  final double yaw;

  RPYPainter({required this.roll, required this.pitch, required this.yaw});

  @override
  void paint(Canvas canvas, Size size) {
    final yawRect = Rect.fromLTWH(
      0,
      size.height - (size.height * 0.075),
      size.width,
      size.height * 0.075,
    );
    final yawPaint = Paint()..color = const Color.fromARGB(192, 0, 0, 0);
    canvas.drawRect(yawRect, yawPaint);

    final rollTextPainter = TextPainter(
      text: TextSpan(
        text: "R: ${roll.toStringAsFixed(1)}°",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    rollTextPainter.layout();

    final pitchTextPainter = TextPainter(
      text: TextSpan(
        text: "P: ${pitch.toStringAsFixed(1)}°",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    pitchTextPainter.layout();

    final yawTextPainter = TextPainter(
      text: TextSpan(
        text: "Y: ${yaw.toStringAsFixed(1)}°",
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    yawTextPainter.layout();

    final offset = size.width / 18;

    final textXr = (size.width / 2) - (offset * 6);
    final textYr = size.height - (size.height * 0.06);

    final textXp = (size.width / 2) - offset;
    final textYp = size.height - (size.height * 0.06);

    final textXy = (size.width / 2) + (offset * 4);
    final textYy = size.height - (size.height * 0.06);

    rollTextPainter.paint(canvas, Offset(textXr, textYr));
    pitchTextPainter.paint(canvas, Offset(textXp, textYp));
    yawTextPainter.paint(canvas, Offset(textXy, textYy));
  }

  @override
  bool shouldRepaint(RPYPainter oldDelegate) {
    return oldDelegate.roll != roll ||
        oldDelegate.pitch != pitch ||
        oldDelegate.yaw != yaw;
  }
}

class BackgroundAndPitchPainter extends CustomPainter {
  final double roll;
  final double pitch;

  BackgroundAndPitchPainter({required this.roll, required this.pitch});

  void drawSkyAndPitchTicks(Canvas canvas, Size size) {
    final double skyHeight = size.height / 2 * (1 + pitch / 21.5);
    final double groundHeight = size.height / 2 * (1 - pitch / 21.5);

    final skyRect = Rect.fromLTWH(-size.width * 500, -skyHeight * 500,
        size.width + size.width * 1000, skyHeight * 1000);
    final groundRect = Rect.fromLTWH(
        -size.width * 500,
        size.height - groundHeight,
        size.width + size.width * 1000,
        groundHeight + 100);

    final skyPaint = Paint()..color = Colors.blue;
    final groundPaint = Paint()..color = Colors.brown;

    // Clip the canvas to only draw within the widget's boundaries
    canvas.clipRect(Offset.zero & size);

    canvas.translate(size.width / 2, size.height / 2);
    canvas.rotate(-roll * (math.pi / 180));
    canvas.translate(-size.width / 2, -size.height / 2);

    canvas.drawRect(skyRect, skyPaint);
    canvas.drawRect(groundRect, groundPaint);

    // Calculate the number of pitch lines
    final double pitchLineWidth = size.width / 9;
    final int pitchLinesCount = (size.height ~/ pitchLineWidth).toInt() * 2 + 1;

    final double pitchLineStartX = size.width * 0.10; // 10% of the width
    final double pitchLineEndX = size.width * 0.30; // 30% of the width

    final pitchLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    // Draw pitch lines on the sky rectangle
    for (int i = 0; i < pitchLinesCount; i++) {
      final double pitchLineY = skyHeight - ((i) * pitchLineWidth);

      final pitchLineStartLeft =
          Offset(pitchLineStartX + (i % 2 * 50), pitchLineY);
      final pitchLineEndLeft = Offset(pitchLineEndX, pitchLineY);
      canvas.drawLine(pitchLineStartLeft, pitchLineEndLeft, pitchLinePaint);

      final pitchLineStartRight =
          Offset(size.width - pitchLineEndX, pitchLineY);
      final pitchLineEndRight =
          Offset(size.width - pitchLineStartX - (i % 2 * 50), pitchLineY);
      canvas.drawLine(pitchLineStartRight, pitchLineEndRight, pitchLinePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: i == 0 ? '0' : '+${i * 5}',
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // final textX = size.width / 2 - textPainter.width / 2;
      final textY = pitchLineY - textPainter.height / 2;
      textPainter.paint(
          canvas, Offset(pitchLineStartX - (size.width * 0.07), textY));
      textPainter.paint(
          canvas, Offset(pitchLineStartRight.dx + (size.width * 0.2), textY));
    }

    // Draw pitch lines on the ground rectangle
    for (int i = 0; i < pitchLinesCount; i++) {
      final double pitchLineY =
          size.height - groundHeight + ((i) * pitchLineWidth);

      final pitchLineStartLeft =
          Offset(pitchLineStartX + (i % 2 * 50), pitchLineY);
      final pitchLineEndLeft = Offset(pitchLineEndX, pitchLineY);
      canvas.drawLine(pitchLineStartLeft, pitchLineEndLeft, pitchLinePaint);

      final pitchLineStartRight =
          Offset(size.width - pitchLineEndX, pitchLineY);
      final pitchLineEndRight =
          Offset(size.width - pitchLineStartX - (i % 2 * 50), pitchLineY);
      canvas.drawLine(pitchLineStartRight, pitchLineEndRight, pitchLinePaint);

      final textPainter = TextPainter(
        text: TextSpan(
          text: (-i * 5).toString(),
          style: const TextStyle(
              color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
        ),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      // final textX = size.width / 2 - textPainter.width / 2;
      final textY = pitchLineY - textPainter.height / 2;
      // textPainter.paint(canvas, Offset(textX, textY));
      textPainter.paint(
          canvas, Offset(pitchLineStartX - (size.width * 0.07), textY));
      textPainter.paint(
          canvas, Offset(pitchLineStartRight.dx + (size.width * 0.2), textY));
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawSkyAndPitchTicks(canvas, size);
  }

  @override
  bool shouldRepaint(BackgroundAndPitchPainter oldDelegate) {
    return oldDelegate.roll != roll || oldDelegate.pitch != pitch;
  }
}

class YawCompassPainter extends CustomPainter {
  final double yaw;
  YawCompassPainter({required this.yaw});

  void drawYawCompass(Canvas canvas, Size size) {
    // Draw yaw lines
    const degreeCount = 360;
    final int yawLinesCount =
        ((size.width * 0.1) ~/ (size.width * 0.05)).toInt() * degreeCount;

    final yawRect = Rect.fromLTWH(0, 0, size.width, size.height * 0.075);
    final yawPaint = Paint()..color = const Color.fromARGB(192, 0, 0, 0);
    canvas.drawRect(yawRect, yawPaint);

    final yawLinePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;

    var desiredValue = yaw; // Change this to the desired value

    if (desiredValue > 180) {
      var overflow = desiredValue - 180;
      desiredValue = 180 + overflow;
    } else if (desiredValue < -180) {
      var overflow = desiredValue + 180;
      desiredValue = 180 + overflow;
    }

    double centerOffset =
        (yawLinesCount / 2 - desiredValue - degreeCount) * (size.width * 0.03);
    final double centerPositionX = size.width / 2 + centerOffset;

    for (int i = -yawLinesCount; i <= yawLinesCount; i++) {
      final double offset = i * (size.width * 0.03);
      final double yawLineX = centerPositionX + offset;

      if (yawLineX >= 0 && yawLineX <= size.width) {
        const yawLineStartY = 0.0;
        final yawLineEndY =
            (i % 5 == 0) ? size.height * 0.015 : size.height * 0.009;

        final yawLineStart = Offset(yawLineX, yawLineStartY);
        final yawLineEnd = Offset(yawLineX, yawLineEndY);

        canvas.drawLine(yawLineStart, yawLineEnd, yawLinePaint);

        var tickText = "";
        double fontSize = 12;
        if (i == 0 || i == -360 || i == 360) {
          fontSize = 15;
          tickText = "N";
        } else if (i == 90 || i == -270) {
          fontSize = 15;
          tickText = "E";
        } else if (i == 180 || i == -180) {
          fontSize = 15;
          tickText = "S";
        } else if (i == 270 || i == -90) {
          fontSize = 15;
          tickText = "W";
        } else if (i % 5 == 0) {
          fontSize = 13;
          if (i > 180) {
            tickText = "${i - 360}°";
          } else if (i < -180) {
            tickText = "${i + 360}°";
          } else {
            tickText = "$i°";
          }
          if (i > 0) {
            tickText = "+$tickText";
          }
        }

        final textPainter = TextPainter(
          text: TextSpan(
            text: tickText,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final textX = yawLineX - textPainter.width / 2;
        final textY = size.height * 0.015;

        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    drawYawCompass(canvas, size);
  }

  @override
  bool shouldRepaint(YawCompassPainter oldDelegate) {
    return oldDelegate.yaw != yaw;
  }
}

class AltitudeIndicatorPainter extends CustomPainter {
  final double altitude;

  AltitudeIndicatorPainter({required this.altitude});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a rectangle to the right side of the canvas
    // Stretching from the very top to the very bottom of the canvas
    final altitudeRectangle =
        Rect.fromLTWH(size.width, 0, size.width * 0.15, size.height);
    final paint = Paint()..color = const Color.fromARGB(192, 0, 0, 0);
    canvas.drawRect(altitudeRectangle, paint);

    // Add a border to the rectangle
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(altitudeRectangle, borderPaint);

    // Draw a text on the very top of the rectangle reading: Alt
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "ALT. (m)",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textX = size.width + (size.width * 0.075) - textPainter.width / 2;
    final textY = size.height * 0.015;
    textPainter.paint(canvas, Offset(textX, textY));

    // draw a line under the text that separates it from the rest of the rectangle
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    canvas.drawLine(
        Offset(size.width, size.height * 0.075),
        Offset(size.width + (size.width * 0.15), size.height * 0.075),
        linePaint);

    // Draw the altitude value in the rectangle starting from -5000 and going up to 5000 in increments of 100
    // The airSpeedValue value should always be in the middle
    double altitudeValue = altitude;
    const int altitudeMaxValue = 5000;
    const int altitudeMinValue = -5000;
    const int altitudeRange = altitudeMaxValue - altitudeMinValue;
    // final double altitudePercentage = altitudeValue / altitudeRange;
    final double altitudeRectangleHeight = size.height;
    // final double altitudeValueY = altitudeRectangleHeight -
    // (altitudeRectangleHeight * altitudePercentage);

    // make a new clip rectangle the size of the altitude rectangle
    // except the top of it is size.height * 0.075 lower
    var clipRect = Rect.fromLTWH(size.width, size.height * 0.075,
        size.width * 0.15, size.height - size.height * 0.075);
    canvas.clipRect(clipRect);

    // draw a red line on the cneter of the rectangle

    final centerLinePaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..strokeWidth = 2.0;

    // Draw a line on each side of the center line
    canvas.drawLine(
        Offset(size.width, altitudeRectangleHeight / 2 - 8),
        Offset(
            size.width + (size.width * 0.15), altitudeRectangleHeight / 2 - 8),
        centerLinePaint);
    canvas.drawLine(
        Offset(size.width, altitudeRectangleHeight / 2 + 8),
        Offset(
            size.width + (size.width * 0.15), altitudeRectangleHeight / 2 + 8),
        centerLinePaint);

    // altitudeValue += 2000;
    // rewrite the same loop above but make sure the altitude-value is always on the center
    for (int i = altitudeMinValue; i <= altitudeMaxValue; i += 10) {
      double altitudeLineY = altitudeRectangleHeight / 2 -
          (altitudeRectangleHeight *
              ((i - altitudeValue * 51) / altitudeRange)) -
          (size.height * 0.05) * (i / 10);

      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.0;

      if (i % 10 == 0) {
        linePaint.color = i == 0
            ? Colors.white
            : i >= 0
                ? Colors.blue
                : Colors.red;

        linePaint.strokeWidth = 2.0;
      }
      if (i < 0) {
        // Make a gradient color based on i that is ranged from -100 to 0, so that the closer we are to 0 the brighter the red is:
        // Maximum red value is 255
        // Minimum red value is 0
        // linePaint.color = Color.fromARGB(255, 255, 0, 0);

        // i = 0 means red is at 255
        // i = -100 means red is at 0
        // i = -50 means red is at 127.5
        var redValue = 0 + ((i + 100) * 2.55);
        linePaint.color = Color.fromARGB(255, redValue.toInt(), 0, 0);
      }
      // line on the left
      canvas.drawLine(Offset(size.width, altitudeLineY),
          Offset(size.width + (size.width * 0.01), altitudeLineY), linePaint);

      // line on the right
      canvas.drawLine(Offset(size.width + (size.width * 0.15), altitudeLineY),
          Offset(size.width + (size.width * 0.14), altitudeLineY), linePaint);

      var textColor = Colors.white;
      if (i == 0) {
        textColor = Colors.white;
      } else if (i > 0) {
        textColor = Colors.blue;
      } else if (i < 0) {
        var redValue = 0 + ((i + 100) * 2.55);
        textColor = Color.fromARGB(255, redValue.toInt(), 0, 0);
      }

      if (i % 10 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i > 0 ? '+${i.toStringAsFixed(0)}' : i.toStringAsFixed(0),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textX = size.width + (size.width * 0.075) - textPainter.width / 2;
        final textY = altitudeLineY - textPainter.height / 2;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(AltitudeIndicatorPainter oldDelegate) {
    return oldDelegate.altitude != altitude;
  }
}

class AirSpeedIndicatorPainter extends CustomPainter {
  final double airSpeed;

  AirSpeedIndicatorPainter({required this.airSpeed});

  @override
  void paint(Canvas canvas, Size size) {
    // Draw a rectangle to the right side of the canvas
    // Stretching from the very top to the very bottom of the canvas
    final airSpeedRectangle =
        Rect.fromLTWH(0, 0, size.width * 0.15, size.height);
    final paint = Paint()..color = const Color.fromARGB(192, 0, 0, 0);
    canvas.drawRect(airSpeedRectangle, paint);

    // Add a border to the rectangle
    final borderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;
    canvas.drawRect(airSpeedRectangle, borderPaint);

    // Draw a text on the very top of the rectangle reading: Alt
    final textPainter = TextPainter(
      text: const TextSpan(
        text: "A.S. (m/s)",
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 9,
        ),
      ),
      textDirection: TextDirection.ltr,
    );

    textPainter.layout();
    final textX = 0 + (size.width * 0.075) - textPainter.width / 2;
    final textY = size.height * 0.015;
    textPainter.paint(canvas, Offset(textX, textY));

    // draw a line under the text that separates it from the rest of the rectangle
    final linePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1.0;
    canvas.drawLine(Offset(0, size.height * 0.075),
        Offset(0 + (size.width * 0.15), size.height * 0.075), linePaint);

    // Draw the airSpeed value in the rectangle starting from -5000 and going up to 5000 in increments of 100
    // The airSpeedValue value should always be in the middle
    double airSpeedValue = airSpeed;
    const int airSpeedMaxValue = 5000;
    const int airSpeedMinValue = -5000;
    const int airSpeedRange = airSpeedMaxValue - airSpeedMinValue;
    final double airSpeedRectangleHeight = size.height;

    // make a new clip rectangle the size of the airSpeed rectangle
    // except the top of it is size.height * 0.075 lower
    var clipRect = Rect.fromLTWH(0, size.height * 0.075, size.width * 0.15,
        size.height - size.height * 0.075);
    canvas.clipRect(clipRect);

    // draw a red line on the cneter of the rectangle
    final centerLinePaint = Paint()
      ..color = const Color.fromARGB(255, 255, 255, 255)
      ..strokeWidth = 2.0;

    // Draw a line on each side of the center line
    canvas.drawLine(
        Offset(0, airSpeedRectangleHeight / 2 - 8),
        Offset(0 + (size.width * 0.15), airSpeedRectangleHeight / 2 - 8),
        centerLinePaint);
    canvas.drawLine(
        Offset(0, airSpeedRectangleHeight / 2 + 8),
        Offset(0 + (size.width * 0.15), airSpeedRectangleHeight / 2 + 8),
        centerLinePaint);

    // rewrite the same loop above but make sure the airSpeed-value is always on the center
    for (int i = airSpeedMinValue; i <= airSpeedMaxValue; i += 10) {
      double airSpeedLineY = airSpeedRectangleHeight / 2 -
          (airSpeedRectangleHeight *
              ((i - airSpeedValue * 51) / airSpeedRange)) -
          (size.height * 0.05) * (i / 10);

      final linePaint = Paint()
        ..color = Colors.white
        ..strokeWidth = 1.0;

      var textColor = Colors.white;
      if (i < 0) {
        var blackValue = 0 + ((i + 100) * 2.55);
        textColor = Color.fromARGB(
            255, blackValue.toInt(), blackValue.toInt(), blackValue.toInt());
      }

      if (i % 10 == 0) {
        linePaint.color = textColor;
        linePaint.strokeWidth = 2.0;
      }

      // line on the left
      if (i >= 0) {
        canvas.drawLine(Offset(0, airSpeedLineY),
            Offset(0 + (size.width * 0.01), airSpeedLineY), linePaint);

        // line on the right
        canvas.drawLine(Offset(0 + (size.width * 0.15), airSpeedLineY),
            Offset(0 + (size.width * 0.14), airSpeedLineY), linePaint);
      }
      if (i % 10 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: i.toStringAsFixed(0),
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        final textX = 0 + (size.width * 0.075) - textPainter.width / 2;
        final textY = airSpeedLineY - textPainter.height / 2;
        textPainter.paint(canvas, Offset(textX, textY));
      }
    }
  }

  @override
  bool shouldRepaint(AirSpeedIndicatorPainter oldDelegate) {
    return oldDelegate.airSpeed != airSpeed;
  }
}

class VehicleIndicatorPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // draw the left side of the triangle
    final leftSidePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    canvas.drawLine(
        Offset(size.width / 2, size.height / 2),
        Offset(size.width / 2 - (size.width * 0.05),
            size.height / 2 + (size.height * 0.05)),
        leftSidePaint);

    // draw the right side of the triangle
    final rightSidePaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2.0;

    canvas.drawLine(
        Offset(size.width / 2, size.height / 2),
        Offset(size.width / 2 + (size.width * 0.05),
            size.height / 2 + (size.height * 0.05)),
        rightSidePaint);
  }

  @override
  bool shouldRepaint(VehicleIndicatorPainter oldDelegate) {
    return false;
  }
}
