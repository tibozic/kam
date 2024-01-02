import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:kam/features/event_creation/eventData.dart';
import 'package:kam/global/common/toast.dart';

class CreateEventPage extends StatefulWidget {
  @override
  _CreateEventPageState createState() => _CreateEventPageState();
}

class _CreateEventPageState extends State<CreateEventPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  TextEditingController _titleController = TextEditingController();
  DateTime? _selectedDateTime;
  TextEditingController _addressController = TextEditingController();
  TextEditingController _descriptionController = TextEditingController();
  TextEditingController _ticketsController = TextEditingController();
  TextEditingController _priceController = TextEditingController();

  bool isCreatingEvent = false;

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
        title: Text("Ustvari dogodek"),
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
                  _createEvent();
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
                  child: isCreatingEvent
                      ? CircularProgressIndicator(color: Colors.white)
                      : Text(
                          'Ustvari dogodek',
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
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );

    if (picked != null) {
      final TimeOfDay? pickedTime = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.now(),
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

  Future<void> _createEvent() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        isCreatingEvent = true;
      });

      try {
        final title = _titleController.text;
        final address = _addressController.text;
        final description = _descriptionController.text;
        final tickets = _ticketsController.text;
        final price = _priceController.text;

        final timestamp = _selectedDateTime != null
            ? Timestamp.fromDate(_selectedDateTime!)
            : Timestamp.now();

        final docEvent = FirebaseFirestore.instance.collection("events").doc();

        final eventDataForm = eventData(
          eid: docEvent.id,
          title: title,
          lowercaseTitle: title.toLowerCase(),
          datetime: timestamp,
          address: address,
          description: description,
          remainingTickets: int.parse(tickets),
          price: double.parse(price),
        );

        final json = eventDataForm.toJson();

        await docEvent.set(json);

        showToast(message: "Dogodek uspešno ustvarjen");

        Navigator.pop(context);

        return;
      } catch (e, stackTrace) {
        print("Error creating event: $e");
        print("Stack trace: $stackTrace");
        showToast(message: "Error creating event");
      } finally {
        setState(() {
          isCreatingEvent = false;
        });
      }
    }
  }
}
