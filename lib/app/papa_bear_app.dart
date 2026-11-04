import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/app/router.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';

class PapaBearApp extends ConsumerWidget {
  const PapaBearApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(
      title: 'PapaBear Shop CRM',
      debugShowCheckedModeBanner: false,
      theme: PbTheme.light(),
      routerConfig: router,
      builder: (context, child) {
        return Material(
          color: PbColors.cream,
          child: child ?? const SizedBox.shrink(),
        );
      },
    );
  }
}
