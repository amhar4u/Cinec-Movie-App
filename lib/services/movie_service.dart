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

  // Get available time slots for a specific date
  Future<List<String>> getAvailableTimeSlots(String date, {String? excludeMovieId}) async {
    try {
      // All possible time slots
      final List<String> allTimeSlots = [
        '9:00 AM',
        '12:00 PM',
        '3:00 PM',
        '6:00 PM',
        '9:00 PM',
      ];

      // Get all movies for the specific date
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('releaseDate', isEqualTo: date)
          .where('isActive', isEqualTo: true)
          .get();

      // Get all booked time slots for this date
      Set<String> bookedTimeSlots = {};
      for (var doc in snapshot.docs) {
        // Skip the current movie if we're editing (excludeMovieId)
        if (excludeMovieId != null && doc.id == excludeMovieId) {
          continue;
        }
        
        final movie = Movie.fromFirestore(doc);
        bookedTimeSlots.addAll(movie.showtimes);
      }

      // Return only available time slots
      return allTimeSlots.where((slot) => !bookedTimeSlots.contains(slot)).toList();
    } catch (e) {
      print('Error getting available time slots: $e');
      return [
        '9:00 AM',
        '12:00 PM',
        '3:00 PM',
        '6:00 PM',
        '9:00 PM',
      ]; // Return all slots as fallback
    }
  }

  // Get movies by release date
  Future<List<Movie>> getMoviesByDate(String date) async {
    try {
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('releaseDate', isEqualTo: date)
          .where('isActive', isEqualTo: true)
          .get();
      
      return snapshot.docs.map((doc) => Movie.fromFirestore(doc)).toList();
    } catch (e) {
      print('Error getting movies by date: $e');
      return [];
    }
  }
}
