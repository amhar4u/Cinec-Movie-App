import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/booking_model.dart';

class BookingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _collection = 'bookings';

  // Create a new booking
  Future<String?> createBooking(MovieBooking booking) async {
    try {
      DocumentReference docRef = await _firestore.collection(_collection).add(booking.toFirestore());
      return docRef.id;
    } catch (e) {
      print('Error creating booking: $e');
      return null;
    }
  }

  // Get all bookings for a user
  Stream<List<MovieBooking>> getUserBookings(String userId) {
    return _firestore
        .collection(_collection)
        .where('userId', isEqualTo: userId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieBooking.fromFirestore(doc)).toList());
  }

  // Get booking by ID
  Future<MovieBooking?> getBookingById(String bookingId) async {
    try {
      DocumentSnapshot doc = await _firestore.collection(_collection).doc(bookingId).get();
      if (doc.exists) {
        return MovieBooking.fromFirestore(doc);
      }
      return null;
    } catch (e) {
      print('Error getting booking: $e');
      return null;
    }
  }

  // Cancel a booking
  Future<bool> cancelBooking(String bookingId) async {
    try {
      await _firestore.collection(_collection).doc(bookingId).update({
        'status': BookingStatus.cancelled.toString().split('.').last,
      });
      return true;
    } catch (e) {
      print('Error cancelling booking: $e');
      return false;
    }
  }

  // Get booked seats for a specific movie, date, and showtime
  Future<List<String>> getBookedSeats({
    required String movieId,
    required String showDate,
    required String showtime,
  }) async {
    try {
      print('Fetching booked seats for movieId: $movieId, date: $showDate, time: $showtime');
      
      QuerySnapshot snapshot = await _firestore
          .collection(_collection)
          .where('movieId', isEqualTo: movieId)
          .where('showDate', isEqualTo: showDate)
          .where('showtime', isEqualTo: showtime)
          .where('status', isEqualTo: BookingStatus.confirmed.toString().split('.').last)
          .get();

      print('Found ${snapshot.docs.length} confirmed bookings');

      List<String> bookedSeats = [];
      for (var doc in snapshot.docs) {
        final booking = MovieBooking.fromFirestore(doc);
        bookedSeats.addAll(booking.seatIds);
        print('Added seats: ${booking.seatIds}');
      }

      print('Total booked seats: $bookedSeats');
      return bookedSeats;
    } catch (e) {
      print('Error getting booked seats: $e');
      print('Error type: ${e.runtimeType}');
      return [];
    }
  }

  // Check if seats are available for booking
  Future<bool> areSeatsAvailable({
    required String movieId,
    required String showDate,
    required String showtime,
    required List<String> seatIds,
  }) async {
    try {
      final bookedSeats = await getBookedSeats(
        movieId: movieId,
        showDate: showDate,
        showtime: showtime,
      );

      // Check if any of the requested seats are already booked
      for (String seatId in seatIds) {
        if (bookedSeats.contains(seatId)) {
          return false;
        }
      }

      return true;
    } catch (e) {
      print('Error checking seat availability: $e');
      return false;
    }
  }

  // Generate cinema seats layout (2 rows, 6 seats per row = 12 total seats)
  Future<List<List<CinemaSeat>>> generateSeatsLayout({
    required String movieId,
    required String showDate,
    required String showtime,
  }) async {
    try {
      print('Generating seats layout for movieId: $movieId, date: $showDate, time: $showtime');
      
      final bookedSeats = await getBookedSeats(
        movieId: movieId,
        showDate: showDate,
        showtime: showtime,
      );

      print('Booked seats retrieved: $bookedSeats');

      List<List<CinemaSeat>> seatsLayout = [];

      for (int row = 0; row < 2; row++) {
        List<CinemaSeat> rowSeats = [];
        for (int seat = 1; seat <= 6; seat++) {
          final seatId = '${String.fromCharCode(65 + row)}$seat';
          final isBooked = bookedSeats.contains(seatId);
          
          print('Seat $seatId - isBooked: $isBooked');
          
          // Different pricing based on row
          double price = 1000.0; // Default price
          if (row == 0) {
            price = 1500.0; // Premium front row (A)
          } else {
            price = 1200.0; // Standard back row (B)
          }

          rowSeats.add(CinemaSeat(
            id: seatId,
            row: row,
            seatNumber: seat,
            isBooked: isBooked,
            price: price,
          ));
        }
        seatsLayout.add(rowSeats);
      }

      print('Generated ${seatsLayout.length} rows with ${seatsLayout.isNotEmpty ? seatsLayout[0].length : 0} seats each');
      return seatsLayout;
    } catch (e) {
      print('Error generating seats layout: $e');
      print('Error type: ${e.runtimeType}');
      // Return empty layout with default seats if error occurs
      return _generateDefaultSeatsLayout();
    }
  }

  // Generate default seats layout when there's an error
  List<List<CinemaSeat>> _generateDefaultSeatsLayout() {
    print('Generating default seats layout (no booked seats)');
    List<List<CinemaSeat>> seatsLayout = [];

    for (int row = 0; row < 2; row++) {
      List<CinemaSeat> rowSeats = [];
      for (int seat = 1; seat <= 6; seat++) {
        final seatId = '${String.fromCharCode(65 + row)}$seat';
        
        // Different pricing based on row
        double price = 1000.0; // Default price
        if (row == 0) {
          price = 1500.0; // Premium front row (A)
        } else {
          price = 1200.0; // Standard back row (B)
        }

        rowSeats.add(CinemaSeat(
          id: seatId,
          row: row,
          seatNumber: seat,
          isBooked: false, // Default to not booked
          price: price,
        ));
      }
      seatsLayout.add(rowSeats);
    }

    return seatsLayout;
  }

  // Get all bookings (admin functionality)
  Stream<List<MovieBooking>> getAllBookings() {
    return _firestore
        .collection(_collection)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieBooking.fromFirestore(doc)).toList());
  }

  // Get bookings for a specific movie
  Stream<List<MovieBooking>> getMovieBookings(String movieId) {
    return _firestore
        .collection(_collection)
        .where('movieId', isEqualTo: movieId)
        .orderBy('bookingDate', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => MovieBooking.fromFirestore(doc)).toList());
  }

  // Get booking statistics
  Future<Map<String, int>> getBookingStats() async {
    try {
      final snapshot = await _firestore.collection(_collection).get();
      
      int totalBookings = snapshot.docs.length;
      int confirmedBookings = 0;
      int cancelledBookings = 0;
      int completedBookings = 0;

      for (var doc in snapshot.docs) {
        final booking = MovieBooking.fromFirestore(doc);
        switch (booking.status) {
          case BookingStatus.confirmed:
            confirmedBookings++;
            break;
          case BookingStatus.cancelled:
            cancelledBookings++;
            break;
          case BookingStatus.completed:
            completedBookings++;
            break;
        }
      }

      return {
        'total': totalBookings,
        'confirmed': confirmedBookings,
        'cancelled': cancelledBookings,
        'completed': completedBookings,
      };
    } catch (e) {
      print('Error getting booking stats: $e');
      return {
        'total': 0,
        'confirmed': 0,
        'cancelled': 0,
        'completed': 0,
      };
    }
  }
}
