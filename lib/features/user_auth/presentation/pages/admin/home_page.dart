import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_profile_picture/flutter_profile_picture.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/create_event_page.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/edit_event_page.dart';
import 'package:kam/features/user_auth/presentation/pages/admin/userList.dart';
import 'package:intl/intl.dart';
import 'package:kam/features/user_auth/presentation/pages/friends_page.dart';
import 'package:kam/features/user_auth/presentation/pages/groups_page.dart';
import 'package:kam/features/user_auth/presentation/pages/social_page.dart';
import 'package:user_profile_avatar/user_profile_avatar.dart';

class AdminHomePage extends StatefulWidget {
  const AdminHomePage({Key? key}) : super(key: key);

  @override
  State<AdminHomePage> createState() => _AdminHomePageState();
}

class _AdminHomePageState extends State<AdminHomePage> {
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
      firstName = "username";
    }

    return DefaultTabController(
      initialIndex: 0,
      length: 1,
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
                    MaterialPageRoute(builder: (context) => userList()),
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
          bottom: TabBar(tabs: [Tab(text: "Domov")]),
          backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        ),
        body: TabBarView(children: [
          HomePageShown(),
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
                    "Ni dogodkov, ki ustreza kriteriju.",
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
        SizedBox(
          height: 10,
        ),
        GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => CreateEventPage()),
            );
          },
          child: Container(
            padding: EdgeInsets.all(10),
            margin: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Center(
              child: Text(
                "Ustvari dogodek",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
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
                "Odjava",
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),
            ),
          ),
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
            builder: (context) => EditEventPage(event: event),
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
      setState(() {
        _events = events;
      });
    });
  }

  Stream<List<eventData>> readEvents() {
    return FirebaseFirestore.instance
        .collection("events")
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
