import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const pages = [
      ('/settings/shop', 'Shop details', 'Name, address and phone on every bill'),
      ('/settings/services', 'Services and prices', 'Price and duration used by the availability check'),
      ('/settings/skills', 'Skills and hours', 'Which services each person does, and their shift'),
      ('/settings/access', 'Logins', 'Receptionist password, enable or disable the desk'),
      ('/settings/categories', 'Expense categories', 'The reasons used on cash out'),
      ('/settings/rules', 'Salary rules', 'Discount cap, commission, working days and leave'),
      ('/settings/backup', 'Backup', 'Download the shop book'),
    ];
    return PbPage(
      kicker: 'Control',
      title: 'Settings',
      subtitle: 'Each control is its own page. The desk cannot open this section.',
      children: [
        for (final page in pages)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, page.$1)),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(page.$2, style: PbText.body(16, weight: FontWeight.w700)),
                        Text(page.$3, style: PbText.body(13, color: PbColors.inkSoft)),
                      ],
                    ),
                  ),
                  const Icon(Icons.arrow_forward_rounded, size: 18),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
