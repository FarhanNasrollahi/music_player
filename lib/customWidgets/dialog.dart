import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:music_player/model/playlist.dart';
import 'package:music_player/utils/config.dart';



class NewPlayListDialog {
  show(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return const Dialog(
            alignment: Alignment.center,
            backgroundColor: Colors.transparent,
            child: NewPlayListDialogDesign());
      },
    );
  }
}

class NewPlayListDialogDesign extends StatefulWidget {
  const NewPlayListDialogDesign({Key? key}) : super(key: key);

  @override
  State<NewPlayListDialogDesign> createState() =>
      _NewPlayListDialogDesignState();
}

class _NewPlayListDialogDesignState extends State<NewPlayListDialogDesign> {

  TextEditingController textEditingControllerName = TextEditingController();
  String imagePath = '';

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery
        .of(context)
        .size;
    return Container(
      width: size.width / 4,
      height: size.width / 4,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
          color: CustomColor.darkBg, borderRadius: BorderRadius.circular(15)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Container(
            width: double.infinity,
            height: 50,
            alignment: Alignment.centerRight,
            child: InkWell(
                onTap: () {
                  Navigator.of(context).pop();
                },
                child: const Icon(Icons.clear, color: CustomColor.gry)),
          ),
          const Spacer(),
          InkWell(
            borderRadius: BorderRadius.circular(15),
            onTap: () async {
              FilePickerResult? result = await FilePicker.platform.pickFiles(
                type: FileType.custom,
                allowMultiple: false,
                allowedExtensions: ['jpg', 'png'],
              );

              if (result != null) {
                setState(() {
                  imagePath = result.files
                      .elementAt(0)
                      .path!;
                });
              }
            },
            child: Container(
              width: size.width / 10,
              height: size.width / 10,
              clipBehavior: Clip.antiAlias,
              margin: const EdgeInsets.only(top: 16),
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(15),
                  color: CustomColor.darkBg,
                  boxShadow: [
                    BoxShadow(
                        color: Colors.black.withOpacity(.5),
                        blurRadius: 2,
                        spreadRadius: 1,
                        offset: const Offset(0, 1))
                  ]),
              child: imagePath.isNotEmpty ? Image.file(
                File(imagePath), fit: BoxFit.cover,) : const Icon(
                  Icons.photo_camera, color: CustomColor.gry),
            ),
          ),
          Container(
            width: size.width / 6,
            height: 50,
            margin: const EdgeInsets.only(top: 16),
            padding: const EdgeInsets.symmetric(horizontal: 8),
            alignment: Alignment.center,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white.withOpacity(.2) ,width: 0.5 ),
              borderRadius: BorderRadius.circular(25)
            ),
            child: TextField(
              controller: textEditingControllerName,
              maxLines: 1,
              decoration: const InputDecoration(
                border: InputBorder.none,
                hintText: 'playlist name',
              ),
            ),
          ),
          const Spacer(),
          Container(
            padding: const EdgeInsets.only(bottom: 16),
            alignment: Alignment.centerRight,
            child: FloatingActionButton(
              mini: true,
              backgroundColor: CustomColor.darkBg,
              elevation: 7,
              onPressed: () {
                String text = textEditingControllerName.text;
                if (text.isNotEmpty) {
                  Box box = Hive.box<PlayList>('playlists');
                  PlayList p = PlayList(text, imagePath, []);
                  box.add(p);
                  Navigator.of(context).pop();
                }
              },
              child: const Icon(Icons.save, color: CustomColor.gry),
            ),
          )
        ],
      ),
    );
  }
}


class PlayListSelectionDialog {

  show(BuildContext context, int id) {
    Box box = Hive.box<PlayList>('playlists');
    Size size = MediaQuery
        .of(context)
        .size;
    showDialog(context: context, builder: (context) {
      return Dialog(
          backgroundColor: Colors.transparent,
          alignment: Alignment.center,
          child: Container(
            width: size.width / 6,
            padding: const EdgeInsets.only(left: 16 , right: 16 , bottom: 16),
            decoration: BoxDecoration(
                color: CustomColor.darkBg, borderRadius: BorderRadius.circular(15)),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: double.infinity,
                  height: 50,
                  alignment: Alignment.centerRight,
                  child: InkWell(
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                      child: const Icon(Icons.clear, color: CustomColor.gry)),
                ),
                ListView.builder(
                  shrinkWrap: true,
                  itemCount: box.length ,
                  itemBuilder: (context, index) {
                    PlayList p = box.getAt(index);
                  return InkWell(
                    onTap: () {
                      if(!p.musicIds.contains(id)){
                        p.musicIds.add(id);
                        box.putAt(index, p);
                        Navigator.of(context).pop();
                      }
                    },
                    child: Container(
                      height: 40,
                      alignment: Alignment.centerLeft,
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: CustomColor.darkBg,
                        borderRadius: BorderRadius.circular(10),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(.5),
                            blurRadius: 2,
                            spreadRadius: 0,
                            offset: const Offset(0,1),
                          )
                        ]
                      ),
                      child: Text(p.name),
                    ),
                  );
                },)
              ],
            ),
          ),
      );
    },);
  }

}
