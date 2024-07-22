import 'dart:convert';
import 'dart:math';
import 'dart:typed_data';
import 'dart:ui';

import 'package:auto_orientation/auto_orientation.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:get_it/get_it.dart';
import 'package:rxdart/rxdart.dart';
import 'package:video_player/video_player.dart';

class PlayerControl {
  final Key id;
  final void Function() play;
  final void Function() pause;

  PlayerControl(
    this.id,
    this.play,
    this.pause,
  );
}

class VideoController {
  VideoController();

  final getIt = GetIt.instance;

  final mainVideoController =
      BehaviorSubject<VideoPlayerController?>.seeded(null);
  final mainVideoControllerCounter = BehaviorSubject<int>.seeded(0);
  final mainVideoControllerInited = BehaviorSubject<bool>.seeded(false);
  final mainVideoControllerPreview = BehaviorSubject<String?>.seeded(null);
  final isOpened = BehaviorSubject<bool>.seeded(false);

  final controller = BehaviorSubject<PlayerControl?>.seeded(null);
  final map = <Key, PlayerControl>{};

  playMainController(String url, String previewUrl) {
    mainVideoControllerPreview.add(previewUrl);

    if (mainVideoController.value != null) {
      try {
        mainVideoController.value?.pause();
      } catch (e) {
        //
      }

      mainVideoControllerInited.add(false);
      mainVideoController.value?.dispose().then((_) {
        mainVideoControllerCounter.add(mainVideoControllerCounter.value + 1);
      });
    }

    const webOptions = VideoPlayerWebOptions(
        allowContextMenu: false,
        allowRemotePlayback: false,
        controls: VideoPlayerWebOptionsControls.disabled());
    final videoPlayerOptions = VideoPlayerOptions(
        allowBackgroundPlayback: false,
        mixWithOthers: true,
        webOptions: webOptions);
    final controller = VideoPlayerController.networkUrl(
      Uri.parse(url),
      videoPlayerOptions: videoPlayerOptions,
    );
    controller.addListener(() {
      mainVideoControllerCounter.add(mainVideoControllerCounter.value + 1);
    });
    controller.setLooping(false);
    controller.setVolume(1.0);
    controller.initialize().then((_) {
      mainVideoControllerInited.add(true);
      try {
        controller.play();
      } catch (e) {
        //
      }
    });
    mainVideoController.add(controller);

    stopController();

    isOpened.add(true);
  }

  stopMainController() {
    if (mainVideoController.value != null) {
      try {
        mainVideoController.value?.pause();
      } catch (e) {
        //
      }

      mainVideoControllerInited.add(false);
      mainVideoController.value?.dispose().then((_) {
        mainVideoControllerCounter.add(mainVideoControllerCounter.value + 1);
      });
      mainVideoController.add(null);

      isOpened.add(false);

      pickFirstRegistered();
    }
  }

  toggleMainController() {
    if (mainVideoController.value?.value.isPlaying == true) {
      try {
        mainVideoController.value?.pause();
      } catch (e) {
        ///
      }
    } else {
      try {
        mainVideoController.value?.play();
      } catch (e) {
        ///
      }
    }
  }

  unsetController(Key id) {
    if (map.containsKey(id)) {
      final controller = map[id];
      map.remove(id);

      if (this.controller.value != null &&
          controller?.id == this.controller.value?.id) {
        try {
          this.controller.value?.pause();
        } catch (e) {
          //
        }

        this.controller.add(null);
      } else {
        controller?.pause();
      }
    }

    pickFirstRegistered();
  }

  setController(Key id, PlayerControl controller) {
    map[id] = controller;

    pickFirstRegistered();
  }

  stopController() {
    if (controller.value != null) {
      try {
        controller.value?.pause();
      } catch (e) {
        //
      }

      controller.add(null);
    }
  }

  pickFirstRegistered() {
    if (mainVideoController.value != null) return;

    if (controller.value == null && map.values.isNotEmpty) {
      var first = map.values.first;

      controller.add(first);

      try {
        controller.value!.play();
      } catch (e) {
        //
      }
    }
  }

  play(Key id) {
    if (mainVideoController.value != null) return;

    final controller = map[id];

    if (this.controller.value != null &&
        controller?.id != this.controller.value?.id) {
      try {
        this.controller.value?.pause();
      } catch (e) {
        //
      }
    }

    if (controller?.id != this.controller.value?.id) {
      this.controller.add(controller);
    }

    try {
      this.controller.value?.play();
    } catch (e) {
      //
    }
  }

  lanscape() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
    ]);
    AutoOrientation.landscapeAutoMode();
  }

  portrait() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    AutoOrientation.portraitAutoMode();
  }
}
