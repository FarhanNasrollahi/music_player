
import 'package:hive/hive.dart';

part 'playlist.g.dart';

@HiveType(typeId: 1)
class PlayList {

  @HiveField(0)
  String name;
  @HiveField(1)
  String image;
  @HiveField(2)
  List<int> musicIds = [];

  PlayList(this.name, this.image, this.musicIds);

}