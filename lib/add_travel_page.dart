import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AddTravelPage extends StatefulWidget {
  const AddTravelPage({super.key});

  @override
  State<AddTravelPage> createState() => _AddTravelPageState();
}

class _AddTravelPageState extends State<AddTravelPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _firestore =
      FirebaseFirestore.instance.collection('Users');
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _dateStartSelected = TextEditingController();
  final TextEditingController _dateEndSelected = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  Future<void> _uploadData() async {
    await _firestore
        .doc(_auth.currentUser!.uid)
        .collection('travels')
        .doc(_placeController.text)
        .set({
      'place': _placeController.text,
      'dateStart': _dateStartSelected.text,
      'dateEnd': _dateEndSelected.text,
      'description': _descriptionController.text,
    });

    Navigator.pop(context);
  }

  Future<void> _selectStartDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateStartSelected.text = picked.toString().split(" ")[0];
      });
    }
  }

  Future<void> _selectEndDate() async {
    DateTime? picked = await showDatePicker(
      context: context,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100),
    );

    if (picked != null) {
      setState(() {
        _dateEndSelected.text = picked.toString().split(" ")[0];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 182, 197),
        iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 238, 224, 201)),
        title: const Text(
          'Add Travel',
          style: TextStyle(
            fontSize: 30,
            color: Color.fromARGB(255, 238, 224, 201),
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: DecoratedBox(
        decoration: const BoxDecoration(
          color: Color.fromARGB(255, 238, 224, 201),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: ListView(
            children: [
              TextField(
                controller: _placeController,
                decoration: const InputDecoration(
                  hintText: 'Place',
                  filled: true,
                  fillColor: Color.fromARGB(255, 150, 182, 197),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 10,
                      color: Color.fromARGB(255, 173, 196, 206),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dateStartSelected,
                decoration: const InputDecoration(
                  hintText: 'Start date',
                  prefixIcon: Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Color.fromARGB(255, 150, 182, 197),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 10,
                      color: Color.fromARGB(255, 173, 196, 206),
                    ),
                  ),
                ),
                onTap: () {
                  _selectStartDate();
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _dateEndSelected,
                decoration: const InputDecoration(
                  hintText: 'End date',
                  prefixIcon: Icon(Icons.calendar_today),
                  filled: true,
                  fillColor: Color.fromARGB(255, 150, 182, 197),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 10,
                      color: Color.fromARGB(255, 173, 196, 206),
                    ),
                  ),
                ),
                onTap: () {
                  _selectEndDate();
                },
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  hintText: 'Description',
                  filled: true,
                  fillColor: Color.fromARGB(255, 150, 182, 197),
                  border: OutlineInputBorder(
                    borderSide: BorderSide(
                      width: 10,
                      color: Color.fromARGB(255, 173, 196, 206),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 50),
              ElevatedButton(
                style: const ButtonStyle(
                  backgroundColor: WidgetStatePropertyAll<Color>(
                    Color.fromARGB(255, 150, 182, 197),
                  ),
                  foregroundColor: WidgetStatePropertyAll<Color>(
                    Color.fromARGB(255, 238, 224, 201),
                  ),
                ),
                onPressed: _uploadData,
                child: const Text(
                  'Add Travel',
                  style: TextStyle(
                    fontSize: 30,
                    color: Color.fromARGB(255, 238, 224, 201),
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
