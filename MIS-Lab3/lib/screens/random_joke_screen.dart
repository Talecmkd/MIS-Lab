import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/joke.dart';
import '../services/favourites_service.dart';
import 'home_screen.dart';

class RandomJokeScreen extends StatefulWidget {
  final Function fetchAndSaveRandomJoke;
  RandomJokeScreen({required this.fetchAndSaveRandomJoke});
  @override
  _RandomJokeScreenState createState() => _RandomJokeScreenState();
}

class _RandomJokeScreenState extends State<RandomJokeScreen> {
  late Future<Joke> _jokeFuture;

  @override
  void initState() {
    super.initState();
    _jokeFuture = _fetchRandomJoke();
  }

  Future<Joke> _fetchRandomJoke() async {
    final querySnapshot = await FirebaseFirestore.instance
        .collection('randomJokes')
        .get();

    final randomIndex = (querySnapshot.docs.isNotEmpty)
        ? (querySnapshot.docs.length * (DateTime.now().millisecondsSinceEpoch % 1000) / 1000).toInt()
        : 0;

    final randomDoc = querySnapshot.docs[randomIndex];
    return Joke.fromFirestore(randomDoc);
  }

  void _getAnotherJoke() {
    setState(() {
      _jokeFuture = _fetchRandomJoke();
    });
    widget.fetchAndSaveRandomJoke();
  }

  Future<void> _toggleFavorite(Joke joke) async {
    await FavouritesService.toggleFavorite(joke);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Random Joke'),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<Joke>(
          future: _jokeFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}'));
            } else if (!snapshot.hasData) {
              return const Center(child: Text('No joke available'));
            }
            final joke = snapshot.data!;
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 16.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.sentiment_satisfied_alt, color: Colors.purple),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                joke.setup,
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                            FutureBuilder<bool>(
                              future: FavouritesService.isFavourite(joke),
                              builder: (context, favSnapshot) {
                                if (favSnapshot.connectionState == ConnectionState.waiting) {
                                  return const CircularProgressIndicator();
                                } else if (favSnapshot.hasError) {
                                  return Icon(Icons.error);
                                } else {
                                  bool isFavourite = favSnapshot.data ?? false;
                                  return IconButton(
                                    icon: Icon(
                                      isFavourite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavourite ? Colors.red : null,
                                    ),
                                    onPressed: () => _toggleFavorite(joke),
                                  );
                                }
                              },
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        Text(
                          joke.punchline,
                          style: const TextStyle(
                            fontSize: 18,
                            color: Colors.black54,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: _getAnotherJoke,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.purpleAccent,
                            padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          child: const Text(
                            'Another One',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
