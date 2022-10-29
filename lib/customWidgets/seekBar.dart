import 'package:flutter/material.dart';
import 'package:music_player/utils/config.dart';
import 'package:music_player/utils/musicPlayer.dart';
import 'package:provider/provider.dart';

class CustomSeekBar extends StatelessWidget {
  const CustomSeekBar({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayer>(
      builder: (context, value, child) {
        return Container(
          width: 150,
          height: 50,
          alignment: Alignment.center,
          padding: const EdgeInsets.only(left: 10),
          child: Row(
            children: [
              InkWell(
                  onTap: () {
                    if (value.getVolume > 0) {
                      value.setMusicVolume(0);
                    } else {
                      value.setMusicVolume(0.5);
                    }
                  },
                  child: Image.asset(value.getVolume == 0 ?
                    'assets/images/mute.png' :
                    value.getVolume < 0.3 ?
                    'assets/images/low-volume.png':
                    value.getVolume < 0.7 ?
                    'assets/images/m_volume.png' :
                    'assets/images/volume.png',
                    color: CustomColor.gry , width: 24,height: 24,)),
              Container(
                width: 106,
                height: 10,
                margin: const EdgeInsets.only(left: 10),
                child: InkWell(
                  onTap: () {

                  },
                  child: GestureDetector(
                    onHorizontalDragDown: (details) {
                      int dx = details.localPosition.dx.round();
                      if (dx >= 0 && dx <= 106) {
                        value.setMusicVolume(((1 / 10) *
                            ((10 / 106) * dx).round()));
                      }
                    },
                    onHorizontalDragUpdate: (details) {
                      int dx = details.localPosition.dx.round();
                      if (dx >= 0 && dx <= 106) {
                        value.setMusicVolume(((1 / 10) *
                            ((10 / 106) * dx).round()));
                      }
                    },
                    child: Stack(
                      children: [
                        Positioned(
                            child: Align(
                              alignment: Alignment.center,
                              child: Container(
                                width: double.infinity,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: CustomColor.darkGry,
                                    borderRadius: BorderRadius.circular(2)
                                ),
                              ),
                            )),
                        Positioned(
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 100),
                                width: 106 * value.getVolume,
                                height: 4,
                                decoration: BoxDecoration(
                                    color: CustomColor.gry,
                                    borderRadius: BorderRadius.circular(2)
                                ),
                              ),
                            )),
                      ],
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }


  }
