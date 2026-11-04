import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/receptionist/cash/cash_modal.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class CashPage extends ConsumerWidget {
  const CashPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final manual = state.cashEntries.where((entry) => sameDay(entry.at, shopNow())).toList();
    final billCash = state.todayBills.where((bill) => bill.tender.cash > 0);
    return PbPage(
      kicker: state.dayClosed ? 'Day closed' : 'Live drawer',
      title: inr(state.expectedCash),
      subtitle: 'Opening ${inr(state.openingCash)} + cash sales ${inr(state.cashFromBillsToday)} + other in ${inr(state.manualInToday)} − cash out ${inr(state.manualOutToday)}.',
      actions: [
        PbButton(label: 'Cash in', primary: false, onPressed: state.dayClosed ? null : () => showCashModal(context, CashKind.cashIn)),
        PbButton(label: 'Cash out', primary: false, onPressed: state.dayClosed ? null : () => showCashModal(context, CashKind.cashOut)),
        PbButton(label: 'Day close', onPressed: () => context.go(rolePath(context, '/cash/day-close'))),
      ],
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 200, child: MetricTile(label: 'UPI today', value: inr(state.upiToday))),
            SizedBox(width: 200, child: MetricTile(label: 'Card today', value: inr(state.cardToday))),
            SizedBox(width: 200, child: MetricTile(label: 'Cash sales', value: inr(state.cashFromBillsToday))),
          ],
        ),
        const SizedBox(height: 16),
        Text('Drawer movement', style: PbText.display(22)),
        const SizedBox(height: 10),
        for (final bill in billCash)
          _row('Bill ${bill.number} · ${bill.customerName}', inr(bill.tender.cash), true, clock(bill.at)),
        for (final entry in manual)
          _row('${entry.category} · ${entry.reason}', inr(entry.amount), entry.kind == CashKind.cashIn, clock(entry.at)),
      ],
    );
  }

  Widget _row(String title, String amount, bool incoming, String time) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PbCard(
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: PbText.body(14.5, weight: FontWeight.w600)),
                  Text(time, style: PbText.body(12, color: PbColors.muted)),
                ],
              ),
            ),
            Text(
              '${incoming ? '+' : '−'}$amount',
              style: PbText.body(15, weight: FontWeight.w700, color: incoming ? PbColors.moss : PbColors.clay),
            ),
          ],
        ),
      ),
    );
  }
}
