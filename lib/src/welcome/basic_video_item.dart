import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/welcome/basic_video_player.dart';
import 'package:stock_game_app/src/welcome/measure.dart';
import 'package:stock_game_app/src/welcome/video_controller.dart';

class BasicVideoItem extends HookWidget {
  final String url;
  final String previewUrl;

  BasicVideoItem({
    super.key,
    required this.url,
    required this.previewUrl,
    this.radius = 8,
    this.elevation = 4.0,
    this.shadow,
    this.disabled = false,
  });

  final Color color = Colors.purple;
  final double radius;
  final double elevation;
  final BoxShadow? shadow;
  final bool disabled;

  final aspect = 1.778;

  final getIt = GetIt.instance;

  Offset _gestureLocation = Offset.zero;
  final Duration _animationDuration = const Duration(milliseconds: 100);

  bool _isPressingBlocked = false;
  bool _isDragInProgress = false;
  bool _mounted = true;

  void _handleTapDown(TapDownDetails details,
      AnimationController animationController, ValueNotifier<bool> isPressing) {
    if (disabled) return;

    _gestureLocation = details.localPosition;
    animationController.forward();
    _isPressingBlocked = true;
    isPressing.value = true;

    Future.delayed(_animationDuration, () {
      if (_isPressingBlocked && !isPressing.value) {
        animationController.stop(canceled: true);
        animationController.reverse();
      }
      _isPressingBlocked = false;
    });
  }

  void _handleTapUp(TapUpDetails details,
      AnimationController animationController, ValueNotifier<bool> isPressing) {
    if (isPressing.value) {
      isPressing.value = false;
      if (!_isPressingBlocked) {
        animationController.stop(canceled: true);
        animationController.reverse();
      }
      onPressed();
    }
  }

  void _handleTapCancel(
      AnimationController animationController, ValueNotifier<bool> isPressing) {
    Future.delayed(_animationDuration, () {
      if (!_isDragInProgress && _mounted) {
        isPressing.value = false;
        if (!_isPressingBlocked) {
          animationController.stop(canceled: true);
          animationController.reverse();
        }
      }
    });
  }

  void _handleDragStart(DragStartDetails details,
      AnimationController animationController, ValueNotifier<bool> isPressing) {
    if (disabled) return;

    _gestureLocation = details.localPosition;
    _isDragInProgress = true;
    animationController.forward();
  }

  void _handleDragEnd(Size buttonSize, AnimationController animationController,
      ValueNotifier<bool> isPressing) {
    if (_isDragInProgress) {
      _isDragInProgress = false;
      isPressing.value = false;
      if (!_isPressingBlocked) {
        animationController.stop(canceled: true);
        animationController.reverse();
      }
    }
    if (_gestureLocation.dx >= 0 &&
        _gestureLocation.dy < buttonSize.width &&
        _gestureLocation.dy >= 0 &&
        _gestureLocation.dy < buttonSize.height) {
      if (isPressing.value) {
        onPressed();
      }
    }
  }

  void _handleDragCancel(
      AnimationController animationController, ValueNotifier<bool> isPressing) {
    if (_isDragInProgress) {
      _isDragInProgress = false;
      isPressing.value = false;
      if (!_isPressingBlocked) {
        animationController.stop(canceled: true);
        animationController.reverse();
      }
    }
  }

  void _handleDragUpdate(DragUpdateDetails details,
      AnimationController animationController, ValueNotifier<bool> isPressing) {
    _gestureLocation = details.localPosition;
  }

  onPressed() {}

  @override
  Widget build(BuildContext context) {
    final controler = getIt<VideoController>();
    // final sizeBody = useState<Size?>(null);
    final isPressing = useState(false);
    // final width = MediaQuery.of(context).size.width;
    // final height = (sizeBody.value?.width ?? 0.0) / aspect;

    final animationController =
        useAnimationController(duration: _animationDuration);
    useAnimation(animationController);

    useEffect(() {
      _mounted = true;
      return () {
        _mounted = false;
        animationController.dispose();
      };
    }, []);

    final top = animationController.value * elevation;
    final topPadding = (1.0 - animationController.value) * elevation;

    return GestureDetector(
      onTap: () {
        controler.playMainController(url, previewUrl);
      },
      onTapDown: (details) =>
          _handleTapDown(details, animationController, isPressing),
      onTapUp: (details) =>
          _handleTapUp(details, animationController, isPressing),
      onTapCancel: () => _handleTapCancel(animationController, isPressing),
      child: Column(
        children: [
          AspectRatio(
            aspectRatio: aspect,
            child: Container(
              clipBehavior: Clip.antiAlias,
              alignment: Alignment.topCenter,
              margin: EdgeInsets.only(top: top),
              padding: EdgeInsets.only(bottom: topPadding),
              decoration: BoxDecoration(
                color: color,
                boxShadow: shadow != null ? [shadow!] : [],
                borderRadius: BorderRadius.circular(radius),
              ),
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                ),
                clipBehavior: Clip.antiAlias,
                child: BasicVideoPlayer(
                    url: url,
                    previewUrl: previewUrl,
                    animationDuration: const Duration(milliseconds: 500)),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  alignment: Alignment.topCenter,
                  height: 40,
                  width: 40,
                  decoration: BoxDecoration(
                    boxShadow: shadow != null ? [shadow!] : [],
                    borderRadius: BorderRadius.circular(100),
                    border: Border.all(
                      color: Colors.purple,
                      strokeAlign: BorderSide.strokeAlignCenter,
                      width: 3,
                    ),
                    image: DecorationImage(
                      scale: 1.0,
                      image: const NetworkImage('https://i.pravatar.cc/300'),
                      alignment: Alignment.center,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Flexible(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Text Widget Example Text Widget Example Text Widget Example Text Widget Example Text Widget Example",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        "Ситуация • 3024 зрителя",
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w400,
                          color: Colors.white.withAlpha(160),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton(
                  itemBuilder: (BuildContext bc) {
                    return const [
                      PopupMenuItem(
                        child: Text("Hello"),
                        value: '/hello',
                      ),
                      PopupMenuItem(
                        child: Text("About"),
                        value: '/about',
                      ),
                      PopupMenuItem(
                        child: Text("Contact"),
                        value: '/contact',
                      )
                    ];
                  },
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}
