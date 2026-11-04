import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class CustomerPage extends ConsumerWidget {
  const CustomerPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final matches = state.customers.where((customer) => customer.id == id);
    if (matches.isEmpty) return const Center(child: Text('Customer not found'));
    final customer = matches.first;
    final visits = state.bills.where((bill) => bill.phone == customer.phone && !bill.voided).toList();
    return PbPage(
      kicker: customer.gender ?? 'Customer',
      title: customer.name,
      subtitle: customer.phone,
      actions: [
        PbButton(label: 'Back', primary: false, onPressed: () => context.go(rolePath(context, '/customers'))),
      ],
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 160, child: MetricTile(label: 'Visits', value: '${customer.visits}')),
            SizedBox(width: 160, child: MetricTile(label: 'Spent', value: inr(customer.spend))),
            SizedBox(
              width: 180,
              child: MetricTile(label: 'First visit', value: customer.firstVisit == null ? '—' : dayLabel(customer.firstVisit!)),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Text('Visit history', style: PbText.display(22)),
        const SizedBox(height: 8),
        for (final bill in visits)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '/bills/${bill.id}')),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(bill.lines.map((line) => line.name).join(', '), style: PbText.body(14, weight: FontWeight.w600)),
                        Text('${dayLabel(bill.at)} · ${bill.lines.map((line) => line.staffName).toSet().join(', ')}', style: PbText.body(12.5, color: PbColors.muted)),
                      ],
                    ),
                  ),
                  Text(inr(bill.total), style: PbText.body(14, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
