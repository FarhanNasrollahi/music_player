import 'dart:io';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:hive/hive.dart';
import '../model/music.dart';

class CheckMusic {

  List<String> musicListPath = [];

  check()  {
    Box box = Hive.box('directory_path');
    getAllMusic();
    for(int i =0;i < box.length; i++){
     String path = box.getAt(i);
    getAllMusicInPath(path);
    }
  }

  getAllMusicInPath(String path) async {
    print('run');
    List<String> listPath = [];
    Directory appDocDir = Directory(path);
    bool folderExists = await appDocDir.exists();
    int size = await appDocDir.list().length;
    List<FileSystemEntity> myList = await appDocDir.list().toList();
    if (folderExists) {
      for(int i = 0;i < size ;i++){
        FileSystemEntity event = myList.elementAt(i);
        if (event.path.contains('.')) {
          if (event.path.endsWith('.mp3') || event.path.endsWith('.m4a')) {
            listPath.add(event.path);
          }
        } else {
          await getAllMusicInDirectory(listPath,event.path);
        }
      }
    }
    checkMusic(listPath);
  }

  getAllMusic(){
    Box box = Hive.box<Music>('music_lists');
    musicListPath.clear();
    for(int b = 0; b < box.length;b++){
      Music mu = box.getAt(b);
      musicListPath.add(mu.path);
    }
  }

  Future<void> getAllMusicInDirectory(List<String> listPath , String path) async {
    Directory appDocDir = Directory(path);
    bool folderExists = await appDocDir.exists();
    int size = await appDocDir.list().length;
    List<FileSystemEntity> myList = await appDocDir.list().toList();
    if (folderExists) {
      for(int i = 0;i < size ;i++){
        FileSystemEntity event = myList.elementAt(i);
        if (event.path.contains('.')) {
          if (event.path.endsWith('.mp3') || event.path.endsWith('.m4a')) {
            listPath.add(event.path);
          }
        } else {
          await getAllMusicInDirectory(listPath , event.path);
        }
      }
    }
  }

  checkMusic(List<String> listPath){
    List<String> listPathSave = [];
    for(int i = 0; i < listPath.length;i++){
      if(!musicListPath.contains(listPath.elementAt(i))){
        listPathSave.add(listPath.elementAt(i));
      }
    }
    save(listPathSave);
  }

  save(List<String> listPathSave) async {
    Box box = Hive.box<Music>('music_lists');
    for(int i = 0; i < listPathSave.length;i++){
      final metaData = await MetadataRetriever.fromFile(File(listPathSave.elementAt(i)));
      String name = metaData.trackName!;
      if(name.isEmpty){
        name = listPathSave.elementAt(i).substring(listPathSave.elementAt(i).lastIndexOf('\\')+1,listPathSave.elementAt(i).lastIndexOf('.'));
      }
      Music music = Music(
          name,
          metaData.trackArtistNames ?? ['null'],
          metaData.albumName ?? 'null',
          metaData.year ?? 0,
          metaData.trackDuration ?? 0,
          metaData.albumArt?.toList() ?? [],
          listPathSave.elementAt(i));
      box.add(music);
    }
  }

}