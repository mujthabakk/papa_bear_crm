import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class CustomersPage extends ConsumerWidget {
  const CustomersPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final customers = ref.watch(crmProvider.select((state) => state.customers));
    return PbPage(
      kicker: 'People who visit',
      title: 'Customers',
      subtitle: 'Search by name or phone. Repeat visits fill in on the next bill.',
      children: [
        PbSearch(
          hint: 'Search name or phone',
          results: (query) {
            final rows = customers.where((customer) => query.isEmpty || customer.name.toLowerCase().contains(query) || customer.phone.contains(digits(query))).toList();
            if (rows.isEmpty) return Text('No customers match that search.', style: PbText.body(14, color: PbColors.muted));
            return Column(
              children: [
                for (final customer in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '/customers/${customer.id}')),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(customer.name, style: PbText.body(15, weight: FontWeight.w700)),
                        Text(
                          '${customer.phone} · ${customer.visits} visits · last ${customer.lastVisit == null ? '—' : dayLabel(customer.lastVisit!)}',
                          style: PbText.body(12.5, color: PbColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(inr(customer.spend), style: PbText.body(14, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
              ],
            );
          },
        ),
      ],
    );
  }
}
