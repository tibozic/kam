import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/userData.dart';
import 'package:kam/features/user_auth/presentation/pages/event_details.dart';
import 'package:kam/global/common/toast.dart';

class FriendInterestsPage extends StatefulWidget {
  const FriendInterestsPage({super.key});

  @override
  State<FriendInterestsPage> createState() => _FriendInterestsPageState();
}

class _FriendInterestsPageState extends State<FriendInterestsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  late List<eventData> _events = [];

  Map<String, List<String>> friendInterests = {};

  Map<String, eventData> eventMap = {};
  Map<String, userData> friendMap = {};

  bool loadingEvents = false;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      getFriendInterests().then((value) {
        if (mounted) {
          setState(() {
            this.friendInterests = value;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
        child: Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        loadingEvents
            ? CircularProgressIndicator(color: Colors.white)
            : (Expanded(
                child: _events.isEmpty
                    ? Center(
                        child: Text(
                          "Ni dogodkov.",
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 19),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _events.length,
                        itemBuilder: (context, index) {
                          return buildEventCard(_events[index]);
                        },
                      ),
              )),
        SizedBox(
          height: 30,
        ),
      ],
    ));
  }

  Widget buildEventCard(eventData event) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EventDetailsPage(event: event),
          ),
        );
      },
      child: Card(
        elevation: 3,
        margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ListTile(
          title: Container(
            padding: EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Image.asset(
              'assets/kam_logo.png',
              width: 150,
              height: 150,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 5,
              ),
              Text(
                "${event.title}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(
                height: 5,
              ),
              Text(
                "${event.datetime != null ? formatTimestamp(event.datetime!) : 'N/A'}",
              ),
              Text("${event.address}"),
              SizedBox(
                height: 5,
              ),
              //Text("Remaining Tickets: ${event.remainingTickets}"),
              Text("${event.price} €"),
              Text(
                  "${(this.friendInterests[event.eid]?.length ?? 0).toString()} povezanih ljudi gre na dogodek")
            ],
          ),
        ),
      ),
    );
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMMd().add_jm().format(dateTime);

    return formattedDate;
  }

  Future<Map<String, List<String>>> getFriendInterests() async {
    setState(() {
      this.loadingEvents = true;
    });

    Map<String, List<String>> friendInterests = {};

    final List<userData> friends =
        await userData.getFriendsFromUid(this.user?.uid as String);

    List<eventData> events = [];

    for (final friend in friends) {
      final friendEvents = await userData.getUserTickets(friend.uid);

      for (final event in friendEvents) {
        if (!(events.map((e) => e.eid).contains(event.eid))) {
          events.add(event);
        }
        if (friendInterests.containsKey(event.eid)) {
          assert(friendInterests[event.eid] != null);
          if (!friendInterests[event.eid]!.contains(friend.uid)) {
            friendInterests[event.eid]?.add(friend.uid);
          }
        } else {
          friendInterests[event.eid] = [friend.uid];
        }
      }
    }

    if (mounted) {
      setState(() {
        this._events = events;
        this.loadingEvents = false;
      });
    }

    return Future.value(friendInterests);
  }
}
