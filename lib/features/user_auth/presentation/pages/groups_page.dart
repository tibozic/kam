import 'dart:convert';
import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/userData.dart';
import 'package:kam/features/groups/groupData.dart';
import 'package:kam/features/user_auth/presentation/pages/group_details_page.dart';
import 'package:kam/global/common/toast.dart';

class GroupsPage extends StatefulWidget {
  @override
  _GroupsPageState createState() => _GroupsPageState();
}

class _GroupsPageState extends State<GroupsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  TextEditingController _groupTagController = TextEditingController();

  bool isJoiningGroup = false;
  List<groupData> groups = [];

  @override
  void dispose() {
    _groupTagController.dispose();
    super.dispose();
  }

  void updateGroupList() {
    groupData.getGroupsFromUid(this.user?.uid as String).then((groups) => {
          this.setState(() {
            this.groups = groups;
          }),
        });
  }

  @override
  void initState() {
    super.initState();
    updateGroupList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Skupine"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _groupTagController,
                  decoration: InputDecoration(
                    labelText: 'Značka skupine',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite veljavno značko skupine';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _joinGroup(this.user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: isJoiningGroup
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Pridruži se skupini',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
          CreateGroup(),
          Expanded(child: GroupList(this.groups))
        ]),
      ),
    );
  }

  void _joinGroup(User? user) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isJoiningGroup = true;
      });

      final groupTag = _groupTagController.text;

      final groupWithMatchingTagSnapshot = await FirebaseFirestore.instance
          .collection("groups")
          .where("tag", isEqualTo: groupTag)
          .get();

      final groupWithMatchingTagDoc = groupWithMatchingTagSnapshot.docs;
      if (groupWithMatchingTagDoc.isEmpty) {
        // No user with such tag
        showToast(message: "Ni skupine s takšno značko");
      } else if (groupWithMatchingTagDoc.length != 1) {
        // ERROR: More than 1 user with the same tag
        showToast(message: "ERROR: Več kot 1 skuino z isto značko");
      } else {
        final groupWithMatchingTag =
            groupWithMatchingTagSnapshot.docs.first.data();

        final groupsData = groupData.fromJSON(groupWithMatchingTag);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user?.uid)
            .collection("groups")
            .doc(groupsData.gid)
            .set(groupWithMatchingTag);

        final currentUserData = await FirebaseFirestore.instance
            .collection("users")
            .doc(user?.uid)
            .get();

        await FirebaseFirestore.instance
            .collection("groups")
            .doc(groupsData.gid)
            .collection("members")
            .doc(user?.uid)
            .set(currentUserData.data() as Map<String, dynamic>);

        showToast(message: "Uspešno pridružen skupini");

        setState(() {
          isJoiningGroup = false;
        });

        updateGroupList();
      }
    }
  }
}

class GroupList extends StatefulWidget {
  List<groupData> groups = [];

  GroupList(this.groups);

  @override
  State<GroupList> createState() => _GroupListState();
}

class _GroupListState extends State<GroupList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  bool isLeavingGroup = false;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.widget.groups.length,
      itemBuilder: (context, index) {
        var group = this.widget.groups[index];

        return Column(
          children: [
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => GroupDetailsPage(group: group),
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: EdgeInsets.all(12),
                child: ListTile(
                  title: Row(
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(
                          group.abbreviation.toUpperCase(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _leaveGroup(this.user, group.gid);
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor:
                              Theme.of(context).colorScheme.primary,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: isLeavingGroup
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Zapusti skupino',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )
                    ],
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  ),
                  subtitle: Column(
                    children: [
                      SizedBox(height: 10),
                      Text(
                        group.title,
                        style: TextStyle(fontSize: 16),
                      )
                    ],
                  ),
                ),
              ),
            ),
            SizedBox(height: 20)
          ],
        );
      },
    );
  }

  void updateGroupList() {
    groupData.getGroupsFromUid(this.user?.uid as String).then((groups) => {
          this.setState(() {
            this.widget.groups = groups;
          }),
        });
  }

  void _leaveGroup(User? user, String gid) async {
    setState(() {
      isLeavingGroup = true;
    });

    await FirebaseFirestore.instance
        .collection("groups")
        .doc(gid)
        .collection("members")
        .doc(user?.uid)
        .delete();
    await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("groups")
        .doc(gid)
        .delete();

    setState(() {
      isLeavingGroup = false;
    });

    updateGroupList();
  }
}

class CreateGroup extends StatefulWidget {
  const CreateGroup({super.key});

  @override
  State<CreateGroup> createState() => _CreateGroupState();
}

class _CreateGroupState extends State<CreateGroup> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  final GlobalKey<FormState> _createGroupFormKey = GlobalKey<FormState>();

  TextEditingController _groupTitleController = TextEditingController();
  TextEditingController _groupAbbreviationController = TextEditingController();
  TextEditingController _groupDescriptionController = TextEditingController();

  bool isCreatingGroup = false;

  @override
  void dispose() {
    _groupAbbreviationController.dispose();
    _groupDescriptionController.dispose();
    _groupTitleController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      ExpansionTile(
        title: Text("Ustvari skupino"),
        children: [
          Form(
            key: _createGroupFormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                TextFormField(
                  controller: _groupTitleController,
                  decoration: InputDecoration(
                    labelText: 'Naziv skupine',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite veljaven naziv skupine';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _groupAbbreviationController,
                  decoration: InputDecoration(
                    labelText: 'Kratica',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite veljavno kratico skupine';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                TextFormField(
                  controller: _groupDescriptionController,
                  decoration: InputDecoration(
                    labelText: 'Opis',
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Prosim vnesite veljaven opis skupine';
                    }
                    return null;
                  },
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    _createGroup(this.user);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    elevation: 3,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    child: isCreatingGroup
                        ? CircularProgressIndicator(color: Colors.white)
                        : Text(
                            'Ustvari skupino',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),
                SizedBox(height: 16)
              ],
            ),
          ),
        ],
      )
    ]);
  }

  void _createGroup(User? user) async {
    if (_createGroupFormKey.currentState!.validate()) {
      setState(() {
        isCreatingGroup = true;
      });

      final groupTitle = _groupTitleController.text;
      final groupAbbreviation = _groupAbbreviationController.text;
      final groupDescription = _groupDescriptionController.text;

      final groupDoc =
          await FirebaseFirestore.instance.collection("groups").doc();

      final groupId = groupDoc.id;

      int radndomInt;
      String tag;

      radndomInt = Random().nextInt(100000) + 10000;
      tag = groupAbbreviation + "#" + radndomInt.toString();

      final groupsCollection = FirebaseFirestore.instance.collection("groups");

      final query = groupsCollection.where("tag", isEqualTo: tag);

      final querySnapshot = await query.get();

      final groupsData = groupData(
          gid: groupId,
          title: groupTitle,
          abbreviation: groupAbbreviation,
          description: groupDescription,
          tag: tag);

      final json = groupsData.toJson();

      await groupDoc.set(json);

      final currentUserData = await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .get();

      await FirebaseFirestore.instance
          .collection("groups")
          .doc(groupId)
          .collection("members")
          .doc(user?.uid)
          .set(currentUserData.data() as Map<String, dynamic>);

      await FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("groups")
          .doc(groupId)
          .set(json);

      showToast(message: "Skupina uspešno ustvarjena");

      setState(() {
        isCreatingGroup = false;
      });

      // _GroupsPageState.updateGroupList();
    }
  }
}
