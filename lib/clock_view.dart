import 'package:flutter/material.dart';
import 'dart:math' as math;

import 'package:flutter/services.dart';

class ClockView extends StatefulWidget {
  const ClockView({Key? key}) : super(key: key);

  @override
  _ClockViewState createState() => _ClockViewState();
}

class _ClockViewState extends State<ClockView> with TickerProviderStateMixin {
  late AnimationController animationController;
  TextEditingController minsController = TextEditingController();
  TextEditingController secondsController = TextEditingController();

  String get timerString {
    Duration duration =
        animationController.duration! * animationController.value;
    return '${duration.inMinutes}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}';
  }

  @override
  void initState() {
    super.initState();
    animationController = AnimationController(
        vsync: this,
        duration: const Duration(seconds: 20));
  }

  @override
  Widget build(BuildContext context) {
    ThemeData themeData = Theme.of(context);
    return Scaffold(
        backgroundColor: Color(0xff2d2f41),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.center,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Stack(
                        children: [
                          Positioned.fill(
                              child: AnimatedBuilder(
                            animation: animationController,
                            builder: (context, child) {
                              return CustomPaint(
                                painter: ClockPainter(
                                  animation: animationController,
                                  backgroundColor: Colors.white,
                                  color: themeData.indicatorColor,
                                ),
                              );
                            },
                          )),
                          Align(
                            alignment: FractionalOffset.center,
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  'Count Down',
                                  style: themeData.textTheme.bodyMedium,
                                ),
                                AnimatedBuilder(
                                    animation: animationController,
                                    builder: (context, child) {
                                      return Text(
                                        timerString,
                                        style:
                                            themeData.textTheme.displayMedium,
                                      );
                                    }),
                              ],
                            ),
                          )
                        ],
                      ),
                    ),
                  ),
                ),
                timeInputs(themeData),
                const SizedBox(
                  height: 30,
                ),
                startPauseBtn()
              ],
            ),
          ),
        ));
  }

  Widget timeInputs(themeData) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
            width: 40,
            height: 30,
            child: TextField(
              controller: minsController,
              keyboardType: TextInputType.number,
                inputFormatters:[
                  LengthLimitingTextInputFormatter(2),
                ]
            )),
        Text('Minutes', style: themeData.textTheme.bodyMedium),
        const SizedBox(
          width: 16,
        ),
        Container(
            width: 40,
            height: 30,
            child: TextField(
              inputFormatters:[
                LengthLimitingTextInputFormatter(2),
              ],
              controller: secondsController,
              keyboardType: TextInputType.number,
            )),
        Text('Seconds', style: themeData.textTheme.bodyMedium),
      ],
    );
  }

  Widget startPauseBtn() {
    return Container(
      margin: const EdgeInsets.all(8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: <Widget>[
          FloatingActionButton(
            child: AnimatedBuilder(
              animation: animationController,
              builder: (context, child) {
                return Icon(animationController.isAnimating
                    ? Icons.pause
                    : Icons.play_arrow);
              },
            ),
            onPressed: () {
              // setState(() => isPlaying = !isPlaying);


              if (animationController.isAnimating) {
                animationController.stop(canceled: true);
              } else {

                Duration duration =
                    animationController.duration! * animationController.value;
                if(duration.inMilliseconds == 0) {
                  setState(() {
                    animationController = AnimationController(
                        vsync: this,
                        duration: Duration(
                            minutes: int.parse(
                                minsController.text == '' ? "0" : minsController
                                    .text),
                            seconds: int.parse(
                                secondsController.text == ''
                                    ? "0"
                                    : secondsController.text)));
                  });
                }

                animationController.reverse(
                    from: animationController.value == 0.0
                        ? 1.0
                        : animationController.value);

              }
              setState(() {});
            },
          ),
          FloatingActionButton(
            child: const Icon(Icons.stop),
            onPressed: () {
              minsController.clear();
              secondsController.clear();
              animationController.reset();
              setState(() {

              });
            },
          )
        ],
      ),
    );
  }
}

class ClockPainter extends CustomPainter {
  ClockPainter(
      {required this.animation,
      required this.backgroundColor,
      required this.color});

  final Animation<double> animation;
  final Color backgroundColor, color;

  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = backgroundColor
      ..strokeWidth = 5.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    canvas.drawCircle(size.center(Offset.zero), size.width / 2.0, paint);
    paint.color = color;

    double progress = (1.0 - animation.value) * 2 * math.pi;

    canvas.drawArc(Offset.zero & size, math.pi * 1.5, -progress, false, paint);
  }

  @override
  bool shouldRepaint(covariant ClockPainter oldDelegate) {
    return animation.value != oldDelegate.animation.value ||
        color != oldDelegate.color ||
        backgroundColor != oldDelegate.backgroundColor;
  }
}
