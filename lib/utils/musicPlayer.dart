import 'dart:math';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/model/music.dart';
import 'package:music_player/model/playlist.dart';

enum MusicFrom { home, playList }

enum MusicRepeat { all, off, one }

class MusicPlayer extends ChangeNotifier {

  AudioPlayer audioPlayer = AudioPlayer(playerId: 'base');

  String musicPath = '';

  String get getPath => musicPath;

  Music? music;

  Music? get getMusic => music;

  MusicRepeat musicRepeat = MusicRepeat.off;

  MusicRepeat get getMusicRepeat => musicRepeat;

  late Box box;
  late Box boxMusic;
  late Box coverBox;

  int musicProgress = 0;

  int get getMusicProgress => musicProgress;

  MusicFrom musicFrom = MusicFrom.home;

  bool playing = false;

  bool get isPlaying => playing;

  bool shuffle = false;

  bool get isShuffle => shuffle;

  Duration duration = Duration.zero;

  Duration get getDuration => duration;

  int musicId = -1;

  int get getId => musicId;

  double volume = 0.5;

  double get getVolume => volume;

  TextEditingController textEditingControllerSearch = TextEditingController();
  TextEditingController get getTextEditingControllerSearch => textEditingControllerSearch;

  String search = '';
  String get getSearch => search;

  notify() {
    Future.delayed(
      Duration.zero,
      () {
        notifyListeners();
      },
    );
  }

  setMusicVolume(double volume) async {
    box.put('volume', volume);
    this.volume = volume;
    await audioPlayer.setVolume(volume);
    notify();
  }

  setMusicShuffle(bool shuffle) {
    this.shuffle = shuffle;
    notify();
  }

  setMusicProgress(int percent) {
    int d = ((music!.duration / 1000) * percent).round();
    audioPlayer.seek(Duration(milliseconds: d));
  }

  setMusicRepeat(MusicRepeat musicRepeat) {
    this.musicRepeat = musicRepeat;
    switch (musicRepeat) {
      case MusicRepeat.all:
        audioPlayer.setReleaseMode(ReleaseMode.stop);
        break;
      case MusicRepeat.off:
        audioPlayer.setReleaseMode(ReleaseMode.stop);
        break;
      case MusicRepeat.one:
        audioPlayer.setReleaseMode(ReleaseMode.loop);
        break;
    }
    notify();
  }

  init() {

    box = Hive.box('player');
    boxMusic = Hive.box<Music>('music_lists');
    coverBox = Hive.box('coverBox');

    audioPlayer.onPlayerStateChanged.listen((event) {
      if (event.name == 'playing') {
        playing = true;
      } else if (event.name == 'paused') {
        playing = false;
      } else if (event.name == 'completed') {
        switch (musicRepeat) {
          case MusicRepeat.all:
            next();
            break;
          case MusicRepeat.off:
            next();
            break;
          case MusicRepeat.one:
            break;
        }
      }
      notify();
    });

    audioPlayer.onPositionChanged.listen((event) {
      duration = event.abs();
      lastMusicDuration(duration);
      musicProgress =
          ((1000 / music!.duration) * event.abs().inMilliseconds).round();
      notify();
    });

    volume = box.get('volume', defaultValue: 0.5);
    audioPlayer.setVolume(volume);
    audioPlayer.setBalance(0);


    textEditingControllerSearch.addListener(() {
      search = textEditingControllerSearch.text;
      notify();
    });

    if(boxMusic.isNotEmpty){
      if(box.get('last_music_path') != null){
        musicId = box.get('last_music_id');
        music = boxMusic.getAt(musicId);
        musicPath = music!.path;
        duration = Duration(milliseconds: box.get('last_music_duration'));
        audioPlayer.setSource(DeviceFileSource(musicPath));
        audioPlayer.seek(duration);
        notify();
      }
    }
  }

  lastMusicPlayedPath(String path) {
    box.put('last_music_path', path);
  }

  lastMusicDuration(Duration duration) {
    box.put('last_music_duration', duration.inMilliseconds);
  }

  lastMusicId(int id) {
    box.put('last_music_id', id);
  }

  lastMusicCover(List<int> cover) {
    switch(musicFrom){
      case MusicFrom.home:
        coverBox.put('last_music_cover', cover);
        break;
      case MusicFrom.playList:
       if(cover.isEmpty){
         coverBox.put('last_music_cover', [playList!.image]);
       }else{
         coverBox.put('last_music_cover', cover);
       }
        break;
    }
  }

  updatePlayList(PlayList playList){
    if(musicFrom == MusicFrom.playList){
      this.playList = playList;
      notify();
    }
  }

  lastMusicFrom(MusicFrom musicFrom) {
    switch (musicFrom) {
      case MusicFrom.home:
        box.put('last_music_from', 'home');
        break;
      case MusicFrom.playList:
        box.put('last_music_from', 'playList');
        break;
    }
  }

  PlayList? playList;

  play(int id, Music music, MusicFrom musicFrom,
      {PlayList? playList, bool? change}) async {
    this.musicFrom = musicFrom;
    if (musicFrom == MusicFrom.playList) {
      this.playList = playList;
    }
    lastMusicId(id);
    lastMusicPlayedPath(music.path);
    lastMusicCover(music.cover);
    musicId = id;
    this.music = music;
    musicPath = music.path;
    notify();
    if (playing) {
      await audioPlayer.stop();
      await audioPlayer.release();
      await audioPlayer.play(DeviceFileSource(music.path));
    } else {
      if (change!) {
        await audioPlayer.setSource(DeviceFileSource(music.path));
      } else {
        await audioPlayer.play(DeviceFileSource(music.path));
      }
    }
  }

  playByKey() {
    if (playing) {
      pause();
    } else {
      resume();
    }
  }

  pause() async {
    await audioPlayer.pause();
  }

  resume() async {
    await audioPlayer.resume();
  }

  next() {
    switch(musicFrom){
      case MusicFrom.home:
        if (musicId < boxMusic.length - 1) {
          if (isShuffle) {
            musicId = Random().nextInt(boxMusic.length);
          } else {
            musicId++;
          }
          play(musicId, boxMusic.getAt(musicId), musicFrom, change: true);
        } else {
          if (musicRepeat == MusicRepeat.all) {
            musicId = 0;
            play(musicId, boxMusic.getAt(musicId), musicFrom, change: true);
          }
        }
        break;
      case MusicFrom.playList:
        int index = playList!.musicIds.indexOf(musicId);
        if (index < playList!.musicIds.length - 1) {
          if (isShuffle) {
            musicId = playList!.musicIds.elementAt(Random().nextInt(playList!.musicIds.length));
          } else {
            musicId = playList!.musicIds.elementAt(index + 1);
          }
          play(musicId, boxMusic.getAt(musicId), musicFrom, change: true , playList: playList);
        }else{
          if (musicRepeat == MusicRepeat.all) {
            musicId = playList!.musicIds.elementAt(0);
            play(musicId, boxMusic.getAt(musicId), musicFrom, change: true, playList: playList);
          }
        }
        break;
    }
  }

  perv() {
    switch(musicFrom){
      case MusicFrom.home:
        if (musicId > 0) {
          if (isShuffle) {
            musicId = Random().nextInt(boxMusic.length);
          } else {
            musicId--;
          }
        } else {
          musicId = boxMusic.length - 1;
        }
        play(musicId, boxMusic.getAt(musicId), musicFrom, change: true);

        break;
      case MusicFrom.playList:

        int index = playList!.musicIds.indexOf(musicId);
        if (index > 0) {
          if (isShuffle) {
            musicId = playList!.musicIds.elementAt(Random().nextInt(playList!.musicIds.length));
          } else {
            musicId = playList!.musicIds.elementAt(index-1);
          }
        } else {
          musicId = playList!.musicIds.elementAt(playList!.musicIds.length - 1);
        }
        play(musicId, boxMusic.getAt(musicId), musicFrom, change: true , playList: playList);

        break;
    }
  }

}
