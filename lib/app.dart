import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:core/core.dart';

import 'router.dart';

class GenieHubApp extends ConsumerWidget {
  const GenieHubApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp.router(
      title: 'GenieHub',
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      debugShowCheckedModeBanner: false,
      routerConfig: appRouter,
    );
  }
}
