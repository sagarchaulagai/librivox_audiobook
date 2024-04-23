import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:librivox_audiobook/resources/models/audiobook.dart';
import 'package:librivox_audiobook/resources/models/audiobook_file.dart';
import 'package:librivox_audiobook/screens/audiobook_details_page.dart';
import 'package:librivox_audiobook/screens/audiobook_player_page.dart';
import 'package:librivox_audiobook/screens/home.dart';

void main() {
  runApp(const MyApp());
}

final GoRouter _router = GoRouter(
  initialLocation: '/home',
  routes: <RouteBase>[
    GoRoute(
      path: '/home',
      name: '/home',
      builder: (context, state) {
        return const MyHomePage();
      },
    ),
    GoRoute(
      path: '/audiobook_details',
      name: '/audiobook_details',
      builder: (context, state) {
        final Audiobook audiobook = state.extra as Audiobook;
        return AudiobookDetailsPage(audiobook: audiobook);
      },
    ),
    GoRoute(
        path: '/audiobook_player',
        name: '/audiobook_player',
        builder: (context, state) {
          final data = state.extra! as Map<String, dynamic>;
          final Audiobook audiobook = data['audiobook'] as Audiobook;
          final List<AudiobookFile> audiobookFiles =
              data['audiobookFiles'] as List<AudiobookFile>;
          final int index = data['index'] as int;

          return AudiobookPlayerPage(
            audiobook: audiobook,
            audiobookFiles: audiobookFiles,
            index: index,
          );
        }),
  ],
);

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      routerConfig: _router,
    );
  }
}
