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
  bool _isActive = true;
  bool _isLoading = false;

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

  final List<String> _availableShowtimes = [
    '9:00 AM',
    '12:00 PM',
    '3:00 PM',
    '6:00 PM',
    '9:00 PM',
  ];

  @override
  void initState() {
    super.initState();
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
      setState(() {
        _releaseDateController.text =
            '${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}';
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
    if (!_formKey.currentState!.validate() || _showtimes.isEmpty) {
      if (_showtimes.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please select at least one showtime')),
        );
      }
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
