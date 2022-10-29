import 'package:flutter/services.dart';
import 'package:hive/hive.dart';
part 'music.g.dart';

@HiveType(typeId: 0)
class Music {

  @HiveField(0)
  String name;
  @HiveField(1)
  List<String> artistNames;
  @HiveField(2)
  String albumName;
  @HiveField(3)
  int year;
  @HiveField(4)
  int duration;
  @HiveField(5)
  List<int> cover;
  @HiveField(6)
  String path;

  Music(this.name, this.artistNames, this.albumName, this.year, this.duration,
      this.cover,this.path);

}