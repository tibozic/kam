import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/features/user_auth/firebase_auth_implementation/userData.dart';
import 'package:kam/global/common/toast.dart';

class EventDetailsPage extends StatefulWidget {
  final eventData event;

  EventDetailsPage({required this.event});

  @override
  _EventDetailsPageState createState() => _EventDetailsPageState();
}

class _EventDetailsPageState extends State<EventDetailsPage> {
  late bool isLiked;
  final FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User? user = _auth.currentUser;
  int numberOfTickets = 1;

  @override
  void initState() {
    super.initState();
    user = auth.currentUser;
    isLiked = false;
    fetchLikeStatus();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Podrobnosti o dogodku"),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          Card(
            elevation: 8,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16.0),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Image.asset(
                      'assets/kam_logo.png',
                      width: 250,
                      height: 250,
                    ),
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text(
                    widget.event.title,
                    style: TextStyle(
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    '${formatTimestamp(widget.event.datetime)}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  Text(
                    '${widget.event.address}',
                    style: TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                  SizedBox(height: 10),
                  Text(
                    '${widget.event.description}',
                    style: TextStyle(
                      fontSize: 18,
                    ),
                  ),
                  SizedBox(height: 16),
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Karta Regular ${widget.event.price} €',
                          style: TextStyle(fontSize: 18),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            _showBuyTicketDialog(context);
                          },
                          child: Text('Kupi karto'),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      setState(() {
                        isLiked = !isLiked;
                      });
                      updateLikeStatus(widget.event.eid, isLiked);
                    },
                    icon: Icon(
                      isLiked ? Icons.favorite : Icons.favorite_border,
                      color: isLiked
                          ? Theme.of(context).colorScheme.inversePrimary
                          : null,
                    ),
                    label: Text(isLiked ? 'Všečkano' : 'Všečkaj'),
                  ),
                  SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Povabi'),
                        ),
                      ),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () {},
                          child: Text('Deli'),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(
                    height: 20,
                  ),
                  Text(
                    'Udeleženci:',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  FriendsGoingList(this.widget.event.eid),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) {
      return 'N/A';
    }

    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMMd().add_jm().format(dateTime);

    return formattedDate;
  }

  Future<void> fetchLikeStatus() async {
    final docLiked = FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("liked");
    final query = docLiked.where("eid", isEqualTo: widget.event.eid);

    final querySnapshot = await query.get();
    setState(() {
      isLiked = querySnapshot.docs.isNotEmpty;
    });
  }

  Future<void> updateLikeStatus(String eventId, bool liked) async {
    if (liked) {
      final docLiked = FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("liked")
          .doc(eventId);

      Map<String, dynamic> dataJson = {
        'eid': eventId,
      };

      await docLiked.set(dataJson);

      final docLiked2 = FirebaseFirestore.instance.collection("liked").doc();

      Map<String, dynamic> dataJson2 = {
        'eid': eventId,
        'uid': user?.uid,
      };

      await docLiked2.set(dataJson2);
    } else {
      final docLiked = FirebaseFirestore.instance
          .collection("users")
          .doc(user?.uid)
          .collection("liked");
      final query = docLiked.where("eid", isEqualTo: eventId);
      query.get().then(
        (querySnapshot) async {
          for (var docSnapshot in querySnapshot.docs) {
            await docLiked.doc(docSnapshot.id).delete();
          }
        },
      );
      final docLiked2 = FirebaseFirestore.instance.collection("liked");
      final query2 = docLiked2
          .where("uid", isEqualTo: user?.uid)
          .where("eid", isEqualTo: eventId);
      query2.get().then(
        (querySnapshot2) async {
          for (var docSnapshot2 in querySnapshot2.docs) {
            await docLiked2.doc(docSnapshot2.id).delete();
          }
        },
      );
    }
  }

  void _showBuyTicketDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return TicketDialog(event: widget.event);
      },
    );
  }
}

class TicketDialog extends StatefulWidget {
  final eventData event;

  const TicketDialog({required this.event});

  @override
  _TicketDialogState createState() => _TicketDialogState();
}

class _TicketDialogState extends State<TicketDialog> {
  int numberOfTickets = 1;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  @override
  Widget build(BuildContext context) {
    // Calculate total price based on the number of tickets
    double totalPrice = widget.event.price * numberOfTickets;
    totalPrice = double.parse(totalPrice.toStringAsFixed(2));
    ;

    return AlertDialog(
      title: Text('Kupi karto'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Izberi število kart:'),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                icon: Icon(Icons.remove),
                onPressed: () {
                  if (numberOfTickets > 1) {
                    setState(() {
                      numberOfTickets--;
                    });
                  }
                },
              ),
              Text(
                '$numberOfTickets',
                style: TextStyle(fontSize: 18),
              ),
              IconButton(
                icon: Icon(Icons.add),
                onPressed: () {
                  setState(() {
                    numberOfTickets++;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 16),
          // Display total price
          Text(
            'Skupna cena: $totalPrice €',
            style: TextStyle(fontSize: 18),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
          },
          child: Text('Preklic'),
        ),
        TextButton(
          onPressed: () {
            final docEvent = FirebaseFirestore.instance.collection("events");
            final query = docEvent
                .where("eid", isEqualTo: widget.event.eid)
                .where("remainingTickets",
                    isGreaterThanOrEqualTo: numberOfTickets);

            query.get().then(
              (querySnapshot) async {
                if (querySnapshot.docs.isNotEmpty) {
                  final colTickets = FirebaseFirestore.instance
                      .collection("users")
                      .doc(user?.uid)
                      .collection("tickets");

                  for (int i = 0; i < numberOfTickets; i++) {
                    final docTicket = colTickets.doc();
                    Map<String, dynamic> dataJson = {
                      "tid": docTicket.id,
                      "eid": widget.event.eid,
                      "title": widget.event.title,
                      "datetime": widget.event.datetime,
                      "address": widget.event.address,
                    };
                    await docTicket.set(dataJson);

                    DocumentReference increment =
                        docEvent.doc(widget.event.eid);
                    await increment
                        .update({"remainingTickets": FieldValue.increment(-1)});
                  }

                  if (numberOfTickets == 1) {
                    showToast(
                        message:
                            "${numberOfTickets} kart kupljenih. This is where the fun begins!");
                  } else {
                    showToast(
                        message:
                            "${numberOfTickets} kart kupljenih. This is where the fun begins!");
                  }
                } else {
                  showToast(message: "Ni dovolj kart na voljo!");
                }
              },
            );

            Navigator.of(context).pop();
          },
          child: Text('Nakup'),
        ),
      ],
    );
  }
}

class FriendsGoingList extends StatefulWidget {
  // const FriendsGoingList({super.key});
  final String eid;

  FriendsGoingList(this.eid);

  @override
  State<FriendsGoingList> createState() => _FriendsGoingListState();
}

class _FriendsGoingListState extends State<FriendsGoingList> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late User? user = _auth.currentUser;

  List<userData> _friendsGoing = [];

  bool loading_friends = false;

  @override
  void initState() {
    super.initState();

    if (mounted) {
      setState(() {
        getFriendGoingToEvent(widget.eid).then((value) {
          if (mounted) {
            setState(() {
              this._friendsGoing = value;
            });
          }
        });
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return loading_friends
        ? CircularProgressIndicator(
            color: Colors.white,
          )
        : (_friendsGoing.isEmpty
            ? Center(
                child: Text(
                  "Noben prijatelj še ni zainteresiran.",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                ),
              )
            : ListView.builder(
                shrinkWrap: true,
                itemCount: this._friendsGoing.length,
                itemBuilder: (context, index) {
                  var friend = this._friendsGoing[index];

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
              ));
  }

  Future<List<userData>> getFriendGoingToEvent(String eid) async {
    setState(() {
      this.loading_friends = true;
    });

    final List<userData> friends =
        await userData.getFriendsFromUid(this.user?.uid as String);

    List<userData> friendsGoing = [];

    for (final friend in friends) {
      final friendEvents = await userData.getUserTickets(friend.uid);

      if (friendEvents.map((e) => e.eid).contains(eid)) {
        friendsGoing.add(friend);
      }
    }

    if (mounted) {
      setState(() {
        this._friendsGoing = friendsGoing;
        this.loading_friends = false;
      });
    }

    return Future.value(friendsGoing);
  }
}
