import 'package:flutter/material.dart';

import 'dart:async';
import 'package:flutter_clock_helper/model.dart';
import 'package:flip_clock/split_flap_array.dart';

enum _Element {
  text,
}

final _lightTheme = {
  _Element.text: Colors.white,
};

final _darkTheme = {
  _Element.text: Colors.white,
};

final _weatherEnumList = [
  "cloudy",
  "foggy",
  "rainy",
  "snowy",
  "sunny",
  "thunderstorm",
  "windy",
];

final _weatherList = [
  "Cloudy",
  "Foggy",
  "Rainy",
  "Snowy",
  "Sunny",
  "Thunderstorm",
  "Windy",
];

final _unitList = [
  "°C",
  "°F",
];

final List<String> _temperatureDigitList = List.generate(11, (index) {
  return index != 10 ? index.toString() : " ";
});

final List<String> _temperatureDigitListFahrenheit = List.generate(11, (index) {
  return index < 2 ? index.toString() : " ";
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
  final GlobalKey<SplitFlapArrayState> _weatherKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureSignKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureFirstKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureSecondKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _temperatureThirdKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> _unitKey = GlobalKey();

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
    final _is24Hour = widget.model.is24HourFormat;
    final _isCelsius = widget.model.unit == TemperatureUnit.celsius;
    final _weather = widget.model.weatherString;
    final _temperature = widget.model.temperature.round();

    int _temperatureDigitOne;
    int _temperatureDigitTwo;
    int _temperatureDigitThree;

    if (_isCelsius) {
      _temperatureDigitOne =
          (_temperature.abs() <= 99) ? (_temperature / 10).abs().floor() : 9;
      _temperatureDigitTwo =
          (_temperature.abs() <= 99) ? (_temperature.abs()) % 10 : 9;
      _temperatureDigitThree = 0;

      _temperatureDigitOne =
          _temperature.abs() < 10 ? 10 : _temperatureDigitOne;
    } else {
      _temperatureDigitOne =
          (_temperature.abs() <= 999) ? (_temperature / 100).abs().floor() : 9;
      _temperatureDigitTwo = (_temperature.abs() <= 999)
          ? (_temperature / 10).abs().floor() % 10
          : 9;
      _temperatureDigitThree =
          (_temperature.abs() <= 999) ? (_temperature.abs()) % 10 : 9;

      _temperatureDigitOne =
          _temperature.abs() < 100 ? 2 : _temperatureDigitOne;
      _temperatureDigitTwo =
          _temperature.abs() < 10 ? 10 : _temperatureDigitTwo;
    }

    // Flip the flaps
    if (_dateTime.hour > 12 && !_is24Hour) {
      _flipFlap(_hourKey, _dateTime.hour - 12);
    } else if (_dateTime.hour == 0 && !_is24Hour) {
      _flipFlap(_hourKey, 12);
    } else {
      _flipFlap(_hourKey, _dateTime.hour);
    }
    _flipFlap(_minuteKey, _dateTime.minute);
    _flipFlap(_secondKey, _dateTime.second);
    if (_dateTime.hour < 12) {
      _flipFlap(_ampmKey, 0);
    } else {
      _flipFlap(_ampmKey, 1);
    }
    _flipFlap(_weatherKey, _weatherEnumList.indexOf(_weather));
    _flipFlap(_temperatureSignKey, (_temperature >= 0) ? 0 : 1);
    _flipFlap(_temperatureFirstKey, _temperatureDigitOne);
    _flipFlap(_temperatureSecondKey, _temperatureDigitTwo);
    _flipFlap(_temperatureThirdKey, _temperatureDigitThree);
    _flipFlap(_unitKey, _isCelsius ? 0 : 1);

    final screenWidth = MediaQuery.of(context).size.width;

    final fontSizeLarge = screenWidth / 5;
    final fontSizeSecond = screenWidth / 14;
    final fontSizeMedium = screenWidth / 18;
    final fontSizeWeather = screenWidth / 22;
    final fontSizeSmall = screenWidth / 24;
    final _raiseTemperatureUnitHeight = screenWidth / 500;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Visibility(
              child: _textFlapArray(_ampmKey, ["AM", "PM"], fontSizeSmall,
                  LeafSize.SMALL, LeafRatio.SQUARE),
              visible: !_is24Hour,
            ),
            _numberedFlapArray(
                _hourKey, 24, fontSizeLarge, LeafSize.LARGE, LeafRatio.SQUARE),
            _numberedFlapArray(_minuteKey, 60, fontSizeLarge, LeafSize.LARGE,
                LeafRatio.SQUARE),
            _numberedFlapArray(_secondKey, 60, fontSizeSecond, LeafSize.MEDIUM,
                LeafRatio.SQUARE),
          ]
              .map(
                (element) => Container(
                  child: element,
                  margin: EdgeInsets.symmetric(
                    horizontal: 4,
                  ),
                ),
              )
              .toList(),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            _textFlapArray(_weatherKey, _weatherList, fontSizeWeather,
                LeafSize.MEDIUM, LeafRatio.WIDE),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),
            _textFlapArray(_temperatureSignKey, [" ", "-"], fontSizeMedium,
                LeafSize.TINY, LeafRatio.SQUARE),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 4,
              ),
            ),
            _textFlapArray(
                _temperatureFirstKey,
                _isCelsius
                    ? _temperatureDigitList
                    : _temperatureDigitListFahrenheit,
                fontSizeMedium,
                LeafSize.SMALL,
                LeafRatio.SQUARE),
            _textFlapArray(_temperatureSecondKey, _temperatureDigitList,
                fontSizeMedium, LeafSize.SMALL, LeafRatio.SQUARE),
            Visibility(
              child: _textFlapArray(_temperatureThirdKey, _temperatureDigitList,
                  fontSizeMedium, LeafSize.SMALL, LeafRatio.SQUARE),
              visible: !_isCelsius,
            ),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 4,
              ),
            ),
            _textFlapArray(_unitKey, _unitList, fontSizeSmall, LeafSize.TINY,
                LeafRatio.SQUARE,
                overrideTextStyle: TextStyle(
                  height: _raiseTemperatureUnitHeight,
                )),
          ],
        ),
      ],
    );
  }

  void _flipFlap(GlobalKey<SplitFlapArrayState> key, int index) {
    key.currentState?.flipToIndex(index);
  }

  Widget _textFlapArray(Key key, List<String> stringList, double fontSize,
          LeafSize leafSize, LeafRatio leafRatio,
          {TextStyle overrideTextStyle}) =>
      Container(
        color: Theme.of(context).canvasColor,
        child: SplitFlapArray(
          key,
          List.generate(stringList.length, (index) {
            return Text(
              stringList[index],
              style: TextStyle(
                fontSize: fontSize,
                fontWeight: Theme.of(context).brightness == Brightness.dark
                    ? FontWeight.w700
                    : FontWeight.w300,
                fontStyle: FontStyle.italic,
              ).merge(
                overrideTextStyle,
              ),
            );
          }),
          leafSize,
          leafRatio,
        ),
      );

  Widget _numberedFlapArray(Key key, int length, double fontSize,
      LeafSize leafSize, LeafRatio leafRatio) {
    final List<String> list = List.generate(length, (index) {
      return '$index'.padLeft(2, '0');
    });
    return _textFlapArray(key, list, fontSize, leafSize, leafRatio);
  }
}
