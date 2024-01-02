import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:intl/intl.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/edit_event_page.dart';
import 'package:kam/features/user_auth/presentation/pages/friends_page.dart';
import 'package:kam/features/user_auth/presentation/pages/groups_page.dart';
import 'package:kam/features/user_auth/presentation/pages/event_details.dart';
import 'package:kam/features/user_auth/presentation/pages/social_page.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:user_profile_avatar/user_profile_avatar.dart';
import 'package:kam/features/user_auth/presentation/pages/login_page.dart';
import 'package:kam/features/user_auth/presentation/pages/profile_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User? user = _auth.currentUser;
  late String? displayName = user?.displayName;

  @override
  Widget build(BuildContext context) {
    String firstName;
    if (displayName != null) {
      List<String> nameList = displayName!.split(" ");
      firstName = nameList[0];
    } else {
      firstName = "Anon";
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Row(
            children: [
              Text(
                "Živjo, $firstName",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              Spacer(),
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => ProfilePage()),
                  );
                },
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ProfilePicture(
                    name: displayName.toString(),
                    radius: 24,
                    fontsize: 18,
                  ),
                ),
              ),
            ],
          ),
          bottom: TabBar(tabs: [
            Tab(text: "Domov"),
            Tab(text: "Prijatelji"),
            Tab(text: "Všečkano"),
            Tab(text: "Karte")
          ]),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: TabBarView(children: [
          HomePageShown(),
          SocialPage(),
          LikedPage(),
          TicketsPage(),
        ]),
      ),
    );
  }
}

class HomePageShown extends StatefulWidget {
  const HomePageShown({super.key});

  @override
  State<HomePageShown> createState() => _HomePageShownState();
}

class _HomePageShownState extends State<HomePageShown> {
  late TextEditingController _searchController;
  late List<eventData> _events = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Išči po nazivu dogodka',
                    border: OutlineInputBorder(),
                  ),
                ),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  searchEvents(_searchController.text);
                },
                child: Text('Išči'),
              ),
              SizedBox(width: 8),
              ElevatedButton(
                onPressed: () {
                  // Clear search and load all events
                  _searchController.clear();
                  _loadEvents();
                },
                child: Text('Počisti'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _events.isEmpty
              ? Center(
                  child: Text(
                    "Ni dogodkov.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                )
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return buildEventCard(_events[index]);
                  },
                ),
        ),
        /*SizedBox(
          height: 30,
        ),
        GestureDetector(
          onTap: () {
            FirebaseAuth.instance.signOut();
            Navigator.pushNamed(context, "/login");
          },
          child: Container(
            height: 45,
            width: 100,
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Sign out",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
        ),*/
      ],
    );
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
            ],
          ),
        ),
      ),
    );
  }

  void _loadEvents() {
    readEvents().listen((events) {
      if (mounted) {
        setState(() {
          _events = events;
        });
      }
    });
  }

  Stream<List<eventData>> readEvents() {
    return FirebaseFirestore.instance
        .collection("events")
        .where("datetime", isGreaterThanOrEqualTo: Timestamp.now())
        .orderBy("datetime")
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map(
                (doc) => eventData.fromJSON(doc.data() as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print("Error parsing eventData: $e");
        return [];
      }
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMMd().add_jm().format(dateTime);

    return formattedDate;
  }

  void searchEvents(String title) {
    FirebaseFirestore.instance
        .collection("events")
        .where("lowercaseTitle", isEqualTo: title.toLowerCase())
        .snapshots()
        .listen((snapshot) {
      try {
        final events = snapshot.docs
            .map(
                (doc) => eventData.fromJSON(doc.data() as Map<String, dynamic>))
            .toList();
        setState(() {
          _events = events;
        });
      } catch (e) {
        print("Error parsing eventData: $e");
        setState(() {
          _events = [];
        });
      }
    });
  }
}

class LikedPage extends StatefulWidget {
  const LikedPage({Key? key}) : super(key: key);

  @override
  State<LikedPage> createState() => _LikedPageState();
}

class _LikedPageState extends State<LikedPage> {
  late List<eventData> _events = [];
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User? user;

  @override
  void initState() {
    super.initState();
    user = _auth.currentUser;
    _loadEvents();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Expanded(
          child: _events.isEmpty
              ? Center(
                  child: Text(
                    "Ni všečkanih dogodkov.",
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
                  ),
                )
              : ListView.builder(
                  itemCount: _events.length,
                  itemBuilder: (context, index) {
                    return buildEventCard(_events[index]);
                  },
                ),
        ),
        SizedBox(
          height: 30,
        ),
      ],
    );
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
              Text("${event.price} €"),
            ],
          ),
        ),
      ),
    );
  }

  void _loadEvents() async {
    final events = await readLikedEvents(user?.uid);
    setState(() {
      _events = events;
    });
  }

  Future<List<eventData>> readLikedEvents(String? userId) async {
    try {
      final likedIds = await getLikedEventIds(userId);
      final snapshot = await FirebaseFirestore.instance
          .collection("events")
          .where(FieldPath.documentId, whereIn: likedIds)
          .get();

      return snapshot.docs
          .map((doc) => eventData.fromJSON(doc.data() as Map<String, dynamic>))
          .toList();
    } catch (e) {
      print("Error reading liked events: $e");
      return [];
    }
  }

  Future<List<String>> getLikedEventIds(String? userId) async {
    try {
      final likedSnapshot = await FirebaseFirestore.instance
          .collection("users")
          .doc(userId)
          .collection("liked")
          .get();

      return likedSnapshot.docs.map((likedDoc) => likedDoc.id).toList();
    } catch (e) {
      print("Error getting liked event IDs: $e");
      return [];
    }
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMMd().add_jm().format(dateTime);

    return formattedDate;
  }
}

class TicketsPage extends StatefulWidget {
  const TicketsPage({Key? key}) : super(key: key);

  @override
  State<TicketsPage> createState() => _TicketsPageState();
}

class _TicketsPageState extends State<TicketsPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  late User? user = _auth.currentUser;
  late List<TicketData> _tickets = [];

  @override
  void initState() {
    super.initState();
    _loadTickets();
  }

  @override
  Widget build(BuildContext context) {
    return _tickets.isEmpty
        ? Center(
            child: Text(
              "Ni kart.",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 19),
            ),
          )
        : ListView.builder(
            itemCount: _tickets.length,
            itemBuilder: (context, index) {
              return buildTicketCard(_tickets[index]);
            },
          );
  }

  Widget buildTicketCard(TicketData ticket) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
      child: ListTile(
        contentPadding: EdgeInsets.all(0),
        title: Row(
          children: [
            SizedBox(
              width: 10,
            ),
            GestureDetector(
              child: Container(
                padding: EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Image.asset(
                  'assets/kam_logo.png',
                  width: 100,
                  height: 100,
                ),
              ),
              onTap: () => _showQrCodeDialog(context, ticket.title),
            ),
            SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("${ticket.title}"),
                  Text(
                    "${ticket.datetime != null ? formatTimestamp(ticket.datetime!) : 'N/A'}",
                  ),
                  Text("${ticket.address}"),
                ],
              ),
            ),
            Column(
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Povabi'),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text('Deli'),
                ),
                IconButton(
                  icon: Icon(Icons.download),
                  onPressed: () {},
                ),
              ],
            ),
            SizedBox(
              width: 5,
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _showQrCodeDialog(BuildContext context, String title) async {
    return showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.white,
          title: Text(
            title,
            style:
                TextStyle(color: Theme.of(context).colorScheme.inversePrimary),
          ),
          content: Container(
            width: 280,
            height: 280,
            child: QrImageView(
              data: 'Ta QR koda je namenjena za testno različico aplikacije',
              version: QrVersions.auto,
              size: 300,
              gapless: false,
              embeddedImage: AssetImage('assets/eventPlaceholder.png'),
              embeddedImageStyle: QrEmbeddedImageStyle(
                size: Size(80, 80),
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Zapri',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _loadTickets() {
    readTickets().listen((tickets) {
      if (mounted) {
        setState(() {
          _tickets = tickets;
        });
      }
    });
  }

  Stream<List<TicketData>> readTickets() {
    return FirebaseFirestore.instance
        .collection("users")
        .doc(user?.uid)
        .collection("tickets")
        .snapshots()
        .map((snapshot) {
      try {
        return snapshot.docs
            .map((doc) =>
                TicketData.fromJSON(doc.data() as Map<String, dynamic>))
            .toList();
      } catch (e) {
        print("Error parsing TicketData: $e");
        return [];
      }
    });
  }

  String formatTimestamp(Timestamp timestamp) {
    DateTime dateTime = timestamp.toDate();
    String formattedDate = DateFormat.yMMMMd().add_jm().format(dateTime);
    return formattedDate;
  }
}

class TicketData {
  final String tid;
  final String eid;
  final String title;
  final Timestamp datetime;
  final String address;

  TicketData({
    required this.tid,
    required this.eid,
    required this.title,
    required this.datetime,
    required this.address,
  });

  factory TicketData.fromJSON(Map<String, dynamic> json) {
    return TicketData(
      tid: json['tid'] ?? '',
      eid: json['eid'] ?? '',
      title: json['title'] ?? '',
      datetime: json['datetime'] ?? Timestamp.now(),
      address: json['address'] ?? '',
    );
  }
}
