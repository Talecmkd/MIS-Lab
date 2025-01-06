import 'package:cloud_firestore/cloud_firestore.dart';

class Joke {
  final String id; // Changed to String to match Firestore document IDs
  final String type;
  final String setup;
  final String punchline;
  bool isFavourite;  // Use isFavourite consistently

  Joke({
    required this.id,
    required this.type,
    required this.setup,
    required this.punchline,
    this.isFavourite = false, // Default to false if not provided
  });

  // Factory method to create a Joke from Firestore data
  factory Joke.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Joke(
      id: doc.id, // Using Firestore's document ID
      type: data['type'] ?? '', // Provide default empty string if null
      setup: data['setup'] ?? '', // Provide default empty string if null
      punchline: data['punchline'] ?? '', // Provide default empty string if null
      // Set a default value of false if 'isFavourite' is null or missing
      isFavourite: data['isFavourite'] ?? false,
    );
  }

  // Factory constructor to create a Joke object from Firestore document data
  factory Joke.fromJson(Map<String, dynamic> json) {
    return Joke(
      id: json['id'].toString() ?? '',  // Assuming you store the joke ID in the Firestore document
      setup: json['setup'] ?? '',
      punchline: json['punchline'] ?? '',
      type: json['type'] ?? '',
      // Default to false if 'isFavourite' is null or missing
      isFavourite: json['isFavourite'] ?? false,
    );
  }

  // Method to convert a Joke into a Firestore-friendly format
  Map<String, dynamic> toFirestore() {
    return {
      'type': type,
      'setup': setup,
      'punchline': punchline,
      'isFavourite': isFavourite, // Save 'isFavourite' as a boolean
    };
  }

  // Method to convert a Joke into a JSON map for other uses, e.g., API calls
  Map<String, dynamic> toJson() {
    return {
      'id': id,  // Including the joke ID in case it's required
      'type': type,
      'setup': setup,
      'punchline': punchline,
      'isFavourite': isFavourite, // Consistency in using 'isFavourite'
    };
  }
}
