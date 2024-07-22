import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';

class WelcomeCard extends HookWidget {
  WelcomeCard({
    super.key,
  });

  final getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            color: Colors.black,
            image: DecorationImage(
              scale: 1.25,
              image: AssetImage('assets/images/pattern-cat.png'),
              opacity: 0.5,
              alignment: Alignment.center,
              repeat: ImageRepeat.repeat,
              fit: BoxFit.none,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              focal: Alignment.center,
              colors: <Color>[
                Colors.black.withAlpha(0),
                Colors.black.withAlpha(200),
              ],
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              center: Alignment.center,
              focal: Alignment.bottomCenter,
              colors: <Color>[
                Colors.black.withAlpha(128),
                Colors.black.withAlpha(0),
              ],
            ),
          ),
        ),
        Container(
          margin: EdgeInsets.zero,
          // shape: const RoundedRectangleBorder(
          //   borderRadius: BorderRadius.zero,
          // ),
          child: SafeArea(
            top: true,
            bottom: false,
            left: true,
            right: true,
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Image.network(
                    "https://rulet.tv/logo-anim.png",
                    height: 200,
                    fit: BoxFit.contain,
                  ),
                  // Card(
                  //   child: InkWell(
                  //     onTap: () {},
                  //     child:
                  //         const Text('Чатик'),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}
