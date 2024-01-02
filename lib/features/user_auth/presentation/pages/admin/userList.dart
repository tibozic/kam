import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/userData.dart';

class userList extends StatefulWidget {
  const userList({super.key});

  @override
  State<userList> createState() => _userListState();
}

class _userListState extends State<userList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("seznam uporabnikov(for admin eyes only)"),
      ),
      body: StreamBuilder(
        stream: readUsers(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            print("Error: ${snapshot.error}");
            return Text("Something went wrong!!");
          } else if (snapshot.hasData) {
            final users = snapshot.data!;
            return ListView(
              children: users.map(buildUser).toList(),
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Widget buildUser(userData user) => ListTile(
        leading: CircleAvatar(
          radius: 31,
          child: Text(
            user.name.isNotEmpty && user.surname.isNotEmpty
                ? user.name[0] + user.surname[0]
                : "?",
            style: TextStyle(fontSize: 21),
          ),
        ),
        title: Text(user.name + " " + user.surname),
        subtitle: Text(user.uid ?? "No UID"), // Handle potential null value
      );

  Stream<List<userData>> readUsers() => FirebaseFirestore.instance
      .collection("users")
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => userData.fromJSON(doc.data())).toList());
}
