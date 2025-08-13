import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../models/booking_model.dart';
import '../../services/booking_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'booking_confirmation_screen.dart';

class SeatSelectionScreen extends StatefulWidget {
  final Movie movie;
  final String selectedDate;
  final String selectedShowtime;

  const SeatSelectionScreen({
    Key? key,
    required this.movie,
    required this.selectedDate,
    required this.selectedShowtime,
  }) : super(key: key);

  @override
  State<SeatSelectionScreen> createState() => _SeatSelectionScreenState();
}

class _SeatSelectionScreenState extends State<SeatSelectionScreen> {
  final BookingService _bookingService = BookingService();
  List<List<CinemaSeat>> _seatsLayout = [];
  List<CinemaSeat> _selectedSeats = [];
  bool _isLoading = true;
  double _totalAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadSeats();
  }

  Future<void> _loadSeats() async {
    setState(() => _isLoading = true);
    
    try {
      print('Loading seats for ${widget.movie.title} on ${widget.selectedDate} at ${widget.selectedShowtime}');
      
      final seatsLayout = await _bookingService.generateSeatsLayout(
        movieId: widget.movie.id,
        showDate: widget.selectedDate,
        showtime: widget.selectedShowtime,
      );
      
      print('Loaded ${seatsLayout.length} rows of seats');
      
      setState(() {
        _seatsLayout = seatsLayout;
        _isLoading = false;
      });
      
      if (seatsLayout.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No seats available for this show'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      }
    } catch (e) {
      print('Error in _loadSeats: $e');
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading seats: $e'),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadSeats,
            ),
          ),
        );
      }
    }
  }

  void _toggleSeat(CinemaSeat seat) {
    if (seat.isBooked) return;

    setState(() {
      final seatIndex = _selectedSeats.indexWhere((s) => s.id == seat.id);
      
      if (seatIndex != -1) {
        // Deselect seat
        _selectedSeats.removeAt(seatIndex);
      } else {
        // Select seat (max 6 seats for small layout)
        if (_selectedSeats.length < 6) {
          _selectedSeats.add(seat);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Maximum 6 seats can be selected'),
              duration: Duration(seconds: 2),
            ),
          );
          return;
        }
      }

      // Update seat selection in layout
      for (int row = 0; row < _seatsLayout.length; row++) {
        for (int seatNum = 0; seatNum < _seatsLayout[row].length; seatNum++) {
          if (_seatsLayout[row][seatNum].id == seat.id) {
            _seatsLayout[row][seatNum] = _seatsLayout[row][seatNum].copyWith(
              isSelected: _selectedSeats.any((s) => s.id == seat.id),
            );
            break;
          }
        }
      }

      // Calculate total amount
      _totalAmount = _selectedSeats.fold(0.0, (sum, seat) => sum + seat.price);
    });
  }

  void _proceedToBooking() {
    if (_selectedSeats.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one seat'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => BookingConfirmationScreen(
          movie: widget.movie,
          selectedDate: widget.selectedDate,
          selectedShowtime: widget.selectedShowtime,
          selectedSeats: _selectedSeats,
          totalAmount: _totalAmount,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Seats'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Column(
              children: [
                // Movie and show info
                Container(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  color: Colors.grey[100],
                  child: Column(
                    children: [
                      Text(
                        widget.movie.title,
                        style: TextStyle(
                          fontSize: isSmallScreen ? 16 : 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: isSmallScreen ? 6 : 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.calendar_today, size: isSmallScreen ? 14 : 16),
                          SizedBox(width: isSmallScreen ? 3 : 4),
                          Text(
                            widget.selectedDate,
                            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                          ),
                          SizedBox(width: isSmallScreen ? 12 : 16),
                          Icon(Icons.access_time, size: isSmallScreen ? 14 : 16),
                          SizedBox(width: isSmallScreen ? 3 : 4),
                          Text(
                            widget.selectedShowtime,
                            style: TextStyle(fontSize: isSmallScreen ? 13 : 14),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Screen indicator
                Container(
                  margin: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  padding: EdgeInsets.symmetric(vertical: isSmallScreen ? 6 : 8),
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Center(
                    child: Text(
                      'SCREEN',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.grey,
                        fontSize: isSmallScreen ? 12 : 14,
                      ),
                    ),
                  ),
                ),

                // Seat legend
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildLegendItem('Available', Colors.grey[300]!, isSmallScreen),
                      _buildLegendItem('Selected', AppTheme.primaryColor, isSmallScreen),
                      _buildLegendItem('Booked', Colors.red[400]!, isSmallScreen),
                    ],
                  ),
                ),

                SizedBox(height: isSmallScreen ? 12 : 16),

                // Seats layout
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: isSmallScreen ? 12 : 16),
                    child: Column(
                      children: [
                        for (int row = 0; row < _seatsLayout.length; row++)
                          _buildSeatRow(row),
                      ],
                    ),
                  ),
                ),

                // Selected seats and total
                if (_selectedSeats.isNotEmpty)
                  Container(
                    padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                    color: Colors.grey[100],
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                'Selected Seats: ${_selectedSeats.map((s) => s.seatLabel).join(', ')}',
                                style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  fontSize: isSmallScreen ? 13 : 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: isSmallScreen ? 6 : 8),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${_selectedSeats.length} seat(s)',
                              style: TextStyle(fontSize: isSmallScreen ? 14 : 16),
                            ),
                            Text(
                              'Rs. ${_totalAmount.toStringAsFixed(0)}',
                              style: TextStyle(
                                fontSize: isSmallScreen ? 16 : 18,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                // Proceed button
                Padding(
                  padding: EdgeInsets.all(isSmallScreen ? 12 : 16),
                  child: SizedBox(
                    width: double.infinity,
                    child: CustomButton(
                      text: 'Proceed to Booking',
                      onPressed: _selectedSeats.isNotEmpty ? _proceedToBooking : null,
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildLegendItem(String label, Color color, [bool isSmallScreen = false]) {
    return Row(
      children: [
        Container(
          width: isSmallScreen ? 14 : 16,
          height: isSmallScreen ? 14 : 16,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
            border: Border.all(color: Colors.grey),
          ),
        ),
        SizedBox(width: isSmallScreen ? 3 : 4),
        Text(
          label,
          style: TextStyle(fontSize: isSmallScreen ? 11 : 12),
        ),
      ],
    );
  }

  Widget _buildSeatRow(int rowIndex) {
    final rowLetter = String.fromCharCode(65 + rowIndex);
    final screenWidth = MediaQuery.of(context).size.width;
    final isSmallScreen = screenWidth < 380;
    
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          // Row label
          SizedBox(
            width: isSmallScreen ? 16 : 20,
            child: Text(
              rowLetter,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 4 : 8),
          
          // Seats in this row
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Left side seats (1-3)
                for (int i = 0; i < 3 && i < _seatsLayout[rowIndex].length; i++)
                  _buildSeat(_seatsLayout[rowIndex][i], isSmallScreen),
                
                SizedBox(width: isSmallScreen ? 8 : 16), // Aisle gap
                
                // Right side seats (4-6)
                for (int i = 3; i < 6 && i < _seatsLayout[rowIndex].length; i++)
                  _buildSeat(_seatsLayout[rowIndex][i], isSmallScreen),
              ],
            ),
          ),
          
          SizedBox(width: isSmallScreen ? 4 : 8),
          
          // Row label (right side)
          SizedBox(
            width: isSmallScreen ? 16 : 20,
            child: Text(
              rowLetter,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: isSmallScreen ? 12 : 14,
              ),
              textAlign: TextAlign.end,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSeat(CinemaSeat seat, [bool isSmallScreen = false]) {
    Color seatColor;
    if (seat.isBooked) {
      seatColor = Colors.red[400]!;
    } else if (seat.isSelected) {
      seatColor = AppTheme.primaryColor;
    } else {
      seatColor = Colors.grey[300]!;
    }

    final seatSize = isSmallScreen ? 28.0 : 32.0;
    final fontSize = isSmallScreen ? 10.0 : 11.0;
    final margin = isSmallScreen ? 2.0 : 3.0;

    return GestureDetector(
      onTap: () => _toggleSeat(seat),
      child: Container(
        width: seatSize,
        height: seatSize,
        margin: EdgeInsets.symmetric(horizontal: margin),
        decoration: BoxDecoration(
          color: seatColor,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: seat.isSelected ? Colors.white : Colors.grey,
            width: seat.isSelected ? 2 : 1,
          ),
        ),
        child: Center(
          child: Text(
            seat.seatNumber.toString(),
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.bold,
              color: seat.isBooked || seat.isSelected ? Colors.white : Colors.black,
            ),
          ),
        ),
      ),
    );
  }
}
