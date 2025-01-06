import 'package:flutter/material.dart';
import '../services/api_services.dart';
import '../models/joke.dart';
import '../services/favourites_service.dart';

class JokesByTypeScreen extends StatefulWidget {
  final String type;

  const JokesByTypeScreen({required this.type, Key? key}) : super(key: key);

  @override
  _JokesByTypeScreenState createState() => _JokesByTypeScreenState();
}

class _JokesByTypeScreenState extends State<JokesByTypeScreen> {
  late Future<List<Joke>> _jokesFuture;

  @override
  void initState() {
    super.initState();
    _jokesFuture = ApiService.fetchJokesByType(widget.type);
  }

  void _toggleFavorite(Joke joke) async{
    await FavouritesService.toggleFavorite(joke);
    setState(() {
      joke.isFavourite = !joke.isFavourite;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Jokes: ${widget.type}'),
        backgroundColor: Colors.deepPurple,
        elevation: 5,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blueAccent, Colors.purpleAccent],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: FutureBuilder<List<Joke>>(
          future: _jokesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Error: ${snapshot.error}',
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
              );
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(
                child: Text(
                  'No jokes available',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              );
            }

            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: snapshot.data!.length,
              itemBuilder: (context, index) {
                final joke = snapshot.data![index];
                return Card(
                  elevation: 4,
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(
                              Icons.sentiment_satisfied_alt,
                              color: Colors.purple,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                joke.setup,
                                style: const TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black87,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            IconButton(
                              icon: FutureBuilder<bool>(
                                future: FavouritesService.isFavourite(joke),
                                builder: (context, snapshot) {
                                  if (snapshot.connectionState == ConnectionState.waiting) {
                                    // You can show a loading indicator while waiting for the result
                                    return const CircularProgressIndicator();
                                  } else if (snapshot.hasError) {
                                    // Handle errors, you can show a default icon in case of an error
                                    return const Icon(Icons.favorite_border);
                                  } else if (snapshot.hasData) {
                                    bool isFavorite = snapshot.data ?? false;
                                    return Icon(
                                      isFavorite ? Icons.favorite : Icons.favorite_border,
                                      color: isFavorite ? Colors.red : null,
                                    );
                                  }
                                  // Default case, when there's no data
                                  return const Icon(Icons.favorite_border);
                                },
                              ),
                              onPressed: () => _toggleFavorite(joke),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text(
                          joke.punchline,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w400,
                            color: Colors.black54,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
