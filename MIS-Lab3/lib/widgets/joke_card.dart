import 'package:flutter/material.dart';
import '../models/joke.dart';

class JokeCard extends StatelessWidget {
  final Joke joke;
  final VoidCallback onTap;
  final VoidCallback onFavoriteToggle;

  const JokeCard({
    required this.joke,
    required this.onTap,
    required this.onFavoriteToggle,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        margin: const EdgeInsets.all(8.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(joke.setup, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              SizedBox(height: 8),
              Text(joke.punchline),
              SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: Icon(
                      joke.isFavourite ? Icons.favorite : Icons.favorite_border,
                      color: joke.isFavourite ? Colors.red : null,
                    ),
                    onPressed: onFavoriteToggle,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
