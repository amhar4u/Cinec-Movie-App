import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/movie_model.dart';

class MovieService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'movies';

  // Get all movies
  Stream<List<Movie>> getMovies() {
    return _firestore
        .collection(_collection)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList());
  }

  // Get a single movie by ID
  Future<Movie?> getMovieById(String id) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(id).get();
      if (doc.exists) {
        return Movie.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting movie: $e');
      return null;
    }
  }

  // Create a new movie
  Future<String?> createMovie(Movie movie) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(movie.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating movie: $e');
      return null;
    }
  }

  // Update an existing movie
  Future<bool> updateMovie(String id, Movie movie) async {
    try {
      await _firestore.collection(_collection).doc(id).update(movie.toFirestore());
      return true;
    } catch (e) {
      print('Error updating movie: $e');
      return false;
    }
  }

  // Delete a movie
  Future<bool> deleteMovie(String id) async {
    try {
      await _firestore.collection(_collection).doc(id).delete();
      return true;
    } catch (e) {
      print('Error deleting movie: $e');
      return false;
    }
  }

  // Search movies by title or genre
  Future<List<Movie>> searchMovies(String query) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('title', isGreaterThanOrEqualTo: query)
          .where('title', isLessThanOrEqualTo: query + '\uf8ff')
          .get();
      
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error searching movies: $e');
      return [];
    }
  }

  // Get movies by genre
  Future<List<Movie>> getMoviesByGenre(String genre) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('genre', isEqualTo: genre)
          .get();
      
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting movies by genre: $e');
      return [];
    }
  }
}
