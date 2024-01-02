import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:kam/global/common/toast.dart';

class eventData {
  String eid;
  final String title;
  final String lowercaseTitle;
  final Timestamp? datetime;
  final String address;
  final String description;
  final int remainingTickets;
  final double price;

  eventData(
      {this.eid = "",
      required this.title,
      this.lowercaseTitle = "",
      required this.datetime,
      required this.address,
      required this.description,
      required this.remainingTickets,
      required this.price});

  Map<String, dynamic> toJson() => {
        "eid": eid,
        "title": title,
        "lowercaseTitle": lowercaseTitle,
        "datetime": datetime,
        "address": address,
        "description": description,
        "remainingTickets": remainingTickets,
        "price": price,
      };
  static eventData fromJSON(Map<String, dynamic> json) {
    return eventData(
      eid: json["eid"],
      title: json["title"],
      lowercaseTitle: json["lowercaseTitle"],
      datetime: json["datetime"],
      address: json["address"],
      description: json["description"],
      remainingTickets: json["remainingTickets"],
      price: json["price"],
    );
  }
}
