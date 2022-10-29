import 'dart:io';

import 'package:bitsdojo_window/bitsdojo_window.dart';
import 'package:desktop_window/desktop_window.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/ui/directoryPatchUi.dart';
import 'package:music_player/ui/homeMusic.dart';
import 'package:music_player/ui/playlistMusic.dart';
import 'package:music_player/utils/checkMusic.dart';
import 'package:music_player/utils/config.dart';
import 'package:music_player/utils/keyManager.dart';
import 'package:music_player/utils/musicPlayer.dart';
import 'package:provider/provider.dart';

import 'customWidgets/dialog.dart';
import 'customWidgets/seekBar.dart';
import 'model/music.dart';
import 'model/playlist.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  // await Hive.deleteBoxFromDisk('music_lists');

  doWhenWindowReady(() {
    final win = appWindow;
    const initialSize = Size(900, 600);
    win.minSize = initialSize;
    win.size = initialSize;
    win.alignment = Alignment.center;
    win.show();
  });

  Hive.registerAdapter(MusicAdapter());
  Hive.registerAdapter(PlayListAdapter());

  await Hive.openBox('coverBox');
  await Hive.openBox('directory_path');
  await Hive.openBox('player');
  await Hive.openBox<Music>('music_lists');
  await Hive.openBox<PlayList>('playlists');

  CheckMusic().check();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider(
            create: (context) => MusicPlayer(),
          ),
          ChangeNotifierProvider(create: (context) => PlayListMusicNotifier(),)
        ],
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Flutter Demo',
          themeMode: ThemeMode.dark,
          theme:
              ThemeData(brightness: Brightness.dark),
          home: WindowBorder(
            color: CustomColor.darkBg,
            width: 0,
            child: Column(
              children: [
                Container(
                  color: CustomColor.darkBg,
                  child: Row(
                    children: [
                      Expanded(child: WindowTitleBarBox(child: Row(
                        children: [
                          Expanded(child: MoveWindow()),
                          const WindowButtons()
                        ],
                      ))),
                    ],
                  ),
                ),
                const Expanded(child: MyHomePage())
              ],
            ),
          ),
        ));
  }
}

final buttonColors = WindowButtonColors(
    iconNormal: const Color(0xFF805306),
    mouseOver: const Color(0xFFF6A00C),
    mouseDown: const Color(0xFF805306),
    iconMouseOver: const Color(0xFF805306),
    iconMouseDown: const Color(0xFFFFD500));

final closeButtonColors = WindowButtonColors(
    mouseOver: const Color(0xFFD32F2F),
    mouseDown: const Color(0xFFB71C1C),
    iconNormal: const Color(0xFF805306),
    iconMouseOver: Colors.white);

class WindowButtons extends StatefulWidget {
  const WindowButtons({Key? key}) : super(key: key);

  @override
  _WindowButtonsState createState() => _WindowButtonsState();
}

class _WindowButtonsState extends State<WindowButtons> {
  void maximizeOrRestore() {
    setState(() {
      appWindow.maximizeOrRestore();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        MinimizeWindowButton(colors: buttonColors),
        appWindow.isMaximized
            ? RestoreWindowButton(
          colors: buttonColors,
          onPressed: maximizeOrRestore,
        )
            : MaximizeWindowButton(
          colors: buttonColors,
          onPressed: maximizeOrRestore,
        ),
        CloseWindowButton(colors: closeButtonColors),
      ],
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  PlayList playList = PlayList('', '', []);
  int playListId = 0;
  int selected = 1;


  bool playListOpen = false;

  @override
  void initState() {
    super.initState();
    context.read<MusicPlayer>().init();
    KeyManager.init(context);
  }

  @override
  Widget build(BuildContext context) {

    List<Widget> list = [const DirectoryPatchUi(), const HomeMusic() , PlayListMusic(playList: playList , playlistId: playListId,)];

    return Scaffold(
      backgroundColor: CustomColor.darkBg,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Expanded(
                child: Row(
              children: [
                Container(
                  width: 1100 / 4,
                  height: double.infinity,
                  decoration:
                      BoxDecoration(color: CustomColor.dark, boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.2),
                        blurRadius: 2,
                        spreadRadius: 0,
                        offset: const Offset(0.1, 0))
                  ]),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: 30,
                        child: Row(
                          children: [
                            Image.asset('assets/images/home.png',
                                width: 20, height: 20, color: selected == 1 ? CustomColor.textColor : CustomColor.gry),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selected = 1;
                                });
                              },
                              child:  Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  'Home',
                                  style: TextStyle(
                                      color: selected == 1 ? CustomColor.textColor : CustomColor.gry,
                                      height: 1.5,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Row(
                          children: [
                             Icon(Icons.settings,
                                color: selected == 0 ? CustomColor.textColor : CustomColor.gry, size: 20),
                            InkWell(
                              onTap: () {
                                setState(() {
                                  selected = 0;
                                });
                              },
                              child:  Padding(
                                padding: const EdgeInsets.only(left: 5),
                                child: Text(
                                  'Settings',
                                  style: TextStyle(
                                      color: selected == 0 ? CustomColor.textColor : CustomColor.gry,
                                      height: 1.5,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                      SizedBox(
                        height: 30,
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            InkWell(
                              onTap: () {
                                setState(() {
                                  playListOpen = !playListOpen;
                                });
                              },
                              child: const Padding(
                                padding: EdgeInsets.only(right: 5, left: 5),
                                child: Text(
                                  'PlayList',
                                  style: TextStyle(
                                      color: CustomColor.gry,
                                      height: 0.9,
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold),
                                ),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                NewPlayListDialog().show(context);
                              },
                              child: const Icon(Icons.add,
                                  color: CustomColor.gry,
                                  size: 16),
                            )
                          ],
                        ),
                      ),
                      Expanded(
                          child: playListOpen
                              ? ValueListenableBuilder<Box>(
                                  valueListenable:
                                      Hive.box<PlayList>('playlists')
                                          .listenable(),
                                  builder: (context, value, child) {
                                    return ListView.builder(
                                      padding: const EdgeInsets.only(left: 5),
                                      shrinkWrap: true,
                                      itemCount: value.length,
                                      itemBuilder: (context, index) {
                                        PlayList p = value.getAt(index);
                                        return InkWell(
                                          onTap: () {
                                            setState(() {
                                              playListId = index;
                                              playList = p;
                                              selected = 2;
                                            });
                                          },
                                          child: SizedBox(
                                            height: 25,
                                            child: Text(p.name,
                                                style: const TextStyle(
                                                    color: CustomColor.textColor,
                                                    height: 0.9,
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.bold)),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                )
                              : Container()),
                      SizedBox(
                        width: (1100 / 4) - 68,
                        height: (1100 / 4) - 68,
                        child: ValueListenableBuilder<Box>(
                          valueListenable: Hive.box('coverBox').listenable(),
                          builder: (context, value, child) {
                            final cover = value.get('last_music_cover', defaultValue: []);
                            List l = cover;
                            bool imageS = false;
                            if(l.length == 1){
                               imageS = true;
                            }
                            return Container(
                              width: (1100 / 4) - 68,
                              height: (1100 / 4) - 68,
                              margin:
                                  const EdgeInsets.only(bottom: 10, top: 10),
                              clipBehavior: Clip.antiAlias,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: CustomColor.darkBg,
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.black.withOpacity(.5),
                                        blurRadius: 3,
                                        offset: const Offset(0, 1),
                                        spreadRadius: 0)
                                  ]),
                              child: imageS ? Image.file(File(l.elementAt(0)),fit: BoxFit.cover) :  Uint8List.fromList(cover).isNotEmpty
                                  ? Image.memory(Uint8List.fromList(cover),
                                      fit: BoxFit.cover)
                                  : Image.asset('assets/images/music.png',
                                      width: 20,
                                      height: 20,
                                      color: CustomColor.gry),
                            );
                          },
                        ),
                      )
                    ],
                  ),
                ),
                Expanded(
                  child: Align(
                      alignment: Alignment.topCenter, child: list[selected]),
                )
              ],
            )),
            Container(
                height: 120,
                decoration: BoxDecoration(color: CustomColor.dark, boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(.2),
                      blurRadius: 2,
                      spreadRadius: 0,
                      offset: const Offset(1100 / 4, -0.1))
                ]),
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: const MusicController())
          ],
        ),
      ),
    );
  }
}

class MusicController extends StatelessWidget {
  const MusicController({Key? key}) : super(key: key);

  Widget customText(String text, double fontSize, Color fontColor) {
    return Text(
      text,
      maxLines: 1,
      style: TextStyle(fontSize: fontSize, color: fontColor),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayer>(
      builder: (context, value, child) {
        return Column(
          children: [
            Expanded(
                child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                    flex: 2,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: customText(
                                value.getMusic?.name ?? '', 16, Colors.white)),
                        Expanded(
                            child: customText(
                                value.getMusic?.artistNames.elementAt(0) ?? '',
                                12,
                                Colors.white.withOpacity(.3)))
                      ],
                    )),
                Expanded(
                    flex: 2,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: InkWell(
                            onTap: () {
                              value.perv();
                            },
                            child: Image.asset(
                              'assets/images/previous.png',
                              color: CustomColor.gry,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                        InkWell(
                          borderRadius: BorderRadius.circular(20),
                          onTap: () {
                            value.playByKey();
                          },
                          child: Container(
                            width: 45,
                            height: 45,
                            decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(22.5),
                                color: Colors.white.withOpacity(.1)),
                            child: Icon(value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          child: InkWell(
                            onTap: () {
                              value.next();
                            },
                            child: Image.asset(
                              'assets/images/next.png',
                              color: CustomColor.gry,
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ],
                    )),
                Expanded(
                  flex: 2,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      InkWell(
                          onTap: () {
                            value.setMusicShuffle(!value.isShuffle);
                          },
                          child: Image.asset(
                            'assets/images/shuffle.png',
                            color: value.isShuffle
                                ? CustomColor.activeIconColor
                                : CustomColor.darkGry,
                            width: 24,
                            height: 24,
                          )),
                      Padding(
                        padding: const EdgeInsets.only(left: 8.0),
                        child: InkWell(
                            onTap: () {
                              switch (value.getMusicRepeat) {
                                case MusicRepeat.all:
                                  value.setMusicRepeat(MusicRepeat.one);
                                  break;
                                case MusicRepeat.off:
                                  value.setMusicRepeat(MusicRepeat.all);
                                  break;
                                case MusicRepeat.one:
                                  value.setMusicRepeat(MusicRepeat.off);
                                  break;
                              }
                            },
                            child: Image.asset(
                              value.getMusicRepeat == MusicRepeat.one
                                  ? 'assets/images/replay.png'
                                  : 'assets/images/repeat.png',
                              color: value.getMusicRepeat != MusicRepeat.off
                                  ? CustomColor.activeIconColor
                                  : CustomColor.darkGry,
                              width: 24,
                              height: 24,
                            )),
                      ),
                      const CustomSeekBar()
                    ],
                  ),
                )
              ],
            )),
            const Expanded(child: BottomTest()),
          ],
        );
      },
    );
  }
}

class BottomTest extends StatelessWidget {
  const BottomTest({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<MusicPlayer>(
      builder: (context, value, child) {
        return NotificationListener<SizeChangedLayoutNotification>(
            onNotification: (notification) {
              value.notify();
              return false;
            },
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Expanded(
                  child: SizedBox(
                    width: MediaQuery.of(context).size.width - 48,
                    height: 10,
                    child: GestureDetector(
                      onHorizontalDragUpdate: (details) {
                        double dx = details.localPosition.dx;
                        if (dx > 0 &&
                            dx < MediaQuery.of(context).size.width - 48) {
                          value.setMusicProgress(((1000 /
                                      (MediaQuery.of(context).size.width -
                                          48)) *
                                  dx)
                              .round());
                        }
                      },
                      onHorizontalDragStart: (details) {
                        double dx = details.localPosition.dx;
                        if (dx > 0 &&
                            dx < MediaQuery.of(context).size.width - 48) {
                          value.setMusicProgress(((1000 /
                                      (MediaQuery.of(context).size.width -
                                          48)) *
                                  dx)
                              .round());
                        }
                      },
                      child: Stack(
                        children: [
                          Positioned(
                              child: Align(
                            alignment: Alignment.center,
                            child: Container(
                              width: MediaQuery.of(context).size.width - 48,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2.5),
                                  color: CustomColor.darkGry),
                            ),
                          )),
                          Positioned(
                              child: Align(
                            alignment: Alignment.centerLeft,
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 500),
                              width: ((MediaQuery.of(context).size.width - 48) /
                                      1000) *
                                  value.getMusicProgress,
                              height: 5,
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(2.5),
                                  gradient: const LinearGradient(
                                    colors: [CustomColor.gry, CustomColor.yel],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.bottomRight,
                                    tileMode: TileMode.clamp,
                                  )),
                            ),
                          ))
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          formatTime(
                              timeInSecond: value.getDuration.inMilliseconds),
                          style: const TextStyle(
                              color: CustomColor.darkGry,
                              fontSize: 14,
                              fontWeight: FontWeight.bold)),
                      const Spacer(),
                      Text(formatTime(timeInSecond: value.music?.duration ?? 0),
                          style: const TextStyle(
                              color: CustomColor.darkGry,
                              fontSize: 14,
                              fontWeight: FontWeight.bold))
                    ],
                  ),
                )
              ],
            ));
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
}
