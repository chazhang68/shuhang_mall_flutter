import 'package:flutter/material.dart';
import 'package:shuhang_mall_flutter/app/services/log_service.dart';

class NavigationService {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static Future<T?> pushNamed<T extends Object?>(
    String routeName, {
    Object? arguments,
  }) async {
    try {
      LogService.i('Navigating to: $routeName');
      return await navigatorKey.currentState?.pushNamed<T>(
        routeName,
        arguments: arguments,
      );
    } catch (e, stack) {
      LogService.navigatorError('pushNamed', error: e, stackTrace: stack);
      return null;
    }
  }

  static Future<T?> pushReplacementNamed<T extends Object?, TO extends Object?>(
    String routeName, {
    TO? result,
    Object? arguments,
  }) async {
    try {
      LogService.i('Replacing route with: $routeName');
      return await navigatorKey.currentState?.pushReplacementNamed<T, TO>(
        routeName,
        arguments: arguments,
        result: result,
      );
    } catch (e, stack) {
      LogService.navigatorError(
        'pushReplacementNamed',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  static Future<T?> pushAndRemoveUntil<T extends Object?>(
    Route<T> newRoute, {
    required RoutePredicate predicate,
  }) async {
    try {
      LogService.i('Pushing route and removing until condition');
      return navigatorKey.currentState?.pushAndRemoveUntil<T>(
        newRoute,
        predicate,
      );
    } catch (e, stack) {
      LogService.navigatorError(
        'pushAndRemoveUntil',
        error: e,
        stackTrace: stack,
      );
      return null;
    }
  }

  static void pop<T extends Object?>([T? result]) {
    try {
      LogService.i('Popping route');
      navigatorKey.currentState?.pop(result);
    } catch (e, stack) {
      LogService.navigatorError('pop', error: e, stackTrace: stack);
    }
  }

  static String getCurrentRoute() {
    // 这是一个简化的方法，实际应用中可能需要更复杂的实现
    return navigatorKey.currentContext
            ?.findAncestorWidgetOfExactType<MaterialApp>()
            ?.navigatorKey
            ?.toString() ??
        "unknown";
  }
}
