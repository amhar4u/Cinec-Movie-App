import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  final double size;
  final Color? primaryColor;
  final Color? secondaryColor;

  const AppLogo({
    super.key,
    this.size = 100,
    this.primaryColor,
    this.secondaryColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primaryColor ?? theme.primaryColor,
            (primaryColor ?? theme.primaryColor).withOpacity(0.8),
          ],
        ),
        borderRadius: BorderRadius.circular(size * 0.2),
        boxShadow: [
          BoxShadow(
            color: (primaryColor ?? theme.primaryColor).withOpacity(0.3),
            blurRadius: size * 0.1,
            offset: Offset(0, size * 0.05),
          ),
        ],
      ),
      child: Center(
        child: Icon(
          Icons.movie_outlined,
          size: size * 0.6,
          color: secondaryColor ?? Colors.white,
        ),
      ),
    );
  }
}
