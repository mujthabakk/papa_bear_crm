import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

/// Keeps a tap inside the login that opened the screen.
/// Reception stays under `/reception`, owner under `/owner`.
String rolePath(BuildContext context, String segment) {
  final current = GoRouterState.of(context).uri.path;
  final root = current.startsWith('/owner') ? '/owner' : '/reception';
  final tail = segment.startsWith('/') ? segment : '/$segment';
  return '$root$tail';
}
