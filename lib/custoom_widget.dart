//import 'dart:math';

import 'package:flutter/material.dart';
import 'dart:math' as math;

enum CircularStrokeCap { butt, round, square }

enum ArcType {
  HALF,
  FULL,
}

class CircularPercentIndicator extends StatefulWidget {
  final double percent;
  final double radius;
  final double lineWidth;
  final double backgroundWidth;
  final Color fillColor;
  final Color backgroundColor;

  Color get progressColor => _progressColor;

  Color _progressColor;
  final bool animation;

  final int animationDuration;

  final Widget header;

  final Widget footer;

  final Widget center;

  final LinearGradient linearGradient;

  final CircularStrokeCap circularStrokeCap;

  final double startAngle;

  final bool animateFromLastPercent;

  final bool addAutomaticKeepAlive;

  final ArcType arcType;

  final Color arcBackgroundColor;

  final bool reverse;

  final MaskFilter maskFilter;

  final Curve curve;

  final bool restartAnimation;

  CircularPercentIndicator(
      {Key key,
        this.percent = 0.0,
        this.lineWidth = 5.0,
        this.startAngle = 0.0,
        @required this.radius,
        this.fillColor = Colors.transparent,
        this.backgroundColor = const Color(0xFFB8C7CB),
        Color progressColor,
        this.backgroundWidth = -1, //negative values ignored, replaced with lineWidth
        this.linearGradient,
        this.animation = false,
        this.animationDuration = 500,
        this.header,
        this.footer,
        this.center,
        this.addAutomaticKeepAlive = true,
        this.circularStrokeCap,
        this.arcBackgroundColor,
        this.arcType,
        this.animateFromLastPercent = false,
        this.reverse = false,
        this.curve = Curves.linear,
        this.maskFilter,
        this.restartAnimation = false})
      : super(key: key) {
    if (linearGradient != null && progressColor != null) {
      throw ArgumentError('Cannot provide both linearGradient and progressColor');
    }
    _progressColor = progressColor ?? Colors.red;

    assert(startAngle >= 0.0);
    assert(curve != null);
    if (percent < 0.0 || percent > 1.0) {
      throw Exception("Percent value must be a double between 0.0 and 1.0");
    }

    if (arcType == null && arcBackgroundColor != null) {
      throw ArgumentError('arcType is required when you arcBackgroundColor');
    }
  }

  @override
  _CircularPercentIndicatorState createState() => _CircularPercentIndicatorState();
}

class _CircularPercentIndicatorState extends State<CircularPercentIndicator>
    with SingleTickerProviderStateMixin, AutomaticKeepAliveClientMixin {
  AnimationController _animationController;
  Animation _animation;
  double _percent = 0.0;

  @override
  void dispose() {
    if (_animationController != null) {
      _animationController.dispose();
    }
    super.dispose();
  }

  @override
  void initState() {
    if (widget.animation) {
      _animationController =
          AnimationController(vsync: this, duration: Duration(milliseconds: widget.animationDuration));
      _animation = Tween(begin: 0.0, end: widget.percent).animate(
        CurvedAnimation(parent: _animationController, curve: widget.curve),
      )..addListener(() {
        setState(() {
          _percent = _animation.value;
        });
        if (widget.restartAnimation && _percent == 1.0) {
          _animationController.repeat(min: 0, max: 1.0);
        }
      });
      _animationController.forward();
    } else {
      _updateProgress();
    }
    super.initState();
  }

  @override
  void didUpdateWidget(CircularPercentIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.percent != widget.percent || oldWidget.startAngle != widget.startAngle) {
      if (_animationController != null) {
        _animationController.duration = Duration(milliseconds: widget.animationDuration);
        _animation = Tween(begin: widget.animateFromLastPercent ? oldWidget.percent : 0.0, end: widget.percent).animate(
          CurvedAnimation(parent: _animationController, curve: widget.curve),
        );
        _animationController.forward(from: 0.0);
      } else {
        _updateProgress();
      }
    }
  }

  _updateProgress() {
    setState(() {
      _percent = widget.percent;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    var items = List<Widget>();
    if (widget.header != null) {
      items.add(widget.header);
    }
    items.add(Container(
        height: widget.radius + widget.lineWidth,
        width: widget.radius,
        child: CustomPaint(
          painter: CirclePainter(
              progress: _percent * 360,
              progressColor: widget.progressColor,
              backgroundColor: widget.backgroundColor,
              startAngle: widget.startAngle,
              circularStrokeCap: widget.circularStrokeCap,
              radius: (widget.radius / 2) - widget.lineWidth / 2,
              lineWidth: widget.lineWidth,
              backgroundWidth: //negative values ignored, replaced with lineWidth
              widget.backgroundWidth >= 0.0?
              (widget.backgroundWidth): widget.lineWidth,
              arcBackgroundColor: widget.arcBackgroundColor,
              arcType: widget.arcType,
              reverse: widget.reverse,
              linearGradient: widget.linearGradient,
              maskFilter: widget.maskFilter),
          child: (widget.center != null) ? Center(child: widget.center) : Container(),
        )));

    if (widget.footer != null) {
      items.add(widget.footer);
    }

    return Material(
      color: widget.fillColor,
      child: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: items,
          )),
    );
  }

  @override
  bool get wantKeepAlive => widget.addAutomaticKeepAlive;
}

class CirclePainter extends CustomPainter {
  final Paint _paintBackground = Paint();
  final Paint _paintLine = Paint();
  final Paint _paintBackgroundStartAngle = Paint();
  final double lineWidth;
  final double backgroundWidth;
  final double progress;
  final double radius;
  final Color progressColor;
  final Color backgroundColor;
  final CircularStrokeCap circularStrokeCap;
  final double startAngle;
  final LinearGradient linearGradient;
  final Color arcBackgroundColor;
  final ArcType arcType;
  final bool reverse;
  final MaskFilter maskFilter;

  CirclePainter(
      {this.lineWidth,
        this.backgroundWidth,
        this.progress,
        @required this.radius,
        this.progressColor,
        this.backgroundColor,
        this.startAngle = 0.0,
        this.circularStrokeCap = CircularStrokeCap.round,
        this.linearGradient,
        this.reverse,
        this.arcBackgroundColor,
        this.arcType,
        this.maskFilter}) {
    _paintBackground.color = backgroundColor;
    _paintBackground.style = PaintingStyle.stroke;
    _paintBackground.strokeWidth = backgroundWidth;

    if (arcBackgroundColor != null) {
      _paintBackgroundStartAngle.color = arcBackgroundColor;
      _paintBackgroundStartAngle.style = PaintingStyle.stroke;
      _paintBackgroundStartAngle.strokeWidth = lineWidth;
      if (circularStrokeCap == CircularStrokeCap.round) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.round;
      } else if (circularStrokeCap == CircularStrokeCap.butt) {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.butt;
      } else {
        _paintBackgroundStartAngle.strokeCap = StrokeCap.square;
      }
    }

    _paintLine.color = progressColor;
    _paintLine.style = PaintingStyle.stroke;
    _paintLine.strokeWidth = lineWidth;
    if (circularStrokeCap == CircularStrokeCap.round) {
      _paintLine.strokeCap = StrokeCap.round;
    } else if (circularStrokeCap == CircularStrokeCap.butt) {
      _paintLine.strokeCap = StrokeCap.butt;
    } else {
      _paintLine.strokeCap = StrokeCap.square;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawCircle(center, radius, _paintBackground);

    if (maskFilter != null) {
      _paintLine.maskFilter = maskFilter;
    }
    if (linearGradient != null) {
      /*
      _paintLine.shader = SweepGradient(
              center: FractionalOffset.center,
              startAngle: math.radians(-90.0 + startAngle),
              endAngle: math.radians(progress),
              //tileMode: TileMode.mirror,
              colors: linearGradient.colors)
          .createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );*/
      _paintLine.shader = linearGradient.createShader(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
      );
    }

    double fixedStartAngle = startAngle;

    double startAngleFixedMargin = 1.0;
    if (arcType != null) {
      if (arcType == ArcType.FULL) {
        fixedStartAngle = 220;
        startAngleFixedMargin = 172 / fixedStartAngle;
      } else {
        fixedStartAngle = 270;
        startAngleFixedMargin = 135 / fixedStartAngle;
      }
    }

    if (arcBackgroundColor != null) {
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        radians(-90.0 + fixedStartAngle),
        radians(360 * startAngleFixedMargin),
        false,
        _paintBackgroundStartAngle,
      );
    }

    if (reverse) {
      final start = radians(360 * startAngleFixedMargin - 90.0 + fixedStartAngle);
      final end = radians(-progress * startAngleFixedMargin);
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        end,
        false,
        _paintLine,
      );
    } else {
      final start = radians(-90.0 + fixedStartAngle);
      final end = radians(progress * startAngleFixedMargin);
      canvas.drawArc(
        Rect.fromCircle(
          center: center,
          radius: radius,
        ),
        start,
        end,
        false,
        _paintLine,
      );
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return true;
  }

  num radians(num deg) => deg * (math.pi / 180.0);
}
