import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/welcome/hooks.dart';
import 'package:stock_game_app/src/welcome/video_controller.dart';
import 'package:video_player/video_player.dart';
import 'package:visibility_detector/visibility_detector.dart';

class BasicVideoPlayer extends HookWidget {
  final String url;
  final String previewUrl;
  final bool play;
  final bool loop;
  final bool muted;
  final Duration debounce;
  final Duration animationDuration;

  BasicVideoPlayer({
    super.key,
    required this.url,
    required this.previewUrl,
    this.play = false,
    this.loop = true,
    this.muted = true,
    this.debounce = const Duration(milliseconds: 2000),
    this.animationDuration = const Duration(milliseconds: 200),
  });

  final getIt = GetIt.instance;
  final rng = Random();

  randomId() {
    return rng.nextInt(1 << 32).toString();
  }

  genKey() => Key(randomId());

  Timer? timer;

  @override
  Widget build(BuildContext context) {
    final id = useMemoized(genKey);
    final controller = useState<VideoPlayerController?>(null);
    final inited = useState(false);
    final counter = useState(0);
    final visibility = useState(false);
    final visibilityDeb = useDebouncedBetter(visibility.value, debounce);

    // final shouldPlay = useState(false);
    // final shouldPlayDebRaw = useDebouncedBetter(shouldPlay.value, debounce);

    final controllerExt = useMemoized<PlayerControl>(
      () => PlayerControl(
        id,
        () {
          timer?.cancel();
          timer = Timer(
            debounce,
            () {
              try {
                controller.value?.play();
                // ignore: empty_catches
              } catch (e) {}
            },
          );
        },
        () {
          timer?.cancel();
          timer = null;
          try {
            controller.value?.pause();
            // ignore: empty_catches
          } catch (e) {}
        },
      ),
      [id],
    );

    final canPlay = controller.value != null &&
        inited.value &&
        visibility.value &&
        visibilityDeb;
    final canPlayDeb = useDebouncedBetter(canPlay, debounce);

    final isPlaying = controller.value?.value.isPlaying ?? false;
    final inSeconds = controller.value?.value.position.inMilliseconds ?? 0;

    final isActive = (isPlaying || inSeconds > 1.0) && visibility.value;

    // useEffect(() {
    //   final shouldPlayDeb = shouldPlay.value && (shouldPlayDebRaw ?? false);
    //   // print(
    //   //     "HERE ${id} ${shouldPlayDeb} ${shouldPlay.value} ${shouldPlayDebRaw}");
    //   if (shouldPlayDeb) {
    //     try {
    //       controller.value?.play();
    //       // ignore: empty_catches
    //     } catch (e) {}
    //   } else {
    //     try {
    //       controller.value?.pause();
    //       // ignore: empty_catches
    //     } catch (e) {}
    //   }

    //   return null;
    // }, [shouldPlayDebRaw, shouldPlay.value]);

    tryPlay() {
      if (visibility.value && context.mounted) {
        if (controller.value == null) {
          var webOptions = const VideoPlayerWebOptions(
              allowContextMenu: false,
              allowRemotePlayback: false,
              controls: VideoPlayerWebOptionsControls.disabled());
          var videoPlayerOptions = VideoPlayerOptions(
              allowBackgroundPlayback: false,
              mixWithOthers: true,
              webOptions: webOptions);
          controller.value = VideoPlayerController.networkUrl(
            Uri.parse(url),
            videoPlayerOptions: videoPlayerOptions,
          );
          controller.addListener(() {
            counter.value++;
          });
          controller.value!.addListener(() {
            counter.value++;
          });
          controller.value!.setLooping(loop);
          controller.value!.setVolume(muted ? 0.0 : 1.0);
          controller.value!.initialize().then((_) => inited.value = true);
        }
      } else if (!visibilityDeb) {
        inited.value = false;
        if (controller.value != null) {
          controller.value?.dispose();
          controller.value = null;
        }
      }

      return null;
    }

    useEffect(() {
      return () {
        inited.value = false;
        getIt<VideoController>().unsetController(id);
        controller.value?.dispose();
        controller.value = null;
      };
    }, []);

    useEffect(tryPlay, [visibility.value, visibilityDeb, context.mounted]);
    // useEffect(tryPlay, []);

    useEffect(() {
      if (!canPlay) {
        getIt<VideoController>().unsetController(id);
      }

      return null;
    }, [canPlay]);

    useEffect(() {
      if (canPlayDeb && canPlay) {
        getIt<VideoController>().setController(id, controllerExt);
        if (play) {
          getIt<VideoController>().play(id);
        }
      } else {
        getIt<VideoController>().unsetController(id);
      }

      return null;
    }, [canPlayDeb, canPlay, play]);

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: DecorationImage(
              scale: 1.0,
              image: NetworkImage(previewUrl),
              alignment: Alignment.center,
              fit: BoxFit.cover,
            ),
          ),
          child: ClipRRect(
            child: AnimatedOpacity(
              opacity: isActive ? 1 : 0,
              duration: animationDuration,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10.0, sigmaY: 10.0),
                child: Container(
                  decoration:
                      BoxDecoration(color: Colors.white.withOpacity(0.0)),
                ),
              ),
            ),
          ),
        ),
        VisibilityDetector(
          key: id,
          onVisibilityChanged: (visibilityInfo) {
            visibility.value = visibilityInfo.visibleFraction * 100 > 99;
          },
          child: inited.value
              ? AnimatedOpacity(
                  opacity: isActive ? 1 : 0,
                  duration: animationDuration,
                  child: Stack(
                    fit: StackFit.expand,
                    alignment: Alignment.center,
                    children: [
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          AspectRatio(
                            aspectRatio:
                                controller.value?.value.aspectRatio ?? 1.0,
                            child: VideoPlayer(controller.value!),
                          ),
                        ],
                      ),
                      Stack(
                        alignment: Alignment.bottomCenter,
                        children: [
                          // _ControlsOverlay(controller: _controller),
                          VideoProgressIndicator(
                            controller.value!,
                            allowScrubbing: false,
                            padding: const EdgeInsets.only(top: 2.0),
                          ),
                        ],
                      ),
                    ],
                  ),
                )
              : Container(),
        )
      ],
    );
  }
}
