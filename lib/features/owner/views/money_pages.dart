import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/data/mock/crm_state.dart';
import 'package:papa_bear_crm/features/owner/reports/report_catalog.dart';

class SalesPage extends ConsumerWidget {
  const SalesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RowsPage(
      kicker: 'Owner',
      title: 'Sales',
      subtitle: 'Today, this month, by service, product, staff and payment mode.',
      ids: const ['daily-sales', 'monthly-sales', 'service-sales', 'product-sales', 'staff-sales', 'payment-mode', 'discounts', 'pending-dues'],
      state: ref.watch(crmProvider),
    );
  }
}

class ExpensesPage extends ConsumerWidget {
  const ExpensesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RowsPage(
      kicker: 'Owner',
      title: 'Expenses',
      subtitle: 'Cash leaving the shop, grouped by the categories you set.',
      ids: const ['expenses', 'cashbook'],
      state: ref.watch(crmProvider),
    );
  }
}

class ProfitPage extends ConsumerWidget {
  const ProfitPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return _RowsPage(
      kicker: 'Owner',
      title: 'Simple profit',
      subtitle: 'Sales minus expenses, stock purchases and salaries paid this month.',
      ids: const ['profit'],
      state: ref.watch(crmProvider),
    );
  }
}

class _RowsPage extends StatelessWidget {
  const _RowsPage({
    required this.kicker,
    required this.title,
    required this.subtitle,
    required this.ids,
    required this.state,
  });

  final String kicker;
  final String title;
  final String subtitle;
  final List<String> ids;
  final CrmState state;

  @override
  Widget build(BuildContext context) {
    return PbPage(
      kicker: kicker,
      title: title,
      subtitle: subtitle,
      children: [
        for (final id in ids) ...[
          Text(
            reportCatalog.firstWhere((report) => report.id == id).title,
            style: PbText.display(22),
          ),
          const SizedBox(height: 8),
          for (final row in reportRows(id, state))
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: PbCard(
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(row.title, style: PbText.body(14.5, weight: FontWeight.w600)),
                          if (row.meta.isNotEmpty) Text(row.meta, style: PbText.body(12.5, color: PbColors.muted)),
                        ],
                      ),
                    ),
                    Text(row.value, style: PbText.body(14, weight: FontWeight.w700)),
                  ],
                ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ],
    );
  }
}
