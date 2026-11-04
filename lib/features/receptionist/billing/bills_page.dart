import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/receptionist/billing/bill_modal.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class BillsPage extends ConsumerWidget {
  const BillsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final bills = state.bills.where((bill) => sameDay(bill.at, shopNow()) || sameMonth(bill.at, shopNow())).take(30).toList();
    return PbPage(
      kicker: 'Sales',
      title: 'Bills',
      subtitle: state.session?.isOwner == true
          ? 'You can void a saved bill. The desk cannot edit or delete one.'
          : 'Saved bills stay locked. Ask the owner if something must be voided.',
      actions: [
        PbButton(label: 'New bill', icon: Icons.add_rounded, onPressed: () => showBillModal(context)),
      ],
      children: [
        for (final bill in bills)
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
                        Text('${bill.number} · ${bill.customerName}', style: PbText.body(15, weight: FontWeight.w600, color: bill.voided ? PbColors.muted : PbColors.ink)),
                        Text(
                          '${dayLabel(bill.at)} ${clock(bill.at)} · ${bill.source.label} · ${bill.tender.summary}',
                          style: PbText.body(12.5, color: PbColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(inr(bill.total), style: PbText.body(15, weight: FontWeight.w700)),
                      if (bill.voided)
                        const PbPill(label: 'Void', background: PbColors.claySoft, foreground: PbColors.clay)
                      else if (bill.balance > 1)
                        PbPill(label: 'Due ${inr(bill.balance)}', background: PbColors.tideSoft, foreground: PbColors.tide),
                    ],
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
