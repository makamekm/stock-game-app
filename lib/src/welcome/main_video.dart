import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/welcome/main_video_screen_max.dart';
import 'package:stock_game_app/src/welcome/main_video_screen_min.dart';
import 'package:stock_game_app/src/welcome/video_controller.dart';

class SwipeToActionWrap extends HookWidget {
  final Widget child;
  final void Function()? actionUp;
  final void Function()? actionDown;

  const SwipeToActionWrap({
    super.key,
    required this.child,
    this.actionUp,
    this.actionDown,
  });

  final swipeMinLength = 50.0;

  @override
  Widget build(BuildContext context) {
    final swipeInProgress = useState(false);
    final startPosY = useState<double>(0.0);

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onVerticalDragStart: (details) {
        swipeInProgress.value = true;
        startPosY.value = details.localPosition.dy;
      },
      onVerticalDragUpdate: (details) {
        final delta = startPosY.value - details.localPosition.dy;
        if (swipeInProgress.value && (delta).abs() > swipeMinLength) {
          if (delta < 0.0) {
            actionDown?.call();
          } else {
            actionUp?.call();
          }
          swipeInProgress.value = false;
        }
      },
      onVerticalDragEnd: (_) => swipeInProgress.value = false,
      child: child,
    );
  }
}

class MainVideo extends HookWidget {
  MainVideo({
    super.key,
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
    final isOpenedStream = useStream(controler.isOpened);
    useStream(controler.mainVideoControllerCounter);

    final hasMainStream = mainVideoControllerStream.data != null;
    final isOpened = isOpenedStream.data == true;

    open() {
      controler.isOpened.add(true);
      HapticFeedback.lightImpact();
    }

    close() {
      controler.isOpened.add(false);
      HapticFeedback.lightImpact();
    }

    stop() {
      controler.stopMainController();
    }

    final animationStream = useAnimationController(
      duration: animationDuration,
      animationBehavior: AnimationBehavior.normal,
      initialValue: 0.0,
    );

    final animationOpen = useAnimationController(
      duration: animationDuration,
      animationBehavior: AnimationBehavior.normal,
      initialValue: 0.0,
    );

    useAnimation(animationStream);
    useAnimation(animationOpen);

    final animationSmallValue =
        animationStream.value * (1.0 - animationOpen.value);
    final animationBigValue = animationStream.value * animationOpen.value;

    useEffect(() {
      if (hasMainStream) {
        animationStream.forward();
      } else {
        animationStream.reverse();
      }
      return null;
    }, [hasMainStream]);

    useEffect(() {
      if (isOpened && hasMainStream) {
        animationOpen.forward();
      } else {
        animationOpen.reverse();
      }
      return null;
    }, [isOpened, hasMainStream]);

    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return Stack(
          alignment: Alignment.bottomCenter,
          children: [
            Opacity(
              key: const Key('main_video_small'),
              opacity: animationSmallValue * animationSmallValue,
              child: Transform.translate(
                offset: Offset(0, 100 * (1.0 - animationSmallValue)),
                child: Container(
                  clipBehavior: Clip.hardEdge,
                  height: height,
                  width: size.width - 8 * 5,
                  decoration: const BoxDecoration(
                    color: Colors.black,
                    borderRadius:
                        BorderRadius.only(topRight: Radius.circular(8)),
                  ),
                  child: SwipeToActionWrap(
                    actionUp: () {
                      open();
                      HapticFeedback.lightImpact();
                    },
                    actionDown: () {
                      stop();
                      HapticFeedback.lightImpact();
                    },
                    child: InkWell(
                      onTap: () {
                        open();
                      },
                      child:
                          MainVideoScreenMin(visible: animationBigValue < 0.9),
                    ),
                  ),
                ),
              ),
            ),
            Opacity(
              key: const Key('main_video_big'),
              opacity: animationBigValue * animationBigValue,
              child: Transform.translate(
                offset: Offset(0, 100 * (1.0 - animationBigValue)),
                child: Transform.scale(
                  scale: animationBigValue,
                  alignment: Alignment.bottomCenter,
                  child: Container(
                    clipBehavior: Clip.hardEdge,
                    width: size.width,
                    height: size.height,
                    decoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    child: SwipeToActionWrap(
                      actionDown: () {
                        close();
                        HapticFeedback.lightImpact();
                      },
                      child: ClipRect(
                        child: MainVideoScreenMax(
                            visible: animationBigValue > 0.01),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
