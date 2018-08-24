import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class _JumpingDot extends AnimatedWidget {
  final Color color;
  final double fontSize;
  _JumpingDot({Key key, Animation<double> animation, this.color, this.fontSize})
      : super(key: key, listenable: animation);

  Widget build(BuildContext context) {
    final Animation<double> animation = listenable;
    return Container(
      height: animation.value,
      child: Text(
        '.',
        style: TextStyle(color: color, fontSize: fontSize),
      ),
    );
  }
}

class JumpingDotsProgressIndicator extends StatefulWidget {
  final int numberOfDots;
  final double fontSize;
  final double dotSpacing;
  final Color color;
  final int milliseconds;
  final double beginTweenValue = 0.0;
  final double endTweenValue = 8.0;

  JumpingDotsProgressIndicator({
    this.numberOfDots = 3,
    this.fontSize = 10.0,
    this.color = Colors.black,
    this.dotSpacing = 0.0,
    this.milliseconds = 250,
  });

  _JumpingDotsProgressIndicatorState createState() =>
      _JumpingDotsProgressIndicatorState(
        numberOfDots: this.numberOfDots,
        fontSize: this.fontSize,
        color: this.color,
        dotSpacing: this.dotSpacing,
        milliseconds: this.milliseconds,
      );
}

class _JumpingDotsProgressIndicatorState
    extends State<JumpingDotsProgressIndicator>
    with SingleTickerProviderStateMixin {
  int numberOfDots;
  int milliseconds;
  double fontSize;
  double dotSpacing;
  Color color;
  AnimationController controller;
  List<Animation<double>> animations;
  List<Widget> _widgets;

  _JumpingDotsProgressIndicatorState({
    this.numberOfDots,
    this.fontSize,
    this.color,
    this.dotSpacing,
    this.milliseconds,
  });

  initState() {
    super.initState();

    final totalDuration =
        Duration(milliseconds: widget.milliseconds * widget.numberOfDots);
    controller = AnimationController(duration: totalDuration, vsync: this);
    controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        //restarting animation
        controller.reset();
        controller.forward();
      }
    });

    // setting up animations for each dot
    final _jumpDurationInterval = 1.0 / widget.numberOfDots;
    animations = List.generate(widget.numberOfDots,
        (index) => _generateDotAnimation(index, _jumpDurationInterval));

    // populate widgets
    _widgets = List.generate(widget.numberOfDots, _createDot);

    // start animation
    controller.forward();
  }

  Animation<double> _generateDotAnimation(
      int index, double jumpDurationInterval) {
    var begin = index * jumpDurationInterval;
    var upAnimation = CurvedAnimation(
        parent: controller,
        curve: Interval(begin, begin + jumpDurationInterval));

    Animation<double> downAnimation = CurvedAnimation(
        parent: controller,
        curve: Interval(begin, begin + jumpDurationInterval));

    downAnimation = Tween(begin: 1.0, end: 0.0).animate(downAnimation);

    return Tween<double>(
            begin: widget.beginTweenValue,
            end: widget.endTweenValue *
                2) // to compensate using AnimationMin (max value is 0.5)
        .animate(AnimationMin(upAnimation, downAnimation));
  }

  Widget _createDot(int index) => Padding(
        padding: EdgeInsets.only(right: dotSpacing),
        child: _JumpingDot(
          animation: animations[index],
          fontSize: fontSize,
          color: color,
        ),
      );

  Widget build(BuildContext context) {
    return SizedBox(
      height: 30.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: _widgets,
      ),
    );
  }

  dispose() {
    controller.dispose();
    super.dispose();
  }
}
