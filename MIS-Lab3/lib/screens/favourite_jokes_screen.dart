import 'package:flutter/material.dart';
import '../models/joke.dart';
import '../services/favourites_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class FavoriteJokesScreen extends StatefulWidget {
  const FavoriteJokesScreen({Key? key}) : super(key: key);

  @override
  _FavoriteJokesScreenState createState() => _FavoriteJokesScreenState();
}

class _FavoriteJokesScreenState extends State<FavoriteJokesScreen> {
  List<Joke> favoriteJokes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFavoriteJokes();
  }

  // Fetch favorite jokes from Firestore
  void _loadFavoriteJokes() async {
    setState(() => _isLoading = true);
    final jokes = await FavouritesService.getFavoriteJokes();
    setState(() {
      favoriteJokes = jokes;
      _isLoading = false;
    });
  }

  // Unfavorite the joke
  void _unfavoriteJoke(Joke joke) async {
    await FavouritesService.toggleFavorite(joke);
    await FavouritesService.deleteFavorite(joke.id);
    _loadFavoriteJokes(); // Refresh the list of favorite jokes
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Favorite Jokes'),
        backgroundColor: Colors.deepPurple,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: _isLoading
            ? const Center(
          child: Text(
            'No favorite jokes yet!',
            style: TextStyle(
              fontSize: 18,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        )
            : ListView.builder(
          itemCount: favoriteJokes.length,
          itemBuilder: (context, index) {
            final joke = favoriteJokes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
              child: ListTile(
                title: Text(
                  joke.setup,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                subtitle: Text(
                  joke.punchline,
                  style: const TextStyle(
                    fontStyle: FontStyle.italic,
                  ),
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.favorite, color: Colors.red),
                  onPressed: () => _unfavoriteJoke(joke),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
