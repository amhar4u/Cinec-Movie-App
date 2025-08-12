import 'package:cloud_firestore/cloud_firestore.dart';

class Movie {
  final String id;
  final String title;
  final String genre;
  final int duration; // in minutes
  final String synopsis;
  final String posterImageUrl;
  final List<String> showtimes; // e.g., ["10:00 AM", "2:00 PM", "6:00 PM", "9:00 PM"]
  final double rating;
  final String releaseDate;
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;

  Movie({
    required this.id,
    required this.title,
    required this.genre,
    required this.duration,
    required this.synopsis,
    required this.posterImageUrl,
    required this.showtimes,
    this.rating = 0.0,
    required this.releaseDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'title': title,
      'genre': genre,
      'duration': duration,
      'synopsis': synopsis,
      'posterImageUrl': posterImageUrl,
      'showtimes': showtimes,
      'rating': rating,
      'releaseDate': releaseDate,
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create from Firestore document
  factory Movie.fromMap(Map<String, dynamic> map) {
    return Movie(
      id: map['id'] ?? '',
      title: map['title'] ?? '',
      genre: map['genre'] ?? '',
      duration: map['duration'] ?? 0,
      synopsis: map['synopsis'] ?? '',
      posterImageUrl: map['posterImageUrl'] ?? '',
      showtimes: List<String>.from(map['showtimes'] ?? []),
      rating: (map['rating'] ?? 0.0).toDouble(),
      releaseDate: map['releaseDate'] ?? '',
      isActive: map['isActive'] ?? true,
      createdAt: DateTime.parse(map['createdAt'] ?? DateTime.now().toIso8601String()),
      updatedAt: DateTime.parse(map['updatedAt'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Firestore specific methods
  factory Movie.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Use Firestore document ID
    return Movie.fromMap(data);
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = toMap();
    data.remove('id'); // Remove id field as Firestore generates it
    return data;
  }

  // Create a copy with updated fields
  Movie copyWith({
    String? id,
    String? title,
    String? genre,
    int? duration,
    String? synopsis,
    String? posterImageUrl,
    List<String>? showtimes,
    double? rating,
    String? releaseDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Movie(
      id: id ?? this.id,
      title: title ?? this.title,
      genre: genre ?? this.genre,
      duration: duration ?? this.duration,
      synopsis: synopsis ?? this.synopsis,
      posterImageUrl: posterImageUrl ?? this.posterImageUrl,
      showtimes: showtimes ?? this.showtimes,
      rating: rating ?? this.rating,
      releaseDate: releaseDate ?? this.releaseDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Format duration as "2h 30m"
  String get formattedDuration {
    final hours = duration ~/ 60;
    final minutes = duration % 60;
    if (hours > 0 && minutes > 0) {
      return '${hours}h ${minutes}m';
    } else if (hours > 0) {
      return '${hours}h';
    } else {
      return '${minutes}m';
    }
  }

  @override
  String toString() {
    return 'Movie(id: $id, title: $title, genre: $genre, duration: $duration)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Movie && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
