import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/welcome/video_controller.dart';
import 'package:video_player/video_player.dart';

class MainVideoPlayer extends HookWidget {
  final Duration animationDuration;
  final bool visible;

  MainVideoPlayer({
    super.key,
    this.animationDuration = Duration.zero,
    this.visible = true,
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
    final previewUrlStream =
        useStream(getIt<VideoController>().mainVideoControllerPreview);
    final controllerStream =
        useStream(getIt<VideoController>().mainVideoController);
    final controllerInitedStream =
        useStream(getIt<VideoController>().mainVideoControllerInited);
    useStream(getIt<VideoController>().mainVideoControllerCounter);

    final controller = controllerStream.data;
    final previewUrl = previewUrlStream.data;

    final inited = controller != null && (controllerInitedStream.data ?? false);
    final canPlay = inited;

    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          alignment: Alignment.center,
          decoration: BoxDecoration(
            image: previewUrl != null
                ? DecorationImage(
                    scale: 1.0,
                    image: NetworkImage(previewUrl),
                    alignment: Alignment.center,
                    fit: BoxFit.cover,
                  )
                : null,
          ),
          child: ClipRRect(
            child: AnimatedOpacity(
              opacity: canPlay ? 1 : 0,
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
        inited
            ? AnimatedOpacity(
                opacity: canPlay ? 1 : 0,
                duration: animationDuration,
                child: Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        AspectRatio(
                          aspectRatio: controller.value.aspectRatio,
                          child:
                              visible ? VideoPlayer(controller) : Container(),
                        ),
                      ],
                    ),
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        // _ControlsOverlay(controller: _controller),
                        VideoProgressIndicator(
                          controller,
                          allowScrubbing: false,
                          padding: const EdgeInsets.only(top: 2.0),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            : Container(),
      ],
    );
  }
}
