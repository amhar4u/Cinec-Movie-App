import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../models/movie_model.dart';
import '../../services/movie_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/custom_text_field.dart';
import '../../widgets/custom_button.dart';

class MovieFormScreen extends StatefulWidget {
  final Movie? movie;

  const MovieFormScreen({Key? key, this.movie}) : super(key: key);

  @override
  State<MovieFormScreen> createState() => _MovieFormScreenState();
}

class _MovieFormScreenState extends State<MovieFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _movieService = MovieService();

  // Controllers
  final _titleController = TextEditingController();
  final _synopsisController = TextEditingController();
  final _posterUrlController = TextEditingController();
  final _releaseDateController = TextEditingController();
  final _durationController = TextEditingController();

  // Form state
  String _selectedGenre = 'Action';
  List<String> _showtimes = [];
  List<String> _availableShowtimes = [];
  bool _isActive = true;
  bool _isLoading = false;
  bool _isLoadingTimeSlots = false;

  final List<String> _genres = [
    'Action',
    'Adventure',
    'Comedy',
    'Drama',
    'Horror',
    'Romance',
    'Sci-Fi',
    'Thriller',
    'Animation',
    'Documentary',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with all time slots
    _availableShowtimes = [
      '9:00 AM',
      '12:00 PM',
      '3:00 PM',
      '6:00 PM',
      '9:00 PM',
    ];
    
    if (widget.movie != null) {
      _populateFields();
    }
  }

  void _populateFields() {
    final movie = widget.movie!;
    _titleController.text = movie.title;
    _synopsisController.text = movie.synopsis;
    _posterUrlController.text = movie.posterImageUrl;
    _releaseDateController.text = movie.releaseDate;
    _durationController.text = movie.duration.toString();
    _selectedGenre = movie.genre;
    _showtimes = List.from(movie.showtimes);
    _isActive = movie.isActive;
    
    // Load available time slots for the movie's release date
    if (movie.releaseDate.isNotEmpty) {
      _loadAvailableTimeSlots(movie.releaseDate);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _synopsisController.dispose();
    _posterUrlController.dispose();
    _releaseDateController.dispose();
    _durationController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      final selectedDate = '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
      setState(() {
        _releaseDateController.text = selectedDate;
        // Clear selected showtimes when date changes
        _showtimes.clear();
      });
      
      // Load available time slots for the selected date
      await _loadAvailableTimeSlots(selectedDate);
    }
  }

  Future<void> _loadAvailableTimeSlots(String date) async {
    setState(() {
      _isLoadingTimeSlots = true;
    });

    try {
      // Get available time slots for the selected date
      // If editing a movie, exclude current movie's ID to allow keeping its current time slots
      final availableSlots = await _movieService.getAvailableTimeSlots(
        date, 
        excludeMovieId: widget.movie?.id
      );
      
      setState(() {
        _availableShowtimes = availableSlots;
        // Remove any selected showtimes that are no longer available
        _showtimes.removeWhere((time) => !availableSlots.contains(time));
      });

      // Show info message about available slots
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              availableSlots.isEmpty 
                ? 'No time slots available for this date'
                : '${availableSlots.length} time slot(s) available for this date'
            ),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading available time slots'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingTimeSlots = false;
      });
    }
  }

  void _toggleShowtime(String time) {
    setState(() {
      if (_showtimes.contains(time)) {
        _showtimes.remove(time);
      } else {
        _showtimes.add(time);
      }
    });
  }

  Future<void> _saveMovie() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_releaseDateController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a release date')),
      );
      return;
    }

    if (_showtimes.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select at least one showtime')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final now = DateTime.now();
      final movie = Movie(
        id: widget.movie?.id ?? '',
        title: _titleController.text.trim(),
        genre: _selectedGenre,
        duration: int.parse(_durationController.text),
        synopsis: _synopsisController.text.trim(),
        posterImageUrl: _posterUrlController.text.trim(),
        showtimes: _showtimes,
        releaseDate: _releaseDateController.text,
        isActive: _isActive,
        createdAt: widget.movie?.createdAt ?? now,
        updatedAt: now,
      );

      bool success;
      if (widget.movie == null) {
        // Create new movie
        final movieId = await _movieService.createMovie(movie);
        success = movieId != null;
      } else {
        // Update existing movie
        success = await _movieService.updateMovie(widget.movie!.id, movie);
      }

      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.movie == null
                ? 'Movie created successfully'
                : 'Movie updated successfully'),
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(widget.movie == null
                ? 'Failed to create movie'
                : 'Failed to update movie'),
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _showScheduledMovies() async {
    if (_releaseDateController.text.isEmpty) return;

    setState(() {
      _isLoadingTimeSlots = true;
    });

    try {
      final scheduledMovies = await _movieService.getMoviesByDate(_releaseDateController.text);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Movies on ${_releaseDateController.text}'),
            content: scheduledMovies.isEmpty
                ? const Text('No movies scheduled for this date.')
                : SizedBox(
                    width: double.maxFinite,
                    child: ListView.builder(
                      shrinkWrap: true,
                      itemCount: scheduledMovies.length,
                      itemBuilder: (context, index) {
                        final movie = scheduledMovies[index];
                        return ListTile(
                          title: Text(movie.title),
                          subtitle: Text(
                            'Time slots: ${movie.showtimes.join(', ')}',
                          ),
                          leading: CircleAvatar(
                            backgroundColor: AppTheme.primaryColor,
                            child: Text(
                              movie.title.substring(0, 1).toUpperCase(),
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Error loading scheduled movies'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() {
        _isLoadingTimeSlots = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.movie == null ? 'Add Movie' : 'Edit Movie'),
        backgroundColor: AppTheme.primaryColor,
        foregroundColor: Colors.white,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Movie Title
              CustomTextField(
                controller: _titleController,
                label: 'Movie Title',
                hint: 'Enter movie title',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter a movie title';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Genre Dropdown
              const Text(
                'Genre',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _selectedGenre,
                decoration: InputDecoration(
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                items: _genres.map((genre) {
                  return DropdownMenuItem(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) {
                  if (value != null) {
                    setState(() {
                      _selectedGenre = value;
                    });
                  }
                },
              ),
              const SizedBox(height: 16),

              // Duration
              const Text(
                'Duration (minutes)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _durationController,
                decoration: InputDecoration(
                  hintText: 'e.g., 120',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter duration';
                  }
                  final duration = int.tryParse(value);
                  if (duration == null || duration <= 0) {
                    return 'Please enter a valid duration';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Release Date
              const Text(
                'Release Date',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              TextFormField(
                controller: _releaseDateController,
                decoration: InputDecoration(
                  hintText: 'YYYY-MM-DD',
                  suffixIcon: const Icon(Icons.calendar_today),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  filled: true,
                  fillColor: Colors.grey[50],
                ),
                readOnly: true,
                onTap: _selectDate,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please select a release date';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Poster URL
              CustomTextField(
                controller: _posterUrlController,
                label: 'Poster Image URL',
                hint: 'https://example.com/poster.jpg',
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter poster URL';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Synopsis
              CustomTextField(
                controller: _synopsisController,
                label: 'Synopsis',
                hint: 'Enter movie synopsis',
                maxLines: 4,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Please enter synopsis';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Showtimes
              const Text(
                'Showtimes',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              if (_releaseDateController.text.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.orange.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.orange.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.orange, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Please select a release date first to see available time slots',
                          style: TextStyle(color: Colors.orange),
                        ),
                      ),
                    ],
                  ),
                )
              else if (_isLoadingTimeSlots)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                        SizedBox(width: 8),
                        Text('Loading available time slots...'),
                      ],
                    ),
                  ),
                )
              else if (_availableShowtimes.isEmpty)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.warning_amber_outlined, color: Colors.red, size: 20),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'No time slots available for this date. All slots are already booked.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                )
              else
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Available time slots for ${_releaseDateController.text}:',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.grey[600],
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLoadingTimeSlots 
                              ? null 
                              : () => _loadAvailableTimeSlots(_releaseDateController.text),
                          icon: const Icon(Icons.refresh, size: 16),
                          label: const Text('Refresh', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                        TextButton.icon(
                          onPressed: _isLoadingTimeSlots 
                              ? null 
                              : _showScheduledMovies,
                          icon: const Icon(Icons.schedule, size: 16),
                          label: const Text('View Scheduled', style: TextStyle(fontSize: 12)),
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _availableShowtimes.map((time) {
                        final isSelected = _showtimes.contains(time);
                        return FilterChip(
                          label: Text(time),
                          selected: isSelected,
                          onSelected: (_) => _toggleShowtime(time),
                          selectedColor: AppTheme.primaryColor.withOpacity(0.2),
                          checkmarkColor: AppTheme.primaryColor,
                        );
                      }).toList(),
                    ),
                  ],
                ),
              const SizedBox(height: 16),

              // Active Status
              SwitchListTile(
                title: const Text('Active'),
                subtitle: Text(_isActive
                    ? 'Movie is available for booking'
                    : 'Movie is hidden from users'),
                value: _isActive,
                onChanged: (value) {
                  setState(() {
                    _isActive = value;
                  });
                },
                activeColor: AppTheme.primaryColor,
              ),
              const SizedBox(height: 32),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: CustomButton(
                  text: widget.movie == null ? 'Create Movie' : 'Update Movie',
                  onPressed: _isLoading ? null : _saveMovie,
                  isLoading: _isLoading,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
