import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme.dart';
import 'core/router.dart';

class AaeApp extends ConsumerStatefulWidget {
  const AaeApp({super.key});

  @override
  ConsumerState<AaeApp> createState() => _AaeAppState();
}

class _AaeAppState extends ConsumerState<AaeApp> {
  String _initialRoute = Routes.dashboard;

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    // For now, go to dashboard. The dashboard will check connection.
    setState(() {
      _initialRoute = Routes.dashboard;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'AI Auto Editor Control',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.darkTheme,
      initialRoute: _initialRoute,
      onGenerateRoute: AaeRouter.generateRoute,
    );
  }
}
