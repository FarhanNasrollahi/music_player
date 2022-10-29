import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/utils/musicPlayer.dart';
import 'package:provider/provider.dart';

import '../customWidgets/dialog.dart';
import '../model/music.dart';
import '../utils/config.dart';

class HomeMusic extends StatelessWidget {
  const HomeMusic({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayer>(
      builder: (context, musicPlayer, child) {
        return ValueListenableBuilder<Box>(
          valueListenable: Hive.box<Music>('music_lists').listenable(),
          builder: (context, value, child) {
            List<Music> musicList = [];
            List<int> musicId = [];
            for(int i = 0;i < value.length; i++){
              Music music = value.getAt(i);
              if(musicPlayer.getSearch.isNotEmpty){
                if(music.name.trim().toLowerCase().contains(musicPlayer.getSearch.trim().toLowerCase())){
                  musicList.add(music);
                  musicId.add(i);
                }
              }else{
                musicList.add(music);
              }
            }
            return Column(
              children: [
                Container(
                  width: double.infinity,
                  height: 40,
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 8),
                  margin: const EdgeInsets.only(top: 16),
                  child: Row(
                    children: [
                      Container(
                        width: 150,
                        height: 30,
                        padding: const EdgeInsets.symmetric(horizontal: 8),
                        decoration: BoxDecoration(
                          color: Colors.transparent,
                          borderRadius: BorderRadius.circular(15),
                          border: Border.all(color: CustomColor.gry.withOpacity(.5), width: 0.5)
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children:  [
                            Expanded(child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: 5.0),
                              child: TextField(
                                controller: musicPlayer.getTextEditingControllerSearch,
                                maxLines: 1,
                                style: const TextStyle(
                                  fontSize: 14
                                ),
                                decoration: const InputDecoration(
                                  hintText: 'search',
                                  hintStyle: TextStyle(
                                    color: CustomColor.gry
                                  ),
                                  border: InputBorder.none
                                ),
                              ),
                            )),
                            const Padding(
                              padding: EdgeInsets.only(left: 0),
                              child: Icon(Icons.search , color: CustomColor.gry),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                ),
                Container(
                  width: double.infinity,
                  height: 20,
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  margin: const EdgeInsets.only(top: 8),
                  child:  Row(
                    children: [
                      Expanded(
                          flex: 3,
                          child: customText('Title', false, bold: true)),
                      Expanded(
                          flex: 2,
                          child: customText('Artist', false, bold: true)),
                      Expanded(
                          flex: 2,
                          child: customText('Album', false, bold: true)),
                      Expanded(
                          flex: 2,
                          child: customText('Genre', false, bold: true)),
                      Expanded(
                          flex: 1,
                          child: customText('Duration', false , bold: true)),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: musicList.length,
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      bool isPlay = musicPlayer.musicId == index ? true : false;
                      Music music = musicList.elementAt(index);
                      return Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: InkWell(
                          borderRadius: BorderRadius.circular(5),
                          hoverColor: Colors.white.withOpacity(.1),
                          onTap: () {
                            musicPlayer.play(index, music, MusicFrom.home,
                                change: false);
                          },
                          child: GestureDetector(
                            onSecondaryTapDown: (details) async {
                              final overlay = Overlay
                                  .of(context)
                                  ?.context
                                  .findRenderObject() as RenderBox;
                              final menuItem = await showMenu<int>(
                                  context: context,
                                  color: CustomColor.darkBg,
                                  elevation: 3,
                                  items: [
                                    PopupMenuItem(value: 1,
                                        height: 30,
                                        child: SizedBox(
                                          width: 100,
                                          child: Row(
                                            children: const [
                                              Icon(Icons.play_arrow, size: 18),
                                              Padding(
                                                padding: EdgeInsets.only(left: 8),
                                                child: Text('play' , style: TextStyle(fontSize: 14 , height: 1.2),),
                                              )
                                            ],
                                          ),
                                        )),
                                    PopupMenuItem(value: 2,
                                        height: 30,
                                        child: Row(
                                          children: const [
                                            Icon(Icons.add, size: 18),
                                            Padding(
                                              padding: EdgeInsets.only(left: 8),
                                              child: Text('add to' , style: TextStyle(fontSize: 14 , height: 1.2),),
                                            )
                                          ],
                                        )),
                                  ],
                                  position: RelativeRect.fromSize(
                                      details.globalPosition & const Size(48.0, 48.0), overlay.size));
                              switch (menuItem) {
                                case 1:
                                  musicPlayer.play(index, music, MusicFrom.home,
                                      change: false);
                                  break;
                                case 2:
                                   PlayListSelectionDialog().show(context, musicPlayer.getSearch.isNotEmpty ? musicId.elementAt(index) : index);
                                  break;
                                default:
                              }
                            },
                            child: Container(
                              width: double.infinity,
                              height: 35,
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                      flex: 3,
                                      child: customText(music.name, isPlay)),
                                  Expanded(
                                      flex: 2,
                                      child: customText(
                                          music.artistNames.isNotEmpty
                                              ? music.artistNames
                                                  .elementAt(0)
                                                  .toString()
                                              : 'Unknown artist',
                                          isPlay)),
                                  Expanded(
                                      flex: 2,
                                      child: customText(
                                          music.albumName.isNotEmpty
                                              ? music.albumName
                                              : 'Unknown album',
                                          isPlay)),
                                  Expanded(
                                      flex: 2,
                                      child: customText(
                                          music.year != 0
                                              ? music.year.toString()
                                              : 'Unknown genre',
                                          isPlay)),
                                  Expanded(
                                      flex: 1,
                                      child: customText(
                                          formatTime(timeInSecond: music.duration),
                                          isPlay)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                )
              ],
            );
          },
        );
      },
    );
  }

  formatTime({required int timeInSecond}) {
    final time = Duration(milliseconds: timeInSecond);
    String times = time.toString().substring(2, 7);
    if (times.startsWith('0')) {
      times = times.substring(1, times.length);
    }
    return times;
  }

  Widget customText(String text, bool isPlay , {bool bold = false}) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(
          fontSize: 12, color: bold ? CustomColor.gry :  isPlay ? Colors.white : CustomColor.textColor , fontWeight: bold ? FontWeight.bold : FontWeight.normal),
    );
  }
}

class SubMenu extends StatefulWidget {
  final String title;
  const SubMenu(this.title);

  @override
  _SubMenuState createState() => _SubMenuState();
}

class _SubMenuState extends State<SubMenu> {
  @override
  Widget build(BuildContext context) {
//     print(rendBox.size.bottomRight);

    return PopupMenuButton<int>(
      onCanceled: () {
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
      },
      offset: const Offset(300, 0),
      itemBuilder: (BuildContext context) => <PopupMenuEntry<int>>[
        const PopupMenuItem(
          value: 1,
          child: Text('Working a lot harder'),
        ),
      ],
      child: Row(
        children: <Widget>[
          Text(widget.title),
          const Spacer(),
          const Icon(Icons.arrow_right, size: 30.0),
        ],
      ),
    );
  }
}
