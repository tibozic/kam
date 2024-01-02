import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kam/features/groups/groupData.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/userData.dart';
import 'package:kam/global/common/toast.dart';

class GroupDetailsPage extends StatefulWidget {
  final groupData group;

  GroupDetailsPage({required this.group});

  @override
  _GroupDetailsPageState createState() => _GroupDetailsPageState();
}

class _GroupDetailsPageState extends State<GroupDetailsPage> {
  final FirebaseAuth auth = FirebaseAuth.instance;
  late User? user; // get user from database

  @override
  void initState() {
    super.initState();
    // Initialize the like status from the database
    user = auth.currentUser;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Podrobnosti skupine"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [GroupDataCard(widget.group), GroupMembersCard(widget.group)],
      ),
    );
  }
}

class GroupDataCard extends StatefulWidget {
  // const GroupDataCard({super.key});
  final groupData group;

  GroupDataCard(this.group);

  @override
  State<GroupDataCard> createState() => _GroupDataCardState();
}

class _GroupDataCardState extends State<GroupDataCard> {
  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Naziv skupine: ${widget.group.title}',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Text(
              'Kratica: ${widget.group.abbreviation}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Značka skupine: ${widget.group.tag}',
              style: TextStyle(fontSize: 18),
            ),
            SizedBox(height: 16),
            Text(
              'Opis: ${widget.group.description}',
              style: TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}

class GroupMembersCard extends StatefulWidget {
  // const GroupMembersCard({super.key});

  final groupData group;
  List<userData> groupMembers = [];

  GroupMembersCard(this.group);

  @override
  State<GroupMembersCard> createState() => _GroupMembersCardState();
}

class _GroupMembersCardState extends State<GroupMembersCard> {
  @override
  void initState() {
    super.initState();

    updateGroupMembersList();
  }

  void updateGroupMembersList() {
    fetchGroupMembers(widget.group).then((members) => {
          this.setState(() {
            widget.groupMembers = members;
          }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return Card(
        elevation: 8,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: this.widget.groupMembers.length,
              itemBuilder: (context, index) {
                var friend = this.widget.groupMembers[index];

                return ListTile(
                  leading: CircleAvatar(
                    radius: 24,
                    child: Text(
                      friend.name[0].toUpperCase() +
                          friend.surname[0].toUpperCase(),
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                  title: Text(friend.name + " " + friend.surname),
                );
              },
            )));
  }

  Future<List<userData>> fetchGroupMembers(groupData group) async {
    final groupMembersSnapshot = await FirebaseFirestore.instance
        .collection("groups")
        .doc(group.gid)
        .collection("members")
        .get();

    List<userData> groupMembersData = [];
    groupMembersSnapshot.docs.forEach((member) {
      groupMembersData.add(userData.fromJSON(member.data()));
    });

    return groupMembersData;
  }
}
