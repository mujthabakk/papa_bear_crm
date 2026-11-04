import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class CustomersPage extends ConsumerStatefulWidget {
  const CustomersPage({super.key});

  @override
  ConsumerState<CustomersPage> createState() => _CustomersPageState();
}

class _CustomersPageState extends ConsumerState<CustomersPage> {
  final _query = TextEditingController();

  @override
  void dispose() {
    _query.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final customers = ref.watch(crmProvider.select((state) => state.customers));
    final q = _query.text.trim().toLowerCase();
    final rows = customers.where((c) => q.isEmpty || c.name.toLowerCase().contains(q) || c.phone.contains(digits(q))).toList();
    return PbPage(
      kicker: 'People who visit',
      title: 'Customers',
      subtitle: 'Search by name or phone. Repeat visits fill in on the next bill.',
      children: [
        TextField(
          controller: _query,
          onChanged: (_) => setState(() {}),
          decoration: const InputDecoration(hintText: 'Search name or phone'),
        ),
        const SizedBox(height: 12),
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
  }
}
