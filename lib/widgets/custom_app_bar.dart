import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showThemeToggle;
  final bool centerTitle;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;

  const CustomAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.showThemeToggle = true,
    this.centerTitle = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    List<Widget> finalActions = [];
    
    // Add custom actions
    if (actions != null) {
      finalActions.addAll(actions!);
    }
    
    // Add theme toggle if enabled
    if (showThemeToggle) {
      finalActions.add(
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return IconButton(
              onPressed: () => themeProvider.toggleTheme(),
              icon: Icon(
                themeProvider.isDarkMode 
                    ? Icons.light_mode_outlined
                    : Icons.dark_mode_outlined,
                color: foregroundColor ?? theme.colorScheme.onSurface,
              ),
              tooltip: themeProvider.isDarkMode 
                  ? 'Switch to Light Mode' 
                  : 'Switch to Dark Mode',
            );
          },
        ),
      );
    }

    return AppBar(
      title: title != null 
          ? Text(
              title!,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: foregroundColor ?? theme.colorScheme.onSurface,
              ),
            )
          : null,
      leading: leading,
      actions: finalActions.isNotEmpty ? finalActions : null,
      centerTitle: centerTitle,
      backgroundColor: backgroundColor ?? Colors.transparent,
      foregroundColor: foregroundColor ?? theme.colorScheme.onSurface,
      elevation: elevation,
      scrolledUnderElevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
