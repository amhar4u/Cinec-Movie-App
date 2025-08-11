import 'package:flutter/material.dart';

class NavigationUtils {
  // Push without replacement
  static Future<T?> push<T>(BuildContext context, Widget screen) {
    return Navigator.push<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Push with replacement
  static Future<T?> pushReplacement<T>(BuildContext context, Widget screen) {
    return Navigator.pushReplacement<T, Object?>(
      context,
      MaterialPageRoute(builder: (context) => screen),
    );
  }

  // Push and remove all previous screens
  static Future<T?> pushAndRemoveUntil<T>(
    BuildContext context,
    Widget screen,
  ) {
    return Navigator.pushAndRemoveUntil<T>(
      context,
      MaterialPageRoute(builder: (context) => screen),
      (route) => false,
    );
  }

  // Pop current screen
  static void pop(BuildContext context, [dynamic result]) {
    Navigator.pop(context, result);
  }

  // Pop until specific screen
  static void popUntil(BuildContext context, String routeName) {
    Navigator.popUntil(context, ModalRoute.withName(routeName));
  }

  // Custom slide transition
  static PageRouteBuilder<T> slideTransition<T>(
    Widget child, {
    Offset begin = const Offset(1.0, 0.0),
    Offset end = Offset.zero,
  }) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return SlideTransition(
          position: Tween<Offset>(
            begin: begin,
            end: end,
          ).animate(CurvedAnimation(
            parent: animation,
            curve: Curves.easeInOut,
          )),
          child: child,
        );
      },
    );
  }

  // Custom fade transition
  static PageRouteBuilder<T> fadeTransition<T>(Widget child) {
    return PageRouteBuilder<T>(
      pageBuilder: (context, animation, secondaryAnimation) => child,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }
}
