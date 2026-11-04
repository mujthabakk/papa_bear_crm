import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

class ActivityPage extends ConsumerWidget {
  const ActivityPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activity = ref.watch(crmProvider.select((state) => state.activity));
    return PbPage(
      kicker: 'Who did what',
      title: 'Activity',
      subtitle: 'Bills, cash, stock, attendance, leave, branch switches and overrides land here. The desk cannot open this log.',
      children: [
        for (final entry in activity)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 10,
                  height: 10,
                  margin: const EdgeInsets.only(top: 6),
                  decoration: const BoxDecoration(color: PbColors.honey, shape: BoxShape.circle),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: PbCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(entry.action, style: PbText.body(14.5, weight: FontWeight.w600)),
                        const SizedBox(height: 4),
                        Text(
                          [
                            if (entry.branchName.isNotEmpty) entry.branchName,
                            entry.actor,
                            entry.roleLabel,
                            '${dayLabel(entry.at)} ${clock(entry.at)}',
                          ].join(' · '),
                          style: PbText.body(12.5, color: PbColors.muted),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}
