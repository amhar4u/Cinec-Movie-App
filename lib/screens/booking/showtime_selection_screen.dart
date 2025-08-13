import 'package:flutter/material.dart';
import '../../models/movie_model.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_button.dart';
import 'seat_selection_screen.dart';

class ShowtimeSelectionScreen extends StatefulWidget {
  final Movie movie;

  const ShowtimeSelectionScreen({Key? key, required this.movie}) : super(key: key);

  @override
  State<ShowtimeSelectionScreen> createState() => _ShowtimeSelectionScreenState();
}

class _ShowtimeSelectionScreenState extends State<ShowtimeSelectionScreen> {
  DateTime? _selectedDate;
  String? _selectedShowtime;

  @override
  void initState() {
    super.initState();
    // Set default date to today
    _selectedDate = DateTime.now();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 30)),
    );
    
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _selectedShowtime = null; // Reset showtime when date changes
      });
    }
  }

  void _proceedToSeatSelection() {
    if (_selectedDate == null || _selectedShowtime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select both date and showtime'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final formattedDate = '${_selectedDate!.year}-${_selectedDate!.month.toString().padLeft(2, '0')}-${_selectedDate!.day.toString().padLeft(2, '0')}';
    
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SeatSelectionScreen(
          movie: widget.movie,
          selectedDate: formattedDate,
          selectedShowtime: _selectedShowtime!,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Showtime'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie info card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    // Movie poster
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: widget.movie.posterImageUrl.isNotEmpty
                          ? Image.network(
                              widget.movie.posterImageUrl,
                              width: 80,
                              height: 120,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                width: 80,
                                height: 120,
                                color: Colors.grey[300],
                                child: const Icon(Icons.movie),
                              ),
                            )
                          : Container(
                              width: 80,
                              height: 120,
                              color: Colors.grey[300],
                              child: const Icon(Icons.movie),
                            ),
                    ),
                    const SizedBox(width: 16),
                    
                    // Movie details
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.movie.title,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.movie.genre,
                            style: TextStyle(
                              color: AppTheme.primaryColor,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.movie.formattedDuration,
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                          if (widget.movie.rating > 0) ...[
                            const SizedBox(height: 4),
                            Row(
                              children: [
                                const Icon(Icons.star, size: 16, color: Colors.amber),
                                const SizedBox(width: 4),
                                Text(
                                  widget.movie.rating.toStringAsFixed(1),
                                  style: const TextStyle(fontWeight: FontWeight.w600),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Date selection
            const Text(
              'Select Date',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey[300]!),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: AppTheme.primaryColor),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Text(
                        _selectedDate != null
                            ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                            : 'Select date',
                        style: const TextStyle(fontSize: 16),
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Showtime selection
            const Text(
              'Select Showtime',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            if (widget.movie.showtimes.isEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.orange[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.orange[300]!),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info, color: Colors.orange),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No showtimes available for this movie.',
                        style: TextStyle(color: Colors.orange),
                      ),
                    ),
                  ],
                ),
              )
            else
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: widget.movie.showtimes.map((showtime) {
                  final isSelected = _selectedShowtime == showtime;
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        _selectedShowtime = showtime;
                      });
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: isSelected ? AppTheme.primaryColor : Colors.transparent,
                        border: Border.all(
                          color: AppTheme.primaryColor,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(25),
                      ),
                      child: Text(
                        showtime,
                        style: TextStyle(
                          color: isSelected ? Colors.white : AppTheme.primaryColor,
                          fontWeight: FontWeight.w600,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),

            const SizedBox(height: 32),

            // Information section
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue[200]!),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue[600]),
                      const SizedBox(width: 8),
                      const Text(
                        'Ticket Information',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    '• Premium seats (Row A): Rs. 1,500\n'
                    '• Standard seats (Row B): Rs. 1,200\n'
                    '• Total seats: 12 (2 rows × 6 seats)\n'
                    '• Maximum 6 seats per booking\n'
                    '• Optimized for mobile screens',
                    style: TextStyle(fontSize: 14),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Proceed button
            SizedBox(
              width: double.infinity,
              child: CustomButton(
                text: 'Select Seats',
                onPressed: (_selectedDate != null && _selectedShowtime != null) 
                    ? _proceedToSeatSelection 
                    : null,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
