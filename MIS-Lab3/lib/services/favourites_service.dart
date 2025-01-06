import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/joke.dart';

class FavouritesService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final CollectionReference _favoritesCollection =
  _firestore.collection('favorites');

  /// Fetch all favorite jokes from Firestore.
  static Future<List<Joke>> get favorites async {
    try {
      final snapshot = await _favoritesCollection.get();
      return snapshot.docs
          .map((doc) => Joke.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to load favorites: $e');
    }
  }
  static Future<List<Joke>> getFavoriteJokes() async {
    QuerySnapshot querySnapshot = await _firestore.collection('favorites')
        .where('isFavourite', isEqualTo: true)
        .get();

    return querySnapshot.docs
        .map((doc) => Joke.fromFirestore(doc))
        .toList();
  }
  /// Toggle the favorite status of a joke.
  static Future<void> toggleFavorite(Joke joke) async {
    await _firestore.collection('favorites').doc(joke.id).set({
      'isFavourite': !joke.isFavourite,
      'punchline': joke.punchline,
      'setup': joke.setup,
      'type': joke.type// Assuming you have a toMap method in your Joke model
    }, SetOptions(merge: true));
  }

  /// Check if a joke is marked as favorite in Firestore.
  static Future<bool> isFavourite(Joke joke) async {
    DocumentSnapshot doc = await _firestore.collection('favorites').doc(joke.id).get();
    return doc.exists && (doc.data() as Map<String, dynamic>)['isFavourite'] == true;
  }

  static Future<void> deleteFavorite(String jokeId) async {
    await _firestore.collection('favorites').doc(jokeId).delete();
  }

  /// Sync fetched jokes with Firestore to mark `isFavourite` field correctly.
  static Future<List<Joke>> syncFavorites(List<Joke> jokes) async {
    try {
      final favoriteSnapshot = await _favoritesCollection.get();
      final favoriteIds = favoriteSnapshot.docs.map((doc) => doc.id).toSet();

      for (final joke in jokes) {
        joke.isFavourite = favoriteIds.contains(joke.id);
      }

      return jokes;
    } catch (e) {
      throw Exception('Failed to sync favorites: $e');
    }
  }
}
