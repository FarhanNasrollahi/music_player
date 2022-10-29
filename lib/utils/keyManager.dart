


import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:keyboard_event/keyboard_event.dart';
import 'package:music_player/utils/musicPlayer.dart';
import 'package:provider/provider.dart';

class KeyManager {

  static bool error = false;
  static KeyboardEvent? keyboardEvent;

  static init(BuildContext context) async {

    String? platformVersion;
    try {
      platformVersion = await KeyboardEvent.platformVersion;
    } on PlatformException {
      error = true;
    }

    try {
      await KeyboardEvent.init();
    } on PlatformException {
      error = true;
    }

    keyboardEvent = KeyboardEvent();

    keyboardEvent?.startListening((keyEvent) async {
      if(keyEvent.flags == 1){
        switch(keyEvent.vkCode){
          case 179:
            context.read<MusicPlayer>().playByKey();
            break;
          case 177:
            context.read<MusicPlayer>().perv();
            break;
          case 176:
            context.read<MusicPlayer>().next();
            break;
        }
      }
    });

  }

}