import 'dart:async';

import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

const colorForeground = Color(0xFF3E2723);
const colorElement = Color(0xFFD7CCC8);
const colorBackground = Color(0xFFEFEBE9);

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(title: 'Flutter Demo', theme: ThemeData(), home: const Screen());
  }
}

class Screen extends StatefulWidget {
  const Screen({super.key});

  @override
  State<Screen> createState() => _ScreenState();
}

class _ScreenState extends State<Screen> {
  Timer timer = Timer(Duration.zero, () => ())..cancel();
  Duration duration = Duration.zero;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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

    return Scaffold(
      backgroundColor: colorBackground,
      body: Center(
        child: Column(
          crossAxisAlignment: .center,
          mainAxisAlignment: .center,
          children: [
            Row(
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              spacing: 50,
              children: [
                if (duration == Duration.zero || duration.inHours > 0)
                  Column(
                    children: [
                      Text("${duration.inHours}", style: textStyleDurationValues),
                      Text("Hours", style: textStyleDurationLabel),
                    ],
                  ),
                if (duration == Duration.zero || duration.inMinutes > 0 && duration.inMinutes <= 60)
                  Column(
                    children: [
                      Text(
                        duration.inMinutes.toString().padLeft(2, "0"),
                        style: textStyleDurationValues,
                      ),
                      Text("Minutes", style: textStyleDurationLabel),
                    ],
                  ),
                if (duration == Duration.zero || duration.inSeconds > 0 && duration.inSeconds <= 60)
                  Column(
                    children: [
                      Text(
                        duration.inSeconds.toString().padLeft(2, "0"),
                        style: textStyleDurationValues,
                      ),
                      Text("Seconds", style: textStyleDurationLabel),
                    ],
                  ),
              ],
            ),
            ElevatedButton(
              onPressed: () => setState(() {
                duration = Duration(seconds: 30);
                timer = Timer.periodic(Duration(seconds: 1), onTimerTick);
              }),
              child: Text("30 Sec"),
            ),
          ],
        ),
      ),
    );
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
