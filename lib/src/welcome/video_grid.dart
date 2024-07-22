import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_custom_carousel/flutter_custom_carousel.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:stock_game_app/src/welcome/basic_short_item.dart';
import 'package:stock_game_app/src/welcome/basic_video_item.dart';
import 'package:stock_game_app/src/welcome/measure.dart';

class VideoGrid extends HookWidget {
  VideoGrid({
    super.key,
  });

  final getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    final size = useState<Size?>(null);
    final selectedShort = useState<int?>(null);
    final h = max(size.value?.height ?? 1.0, 1.0);
    final w = max(size.value?.width ?? 1.0, 1.0);
    // final h = MediaQuery.of(context).size.height;
    // final w = MediaQuery.of(context).size.width;
    // final maxSize = max(h, w);
    final minSize = min(h, w);
    final height = max(h - minSize * 1.0, 1.0);
    final aspect = w / h;
    final isHorizontal = aspect > 1 && height > 2.0;

    return MeasureSize(
      onChange: (Size? newSize) {
        size.value = newSize;
      },
      child: SingleChildScrollView(
        child: SafeArea(
          top: true,
          bottom: false,
          left: true,
          right: true,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: <Widget>[
              SizedBox(
                height: height > 2.0 ? height : null,
                child: SizedBox(
                  height: height,
                  child: CustomCarousel(
                    tapToSelect: true,
                    scrollDirection: Axis.horizontal,
                    alignment: Alignment.center,
                    itemCountBefore: 2,
                    itemCountAfter: 2,
                    loop: !isHorizontal,
                    physics: const CustomCarouselScrollPhysics(sticky: true),
                    // scrollSpeed: 0.6,
                    effectsBuilder: (index, scrollRatio, child) {
                      final scroll = scrollRatio.abs();
                      final opacity =
                          max(min(1.0 - 2 * (scroll - 0.5), 1.0), 0.0);
                      return Opacity(
                        opacity: opacity,
                        child: Transform.translate(
                          offset: Offset(scrollRatio * height * 1.4 + 4.0, 0),
                          child: Transform.scale(
                            scale: min(max(1.0 - scroll * 0.9, 0.9), 1.0),
                            child: child,
                          ),
                        ),
                      );
                    },
                    // This is mostly just used to update the "Next Card" button to say
                    // "Shuffle Deck" when the last card is selected.
                    onSelectedItemChanged: (i) => selectedShort.value = i,
                    children: List.generate(8, (index) {
                      return BasicShortItem(
                        key: Key(index.toString()),
                        selected: selectedShort.value == index,
                        url:
                            "https://github.com/makamekm/file-test/raw/main/${index + 1}.mp4",
                        previewUrl: 'https://loremflickr.com/200/400',
                      );
                    }),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: StaggeredGrid.count(
                  crossAxisCount: isHorizontal ? 4 : 1,
                  crossAxisSpacing: 5.0,
                  mainAxisSpacing: 5.0,
                  children: [
                    BasicVideoItem(
                      key: const Key('asdf1'),
                      url:
                          'https://github.com/makamekm/file-test/raw/main/1.mp4',
                      previewUrl: 'https://loremflickr.com/320/240',
                    ),
                    BasicVideoItem(
                      key: const Key('asdf2'),
                      url:
                          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                      previewUrl: 'https://loremflickr.com/320/240',
                    ),
                    BasicVideoItem(
                      key: const Key('asdf3'),
                      url:
                          'https://github.com/makamekm/file-test/raw/main/2.mp4',
                      previewUrl: 'https://loremflickr.com/320/240',
                    ),
                    BasicVideoItem(
                      key: const Key('asdf4'),
                      url:
                          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                      previewUrl: 'https://loremflickr.com/320/240',
                    ),
                    BasicVideoItem(
                      key: const Key('asdf5'),
                      url:
                          'https://github.com/makamekm/file-test/raw/main/3.mp4',
                      previewUrl: 'https://loremflickr.com/320/240',
                    ),
                    BasicVideoItem(
                      key: const Key('asdf6'),
                      url:
                          'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
                      previewUrl: 'https://loremflickr.com/320/240',
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
