import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:http/http.dart' as http;

import '../models/joke.dart';

// Class to handle API calls
class ApiService {
  // Fetch joke types
  static Future<List<String>> fetchJokeTypes() async {
    try {
      // Fetch joke types from the API
      final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/types'));

      if (response.statusCode == 200) {
        // Parse the JSON response and return it as a List of Strings
        final List<dynamic> jokeTypesJson = jsonDecode(response.body);
        return jokeTypesJson.map((e) => e.toString()).toList(); // Ensure joke types are strings
      } else {
        throw Exception('Failed to load joke types');
      }
    } catch (e) {
      throw Exception('Error fetching joke types: $e');
    }
  }

  // Fetch jokes of a specific type
  static Future<List<Joke>> fetchJokesByType(String type) async {
    try {
      // Fetch jokes of the specified type from the API
      final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/jokes/$type/ten'));

      if (response.statusCode == 200) {
        // Parse the JSON response and return a List of Joke objects
        final List<dynamic> jokesJson = jsonDecode(response.body);
        final jokesList = jokesJson.map((e) => Joke.fromJson(e)).toList();

        // Save each joke to Firestore after checking for duplicates
        final jokesCollection = FirebaseFirestore.instance.collection('jokesByType').doc(type).collection('jokes');

        for (var joke in jokesList) {
          final jokeQuery = await jokesCollection
              .where('setup', isEqualTo: joke.setup)
              .where('punchline', isEqualTo: joke.punchline)
              .get();

          if (jokeQuery.docs.isEmpty) {
            // If the joke is not already in Firestore, save it
            await jokesCollection.add({
              'type': type,
              'setup': joke.setup,
              'punchline': joke.punchline,
              'isFavourite': joke.isFavourite
            });
          }
        }
        return jokesList;
      } else {
        throw Exception('Failed to load jokes for type: $type');
      }
    } catch (e) {
      throw Exception('Error fetching jokes: $e');
    }
  }

  // Fetch a random joke
  static Future<Joke> fetchRandomJoke() async {
    try {
      // Fetch a random joke from the API
      final response = await http.get(Uri.parse('https://official-joke-api.appspot.com/random_joke'));

      if (response.statusCode == 200) {
        // Parse the JSON response and return it as a Joke object
        final dynamic jokeJson = jsonDecode(response.body);
        return Joke.fromJson(jokeJson); // Ensure the joke is converted to a Joke object
      } else {
        throw Exception('Failed to load random joke');
      }
    } catch (e) {
      throw Exception('Error fetching random joke: $e');
    }
  }
}
