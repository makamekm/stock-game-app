import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/push_button/pushable_button.dart';
import 'package:stock_game_app/src/welcome/main_video_player.dart';
import 'package:stock_game_app/src/welcome/video_controller.dart';

class MainVideoScreenMax extends HookWidget {
  final bool visible;

  MainVideoScreenMax({
    super.key,
    required this.visible,
  });

  final getIt = GetIt.instance;

  final aspect = 1.778;
  final contHeight = 48.0;
  final height = 48.0 + 16;
  final animationDuration = const Duration(milliseconds: 200);

  @override
  Widget build(BuildContext context) {
    final controler = getIt<VideoController>();
    final mainVideoControllerStream = useStream(controler.mainVideoController);
    final controllerInitedStream =
        useStream(controler.mainVideoControllerInited);
    final isOpenedStream = useStream(controler.isOpened);
    useStream(controler.mainVideoControllerCounter);

    final hasMainStream = (controllerInitedStream.data ?? false) &&
        mainVideoControllerStream.data != null;
    final isOpened = isOpenedStream.data == true;

    isPlayingGet() => mainVideoControllerStream.data?.value.isPlaying == true;
    final isPlaying = isPlayingGet();

    close() {
      controler.isOpened.add(false);
      HapticFeedback.lightImpact();
    }

    stop() {
      controler.stopMainController();
    }

    useEffect(() {
      if (isOpened && hasMainStream) {
        // controler.lanscape();
      } else {
        controler.portrait();
      }
      return null;
    }, [isOpened, hasMainStream]);

    fullscreen() {
      controler.lanscape();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: min(size.width, size.width / aspect),
                child: MainVideoPlayer(visible: visible),
              ),
              const Text(
                'asdfasdfasdfsdf asdfsfsdf asdfasdfasdfsdf asdfsfsdf asdfasdfasdfsdf asdfsfsdf asdfasdfasdfsdf asdfsfsdf asdfasdfasdfsdf asdfsfsdf',
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    inherit: true,
                    fontSize: 18.0,
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                    shadows: [
                      Shadow(
                        blurRadius: 10,
                        color: Color.fromARGB(128, 0, 0, 0),
                      ),
                    ]),
              ),
              const Expanded(child: SizedBox(height: 4)),
              Container(
                width: size.width,
                height: height,
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: <Widget>[
                    PushableButton(
                      height: contHeight,
                      width: contHeight,
                      // disabled: true,
                      hslColor: HSLColor.fromColor(Colors.orange.shade200)
                          .withAlpha(0.1),
                      // hslColor: HSLColor.fromColor(Colors.black),
                      // bottomHslColor:
                      //     HSLColor.fromColor(Colors.black),
                      // bottomHslColorBottom:
                      //     HSLColor.fromColor(Colors.black),
                      // topHslColor:
                      //     HSLColor.fromColor(Colors.black),
                      patternOpacity: 0.3,
                      onPressed: () => print('Button Pressed!'),
                      child: const Icon(
                        Icons.thumb_down_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PushableButton(
                      height: contHeight,
                      width: contHeight,
                      hslColor: HSLColor.fromColor(Colors.green.shade300)
                          .withAlpha(0.1),
                      // bottomHslColor:
                      //     HSLColor.fromColor(Colors.white)
                      //         .withAlpha(0.5),
                      // bottomHslColorBottom:
                      //     HSLColor.fromColor(Colors.white)
                      //         .withAlpha(0.5),
                      // topHslColor:
                      //     HSLColor.fromColor(Colors.white)
                      //         .withAlpha(0.5),
                      patternOpacity: 0.3,
                      onPressed: () => print('Button Pressed!'),
                      child: const Icon(
                        Icons.thumb_up_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const Expanded(
                      child: SizedBox(width: 4),
                    ),
                    PushableButton(
                      height: contHeight,
                      width: contHeight,
                      hslColor: HSLColor.fromColor(Colors.black),
                      bottomHslColor: HSLColor.fromColor(Colors.black),
                      bottomHslColorBottom: HSLColor.fromColor(Colors.black),
                      topHslColor: HSLColor.fromColor(Colors.black),
                      patternOpacity: 0.2,
                      onPressed: () {
                        fullscreen();
                      },
                      child: const Icon(
                        Icons.fullscreen_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PushableButton(
                      height: contHeight,
                      width: contHeight,
                      hslColor:
                          HSLColor.fromColor(Colors.deepOrange).withAlpha(0.6),
                      onPressed: () {
                        close();
                        stop();
                      },
                      child: const Icon(
                        Icons.stop_rounded,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 4),
                    PushableButton(
                      height: contHeight,
                      width: contHeight,
                      hslColor: HSLColor.fromColor(Colors.blue).withAlpha(0.6),
                      onPressed: () {
                        controler.toggleMainController();
                      },
                      child: Icon(
                        isPlaying
                            ? Icons.play_arrow_rounded
                            : Icons.pause_rounded,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
