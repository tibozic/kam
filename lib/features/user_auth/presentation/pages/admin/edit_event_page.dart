import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/global/common/toast.dart';

class EditEventPage extends StatefulWidget {
  final eventData event;

  EditEventPage({required this.event});

  @override
  _EditEventPageState createState() => _EditEventPageState();
}

class _EditEventPageState extends State<EditEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late TextEditingController _titleController;
  DateTime? _selectedDateTime;
  late TextEditingController _addressController;
  late TextEditingController _descriptionController;
  late TextEditingController _ticketsController;
  late TextEditingController _priceController;

  bool isUpdatingEvent = false;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.event.title);
    _selectedDateTime = widget.event.datetime?.toDate();
    _addressController = TextEditingController(text: widget.event.address);
    _descriptionController =
        TextEditingController(text: widget.event.description);
    _ticketsController =
        TextEditingController(text: widget.event.remainingTickets.toString());
    _priceController =
        TextEditingController(text: widget.event.price.toString());
  }

  @override
  void dispose() {
    _titleController.dispose();
    _addressController.dispose();
    _descriptionController.dispose();
    _ticketsController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Uredi dogodek"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: InputDecoration(
                  labelText: 'Naziv dogodka',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prosim vnesite naziv dogodka';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectDateTime(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Theme.of(context).colorScheme.secondary,
                  elevation: 3,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    _selectedDateTime == null
                        ? 'Izberite datum in čas'
                        : 'Datum in čas: ${_selectedDateTime!.toLocal()}',
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.onPrimary,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(
                  labelText: 'Naslov',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prosim vnesite naslov';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _descriptionController,
                decoration: InputDecoration(
                  labelText: 'Opis',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prosim vnesite opis';
                  }
                  return null;
                },
              ),
              SizedBox(
                height: 16,
              ),
              TextFormField(
                controller: _priceController,
                decoration: InputDecoration(
                  labelText: 'Cena',
                  border: OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          double currentPrice =
                              double.tryParse(_priceController.text) ?? 0;
                          if (currentPrice > 0) {
                            setState(() {
                              _priceController.text =
                                  (currentPrice - 1).toString();
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          double currentPrice =
                              double.tryParse(_priceController.text) ?? 0;
                          setState(() {
                            _priceController.text =
                                (currentPrice + 1).toString();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prosim vnesite ceno vstopnice';
                  }
                  if (double.tryParse(value) == null) {
                    return 'Prosim vnesite veljavno število';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              TextFormField(
                controller: _ticketsController,
                decoration: InputDecoration(
                  labelText: 'Število vstopnic',
                  border: OutlineInputBorder(),
                  suffixIcon: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove),
                        onPressed: () {
                          int currentTickets =
                              int.tryParse(_ticketsController.text) ?? 0;
                          if (currentTickets > 0) {
                            setState(() {
                              _ticketsController.text =
                                  (currentTickets - 1).toString();
                            });
                          }
                        },
                      ),
                      IconButton(
                        icon: Icon(Icons.add),
                        onPressed: () {
                          int currentTickets =
                              int.tryParse(_ticketsController.text) ?? 0;
                          setState(() {
                            _ticketsController.text =
                                (currentTickets + 1).toString();
                          });
                        },
                      ),
                    ],
                  ),
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Prosim vnesite število vstopnic';
                  }
                  if (int.tryParse(value) == null) {
                    return 'Prosim vnesite veljavno število';
                  }
                  return null;
                },
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  _updateEvent();
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
                  child: isUpdatingEvent
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Posodobi dogodek',
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
      ),
    );
  }

  Future<void> _selectDateTime(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime:
            TimeOfDay.fromDateTime(_selectedDateTime ?? DateTime.now()),
      );

      if (pickedTime != null) {
        setState(() {
          _selectedDateTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            pickedTime.hour,
            pickedTime.minute,
          );
        });
      }
    }
  }

  void _updateEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isUpdatingEvent = true;
      });

      final title = _titleController.text;
      final address = _addressController.text;
      final description = _descriptionController.text;
      final tickets = _ticketsController.text;
      final price = _priceController.text;

      final timestamp = _selectedDateTime != null
          ? Timestamp.fromDate(_selectedDateTime!)
          : Timestamp.now();

      final docEvent =
          FirebaseFirestore.instance.collection("events").doc(widget.event.eid);

      final eventDataForm = eventData(
        eid: widget.event.eid,
        title: title,
        lowercaseTitle: title.toLowerCase(),
        datetime: timestamp,
        address: address,
        description: description,
        remainingTickets: int.parse(tickets),
        price: double.parse(price),
      );

      final json = eventDataForm.toJson();

      await docEvent.update(json);

      showToast(message: "Dogodek uspešno posodobljen");

      Navigator.pop(context);

      setState(() {
        isUpdatingEvent = false;
      });
    }
  }
}
