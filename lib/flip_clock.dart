import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter_clock_helper/model.dart';
import 'package:flip_clock/split_flap_array.dart';

final _lightFlapTheme = {
  Flap.backgroundTop: Color(0xFFF7F7F7),
  Flap.backgroundBottom: Colors.white,
  Flap.border: Color(0xFF8B8B8B),
};

final _darkFlapTheme = {
  Flap.backgroundTop: Color(0xFF222222),
  Flap.backgroundBottom: Color(0xFF2D2D2D),
  Flap.border: Colors.black,
};

enum _ClockFace {
  background,
  fontWeight,
}

final _lightTheme = {
  _ClockFace.background: Color(0xFFFCFCFC),
  _ClockFace.fontWeight: FontWeight.w300,
};

final _darkTheme = {
  _ClockFace.background: Color(0xFFFF181818),
  _ClockFace.fontWeight: FontWeight.w700,
};

final _weekdays = [
  "Mon",
  "Tue",
  "Wed",
  "Thu",
  "Fri",
  "Sat",
  "Sun",
];

final _days = List.generate(31, (index) => (index + 1).toString());
final _months = [
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Okt",
  "Nov",
  "Dec",
];

final _unitList = [
  "°C",
  "°F",
];

final List<String> _temperatureDigitList = List.generate(11, (index) {
  return index != 10 ? index.toString() : " ";
});

final List<String> _ampmDigitList = List.generate(24, (index) {
  if (index == 0) {
    return "12";
  } else if (index >= 1 && index <= 12) {
    return index.toString();
  } else {
    return (index - 12).toString();
  }
});

class FlipClock extends StatefulWidget {
  const FlipClock(this.model);

  final ClockModel model;

  @override
  _FlipClockState createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> {
  final GlobalKey<SplitFlapArrayState> _hourKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _minuteKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _secondKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _ampmKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _weekdayKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _dayKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _monthKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureSignKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureFirstKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureSecondKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureThirdKey = GlobalKey();

  DateTime _dateTime = DateTime.now();
  Timer _timer;

  @override
  void initState() {
    super.initState();
    widget.model.addListener(_updateModel);
    _updateTime();
    _updateModel();
  }

  @override
  void didUpdateWidget(FlipClock oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.model != oldWidget.model) {
      oldWidget.model.removeListener(_updateModel);
      widget.model.addListener(_updateModel);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    widget.model.removeListener(_updateModel);
    widget.model.dispose();
    super.dispose();
  }

  void _updateModel() {
    setState(() {});
  }

  void _updateTime() {
    setState(() {
      _dateTime = DateTime.now();
      // _timer = Timer(
      //   Duration(minutes: 1) -
      //       Duration(seconds: _dateTime.second) -
      //       Duration(milliseconds: _dateTime.millisecond),
      //   _updateTime,
      // );
      // Update once per second, but make sure to do it at the beginning of each
      // new second, so that the clock is accurate.
      _timer = Timer(
        Duration(seconds: 1) - Duration(milliseconds: _dateTime.millisecond),
        _updateTime,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final _light = Theme.of(context).brightness == Brightness.light;
    final _theme = _light ? _lightTheme : _darkTheme;

    final _is24Hour = widget.model.is24HourFormat;
    final _isCelsius = widget.model.unit == TemperatureUnit.celsius;
    final _temperature = widget.model.temperature.round();

    int _temperatureDigitOne;
    int _temperatureDigitTwo;
    int _temperatureDigitThree;

    final _absTemp = _temperature.round().abs();

    _temperatureDigitOne = _absTemp % 100 % 10;
    _temperatureDigitTwo = ((_absTemp % 100) / 10).floor();
    _temperatureDigitThree = (_absTemp >= 100) ? 1 : 0;

    _temperatureDigitTwo = (_absTemp < 10) ? 10 : _temperatureDigitTwo;
    if (_isCelsius && _absTemp > 99) {
      _temperatureDigitOne = 9;
      _temperatureDigitTwo = 9;
    } else if (_absTemp > 199) {
      _temperatureDigitOne = 9;
      _temperatureDigitTwo = 9;
    }

    // Flip the flaps
    _flipFlap(_hourKey, _dateTime.hour);
    _flipFlap(_ampmKey, _dateTime.hour);
    _flipFlap(_minuteKey, _dateTime.minute);
    _flipFlap(_secondKey, _dateTime.second);
    _flipFlap(_temperatureSignKey, (_temperature >= 0) ? 0 : 1);
    _flipFlap(_weekdayKey, _dateTime.weekday - 1);
    _flipFlap(_dayKey, _dateTime.day - 1);
    _flipFlap(_monthKey, _dateTime.month - 1);
    _flipFlap(_temperatureFirstKey, _temperatureDigitOne);
    _flipFlap(_temperatureSecondKey, _temperatureDigitTwo);
    _flipFlap(_temperatureThirdKey, _temperatureDigitThree);

    final _screenWidth = MediaQuery.of(context).size.width;

    final fontSizeLarge = _screenWidth / 4.5;
    final fontSizeSecond = _screenWidth / 12;
    final fontSizeMedium = _screenWidth / 18;
    final fontSizeSmall = _screenWidth / 24;
    final _margin = _screenWidth / 173;

    return Container(
      color: _theme[_ClockFace.background],
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              // Visibility(
              //   child: _textFlapArray(_ampmKey, ["AM", "PM"], fontSizeSmall,
              //       LeafSize.SMALL, LeafRatio.SQUARE),
              //   visible: !_is24Hour,
              // ),
              _is24Hour
                  ? _numberedFlapArray(_hourKey, 24, fontSizeLarge,
                      LeafSize.LARGE, LeafRatio.SQUARE)
                  : _ampmFlapArray(_ampmKey, _ampmDigitList, fontSizeLarge,
                      LeafSize.LARGE, LeafRatio.SQUARE),
              Container(
                margin: EdgeInsets.symmetric(horizontal: _margin * 2),
                child: _numberedFlapArray(_minuteKey, 60, fontSizeLarge,
                    LeafSize.LARGE, LeafRatio.SQUARE),
              ),
              _numberedFlapArray(_secondKey, 60, fontSizeSecond,
                  LeafSize.MEDIUM, LeafRatio.SQUARE),
            ],
          ),
          Container(
            width: (_screenWidth / 3.4) * 2.5 + _margin * 4,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: <Widget>[
                    _textFlapArray(_weekdayKey, _weekdays, fontSizeMedium,
                        LeafSize.SMALL, LeafRatio.WIDE,
                        overrideTextStyle: TextStyle(height: 1.1)),
                    Container(
                      margin: EdgeInsets.symmetric(horizontal: _margin),
                      child: _textFlapArray(_dayKey, _days, fontSizeMedium,
                          LeafSize.SMALL, LeafRatio.SQUARE),
                    ),
                    _textFlapArray(_monthKey, _months, fontSizeMedium,
                        LeafSize.SMALL, LeafRatio.WIDE),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    Container(
                      margin: EdgeInsets.only(right: _margin),
                      child: _textFlapArray(_temperatureSignKey, [" ", "-"],
                          fontSizeSmall, LeafSize.TINY, LeafRatio.SQUARE),
                    ),
                    Visibility(
                      child: Container(
                        margin: EdgeInsets.only(right: _margin),
                        child: _textFlapArray(_temperatureThirdKey, [" ", "1"],
                            fontSizeMedium, LeafSize.SMALL, LeafRatio.SQUARE),
                      ),
                      visible: !_isCelsius,
                    ),
                    Container(
                      margin: EdgeInsets.only(right: _margin),
                      child: _textFlapArray(
                          _temperatureSecondKey,
                          _temperatureDigitList,
                          fontSizeMedium,
                          LeafSize.SMALL,
                          LeafRatio.SQUARE),
                    ),
                    Container(
                      margin: EdgeInsets.only(right: _margin),
                      child: _textFlapArray(
                          _temperatureFirstKey,
                          _temperatureDigitList,
                          fontSizeMedium,
                          LeafSize.SMALL,
                          LeafRatio.SQUARE),
                    ),
                    Container(
                      child: Text(
                        _unitList[_isCelsius ? 0 : 1],
                        style: TextStyle(
                          fontStyle: FontStyle.italic,
                          fontSize: fontSizeMedium,
                          fontWeight: _theme[_ClockFace.fontWeight],
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _flipFlap(GlobalKey<SplitFlapArrayState> key, int index) {
    key.currentState?.flipToIndex(index);
  }

  Widget _textFlapArray(Key key, List<String> stringList, double fontSize,
      LeafSize leafSize, LeafRatio leafRatio,
      {TextStyle overrideTextStyle}) {
    return SplitFlapArray(
      key,
      List.generate(
        stringList.length,
        (index) => Text(
          stringList[index],
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: Theme.of(context).brightness == Brightness.light
                ? _lightTheme[_ClockFace.fontWeight]
                : _darkTheme[_ClockFace.fontWeight],
            fontStyle: FontStyle.italic,
          ).merge(overrideTextStyle),
        ),
      ),
      size: leafSize,
      ratio: leafRatio,
      colors: Theme.of(context).brightness == Brightness.light
          ? _lightFlapTheme
          : _darkFlapTheme,
    );
  }

  Widget _numberedFlapArray(Key key, int length, double fontSize,
      LeafSize leafSize, LeafRatio leafRatio) {
    final List<String> list = List.generate(length, (index) {
      return '$index'.padLeft(2, '0');
    });
    return _textFlapArray(key, list, fontSize, leafSize, leafRatio);
  }

  Widget _ampmFlapArray(Key key, List<String> list, double fontSize,
      LeafSize leafSize, LeafRatio leafRatio) {
    return SplitFlapArray(
      key,
      List.generate(list.length, (index) {
        final ampm = (index < 13) ? "am" : "pm";
        final fontWeight = Theme.of(context).brightness == Brightness.light
            ? _lightTheme[_ClockFace.fontWeight]
            : _darkTheme[_ClockFace.fontWeight];
        return Container(
          width: double.maxFinite,
          height: double.maxFinite,
          child: Stack(
            alignment: Alignment.center,
            children: <Widget>[
              Positioned(
                left: 8,
                bottom: 8,
                child: Container(
                  child: Text(ampm,
                      style: TextStyle(
                        fontSize: fontSize / 5,
                        fontWeight: fontWeight,
                        fontStyle: FontStyle.italic,
                      )),
                ),
              ),
              Positioned(
                child: Text(
                  list[index].padLeft(2, "  "),
                  style: TextStyle(
                    fontSize: fontSize,
                    fontWeight: fontWeight,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            ],
          ),
        );
      }),
      size: leafSize,
      ratio: leafRatio,
      colors: Theme.of(context).brightness == Brightness.light
          ? _lightFlapTheme
          : _darkFlapTheme,
    );
  }
}
