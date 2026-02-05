import 'dart:async';
import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_fullscreen/flutter_fullscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await FullScreen.ensureInitialized();

  runApp(MaterialApp(title: 'Zen Timer', home: const Screen()));
}

const colorForeground = Color(0xFF3E2723); // 9 44 24
const colorBackground = Color(0xFFD7CCC8); // 20 3 94

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

  bool isMouseOverWindow = false;

  @override
  void dispose() {
    timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: colorBackground,
      body: MouseRegion(
        onEnter: (event) => setState(() => isMouseOverWindow = true),
        onExit: (event) => setState(() => isMouseOverWindow = false),
        child: Column(
          mainAxisAlignment: .center,
          crossAxisAlignment: .center,
          children: [
            Row(
              mainAxisSize: .max,
              mainAxisAlignment: .center,
              crossAxisAlignment: .center,
              spacing: 50,
              children: [
                if (timer.isActive == false || hours > 0)
                  AnimatedScrollableIntValueDisplay(
                    onScrolledUp: () => _modifyDuration(const Duration(hours: 1)),
                    onScrolledDown: () => _modifyDuration(const Duration(hours: -1)),
                    value: hours,
                    leftPadAmount: timer.isActive ? 1 : 2,
                    label: "h",
                  ),

                if (timer.isActive == false || minutes > 0 && duration.inMinutes < 60)
                  AnimatedScrollableIntValueDisplay(
                    onScrolledUp: () => _modifyDuration(const Duration(minutes: 5)),
                    onScrolledDown: () => _modifyDuration(const Duration(minutes: -5)),
                    value: minutes,
                    leftPadAmount: timer.isActive ? 1 : 2,
                    label: "min",
                  ),

                if (timer.isActive == false || duration.inSeconds < 60)
                  AnimatedScrollableIntValueDisplay(
                    onScrolledUp: () => _modifyDuration(const Duration(seconds: 15)),
                    onScrolledDown: () => _modifyDuration(const Duration(seconds: -15)),
                    value: seconds,
                    leftPadAmount: timer.isActive ? 1 : 2,
                    label: "sec",
                  ),
              ],
            ),
            AnimatedCrossFade(
              crossFadeState: isMouseOverWindow ? .showSecond : .showFirst,
              duration: const Duration(milliseconds: 750),
              firstCurve: Curves.decelerate,
              secondCurve: Curves.decelerate,
              sizeCurve: Curves.decelerate,
              alignment: .center,
              firstChild: SizedBox(),
              secondChild: Padding(
                padding: EdgeInsets.only(top: 20),
                child: Row(
                  crossAxisAlignment: .center,
                  mainAxisAlignment: .center,
                  spacing: 20,
                  children: [
                    Button(
                      onPressed: _onPlayPauseButtonTap,
                      icon: timer.isActive ? Icons.pause : Icons.play_arrow,
                    ),
                    Button(onPressed: _onStopButtonTap, icon: Icons.stop),
                    Button(
                      onPressed: _onFullScreenButtonTap,
                      icon: FullScreen.isFullScreen ? Icons.fullscreen_exit : Icons.fullscreen,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// ---------------------------------------------------------------------------------------------------
  void _onFullScreenButtonTap() {
    FullScreen.setFullScreen(FullScreen.isFullScreen == false, systemUiMode: .immersive);
    setState(() {}); // button's icon has to change
  }

  /// ---------------------------------------------------------------------------------------------------
  void _modifyDuration(Duration changeBy) {
    setState(() {
      final newDuration = duration + changeBy;
      duration = (newDuration.isNegative) ? Duration.zero : newDuration;
    });
  }

  /// ---------------------------------------------------------------------------------------------------
  void _onStopButtonTap() => setState(() {
    timer.cancel();
    duration = Duration.zero;
  });

  /// ---------------------------------------------------------------------------------------------------
  void _onPlayPauseButtonTap() {
    setState(() {
      if (timer.isActive) {
        timer.cancel();
      } else if (duration > Duration.zero) {
        timer = Timer.periodic(Duration(seconds: 1), _onTimerTick);
      }
    });
  }

  /// ---------------------------------------------------------------------------------------------------
  void _onTimerTick(Timer timer) {
    if (duration < Duration(seconds: 1)) {
      timer.cancel();
      setState(() => duration = Duration.zero);
    } else {
      setState(() => duration -= Duration(seconds: 1));
    }
  }
}

class AnimatedScrollableIntValueDisplay extends StatelessWidget {
  final void Function() onScrolledUp;
  final void Function() onScrolledDown;
  final int value;
  final int leftPadAmount;
  final String label;

  const AnimatedScrollableIntValueDisplay({
    super.key,
    required this.value,
    required this.leftPadAmount,
    required this.onScrolledUp,
    required this.onScrolledDown,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerSignal: (event) {
        if (event is PointerScrollEvent && event.scrollDelta.dy > 0) {
          onScrolledDown();
        } else if (event is PointerScrollEvent && event.scrollDelta.dy < 0) {
          onScrolledUp();
        }
      },
      child: Row(
        crossAxisAlignment: .baseline,
        textBaseline: .alphabetic,
        children: [
          AnimatedSize(
            clipBehavior: .none,
            duration: const Duration(milliseconds: 1000),
            curve: Curves.decelerate,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                value.toString().padLeft(leftPadAmount, "0"),
                style: TextStyle(
                  fontSize: 100,
                  fontFamily: "NotoSans",
                  fontVariations: [FontVariation.weight(800)],
                  fontFeatures: [FontFeature.tabularFigures()],
                  color: colorForeground,
                ),
              ),
            ),
          ),
          Text(
            label,
            style: TextStyle(
              fontSize: 30,
              fontFamily: "NotoSans",
              fontVariations: [FontVariation.weight(600)],
              color: colorForeground,
            ),
          ),
        ],
      ),
    );
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
        overlayColor: WidgetStatePropertyAll(Colors.white10),
        borderRadius: BorderRadius.all(Radius.circular(10)),
        onTap: onPressed,
        child: Ink(
          decoration: BoxDecoration(
            color: colorForeground,
            borderRadius: BorderRadius.all(Radius.circular(10)),
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minWidth: 80, minHeight: 80),
            child: Icon(icon, size: 40, color: Color(0xFFFFFFFF)),
          ),
        ),
      ),
    );
  }
}
