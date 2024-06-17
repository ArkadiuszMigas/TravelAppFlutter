import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class TravelDetails extends StatefulWidget {
  const TravelDetails({super.key, required this.travel});

  final String travel;

  @override
  State<TravelDetails> createState() => _TravelDetailsState();
}

class _TravelDetailsState extends State<TravelDetails> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CollectionReference _place =
      FirebaseFirestore.instance.collection('Users');
  List<Map<String, dynamic>> _notes = [];

  @override
  void initState() {
    super.initState();
    _loadNotes();
  }

  Future<void> _loadNotes() async {
    _notes = [];
    var details = await _place
        .doc(_auth.currentUser!.uid)
        .collection('travels')
        .doc(widget.travel)
        .collection('details')
        .doc('details')
        .get();

    if (details.exists && details.data()!['notes'] != null) {
      setState(() {
        _notes = List<Map<String, dynamic>>.from(details.data()!['notes']);
      });
    }
  }

  Future<void> _pickImage(int index) async {
    final pickedFile =
        await ImagePicker().pickImage(source: ImageSource.camera);
    if (pickedFile != null) {
      final File image = File(pickedFile.path);
      final String imageName = '${DateTime.now().millisecondsSinceEpoch}.png';
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('travel_images/${widget.travel}/$imageName');
      await storageRef.putFile(image);
      final imageUrl = await storageRef.getDownloadURL();

      setState(() {
        _notes[index]['imageUrl'] = imageUrl;
      });

      await _place
          .doc(_auth.currentUser!.uid)
          .collection('travels')
          .doc(widget.travel)
          .update({
        'notes': _notes,
      });
    }
  }

  Future<void> _saveNoteText(int index, String text) async {
    setState(() {
      _notes[index]['text'] = text;
    });

    await _place
        .doc(_auth.currentUser!.uid)
        .collection('travels')
        .doc(widget.travel)
        .update({
      'notes': _notes,
    });
  }

  Future<void> _addNote() async {
    String newText = '';
    File? newImage;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: Container(
            decoration:
                const BoxDecoration(color: Color.fromARGB(255, 150, 182, 197)),
            child: Wrap(
              children: [
                ListTile(
                  leading: const Icon(Icons.note_add),
                  title: TextField(
                    onChanged: (text) {
                      newText = text;
                    },
                    decoration: const InputDecoration(
                      hintText: 'Note',
                      filled: true,
                      fillColor: Color.fromARGB(255, 238, 224, 201),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(
                          width: 10,
                          color: Color.fromARGB(255, 173, 196, 206),
                        ),
                      ),
                    ),
                  ),
                ),
                ListTile(
                  leading: IconButton(
                    icon: const Icon(Icons.camera_alt),
                    onPressed: () async {
                      final pickedFile = await ImagePicker()
                          .pickImage(source: ImageSource.camera);
                      if (pickedFile != null) {
                        setState(() {
                          newImage = File(pickedFile.path);
                        });
                      }
                    },
                  ),
                  title: newImage == null
                      ? const Text('No image selected.')
                      : Image.file(newImage!),
                ),
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: ElevatedButton(
                    style: const ButtonStyle(
                      foregroundColor: WidgetStatePropertyAll<Color>(
                        Color.fromARGB(255, 150, 182, 197),
                      ),
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Color.fromARGB(255, 238, 224, 201),
                      ),
                    ),
                    onPressed: () async {
                      String imageUrl = '';
                      if (newImage != null) {
                        final String imageName =
                            '${DateTime.now().millisecondsSinceEpoch}.png';
                        final storageRef = FirebaseStorage.instance
                            .ref()
                            .child('travel_images/$imageName');
                        await storageRef.putFile(newImage!);
                        imageUrl = await storageRef.getDownloadURL();
                      }

                      setState(() {
                        _notes.add({'text': newText, 'imageUrl': imageUrl});
                      });

                      await _place
                          .doc(_auth.currentUser!.uid)
                          .collection('travels')
                          .doc(widget.travel)
                          .collection('details')
                          .doc('details')
                          .set({
                        'notes': _notes,
                      });

                      // ignore: use_build_context_synchronously
                      Navigator.pop(context);
                    },
                    child: const Text('Add Note'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Future<void> _deleteNote(place) async {
    _notes.remove(place);

    await _place
        .doc(_auth.currentUser!.uid)
        .collection('travels')
        .doc(widget.travel)
        .collection('details')
        .doc('details')
        .set({
      'notes': _notes,
    });
    _loadNotes();
  }

  @override
  Widget build(BuildContext context) {
    final details = _place
        .doc(_auth.currentUser!.uid)
        .collection('travels')
        .doc(widget.travel)
        .collection('details')
        .doc('details');
    details.get().then(
      (DocumentSnapshot doc) {
        final data = doc.data() as Map<String, dynamic>;
        _notes = data['notes'];
      },
      onError: (e) => ("Error getting document: $e"),
    );
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 182, 197),
         iconTheme:
            const IconThemeData(color: Color.fromARGB(255, 238, 224, 201)),
        title: Text(
          widget.travel,
          style: const TextStyle(
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
        child: StreamBuilder<DocumentSnapshot>(
          stream: _place
              .doc(_auth.currentUser!.uid)
              .collection('travels')
              .doc(widget.travel)
              .snapshots(),
          builder: (context, AsyncSnapshot<DocumentSnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            var travelData = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView(
                children: [
                  Text(
                    'Date: From ${travelData['dateStart']} to ${travelData['dateEnd']}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 150, 182, 197),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${travelData['description']}',
                    style: const TextStyle(
                      fontSize: 20,
                      color: Color.fromARGB(255, 150, 182, 197),
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 10),
                  ..._notes.map((note) {
                    int index = _notes.indexOf(note);
                    return Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Color.fromARGB(255, 212, 210, 193),
                          borderRadius: BorderRadius.all(
                            Radius.circular(30),
                          ),
                        ),
                        padding: const EdgeInsets.all(15),
                        child: Column(
                          children: [
                            Text(
                              note['text'],
                              style: const TextStyle(
                                fontSize: 20,
                                color: Color.fromARGB(255, 150, 182, 197),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 10),
                            note['imageUrl'] == ''
                                ? IconButton(
                                    icon: const Icon(Icons.camera_alt),
                                    onPressed: () => _pickImage(index),
                                  )
                                : Image.network(
                                    note['imageUrl'],
                                    scale: 3,
                                  ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: const ButtonStyle(
                                backgroundColor: WidgetStatePropertyAll<Color>(
                                  Color.fromARGB(255, 150, 182, 197),
                                ),
                                foregroundColor: WidgetStatePropertyAll<Color>(
                                  Color.fromARGB(255, 238, 224, 201),
                                ),
                              ),
                              onPressed: () => _deleteNote(note),
                              child: const Text(
                                'Delete note',
                                style: TextStyle(fontSize: 20),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                  ElevatedButton(
                    style: const ButtonStyle(
                      backgroundColor: WidgetStatePropertyAll<Color>(
                        Color.fromARGB(255, 150, 182, 197),
                      ),
                      foregroundColor: WidgetStatePropertyAll<Color>(
                        Color.fromARGB(255, 238, 224, 201),
                      ),
                    ),
                    onPressed: _addNote,
                    child: const Text(
                      'Add note and picture',
                      style: TextStyle(fontSize: 20),
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
