import 'package:flutter/material.dart';
import 'dart:math';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';
import 'favourite_jokes_screen.dart';
import 'jokes_by_type_screen.dart';
import 'random_joke_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Import Firestore

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<String>> jokeTypes;

  final List<String> emojis = ['😂', '🤣', '😆', '😅', '😄'];

  @override
  void initState() {
    super.initState();
    jokeTypes = ApiService.fetchJokeTypes();
    _fetchAndSaveJokeTypes();  // Fetch and save joke types in Firestore (optional)
    _fetchAndSaveJokesByType();// Fetch and save jokes by type to Firestore
    _fetchAndSaveRandomJoke();
  }

  // Function to fetch and save joke types to Firestore
  void _fetchAndSaveJokeTypes() async {
    try {
      final types = await ApiService.fetchJokeTypes();
      final jokeTypesCollection = FirebaseFirestore.instance.collection('jokeTypes');

      for (var type in types) {
        await jokeTypesCollection.doc(type).set({
          'type': type,
        });
      }
    } catch (e) {
      print("Error saving joke types to Firestore: $e");
    }
  }

  // Function to fetch and save jokes by type to Firestore
  void _fetchAndSaveJokesByType() async {
    try {
      final types = await ApiService.fetchJokeTypes();
      for (var type in types) {
        final jokes = await ApiService.fetchJokesByType(type);
        final jokesCollection = FirebaseFirestore.instance.collection('jokesByType').doc(type).collection('jokes');

        for (var joke in jokes) {
          // Check if the joke already exists in Firestore
          final jokeQuery = await jokesCollection
              .where('setup', isEqualTo: joke.setup)
              .where('punchline', isEqualTo: joke.punchline)
              .get();

          // If the joke doesn't exist, add it to Firestore
          if (jokeQuery.docs.isEmpty) {
            await jokesCollection.add({
              'type': type,
              'setup': joke.setup,
              'punchline': joke.punchline,
              'isFavourite': joke.isFavourite
            });
          }
        }
      }
    } catch (e) {
      print("Error saving jokes by type to Firestore: $e");
    }
  }

  // Function to fetch and save a random joke to Firestore
  void _fetchAndSaveRandomJoke() async {
    try {
      final randomJoke = await ApiService.fetchRandomJoke();
      final randomJokesCollection = FirebaseFirestore.instance.collection('randomJokes');

      final randomJokeQuery = await randomJokesCollection
          .where('setup', isEqualTo: randomJoke.setup)
          .where('punchline', isEqualTo: randomJoke.punchline)
          .get();

      if (randomJokeQuery.docs.isEmpty) {
        await randomJokesCollection.add({
          'setup': randomJoke.setup,
          'punchline': randomJoke.punchline,
        });
      }
    } catch (e) {
      print("Error saving random joke to Firestore: $e");
    }
  }
  List<Widget> _generateRandomEmojis() {
    final random = Random();
    return List.generate(10, (index) {
      final left = random.nextDouble() * MediaQuery.of(context).size.width;
      final top = random.nextDouble() * MediaQuery.of(context).size.height;
      final size = random.nextDouble() * 24 + 16;
      return Positioned(
        left: left,
        top: top,
        child: Text(
          emojis[random.nextInt(emojis.length)],
          style: TextStyle(fontSize: size),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Padding(
          padding: const EdgeInsets.only(bottom: 25.0),
          child: const Text('Joke Types'),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => RandomJokeScreen(
                      fetchAndSaveRandomJoke: _fetchAndSaveRandomJoke
                  )
                  ),
                );
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.purpleAccent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 6,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                padding: const EdgeInsets.symmetric(
                    vertical: 12.0, horizontal: 16.0),
                child: Row(
                  children: [
                    const Text(
                      'Get a random joke',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Icon(
                      Icons.sentiment_very_satisfied,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
            ),
          )
        ],
      ),
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.orangeAccent, Colors.yellowAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          ..._generateRandomEmojis(),
          Center(
            child: Padding(
              padding: const EdgeInsets.only(top: kToolbarHeight + 16),
              child: FutureBuilder<List<String>>(
                future: jokeTypes,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  } else if (snapshot.hasError) {
                    return Center(child: Text('Error: ${snapshot.error}'));
                  } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return const Center(child: Text('No joke types available'));
                  }
                  return Container(
                    height: MediaQuery.of(context).size.height * 0.8,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: snapshot.data!
                          .map((type) => Card(
                        color: Colors.white,
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: ListTile(
                          title: Text(
                            type.toUpperCase(),
                            style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold),
                          ),
                          trailing: const Icon(Icons.arrow_forward_ios),
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    JokesByTypeScreen(type: type),
                              ),
                            );
                          },
                        ),
                      ))
                          .toList(),
                    ),
                  );
                },
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => FavoriteJokesScreen(),
            ),
          );
        },
        child: Icon(Icons.favorite),
        backgroundColor: Colors.purpleAccent,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
