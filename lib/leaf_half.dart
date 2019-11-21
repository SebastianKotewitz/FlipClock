import 'package:flutter/material.dart';

enum _Flap {
  background,
  border,
}

final _lightTheme = {
  _Flap.background: Colors.white,
  _Flap.border: Colors.black,
};

final _darkTheme = {
  _Flap.background: Color(0xFF333333),
  _Flap.border: Colors.black,
};

class LeafHalf extends StatelessWidget {
  const LeafHalf(
    this.widget, {
    this.top = true,
    this.height = 0.0,
  });

  final Widget widget;
  final bool top;
  final double height;

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).brightness == Brightness.light
        ? _lightTheme
        : _darkTheme;
    final borderWidth = 1.0;
    final borderRadius = 4.0;
    return Container(
      decoration: BoxDecoration(
        color: colors[_Flap.background],
        border: Border.all(
          color: colors[_Flap.border],
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
