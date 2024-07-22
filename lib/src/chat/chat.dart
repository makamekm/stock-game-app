import 'package:bottom_sheet/bottom_sheet.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bootstrap/flutter_bootstrap.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:get_it/get_it.dart';
import 'package:chat_bubbles/chat_bubbles.dart';
// import 'package:flutter_bootstrap/flutter_bootstrap.dart';

class ChatText extends HookWidget {
  ChatText({
    super.key,
    required this.controller,
    required this.focusNode,
    this.onPressed,
  });

  final FocusNode focusNode;
  final TextEditingController controller;
  final VoidCallback? onPressed;

  final getIt = GetIt.instance;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: EdgeInsets.symmetric(horizontal: 4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(35.0),
              boxShadow: const [
                BoxShadow(blurRadius: 5, color: Colors.black12)
              ],
            ),
            child: Row(
              children: [
                IconButton(
                    icon: const Icon(
                      Icons.face,
                      color: Colors.blueAccent,
                    ),
                    onPressed: () {
                      onPressed?.call();
                    }),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: controller,
                    textInputAction: TextInputAction.send,
                    onSubmitted: (value) {
                      onPressed?.call();
                    },
                    style: const TextStyle(color: Colors.black87),
                    decoration: InputDecoration(
                        hintText: "Сообщение...",
                        hintStyle: const TextStyle(color: Colors.black54),
                        border: InputBorder.none),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        InkWell(
          onTap: () {
            onPressed?.call();
          },
          child: Container(
            alignment: Alignment.center,
            padding: const EdgeInsets.all(16.0),
            decoration: const BoxDecoration(
                color: Colors.blueAccent, shape: BoxShape.circle),
            child: const Icon(
              Icons.send,
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class ChatContainer extends HookWidget {
  ChatContainer({
    super.key,
    required this.controller,
  }) {
    list = [
      const SizedBox(height: 48 + 8),
      ...generateList(),
      ...generateList(),
      ...generateList(),
      ...generateList(),
      ...generateList(),
      ...generateList(),
      ...generateList(),
    ];
  }

  final ScrollController controller;
  final TextEditingController textEditingController = TextEditingController();
  List<Widget> list = List.empty();
  final focusNode = FocusNode();

  final getIt = GetIt.instance;

  Future<void> onFieldSubmitted() async {
    // addMessage();

    // Move the scroll position to the bottom
    controller.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );

    textEditingController.text = '';

    print('send');
  }

  generateList() => const <Widget>[
        BubbleSpecialThree(
          text: 'Added iMessage shape bubbles',
          color: Color(0xFF1B97F3),
          tail: false,
          textStyle: TextStyle(color: Colors.white, fontSize: 16),
        ),
        BubbleSpecialThree(
          text: 'Please try and give some feedback on it!',
          color: Color(0xFF1B97F3),
          tail: true,
          textStyle: TextStyle(color: Colors.white, fontSize: 16),
        ),
        BubbleSpecialThree(
          text: 'Sure',
          color: Color(0xFFE8E8EE),
          tail: false,
          isSender: false,
        ),
        BubbleSpecialThree(
          text: "I tried. It's awesome!!!",
          color: Color(0xFFE8E8EE),
          tail: false,
          isSender: false,
        ),
        BubbleSpecialThree(
          text: "Thanks",
          color: Color(0xFFE8E8EE),
          tail: true,
          isSender: false,
        ),
      ];

  BootstrapContainer wrap(Widget child) {
    return BootstrapContainer(
      key: child.key,
      children: [
        child,
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    // var controler = getIt<LocalVideoController>();
    // final selectedVideoStream = useStream(controler.selectedVideoStream);
    // final selectedAudioStream = useStream(controler.selectedAudioStream);
    // final videoDevices = useStream(controler.videoDevices);
    // final audioDevices = useStream(controler.audioDevices);

    return Stack(
      fit: StackFit.expand,
      children: [
        GestureDetector(
          onTap: () {
            FocusScope.of(context).unfocus();
          },
          child: Container(
            // margin: const EdgeInsets.only(bottom: 48),
            child: ListView(
              padding: const EdgeInsets.all(16),
              controller: controller,
              shrinkWrap: true,
              reverse: true,
              children: list.map(wrap).toList(),
            ),
          ),
        ),
        Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: wrap(
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 8,
                ),
                color: Colors.white,
                child: ChatText(
                    focusNode: focusNode,
                    controller: textEditingController,
                    onPressed: () {
                      onFieldSubmitted();
                    }),
              ),
            )),
      ],
    );
  }
}

class Chat {
  static void openChat(BuildContext context) {
    showFlexibleBottomSheet<void>(
        anchors: [0.5, 0.9],
        isExpand: true,
        initHeight: 0.5,
        maxHeight: 0.9,
        isSafeArea: true,
        context: context,
        bottomSheetColor: Colors.white,
        bottomSheetBorderRadius:
            const BorderRadius.vertical(top: Radius.circular(12)),
        builder: (context, controller, offset) {
          return SafeArea(
            child: ChatContainer(controller: controller),
          );
        });
  }
}
