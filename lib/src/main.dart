import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:stock_game_app/src/welcome/main_video.dart';
import 'package:stock_game_app/src/welcome/video_grid.dart';

class Main extends HookWidget {
  final RouteSettings routeSettings;

  Main({
    super.key,
    required this.routeSettings,
  });

  final getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: true,
      body: Stack(
        fit: StackFit.expand,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Expanded(child: VideoGrid()),
            ],
          ),
          MainVideo(),
        ],
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(4.0),
        child: SizedBox(
          height: 48,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              const IconButton(
                isSelected: true,
                icon: Icon(Icons.home),
                onPressed: null,
                enableFeedback: true,
              ),
              IconButton(
                icon: const Icon(Icons.chat_bubble),
                onPressed: () {
                  Chat.openChat(context);
                },
                enableFeedback: true,
              ),
              const IconButton(
                icon: Icon(Icons.supervised_user_circle_sharp),
                onPressed: null,
                enableFeedback: true,
              ),
              IconButton(
                icon: const Icon(Icons.settings),
                onPressed: () {
                  // Go to settings
                },
                enableFeedback: true,
              ),
              IconButton(
                icon: const Icon(Icons.loyalty),
                onPressed: () {},
                enableFeedback: true,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
