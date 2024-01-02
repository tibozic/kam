import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/userData.dart';
import 'package:kam/global/common/toast.dart';

class FriendsPage extends StatefulWidget {
  @override
  _FriendsPageState createState() => _FriendsPageState();
}

class _FriendsPageState extends State<FriendsPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  TextEditingController _friendTagController = TextEditingController();

  bool isAddingFriend = false;
  List<userData> friends = [];

  @override
  void dispose() {
    _friendTagController.dispose();
    super.dispose();
  }

  void updateFriendList() {
    userData.getFriendsFromUid(this.user?.uid as String).then((friends) => {
          this.setState(() {
            this.friends = friends;
          }),
        });
  }

  @override
  void initState() {
    super.initState();
    updateFriendList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Prijatelji"),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              TextFormField(
                controller: _friendTagController,
                decoration: InputDecoration(
                  labelText: 'Značka prijatelja',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prosim vnesite veljavno značko';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _addFriend(this.user);
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
                  child: isAddingFriend
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Dodaj prijatelja',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 20),
              Expanded(child: FriendList(this.friends)),
            ],
          ),
        ),
      ),
    );
  }

  void _addFriend(User? user) async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isAddingFriend = true;
      });

      final friendTag = _friendTagController.text;

      final userWithMatchingTagSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .where("tag", isEqualTo: friendTag)
          .get();

      final userWithcMatchingTagDoc = userWithMatchingTagSnapshot.docs;
      if (userWithcMatchingTagDoc.length == 0) {
        // No user with such tag
        showToast(message: "Ni uporabnika s takšno značko");
      } else if (userWithcMatchingTagDoc.length != 1) {
        // ERROR: More than 1 user with the same tag
        showToast(message: "ERROR: več kot 1 uporabnik z isto značko");
      } else {
        final userWithMatchingTag =
            userWithMatchingTagSnapshot.docs.first.data();

        final friendData = userData.fromJSON(userWithMatchingTag);

        await FirebaseFirestore.instance
            .collection("users")
            .doc(user?.uid)
            .collection("friends")
            .doc(friendData.uid)
            .set(userWithMatchingTag);

        final currentUserData = await FirebaseFirestore.instance
            .collection("users")
            .doc(user?.uid)
            .get();

        await FirebaseFirestore.instance
            .collection("users")
            .doc(friendData.uid)
            .collection("friends")
            .doc(user?.uid)
            .set(currentUserData.data() as Map<String, dynamic>);

        showToast(message: "Prijatelj uspešno dodan");

        setState(() {
          isAddingFriend = false;
        });

        updateFriendList();
      }
    }
  }
}

class FriendList extends StatefulWidget {
  List<userData> friends = [];

  FriendList(this.friends);

  @override
  State<FriendList> createState() => _FriendListState();
}

class _FriendListState extends State<FriendList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  bool isRemovingFriend = false;

  void updateFriendList() {
    userData.getFriendsFromUid(this.user?.uid as String).then((friends) => {
          this.setState(() {
            widget.friends = friends;
          }),
        });
  }

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: this.widget.friends.length,
      itemBuilder: (context, index) {
        var friend = this.widget.friends[index];

        return Column(
          children: [
            Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: EdgeInsets.all(12),
              child: ListTile(
                title: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      CircleAvatar(
                        radius: 24,
                        child: Text(
                          friend.name[0].toUpperCase() +
                              friend.surname[0].toUpperCase(),
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          _removeFriend(this.user, friend.uid);
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
                          child: isRemovingFriend
                              ? CircularProgressIndicator(color: Colors.white)
                              : Text(
                                  'Odstrani prijatelja',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                        ),
                      )
                    ]),
                subtitle: Column(
                  children: [
                    SizedBox(height: 10),
                    Text(friend.name + " " + friend.surname,
                        style: TextStyle(fontSize: 16))
                  ],
                ),
              ),
            ),
            SizedBox(height: 20)
          ],
        );
      },
    );
  }

  void _removeFriend(User? user, String friendUid) async {
    isRemovingFriend = true;

    await FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("friends")
        .doc(friendUid)
        .delete();

    await FirebaseFirestore.instance
        .collection("users")
        .doc(friendUid)
        .collection("friends")
        .doc(user?.uid)
        .delete();

    isRemovingFriend = false;
    updateFriendList();
  }
}
