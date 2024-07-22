import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';

class PushableButton extends HookWidget {
  PushableButton({
    super.key,
    this.child,
    required this.hslColor,
    this.height = 48,
    this.width,
    this.radius = 8,
    this.patternOpacity = 0.5,
    this.elevation = 4.0,
    this.disabled = false,
    this.shadow,
    this.onPressed,
    this.bottomHslColorBottom,
    this.bottomHslColor,
    this.topHslColor,
  }) : assert(height > 0);

  final HSLColor? bottomHslColorBottom;
  final HSLColor? bottomHslColor;
  final HSLColor? topHslColor;
  bool _isPressingBlocked = false;
  bool _isDragInProgress = false;
  bool _mounted = true;

  Offset _gestureLocation = Offset.zero;
  final Duration _animationDuration = const Duration(milliseconds: 100);

  HSLColor get bottomHslColorBottomGet {
    return bottomHslColorBottom ??
        hslColor
            .withLightness(hslColor.lightness - (0.15 + (disabled ? 0.1 : 0)));
  }

  HSLColor get bottomHslColorGet {
    return bottomHslColor ??
        hslColor
            .withLightness(hslColor.lightness - (0.35 + (disabled ? 0.1 : 0)));
  }

  HSLColor get topHslColorGet {
    return topHslColor ?? hslColor.withLightness(0.4);
  }

  /// child widget (normally a Text or Icon)
  final Widget? child;

  /// Color of the top layer
  /// The color of the bottom layer is derived by decreasing the luminosity by 0.15
  final HSLColor hslColor;

  /// height of the top layer
  final double height;

  /// border radius
  final double radius;

  /// border radius
  final double patternOpacity;

  /// elevation or "gap" between the top and bottom layer
  final double elevation;

  /// disable button state
  final bool disabled;

  /// An optional shadow to make the button look better
  /// This is added to the bottom layer only
  final BoxShadow? shadow;

  /// button pressed callback
  final VoidCallback? onPressed;

  final double? width;

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
      onPressed?.call();
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

  // void _handleDragStart(DragStartDetails details,
  //     AnimationController animationController, ValueNotifier<bool> isPressing) {
  //   if (disabled) return;

  //   _gestureLocation = details.localPosition;
  //   _isDragInProgress = true;
  //   animationController.forward();
  // }

  // void _handleDragEnd(Size buttonSize, AnimationController animationController,
  //     ValueNotifier<bool> isPressing) {
  //   if (_isDragInProgress) {
  //     _isDragInProgress = false;
  //     isPressing.value = false;
  //     if (!_isPressingBlocked) {
  //       animationController.stop(canceled: true);
  //       animationController.reverse();
  //     }
  //   }
  //   if (_gestureLocation.dx >= 0 &&
  //       _gestureLocation.dy < buttonSize.width &&
  //       _gestureLocation.dy >= 0 &&
  //       _gestureLocation.dy < buttonSize.height) {
  //     if (isPressing.value) {
  //       onPressed?.call();
  //     }
  //   }
  // }

  // void _handleDragCancel(
  //     AnimationController animationController, ValueNotifier<bool> isPressing) {
  //   if (_isDragInProgress) {
  //     _isDragInProgress = false;
  //     isPressing.value = false;
  //     if (!_isPressingBlocked) {
  //       animationController.stop(canceled: true);
  //       animationController.reverse();
  //     }
  //   }
  // }

  // void _handleDragUpdate(DragUpdateDetails details,
  //     AnimationController animationController, ValueNotifier<bool> isPressing) {
  //   _gestureLocation = details.localPosition;
  // }

  @override
  Widget build(BuildContext context) {
    final isPressing = useState(false);

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

    final bottomHslColor = bottomHslColorGet;
    final bottomHslColorBottom = bottomHslColorBottomGet;
    final topHslColor = topHslColorGet;

    final totalHeight = height + elevation;
    final top = animationController.value * elevation;

    return SizedBox(
      height: totalHeight,
      child: LayoutBuilder(
        builder: (context, constraints) {
          // final buttonSize = Size(constraints.maxWidth, constraints.maxHeight);

          final body = Stack(
            children: [
              // Draw bottom layer first
              Container(
                margin: EdgeInsets.only(top: top),
                width: width,
                alignment: Alignment.bottomCenter,
                height: totalHeight - top,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      bottomHslColor.toColor(),
                      bottomHslColorBottom.toColor()
                    ],
                  ),
                  boxShadow: shadow != null ? [shadow!] : [],
                  borderRadius: BorderRadius.circular(radius),
                ),
              ),
              // Then top (pushable) layer
              Container(
                margin: EdgeInsets.only(top: top),
                alignment: Alignment.topCenter,
                height: height,
                width: width,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      topHslColor.toColor(),
                      hslColor.toColor(),
                    ],
                  ),
                  boxShadow: shadow != null ? [shadow!] : [],
                  borderRadius: BorderRadius.circular(radius),
                  image: DecorationImage(
                    scale: 1.25,
                    image: const AssetImage('assets/images/pattern-cat.png'),
                    opacity: patternOpacity,
                    alignment: Alignment.center,
                    repeat: ImageRepeat.repeat,
                    fit: BoxFit.none,
                  ),
                ),
                child: Center(child: child),
              ),
              Container(
                margin: EdgeInsets.only(top: top),
                alignment: Alignment.topCenter,
                height: height,
                width: width,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(radius),
                  color: Colors.black.withAlpha(disabled ? 128 : 0),
                ),
              ),
            ],
          );

          return disabled
              ? body
              : GestureDetector(
                  onTapDown: (details) =>
                      _handleTapDown(details, animationController, isPressing),
                  onTapUp: (details) =>
                      _handleTapUp(details, animationController, isPressing),
                  onTapCancel: () =>
                      _handleTapCancel(animationController, isPressing),
                  // onHorizontalDragStart: (details) => _handleDragStart(
                  //     details, animationController, isPressing),
                  // onHorizontalDragEnd: (_) => _handleDragEnd(
                  //     buttonSize, animationController, isPressing),
                  // onHorizontalDragCancel: () =>
                  //     _handleDragCancel(animationController, isPressing),
                  // onHorizontalDragUpdate: (details) => _handleDragUpdate(
                  //     details, animationController, isPressing),
                  // onVerticalDragStart: (details) => _handleDragStart(
                  //     details, animationController, isPressing),
                  // onVerticalDragEnd: (_) => _handleDragEnd(
                  //     buttonSize, animationController, isPressing),
                  // onVerticalDragCancel: () =>
                  //     _handleDragCancel(animationController, isPressing),
                  // onVerticalDragUpdate: (details) => _handleDragUpdate(
                  //     details, animationController, isPressing),
                  child: body,
                );
        },
      ),
    );
  }
}
