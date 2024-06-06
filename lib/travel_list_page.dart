import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:travel_app/add_travel_page.dart';
import 'package:travel_app/travel_details.dart';

class TravelListPage extends StatefulWidget {
  const TravelListPage({super.key});

  @override
  State<TravelListPage> createState() => _TravelListPageState();
}

class _TravelListPageState extends State<TravelListPage> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 150, 182, 197),
        title: const Text(
          'Your JOURNEYS',
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
        child: StreamBuilder(
          stream: _firestore
              .collection('Users')
              .doc(_auth.currentUser!.uid)
              .collection('travels')
              .snapshots(),
          builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
            if (!snapshot.hasData) {
              return const Center(child: CircularProgressIndicator());
            }
            final travels = snapshot.data!.docs;
            return ListView.builder(
              itemCount: travels.length,
              itemBuilder: (context, index) {
                final travel = travels[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TravelDetails(
                          travel: travel['place'],
                        ),
                      ),
                    );
                  },
                  child: Card(
                    color: const Color.fromARGB(255, 150, 182, 197),
                    child: ListTile(
                      title: Text(
                        travel['place'],
                        style: const TextStyle(
                          fontSize: 20,
                          color:  Color.fromARGB(255, 238, 224, 201),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        'From ${travel['dateStart']} to ${travel['dateEnd']}',
                        style: const TextStyle(
                          fontSize: 20,
                          color:  Color.fromARGB(255, 238, 224, 201),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color.fromARGB(255, 150, 182, 197),
        foregroundColor: const Color.fromARGB(255, 238, 224, 201),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const AddTravelPage()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
