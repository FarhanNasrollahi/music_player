import 'dart:io';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:music_player/model/playlist.dart';
import 'package:provider/provider.dart';

import '../model/music.dart';
import '../utils/config.dart';
import '../utils/musicPlayer.dart';


class PlayListMusicNotifier extends ChangeNotifier {

  List<Music> listMusic = [];
  List<Music> get mData => listMusic;

  notify(){
    Future.delayed(Duration.zero,() {
      notifyListeners();
    },);
  }

  init(PlayList playList){
    Box box = Hive.box<Music>('music_lists');
    listMusic.clear();
    playList.musicIds.map((e){
      listMusic.add(box.getAt(e));
    }).toList();
    notify();
  }

}

class PlayListMusic extends StatelessWidget {
  const PlayListMusic({Key? key, required this.playList, required this.playlistId}) : super(key: key);

  final int playlistId;
  final PlayList playList;

  @override
  Widget build(BuildContext context) {

    Size size = MediaQuery
        .of(context)
        .size;

    return Consumer2<MusicPlayer,PlayListMusicNotifier>(
      builder: (context, musicPlayer, val , child) {
        val.init(playList);
        return Stack(
          children: [
            Positioned(child: Align(
                alignment: Alignment.center,
                child: Container(
                  width: double.infinity,
                  height: double.infinity,
                  clipBehavior: Clip.antiAlias,
                  decoration: BoxDecoration(
                      image: DecorationImage(
                          image: FileImage(File(playList.image)),
                          fit: BoxFit.cover
                      )
                  ),
                  child: BackdropFilter(
                    filter:  ImageFilter.blur(sigmaX: 20.0, sigmaY: 20.0),
                    child:  Container(
                      decoration:  BoxDecoration(color: Colors.black.withOpacity(0.3)),
                    ),
                  ),
                ))),
            Positioned(child: Align(
              alignment: Alignment.center,
              child: Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    height: size.height / 3,
                    child: Stack(
                      children: [
                        Positioned(child: Align(
                          alignment: Alignment.center,
                          child: Row(
                            children: [
                              Container(
                                width: (size.height / 3) - 48,
                                height: (size.height / 3) - 48,
                                margin: const EdgeInsets.only(left: 24),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(15),
                                    image: DecorationImage(
                                        image: FileImage(File(playList.image)),
                                        fit: BoxFit.cover
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                          color: Colors.white.withOpacity(.1),
                                          offset: const Offset(0,1),
                                          blurRadius: 2,
                                          spreadRadius: 0
                                      )
                                    ]
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(32),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children:  [
                                    Row(
                                      children:  [
                                        const Text('playList' , style: TextStyle(color: CustomColor.gry , fontSize: 14),),
                                        Padding(
                                          padding: EdgeInsets.only(left: 5.0),
                                          child: InkWell(onTap: () {
                                            Box box = Hive.box<PlayList>('playlists');
                                            box.deleteAt(playlistId);
                                          },child: const Icon(Icons.remove , color: CustomColor.darkGry,)),
                                        )
                                      ],
                                    ),
                                    const Spacer(),
                                    Text(playList.name , style: const TextStyle(color: CustomColor.textColor , fontSize: 50 , fontWeight: FontWeight.bold),),
                                  ],
                                ),
                              ),
                              const Spacer(),
                              Column(
                                children: const [
                                  Text('Remove PlayList' , style: TextStyle(color: CustomColor.gry , fontSize: 14),),
                                ],
                              )
                            ],
                          ),
                        ))
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
                    child: Container(
                      decoration: const BoxDecoration(
                        color: CustomColor.darkBg
                      ),
                      child: ReorderableListView.builder(
                        shrinkWrap: true,
                        itemCount: val.mData.length,
                        buildDefaultDragHandles: true,
                        onReorder: (oldIndex, newIndex) {
                          int index = newIndex > oldIndex ? newIndex - 1 : newIndex;
                          Box box = Hive.box<PlayList>('playlists');
                          int indexMusic = playList.musicIds.elementAt(oldIndex);
                          playList.musicIds.removeAt(oldIndex);
                          playList.musicIds.insert(index, indexMusic);
                          box.putAt(playlistId,playList);
                          musicPlayer.updatePlayList(playList);
                          val.init(playList);
                        },
                        itemBuilder: (context, index) {
                          bool isPlay = musicPlayer.musicId == playList.musicIds.elementAt(index) ? true : false;
                          Music music = val.mData.elementAt(index);
                          return Padding(
                            key: ValueKey(music.name),
                            padding: const EdgeInsets.only(top: 8),
                            child: InkWell(
                              borderRadius: BorderRadius.circular(5),
                              hoverColor: Colors.white,
                              onTap: () {
                                musicPlayer.play(playList.musicIds.elementAt(index), music, MusicFrom.playList, change: false , playList: playList);
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
                                                  Icon(Icons.play_arrow , size: 18),
                                                  Padding(
                                                    padding: EdgeInsets.only(left: 8),
                                                    child: Text('Play' , style: TextStyle(fontSize: 14 , height: 1.2),),
                                                  )
                                                ],
                                              ),
                                            )),
                                        PopupMenuItem(value: 2,
                                            height: 30,
                                            child: Row(
                                              children: const [
                                                Icon(Icons.close , size: 18),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 8),
                                                  child: Text('Remove' , style: TextStyle(fontSize: 14 , height: 1.2),),
                                                )
                                              ],
                                            )),
                                        PopupMenuItem(value: 3,
                                            height: 30,
                                            child: Row(
                                              children: const [
                                                Icon(Icons.arrow_upward_rounded, size: 18),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 8),
                                                  child: Text('Move Up' , style: TextStyle(fontSize: 14 , height: 1.2),),
                                                )
                                              ],
                                            )),
                                        PopupMenuItem(value: 4,
                                            height: 30,
                                            child: Row(
                                              children: const [
                                                Icon(Icons.arrow_downward_rounded, size: 18),
                                                Padding(
                                                  padding: EdgeInsets.only(left: 8),
                                                  child: Text('Move Down' , style: TextStyle(fontSize: 14 , height: 1.2),),
                                                )
                                              ],
                                            )),
                                      ],
                                      position: RelativeRect.fromSize(details.globalPosition & const Size(48.0, 48.0), overlay.size));
                                  switch (menuItem) {
                                    case 1:
                                      musicPlayer.play(index, music, MusicFrom.home,
                                          change: false);
                                      break;
                                    case 2:
                                      Box box = Hive.box<PlayList>('playlists');
                                      playList.musicIds.removeAt(index);
                                      box.putAt(playlistId,playList);
                                      musicPlayer.updatePlayList(playList);
                                      val.init(playList);
                                      break;
                                    case 3:
                                      if(index > 0){
                                        Box box = Hive.box<PlayList>('playlists');
                                        int indexMusic = playList.musicIds.elementAt(index);
                                        playList.musicIds.removeAt(index);
                                        playList.musicIds.insert(index - 1, indexMusic);
                                        box.putAt(playlistId,playList);
                                        musicPlayer.updatePlayList(playList);
                                        val.init(playList);
                                      }
                                      break;
                                    case 4:
                                      if(index < playList.musicIds.length - 1){
                                        Box box = Hive.box<PlayList>('playlists');
                                        int indexMusic = playList.musicIds.elementAt(index);
                                        playList.musicIds.removeAt(index);
                                        playList.musicIds.insert(index + 1, indexMusic);
                                        box.putAt(playlistId,playList);
                                        musicPlayer.updatePlayList(playList);
                                        val.init(playList);
                                      }
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
                        },),
                    ),
                  )
                ],
              ),
            ))
          ],
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
