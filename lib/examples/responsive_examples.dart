import 'package:flutter/material.dart';
import '../utils/responsive_utils.dart';

// Example 1: Basic Responsive Container (like your original example)
class ResponsiveContainerExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responsive Container Example')),
      body: Center(
        child: Container(
          width: context.screenWidth, // Full device width
          height: context.heightPercent(25), // 25% of screen height
          color: Colors.blue,
          child: Center(
            child: ResponsiveText(
              'Responsive Container',
              mobileFontSize: 16,
              tabletFontSize: 20,
              desktopFontSize: 24,
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}

// Example 2: Movie Card Layout with Responsive Design
class ResponsiveMovieCard extends StatelessWidget {
  final String title;
  final String posterUrl;
  final String rating;

  const ResponsiveMovieCard({
    Key? key,
    required this.title,
    required this.posterUrl,
    required this.rating,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      mobileWidth: context.widthPercent(45), // 45% width on mobile
      tabletWidth: context.widthPercent(30),  // 30% width on tablet
      desktopWidth: context.widthPercent(20), // 20% width on desktop
      height: context.isMobile ? 280 : context.isTablet ? 320 : 360,
      margin: EdgeInsets.all(context.smallSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie Poster
          Expanded(
            flex: 3,
            child: Container(
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                image: DecorationImage(
                  image: NetworkImage(posterUrl),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
          
          // Movie Details
          Expanded(
            flex: 1,
            child: Padding(
              padding: EdgeInsets.all(context.smallSpacing),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    title,
                    mobileFontSize: 14,
                    tabletFontSize: 16,
                    desktopFontSize: 18,
                    fontWeight: FontWeight.bold,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  SizedBox(height: context.smallSpacing / 2),
                  Row(
                    children: [
                      Icon(
                        Icons.star,
                        color: Colors.amber,
                        size: context.isMobile ? 16 : 18,
                      ),
                      SizedBox(width: 4),
                      ResponsiveText(
                        rating,
                        mobileFontSize: 12,
                        tabletFontSize: 14,
                        desktopFontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example 3: Responsive Movie List/Grid
class ResponsiveMovieGrid extends StatelessWidget {
  final List<Map<String, String>> movies = [
    {'title': 'Avengers: Endgame', 'poster': 'https://example.com/poster1.jpg', 'rating': '8.4'},
    {'title': 'Spider-Man', 'poster': 'https://example.com/poster2.jpg', 'rating': '7.8'},
    {'title': 'Black Widow', 'poster': 'https://example.com/poster3.jpg', 'rating': '6.7'},
    {'title': 'Thor: Ragnarok', 'poster': 'https://example.com/poster4.jpg', 'rating': '7.9'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Responsive Movie Grid')),
      body: Padding(
        padding: context.mediumPadding,
        child: ResponsiveGrid(
          mobileColumns: 2,
          tabletColumns: 3,
          desktopColumns: 4,
          children: movies.map((movie) => ResponsiveMovieCard(
            title: movie['title']!,
            posterUrl: movie['poster']!,
            rating: movie['rating']!,
          )).toList(),
        ),
      ),
    );
  }
}

// Example 4: Responsive Layout with Different Widgets for Different Screens
class ResponsiveHomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cinema App'),
        centerTitle: !context.isDesktop, // Center title only on mobile/tablet
      ),
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.mediumPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeroSection(context),
          SizedBox(height: context.largeSpacing),
          _buildFeaturedMovies(context),
          SizedBox(height: context.largeSpacing),
          _buildNowPlaying(context),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.mediumPadding,
      child: Column(
        children: [
          _buildHeroSection(context),
          SizedBox(height: context.largeSpacing),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                flex: 2,
                child: _buildFeaturedMovies(context),
              ),
              SizedBox(width: context.mediumSpacing),
              Expanded(
                flex: 1,
                child: _buildNowPlaying(context),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Sidebar
        Container(
          width: 300,
          color: Colors.grey[100],
          child: _buildSidebar(context),
        ),
        // Main content
        Expanded(
          child: SingleChildScrollView(
            padding: context.largePadding,
            child: Column(
              children: [
                _buildHeroSection(context),
                SizedBox(height: context.largeSpacing),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      flex: 3,
                      child: _buildFeaturedMovies(context),
                    ),
                    SizedBox(width: context.mediumSpacing),
                    Expanded(
                      flex: 1,
                      child: _buildNowPlaying(context),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    return Container(
      width: double.infinity,
      height: context.isMobile ? 200 : context.isTablet ? 250 : 300,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.blue, Colors.purple],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ResponsiveText(
              'Welcome to Cinema',
              mobileFontSize: 24,
              tabletFontSize: 32,
              desktopFontSize: 40,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            SizedBox(height: context.smallSpacing),
            ResponsiveText(
              'Book your favorite movies',
              mobileFontSize: 14,
              tabletFontSize: 16,
              desktopFontSize: 18,
              color: Colors.white70,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeaturedMovies(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Featured Movies',
          mobileFontSize: 20,
          tabletFontSize: 24,
          desktopFontSize: 28,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: context.mediumSpacing),
        Container(
          height: context.isMobile ? 200 : context.isTablet ? 250 : 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: 5,
            itemBuilder: (context, index) {
              return Container(
                width: context.isMobile ? 120 : context.isTablet ? 150 : 180,
                margin: EdgeInsets.only(right: context.mediumSpacing),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ResponsiveText(
                    'Movie ${index + 1}',
                    mobileFontSize: 12,
                    tabletFontSize: 14,
                    desktopFontSize: 16,
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNowPlaying(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ResponsiveText(
          'Now Playing',
          mobileFontSize: 18,
          tabletFontSize: 20,
          desktopFontSize: 24,
          fontWeight: FontWeight.bold,
        ),
        SizedBox(height: context.mediumSpacing),
        ...List.generate(3, (index) => Container(
          margin: EdgeInsets.only(bottom: context.smallSpacing),
          padding: context.smallPadding,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Container(
                width: context.isMobile ? 60 : 80,
                height: context.isMobile ? 60 : 80,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              SizedBox(width: context.smallSpacing),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    ResponsiveText(
                      'Movie Title ${index + 1}',
                      mobileFontSize: 14,
                      tabletFontSize: 16,
                      desktopFontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                    ResponsiveText(
                      'Action • 2h 30m',
                      mobileFontSize: 12,
                      tabletFontSize: 14,
                      desktopFontSize: 16,
                      color: Colors.grey[600],
                    ),
                  ],
                ),
              ),
            ],
          ),
        )),
      ],
    );
  }

  Widget _buildSidebar(BuildContext context) {
    return Padding(
      padding: context.mediumPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ResponsiveText(
            'Categories',
            mobileFontSize: 18,
            tabletFontSize: 20,
            desktopFontSize: 22,
            fontWeight: FontWeight.bold,
          ),
          SizedBox(height: context.mediumSpacing),
          ...['Action', 'Comedy', 'Drama', 'Horror', 'Sci-Fi'].map(
            (category) => Padding(
              padding: EdgeInsets.only(bottom: context.smallSpacing),
              child: ResponsiveText(
                category,
                mobileFontSize: 14,
                tabletFontSize: 16,
                desktopFontSize: 18,
                color: Colors.grey[700],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// Example 5: Responsive Form Layout
class ResponsiveBookingForm extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Book Movie')),
      body: Center(
        child: Container(
          width: context.isDesktop 
              ? 600 
              : context.isTablet 
                  ? context.widthPercent(70)
                  : context.widthPercent(90),
          padding: context.mediumPadding,
          child: Column(
            children: [
              // Movie info section
              Container(
                width: double.infinity,
                height: context.heightPercent(context.isMobile ? 15 : 20),
                decoration: BoxDecoration(
                  color: Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: ResponsiveText(
                    'Movie Poster & Info',
                    mobileFontSize: 16,
                    tabletFontSize: 18,
                    desktopFontSize: 20,
                  ),
                ),
              ),
              
              SizedBox(height: context.largeSpacing),
              
              // Form fields
              if (context.isDesktop) ...[
                // Desktop: side by side layout
                Row(
                  children: [
                    Expanded(child: _buildDateTimeFields(context)),
                    SizedBox(width: context.mediumSpacing),
                    Expanded(child: _buildPersonalFields(context)),
                  ],
                ),
              ] else ...[
                // Mobile/Tablet: stacked layout
                _buildDateTimeFields(context),
                SizedBox(height: context.mediumSpacing),
                _buildPersonalFields(context),
              ],
              
              SizedBox(height: context.largeSpacing),
              
              // Book button
              SizedBox(
                width: double.infinity,
                height: context.isMobile ? 50 : 60,
                child: ElevatedButton(
                  onPressed: () {},
                  child: ResponsiveText(
                    'Book Now',
                    mobileFontSize: 16,
                    tabletFontSize: 18,
                    desktopFontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateTimeFields(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Select Date',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(context.smallSpacing),
          ),
        ),
        SizedBox(height: context.mediumSpacing),
        TextField(
          decoration: InputDecoration(
            labelText: 'Select Time',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(context.smallSpacing),
          ),
        ),
      ],
    );
  }

  Widget _buildPersonalFields(BuildContext context) {
    return Column(
      children: [
        TextField(
          decoration: InputDecoration(
            labelText: 'Your Name',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(context.smallSpacing),
          ),
        ),
        SizedBox(height: context.mediumSpacing),
        TextField(
          decoration: InputDecoration(
            labelText: 'Phone Number',
            border: OutlineInputBorder(),
            contentPadding: EdgeInsets.all(context.smallSpacing),
          ),
        ),
      ],
    );
  }
}
