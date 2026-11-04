import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/features/owner/reports/report_catalog.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class ReportsPage extends StatelessWidget {
  const ReportsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final groups = reportCatalog.map((report) => report.group).toSet().toList();
    return PbPage(
      kicker: '${reportCatalog.length} reports',
      title: 'Reports',
      subtitle: 'Filter in your head for today, this week or this month. Excel and PDF export is the next build step — every report already has its layout.',
      children: [
        for (final group in groups) ...[
          Text(group, style: PbText.display(22)),
          const SizedBox(height: 8),
          LayoutBuilder(
            builder: (context, constraints) {
              final columns = constraints.maxWidth > 900 ? 3 : constraints.maxWidth > 560 ? 2 : 1;
              final width = (constraints.maxWidth - (columns - 1) * 12) / columns;
              final items = reportCatalog.where((report) => report.group == group);
              return Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final report in items)
                    SizedBox(
                      width: width,
                      child: PbCard(
                        onTap: () => context.go(rolePath(context, '/reports/${report.id}')),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(report.title, style: PbText.body(16, weight: FontWeight.w700)),
                            const SizedBox(height: 4),
                            Text(report.blurb, style: PbText.body(13, color: PbColors.inkSoft)),
                          ],
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          const SizedBox(height: 16),
        ],
      ],
    );
  }
}
