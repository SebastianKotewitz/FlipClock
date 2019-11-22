import 'package:flutter/material.dart';
import 'dart:math' as math;

enum LeafSize {
  TINY,
  SMALL,
  MEDIUM,
  LARGE,
}

enum LeafRatio {
  SQUARE,
  WIDE,
}

enum Flap {
  backgroundTop,
  backgroundBottom,
  border,
}

final _defaultTheme = {
  Flap.backgroundTop: Colors.white,
  Flap.backgroundBottom: Colors.white,
  Flap.border: Colors.black,
};

class SplitFlapArray extends StatefulWidget {
  const SplitFlapArray(
    this.key,
    this.list, {
    this.colors,
    this.height,
    this.width,
    this.size,
    this.ratio,
  });

  final Key key;
  final List<Widget> list;
  final LeafSize size;
  final LeafRatio ratio;
  final Map<Flap, Color> colors;
  final double height, width;

  @override
  SplitFlapArrayState createState() => SplitFlapArrayState();
}

class SplitFlapArrayState extends State<SplitFlapArray> {
  int _currentIndex = 0;
  int _prevIndex;
  double _rotation = 0.0;
  bool _flipping = false;

  @override
  void initState() {
    super.initState();
    setState(() {
      _prevIndex = widget.list.length - 1;
    });
  }

  final int tickMilliseconds = 20;
  final int catchUpMilliseconds = 5;
  final int durationMilliseconds = 250;

  @override
  Widget build(BuildContext context) {
    final int prevIndex = _prevIndex;
    final LeafSize leafSize = widget.size;
    final LeafRatio leafRatio = widget.ratio;
    final double screenWidth = MediaQuery.of(context).size.width;
    double containerHeight, containerWidth;
    if (widget.height == null) {
      containerHeight = leafSize == LeafSize.TINY
          ? screenWidth / 28.0
          : leafSize == LeafSize.SMALL
              ? screenWidth / 14.0
              : leafSize == LeafSize.MEDIUM
                  ? screenWidth / 6.8
                  : leafSize == LeafSize.LARGE
                      ? screenWidth / 3.4
                      : screenWidth / 14.0;
    } else {
      containerHeight = widget.height;
    }
    if (widget.width == null) {
      containerWidth = leafRatio == LeafRatio.SQUARE
          ? containerHeight
          : leafRatio == LeafRatio.WIDE
              ? containerHeight * 1.8
              : containerHeight;
    } else {
      containerWidth = widget.width;
    }
    final double leafHeight = containerHeight / 2.0;

    //Animation parameters to allow for only one necessary widget controlling the animation
    //The animation flips the next flap onto the front one
    //The animation is repeated quickly if a deeper flap is needed
    final bool rotationFirstHalf = (_rotation <= math.pi / 2);
    final Alignment animationAlign =
        rotationFirstHalf ? Alignment.topCenter : Alignment.bottomCenter;
    final Widget animationWidget =
        rotationFirstHalf ? widget.list[prevIndex] : widget.list[_currentIndex];
    final bool animationTop = rotationFirstHalf;
    final double animationRotation =
        rotationFirstHalf ? _rotation : _rotation + math.pi;
    final colors = widget.colors ?? _defaultTheme;

    return Align(
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxHeight: containerHeight,
          minHeight: containerHeight,
          maxWidth: containerWidth,
          minWidth: containerWidth,
        ),
        child: Stack(
          children: <Widget>[
            Align(
              alignment: Alignment.topCenter,
              child: _LeafHalf(
                widget.list[_currentIndex],
                colors,
                top: true,
                height: leafHeight,
              ),
            ),
            Align(
              alignment: Alignment.bottomCenter,
              child: _LeafHalf(
                _rotation == 0
                    ? widget.list[_currentIndex]
                    : widget.list[prevIndex],
                colors,
                top: false,
                height: leafHeight,
              ),
            ),
            Visibility(
              child: AnimatedPositioned(
                curve: Curves.linear,
                duration: Duration(
                  milliseconds: durationMilliseconds,
                ),
                child: Transform(
                  transform: Matrix4.identity()..rotateX(animationRotation),
                  origin: Offset(containerWidth / 2, containerHeight / 2),
                  child: Align(
                    alignment: animationAlign,
                    child: _LeafHalf(
                      animationWidget,
                      colors,
                      top: animationTop,
                      height: leafHeight,
                    ),
                  ),
                ),
              ),
              visible: _rotation != 0,
            ),
          ],
        ),
      ),
    );
  }

  void changeToIndex(int _index) {
    setState(() {
      _currentIndex = _index;
      _prevIndex = _index;
      _rotation = 0;
      _flipping = false;
    });
  }

  void flipToIndex(int _index) async {
    final int index = _index % widget.list.length;
    if (_currentIndex != index && !_flipping) {
      setState(() {
        _prevIndex = _currentIndex;
        _currentIndex = (_currentIndex + 1) % (widget.list.length);
        _flipping = true;
      });
      final int delay = (index - _currentIndex).abs() <= 1 ||
              (_currentIndex == widget.list.length - 1 && index == 0)
          ? tickMilliseconds
          : catchUpMilliseconds;
      while (_rotation <= math.pi && mounted) {
        setState(() {
          _rotation = _rotation + math.pi / 8;
        });

        await Future.delayed(Duration(milliseconds: delay));
      }
      if (mounted) {
        setState(() {
          _rotation = 0;
          _flipping = false;
        });
        flipToIndex(index);
      }
    }
  }
}

class _LeafHalf extends StatelessWidget {
  const _LeafHalf(
    this.widget,
    this.colors, {
    this.top = true,
    this.height = 0.0,
  });

  final Widget widget;
  final bool top;
  final double height;
  final Map<Flap, Color> colors;

  @override
  Widget build(BuildContext context) {
    final borderWidth = 1.0;
    final borderRadius = 4.0;
    return Container(
      decoration: BoxDecoration(
        color: top ? colors[Flap.backgroundTop] : colors[Flap.backgroundBottom],
        border: Border.all(
          color: colors[Flap.border],
          width: borderWidth,
        ),
        borderRadius: BorderRadius.circular(borderRadius),
      ),
      // height: height,
      child: ClipRect(
        child: Align(
          heightFactor: 0.5,
          alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
          child: Container(
            child: Center(
              child: widget,
            ),
          ),
        ),
      ),
    );
  }
}
