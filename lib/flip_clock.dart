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

class FlipClock extends StatefulWidget {
  const FlipClock(this.model);

  final ClockModel model;

  @override
  _FlipClockState createState() => _FlipClockState();
}

class _FlipClockState extends State<FlipClock> {
  final GlobalKey<SplitFlapArrayState> hourKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> minuteKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> secondKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> ampmKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> weatherKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> temperatureFirstKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> temperatureSecondKey = GlobalKey();
  final GlobalKey<SplitFlapArrayState> unitKey = GlobalKey();

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
    final _weather = widget.model.weatherString;
    final _temperature = widget.model.temperature.round();
    final _unit = widget.model.unit;

    // Flip the flaps
    if (_dateTime.hour > 12 && !_is24Hour) {
      hourKey.currentState?.flipToIndex(_dateTime.hour - 12);
    } else if (_dateTime.hour == 0 && !_is24Hour) {
      hourKey.currentState?.flipToIndex(12);
    } else {
      hourKey.currentState?.flipToIndex(_dateTime.hour);
    }
    minuteKey.currentState?.flipToIndex(_dateTime.minute);
    secondKey.currentState?.flipToIndex(_dateTime.second);
    if (_dateTime.hour < 12) {
      ampmKey.currentState?.flipToIndex(0);
    } else {
      ampmKey.currentState?.flipToIndex(1);
    }
    weatherKey.currentState?.flipToIndex(_weatherEnumList.indexOf(_weather));
    unitKey.currentState?.flipToIndex(_unit == TemperatureUnit.celsius ? 0 : 1);
    temperatureFirstKey.currentState?.flipToIndex((_temperature / 10).floor());
    temperatureSecondKey.currentState?.flipToIndex(_temperature % 10);

    final fontSizeLarge = MediaQuery.of(context).size.width / 6;
    final fontSizeSecond = MediaQuery.of(context).size.width / 14;
    final fontSizeMedium = MediaQuery.of(context).size.width / 18;
    final fontSizeWeather = MediaQuery.of(context).size.width / 22;
    final fontSizeSmall = MediaQuery.of(context).size.width / 24;

    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: <Widget>[
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: <Widget>[
            Visibility(
              child: _textFlapArray(ampmKey, ["AM", "PM"], fontSizeSmall,
                  LeafSize.SMALL, LeafRatio.SQUARE),
              visible: !_is24Hour,
            ),
            _numberedFlapArray(
                hourKey, 24, fontSizeLarge, LeafSize.LARGE, LeafRatio.SQUARE),
            _numberedFlapArray(
                minuteKey, 60, fontSizeLarge, LeafSize.LARGE, LeafRatio.SQUARE),
            _numberedFlapArray(secondKey, 60, fontSizeSecond, LeafSize.MEDIUM,
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
            _textFlapArray(weatherKey, _weatherList, fontSizeWeather,
                LeafSize.MEDIUM, LeafRatio.WIDE),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 8,
              ),
            ),
            _numberedFlapArray(temperatureFirstKey, 10, fontSizeMedium,
                LeafSize.SMALL, LeafRatio.SQUARE),
            _numberedFlapArray(temperatureSecondKey, 10, fontSizeMedium,
                LeafSize.SMALL, LeafRatio.SQUARE),
            Container(
              margin: EdgeInsets.symmetric(
                horizontal: 4,
              ),
            ),
            _textFlapArray(unitKey, _unitList, fontSizeSmall, LeafSize.TINY,
                LeafRatio.SQUARE),
          ],
        ),
      ],
    );
  }

  Widget _textFlapArray(Key key, List<String> stringList, double fontSize,
          LeafSize leafSize, LeafRatio leafRatio) =>
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
      if (length > 10) {
        return '$index'.padLeft(2, '0');
      } else {
        return '$index';
      }
    });
    return _textFlapArray(key, list, fontSize, leafSize, leafRatio);
  }
}
