import 'dart:async';
import 'dart:io';
import 'package:ffi/ffi.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_media_metadata/flutter_media_metadata.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:music_player/utils/config.dart';

import '../customWidgets/dialog.dart';
import '../model/music.dart';

class DirectoryPatchUi extends StatefulWidget {
  const DirectoryPatchUi({Key? key}) : super(key: key);

  @override
  State<DirectoryPatchUi> createState() => _DirectoryPatchUiState();
}

class _DirectoryPatchUiState extends State<DirectoryPatchUi> {
  @override
  Widget build(BuildContext context) {
    getAllMusic();
    return Stack(
      children: [
        ValueListenableBuilder<Box>(
          valueListenable: Hive.box('directory_path').listenable(),
          builder: (context, value, child) {
            return ListView.builder(
              itemCount: value.length,
              shrinkWrap: true,
              itemBuilder: (context, index) {
                return Container(
                  width: double.infinity,
                  height: 50,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      Expanded(child: Text(value.getAt(index).toString())),
                      InkWell(
                          onTap: () {
                            value.deleteAt(index);
                          },
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                          ))
                    ],
                  ),
                );
              },
            );
          },
        ),
        Positioned(
            child: Container(
          margin: const EdgeInsets.only(bottom: 16, right: 16),
          alignment: Alignment.bottomRight,
          child: FloatingActionButton(
            mini: true,
            backgroundColor: CustomColor.dark,
            onPressed: () async {
              String? result = await FilePicker.platform.getDirectoryPath();
              if (result != null) {
                listPath.clear();
                Box box = Hive.box('directory_path');
                bool exist = false;
                for(int i = 0; i < box.length;i++){
                  if(box.getAt(i) == result){
                    exist = true;
                  }
                }
                if(!exist){
                  getAllMusicInPath(result);
                  box.add(result);
                }
              }
            },
            child: const Icon(Icons.folder_open, color: Colors.white),
          ),
        )),
        Positioned(
            child: Container(
              margin: const EdgeInsets.only(bottom: 16, left: 16),
              alignment: Alignment.bottomLeft,
              child: FloatingActionButton(
                mini: true,
                backgroundColor: CustomColor.dark,
                onPressed: () async {

                },
                child: const Icon(Icons.folder_open, color: Colors.white),
              ),
            ))
      ],
    );
  }

  List<String> musicListPath = [];
  List<String> listPath = [];
  List<String> listPathSave = [];

  getAllMusicInPath(String path) async {
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
          await getAllMusicInDirectory(event.path);
        }
      }
    }
    checkMusic();
  }

  getAllMusic(){
    Box box = Hive.box<Music>('music_lists');
    musicListPath.clear();
    for(int b = 0; b < box.length;b++){
      Music mu = box.getAt(b);
      musicListPath.add(mu.path);
    }
  }

  Future<void> getAllMusicInDirectory(String path) async {
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
          await getAllMusicInDirectory(event.path);
        }
      }
    }
  }

  show(){
    showDialog(context: context, builder: (context) {
      return Dialog(
        backgroundColor: Colors.transparent,
        clipBehavior: Clip.antiAlias,
        child: Container(
          color: Colors.transparent,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: 100,
                height: 100,
                padding: const EdgeInsets.all(16),
                color: CustomColor.dark,
                child: const CircularProgressIndicator(),
              ),
            ],
          ),
        ),
      );
    },);
  }

  checkMusic(){
    for(int i = 0; i < listPath.length;i++){
      if(!musicListPath.contains(listPath.elementAt(i))){
        listPathSave.add(listPath.elementAt(i));
      }
    }
    listPathSave.toList().map((e) => print(e)).toList();
    save();
  }

  save() async {
    Box box = Hive.box<Music>('music_lists');
    show();
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
    Navigator.of(context).pop();
  }

}



