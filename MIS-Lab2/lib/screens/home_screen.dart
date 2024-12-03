import 'package:flutter/material.dart';
import 'dart:math';
import '../services/api_services.dart';
import '../widgets/joke_card.dart';
import 'jokes_by_type_screen.dart';
import 'random_joke_screen.dart';

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
                  MaterialPageRoute(builder: (context) => RandomJokeScreen()),
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
          // Gradient Background
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
    );
  }
}
