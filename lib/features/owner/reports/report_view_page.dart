import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/owner/reports/report_catalog.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class ReportViewPage extends ConsumerWidget {
  const ReportViewPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final matches = reportCatalog.where((report) => report.id == id);
    if (matches.isEmpty) return const Center(child: Text('Unknown report'));
    final report = matches.first;
    final rows = reportRows(id, state);
    return PbPage(
      kicker: report.group,
      title: report.title,
      subtitle: report.blurb,
      actions: [
        PbButton(
          label: GoRouterState.of(context).uri.path.contains('/today/') ? 'Today' : 'All reports',
          primary: false,
          onPressed: () => context.go(
            rolePath(context, GoRouterState.of(context).uri.path.contains('/today/') ? '/today' : '/reports'),
          ),
        ),
        PbButton(label: 'Excel', primary: false, onPressed: () => showPbToast(context, 'Excel download is wired in the next stage. The rows below are the export.')),
        PbButton(label: 'PDF', onPressed: () => showPbToast(context, 'PDF download is wired in the next stage. The rows below are the export.')),
      ],
      children: [
        Wrap(
          spacing: 8,
          children: const [
            PbPill(label: 'Today', background: PbColors.ink, foreground: PbColors.cream),
            PbPill(label: 'This month', background: PbColors.cream, foreground: PbColors.inkSoft),
            PbPill(label: 'Custom dates', background: PbColors.cream, foreground: PbColors.inkSoft),
          ],
        ),
        const SizedBox(height: 12),
        for (final row in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(row.title, style: PbText.body(15, weight: FontWeight.w600)),
                        if (row.meta.isNotEmpty) Text(row.meta, style: PbText.body(12.5, color: PbColors.muted)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 12),
                  Flexible(child: Text(row.value, textAlign: TextAlign.right, style: PbText.body(14, weight: FontWeight.w700))),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
