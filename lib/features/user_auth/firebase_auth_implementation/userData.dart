import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/global/common/toast.dart';

class userData {
  String uid;
  final String role;
  final String name;
  final String surname;
  final String tag;

  userData(
      {this.uid = "",
      required this.role,
      required this.name,
      required this.surname,
      required this.tag});

  Map<String, dynamic> toJson() =>
      {"uid": uid, "role": role, "name": name, "surname": surname, "tag": tag};

  static userData fromJSON(Map<String, dynamic> json) => userData(
      uid: json["uid"],
      role: json["role"],
      name: json["name"],
      surname: json["surname"],
      tag: json["tag"]);

  Future<List<userData>> getFriends() async {
    final friends = await FirebaseFirestore.instance
        .collection("users")
        .doc(this.uid)
        .collection("friends")
        .get();

    final friendsData = <userData>[];
    friends.docs.forEach((friend) {
      friendsData.add(userData.fromJSON(friend.data()));
    });

    return friendsData;
  }

  static Future<List<userData>> getFriendsFromUid(String uid) async {
    final friends = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("friends")
        .get();

    final friendsData = <userData>[];
    friends.docs.forEach((friend) {
      friendsData.add(userData.fromJSON(friend.data()));
    });

    return friendsData;
  }

  static Future<List<eventData>> getUserTickets(String uid) async {
    final userTicketsSnapshot = await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("tickets")
        .get();

    List<eventData> userTickets = [];

    for (final ticket in userTicketsSnapshot.docs) {
      final eventSnapshot = await FirebaseFirestore.instance
          .collection("events")
          .doc(ticket.get("eid"))
          .get();

      userTickets.add(
          eventData.fromJSON(eventSnapshot.data() as Map<String, dynamic>));

/*
      showToast(
          message: userTickets.last.title +
              " length: " +
              userTickets.length.toString());
              */
    }

    // showToast(message: "uid has " + userTickets.length.toString() + " tickets");

    return userTickets;
  }
}
