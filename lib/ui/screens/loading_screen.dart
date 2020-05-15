import 'dart:math';
import 'dart:wasm';

import 'package:flutter/material.dart';

class LoadingScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Container(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.end,
            children: <Widget>[
              AnimtedLoadingIcon(),
              SizedBox(height: 1),
              Opacity(
                opacity: 0.5,
                child: ShaderMask(
                  shaderCallback: (rect) {
                    return LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black,
                        Colors.black.withOpacity(0.8),
                        Colors.black.withOpacity(0.6),
                        Colors.black.withOpacity(0.4),
                        Colors.transparent,
                      ],
                      stops: [
                        0.0,
                        0.2,
                        0.4,
                        0.6,
                        1.0,
                      ],
                    ).createShader(Rect.fromLTRB(0, 0, rect.width, rect.height));
                  },
                  blendMode: BlendMode.dstIn,
                  child: Transform(
                    alignment: Alignment.center,
                    transform: Matrix4.rotationX(pi),
                    child: AnimtedLoadingIcon(),
                  ),
                ),
              ),
              SizedBox(height: 16),
              Text("Infinity.", style: TextStyle(color: Colors.white, fontSize: 24,fontWeight: FontWeight.bold)),
              SizedBox(height: 64),
            ],
          ),
        ),
      ),
    );
  }
}

class AnimtedLoadingIcon extends StatefulWidget {
  const AnimtedLoadingIcon({
    Key key,
  }) : super(key: key);

  @override
  _AnimtedLoadingIconState createState() => _AnimtedLoadingIconState();
}

class _AnimtedLoadingIconState extends State<AnimtedLoadingIcon> with SingleTickerProviderStateMixin {
  AnimationController animController;
  Animation animation;

  _AnimtedLoadingIconState() {
    animController = AnimationController(vsync: this, duration: Duration(milliseconds: 1500))
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed) {
          animController.repeat();
        }
      });
    animation = IntTween(begin: 0, end: 360).animate(animController);
  }

  @override
  void initState() {
    super.initState();
    animController.forward();
  }

  @override
  void dispose() {
    animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animController,
      builder: (context, child) {
        return Transform.rotate(
          angle: animation.value * pi / 180,
          child: child,
        );
      },
      child: Container(
        width: 100,
        height: 100,
        child: AspectRatio(
          aspectRatio: 1.0,
          child: CustomPaint(
            painter: _LoadingCirclePainter(),
          ),
        ),
      ),
    );
  }
}

class _LoadingCirclePainter extends CustomPainter {
  final Color startColor = Color(0xFFB80B18);
  final Color endColor = Color(0xFF5D0710);
  final double strokeWidth = 24;
  Gradient _radialGradient;
  Paint circlePaint = Paint()
    ..style = PaintingStyle.stroke
    ..color = Colors.white
    ..strokeCap = StrokeCap.round;

  _LoadingCirclePainter() {
    _radialGradient = LinearGradient(colors: [startColor, endColor, endColor.withOpacity(0.0)], stops: [0.0, 0.5, 1.0]);
    circlePaint.strokeWidth = strokeWidth;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var centerPoint = Offset(size.width / 2, size.height / 2);
    var minLength = min(size.width, size.height);
    var circleRadius = (minLength / 2) - strokeWidth / 2;
    // create a bounding square, based on the centre and radius of the arc
    Rect rect = new Rect.fromCircle(
      center: centerPoint,
      radius: minLength / 2,
    );

    // a fancy rainbow gradient
    Gradient gradient = new SweepGradient(
      colors: <Color>[
        endColor.withOpacity(0.0),
        endColor,
        startColor,
      ],
      stops: [
        0.0,
        0.5,
        0.95,
      ],
    );

    // create the Shader from the gradient and the bounding square
    circlePaint.shader = gradient.createShader(rect);
//    var strokeWidth = radius * 0.6;
//    circlePaint.strokeWidth = strokeWidth;

    var rad = pi / 180;
    var startAngle = (strokeWidth * 1.2) * rad;
    var endAngle = (360 - strokeWidth - strokeWidth * 1.8) * rad;
    final path = Path();
    var innerRect = Rect.fromCircle(center: centerPoint, radius: circleRadius);
    path.arcTo(innerRect, startAngle, endAngle, false);
//    path.arcTo(rect, endAngle, endAngle, false);

    // and draw an arc
    canvas.drawPath(path, circlePaint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }
}
