import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'config/constants.dart';
import 'config/router.dart';
import 'config/theme.dart';

/// Root widget — wires together ScreenUtil, theme, localisation, and routing.
class VineAndBranchesApp extends ConsumerWidget {
  const VineAndBranchesApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ScreenUtilInit(
      // Design baseline: iPhone 14 Pro (390 × 844 pt)
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) {
        return MaterialApp.router(
          title: 'Peer-to-Peer Global Bible Study Network',
          debugShowCheckedModeBanner: false,
          theme: buildAppTheme(),
          darkTheme: buildAppTheme(), // same dark-first design
          themeMode: ThemeMode.dark,
          routerConfig: appRouter,
          localizationsDelegates: const [
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppConstants.supportedLocales,
        );
      },
    );
  }
}
