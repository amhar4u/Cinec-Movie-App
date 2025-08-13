# How to Make Your Movie App Responsive

## Quick Start Guide

Instead of using `MediaQuery.of(context).size.width` directly everywhere, you can now use the enhanced `ResponsiveUtils` class and extension methods for cleaner, more maintainable code.

## Basic Usage Examples

### 1. Replace Your Original Code

**Before (your original approach):**
```dart
double deviceWidth = MediaQuery.of(context).size.width;
double deviceHeight = MediaQuery.of(context).size.height;

Container(
  width: MediaQuery.of(context).size.width, // full device width
  height: 200,
  color: Colors.blue,
)
```

**After (with our responsive utils):**
```dart
Container(
  width: context.screenWidth, // full device width
  height: context.heightPercent(25), // 25% of screen height
  color: Colors.blue,
)
```

### 2. Percentage-Based Sizing

```dart
// Easy percentage calculations
Container(
  width: context.widthPercent(50), // 50% of screen width
  height: context.heightPercent(30), // 30% of screen height
)
```

### 3. Device-Specific Layouts

```dart
Container(
  width: context.isMobile ? context.widthPercent(90) : context.widthPercent(60),
  height: context.isMobile ? 200 : 300,
)
```

### 4. Responsive Spacing

```dart
Padding(
  padding: EdgeInsets.all(context.mediumSpacing), // Auto-adjusts for device
  child: Column(
    children: [
      Text('Title'),
      SizedBox(height: context.smallSpacing),
      Text('Subtitle'),
    ],
  ),
)
```

## Implementation Steps

### Step 1: Import the Responsive Utils
Add this import to any screen where you want responsive design:
```dart
import '../utils/responsive_utils.dart';
```

### Step 2: Update Your Existing Screens

Here's how to convert your existing movie screens:

#### Movie List Screen
```dart
class MovieListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Movies')),
      body: Padding(
        padding: context.mediumPadding, // Responsive padding
        child: ResponsiveGrid(
          mobileColumns: 2,    // 2 columns on mobile
          tabletColumns: 3,    // 3 columns on tablet
          desktopColumns: 4,   // 4 columns on desktop
          children: movies.map((movie) => MovieCard(movie: movie)).toList(),
        ),
      ),
    );
  }
}
```

#### Movie Detail Screen
```dart
class MovieDetailScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ResponsiveWidget(
        mobile: _buildMobileLayout(context),
        tablet: _buildTabletLayout(context),
        desktop: _buildDesktopLayout(context),
      ),
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          // Movie poster
          Container(
            width: context.screenWidth,
            height: context.heightPercent(40),
            child: Image.network(movie.posterUrl, fit: BoxFit.cover),
          ),
          
          Padding(
            padding: context.mediumPadding,
            child: Column(
              children: [
                ResponsiveText(
                  movie.title,
                  mobileFontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: context.mediumSpacing),
                ResponsiveText(
                  movie.description,
                  mobileFontSize: 16,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabletLayout(BuildContext context) {
    return SingleChildScrollView(
      padding: context.mediumPadding,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Movie poster
          Container(
            width: context.widthPercent(40),
            height: context.heightPercent(60),
            child: Image.network(movie.posterUrl, fit: BoxFit.cover),
          ),
          
          SizedBox(width: context.mediumSpacing),
          
          // Movie details
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                ResponsiveText(
                  movie.title,
                  tabletFontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                SizedBox(height: context.mediumSpacing),
                ResponsiveText(
                  movie.description,
                  tabletFontSize: 18,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Center(
      child: Container(
        width: context.widthPercent(80),
        padding: context.largePadding,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Movie poster
            Container(
              width: 400,
              height: 600,
              child: Image.network(movie.posterUrl, fit: BoxFit.cover),
            ),
            
            SizedBox(width: context.largeSpacing),
            
            // Movie details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    movie.title,
                    desktopFontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                  SizedBox(height: context.largeSpacing),
                  ResponsiveText(
                    movie.description,
                    desktopFontSize: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Step 3: Use Responsive Components

#### Responsive Movie Card
```dart
class MovieCard extends StatelessWidget {
  final Movie movie;

  const MovieCard({required this.movie});

  @override
  Widget build(BuildContext context) {
    return ResponsiveContainer(
      mobileWidth: context.widthPercent(45),
      tabletWidth: context.widthPercent(30),
      desktopWidth: context.widthPercent(22),
      height: context.isMobile ? 280 : 320,
      margin: EdgeInsets.all(context.smallSpacing),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 8)],
      ),
      child: Column(
        children: [
          Expanded(
            flex: 3,
            child: ClipRRect(
              borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
              child: Image.network(movie.posterUrl, fit: BoxFit.cover),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: context.smallPadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ResponsiveText(
                    movie.title,
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
                      Icon(Icons.star, color: Colors.amber, size: 16),
                      SizedBox(width: 4),
                      ResponsiveText(
                        movie.rating.toString(),
                        mobileFontSize: 12,
                        tabletFontSize: 14,
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
```

## Key Benefits

1. **Cleaner Code**: No more repetitive `MediaQuery.of(context).size.width`
2. **Consistent Spacing**: Automatic responsive spacing across all devices
3. **Easy Maintenance**: Change breakpoints in one place
4. **Better UX**: Optimal layouts for each device type
5. **Flexible**: Easy to customize for specific use cases

## Quick Reference

### Extension Methods
- `context.isMobile` / `context.isTablet` / `context.isDesktop`
- `context.screenWidth` / `context.screenHeight`
- `context.widthPercent(50)` / `context.heightPercent(30)`
- `context.smallSpacing` / `context.mediumSpacing` / `context.largeSpacing`
- `context.smallPadding` / `context.mediumPadding` / `context.largePadding`

### Responsive Widgets
- `ResponsiveWidget` - Different widgets for different screens
- `ResponsiveContainer` - Auto-sizing containers
- `ResponsiveGrid` - Auto-column grids
- `ResponsiveText` - Auto-sizing text

Start by replacing your existing `MediaQuery` calls with these extension methods, then gradually adopt the responsive widgets for more complex layouts!
