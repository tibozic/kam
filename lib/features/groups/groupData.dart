import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam/global/common/toast.dart';

class groupData {
  String gid;
  final String title;
  final String abbreviation;
  final String description;
  int memberCount = 0;
  final String tag;

  groupData({
    this.gid = "",
    required this.title,
    required this.abbreviation,
    required this.description,
    required this.tag,
  });

  Map<String, dynamic> toJson() => {
        "gid": gid,
        "title": title,
        "abbreviation": abbreviation,
        "description": description,
        "tag": tag
      };

  static groupData fromJSON(Map<String, dynamic> json) {
    return groupData(
      gid: json["gid"],
      title: json["title"],
      abbreviation: json["abbreviation"],
      description: json["description"],
      tag: json["tag"],
    );
  }

  static Future<List<groupData>> getGroupsFromUid(String uid) async {
    final groups = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("groups")
        .get();

    final groupsData = <groupData>[];
    groups.docs.forEach((group) async {
      groupsData.add(groupData.fromJSON(group.data()));
    });

    return groupsData;
  }
}
