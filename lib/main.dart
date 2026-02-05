import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MaterialApp(title: 'Zen Timer', home: const Screen()));
}

const colorForeground = Color(0xFF3E2723);
const colorElement = Color(0xFFD7CCC8);
const colorBackground = Color(0xFFEFEBE9);

const textStyleDurationLabel = TextStyle(
  fontSize: 30,
  fontFamily: "NotoSans",
  fontVariations: [FontVariation.weight(600)],
  color: colorForeground,
);

const textStyleDurationValues = TextStyle(
  fontSize: 100,
  fontFamily: "NotoSans",
  fontVariations: [FontVariation.weight(800)],
  color: colorForeground,
);

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  Timer timer = Timer(Duration.zero, () => ())..cancel();
  Duration duration = Duration.zero;

  int get hours => duration.inHours;

  int get minutes => duration.inMinutes - hours * 60;

  int get seconds => duration.inSeconds - minutes * 60 - hours * 3600;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: Center(
        child: Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          spacing: 50,
          children: [
            Row(
              mainAxisSize: .min,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              spacing: 50,
              children: [
                if (timer.isActive == false || hours > 0)
                  Listener(
                    onPointerSignal: _onHoursScrolled,
                    child: Row(
                      crossAxisAlignment: .baseline,
                      textBaseline: .alphabetic,
                      spacing: 5,
                      children: [
                        Text("$hours", style: textStyleDurationValues),
                        Text("h", style: textStyleDurationLabel),
                      ],
                    ),
                  ),

                if (timer.isActive == false || minutes > 0 && duration.inMinutes < 60)
                  Listener(
                    onPointerSignal: _onMinutesScrolled,
                    child: Row(
                      crossAxisAlignment: .baseline,
                      textBaseline: .alphabetic,
                      spacing: 5,
                      children: [
                        Text(minutes.toString().padLeft(2, "0"), style: textStyleDurationValues),
                        Text("min", style: textStyleDurationLabel),
                      ],
                    ),
                  ),
                if (timer.isActive == false || duration.inSeconds < 60)
                  Listener(
                    onPointerSignal: _onSecondsScrolled,
                    child: Row(
                      crossAxisAlignment: .baseline,
                      textBaseline: .alphabetic,
                      spacing: 5,
                      children: [
                        Text(seconds.toString().padLeft(2, "0"), style: textStyleDurationValues),
                        Text("sec", style: textStyleDurationLabel),
                      ],
                    ),
                  ),
              ],
            ),
            Row(
              crossAxisAlignment: .center,
              mainAxisAlignment: .center,
              spacing: 25,
              children: [
                Button(
                  onPressed: () => setState(() {
                    if (timer.isActive) {
                      timer.cancel();
                    } else {
                      timer = Timer.periodic(Duration(seconds: 1), onTimerTick);
                    }
                  }),
                  icon: timer.isActive ? Icons.stop_sharp : Icons.play_arrow_sharp,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _onHoursScrolled(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final hourChange = (event.scrollDelta.dy > 0)
        ? -1
        : (event.scrollDelta.dy < 0)
        ? 1
        : 0;
    setState(() {
      duration = Duration(hours: max(0, hours + hourChange), minutes: minutes, seconds: seconds);
    });
  }

  void _onMinutesScrolled(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final minuteChange = (event.scrollDelta.dy > 0)
        ? -5
        : (event.scrollDelta.dy < 0)
        ? 5
        : 0;
    setState(() {
      duration = Duration(hours: hours, minutes: max(0, minutes + minuteChange), seconds: seconds);
    });
  }

  void _onSecondsScrolled(PointerSignalEvent event) {
    if (event is! PointerScrollEvent) return;
    final secondChange = (event.scrollDelta.dy > 0)
        ? -15
        : (event.scrollDelta.dy < 0)
        ? 15
        : 0;
    setState(() {
      duration = Duration(hours: hours, minutes: minutes, seconds: max(0, seconds + secondChange));
    });
  }

  void onTimerTick(Timer timer) {
    if (duration < Duration(seconds: 1)) {
      timer.cancel();
      setState(() => duration = Duration.zero);
    } else {
      setState(() => duration -= Duration(seconds: 1));
    }
  }
}

class Button extends StatelessWidget {
  final void Function() onPressed;
  final IconData icon;

  const Button({super.key, required this.onPressed, required this.icon});

  @override
  Widget build(BuildContext context) {
    return Material(
      type: .transparency,
      child: InkWell(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: colorElement,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 80, minHeight: 80),
            child: Icon(icon, size: 40),
          ),
        ),
      ),
    );
  }
}
