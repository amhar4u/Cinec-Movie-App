import 'package:cloud_firestore/cloud_firestore.dart';

enum BookingStatus {
  confirmed,
  cancelled,
  completed,
}

class MovieBooking {
  final String id;
  final String userId;
  final String movieId;
  final String movieTitle;
  final String moviePosterUrl;
  final String showDate;
  final String showtime;
  final List<String> seatIds;
  final int totalSeats;
  final double totalAmount;
  final String userPhone;
  final BookingStatus status;
  final DateTime bookingDate;

  MovieBooking({
    required this.id,
    required this.userId,
    required this.movieId,
    required this.movieTitle,
    required this.moviePosterUrl,
    required this.showDate,
    required this.showtime,
    required this.seatIds,
    required this.totalSeats,
    required this.totalAmount,
    required this.userPhone,
    this.status = BookingStatus.confirmed,
    required this.bookingDate,
  });

  // Helper getters
  bool get isUpcoming {
    final showDateTime = _parseShowDateTime();
    return showDateTime.isAfter(DateTime.now()) && status == BookingStatus.confirmed;
  }

  bool get isPast {
    final showDateTime = _parseShowDateTime();
    return showDateTime.isBefore(DateTime.now()) || status != BookingStatus.confirmed;
  }

  String get formattedBookingDate {
    return '${bookingDate.day}/${bookingDate.month}/${bookingDate.year}';
  }

  DateTime _parseShowDateTime() {
    try {
      // Parse show date (assuming format: YYYY-MM-DD)
      final dateParts = showDate.split('-');
      final year = int.parse(dateParts[0]);
      final month = int.parse(dateParts[1]);
      final day = int.parse(dateParts[2]);
      
      // Parse showtime (assuming format: "HH:MM AM/PM")
      final timeParts = showtime.split(' ');
      final timeValue = timeParts[0].split(':');
      var hour = int.parse(timeValue[0]);
      final minute = int.parse(timeValue[1]);
      
      if (timeParts[1].toUpperCase() == 'PM' && hour != 12) {
        hour += 12;
      } else if (timeParts[1].toUpperCase() == 'AM' && hour == 12) {
        hour = 0;
      }
      
      return DateTime(year, month, day, hour, minute);
    } catch (e) {
      return DateTime.now();
    }
  }

  // Convert to Map for Firestore
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'userId': userId,
      'movieId': movieId,
      'movieTitle': movieTitle,
      'moviePosterUrl': moviePosterUrl,
      'showDate': showDate,
      'showtime': showtime,
      'seatIds': seatIds,
      'totalSeats': totalSeats,
      'totalAmount': totalAmount,
      'userPhone': userPhone,
      'status': status.toString().split('.').last,
      'bookingDate': bookingDate.toIso8601String(),
    };
  }

  // Create from Map
  factory MovieBooking.fromMap(Map<String, dynamic> map) {
    return MovieBooking(
      id: map['id'] ?? '',
      userId: map['userId'] ?? '',
      movieId: map['movieId'] ?? '',
      movieTitle: map['movieTitle'] ?? '',
      moviePosterUrl: map['moviePosterUrl'] ?? '',
      showDate: map['showDate'] ?? '',
      showtime: map['showtime'] ?? '',
      seatIds: List<String>.from(map['seatIds'] ?? []),
      totalSeats: map['totalSeats'] ?? 0,
      totalAmount: (map['totalAmount'] ?? 0.0).toDouble(),
      userPhone: map['userPhone'] ?? '',
      status: BookingStatus.values.firstWhere(
        (status) => status.toString().split('.').last == map['status'],
        orElse: () => BookingStatus.confirmed,
      ),
      bookingDate: DateTime.parse(map['bookingDate'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Firestore specific methods
  factory MovieBooking.fromFirestore(DocumentSnapshot doc) {
    Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
    data['id'] = doc.id; // Use Firestore document ID
    return MovieBooking.fromMap(data);
  }

  Map<String, dynamic> toFirestore() {
    Map<String, dynamic> data = toMap();
    data.remove('id'); // Remove id field as Firestore generates it
    return data;
  }

  // Create a copy with updated fields
  MovieBooking copyWith({
    String? id,
    String? userId,
    String? movieId,
    String? movieTitle,
    String? moviePosterUrl,
    String? showDate,
    String? showtime,
    List<String>? seatIds,
    int? totalSeats,
    double? totalAmount,
    String? userPhone,
    BookingStatus? status,
    DateTime? bookingDate,
  }) {
    return MovieBooking(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      movieId: movieId ?? this.movieId,
      movieTitle: movieTitle ?? this.movieTitle,
      moviePosterUrl: moviePosterUrl ?? this.moviePosterUrl,
      showDate: showDate ?? this.showDate,
      showtime: showtime ?? this.showtime,
      seatIds: seatIds ?? this.seatIds,
      totalSeats: totalSeats ?? this.totalSeats,
      totalAmount: totalAmount ?? this.totalAmount,
      userPhone: userPhone ?? this.userPhone,
      status: status ?? this.status,
      bookingDate: bookingDate ?? this.bookingDate,
    );
  }
}

// Seat model for seat selection
class CinemaSeat {
  final String id;
  final int row;
  final int seatNumber;
  final bool isBooked;
  final bool isSelected;
  final double price;

  CinemaSeat({
    required this.id,
    required this.row,
    required this.seatNumber,
    this.isBooked = false,
    this.isSelected = false,
    this.price = 1000.0, // Default price in LKR
  });

  String get seatLabel => '${String.fromCharCode(65 + row)}${seatNumber}';

  CinemaSeat copyWith({
    String? id,
    int? row,
    int? seatNumber,
    bool? isBooked,
    bool? isSelected,
    double? price,
  }) {
    return CinemaSeat(
      id: id ?? this.id,
      row: row ?? this.row,
      seatNumber: seatNumber ?? this.seatNumber,
      isBooked: isBooked ?? this.isBooked,
      isSelected: isSelected ?? this.isSelected,
      price: price ?? this.price,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'row': row,
      'seatNumber': seatNumber,
      'isBooked': isBooked,
      'price': price,
    };
  }

  factory CinemaSeat.fromMap(Map<String, dynamic> map) {
    return CinemaSeat(
      id: map['id'] ?? '',
      row: map['row'] ?? 0,
      seatNumber: map['seatNumber'] ?? 0,
      isBooked: map['isBooked'] ?? false,
      price: (map['price'] ?? 1000.0).toDouble(),
    );
  }
}
