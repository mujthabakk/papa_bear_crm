import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/features/owner/reports/report_catalog.dart';

const receptionReportIds = [
  'daily-sales',
  'pending-dues',
  'today-bookings',
  'cashbook',
  'day-close',
  'current-stock',
  'low-stock',
  'daily-attendance',
  'leave-report',
];

class TodayPage extends ConsumerWidget {
  const TodayPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final reports = reportCatalog.where((report) => receptionReportIds.contains(report.id));
    return PbPage(
      kicker: 'Reception',
      title: 'Today',
      subtitle: 'The desk sees today’s numbers only. Month totals, salary and the activity log stay with the owner.',
      children: [
        for (final report in reports)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '/today/${report.id}')),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(report.title, style: PbText.body(15, weight: FontWeight.w700)),
                        Text(report.blurb, style: PbText.body(13, color: PbColors.inkSoft)),
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
