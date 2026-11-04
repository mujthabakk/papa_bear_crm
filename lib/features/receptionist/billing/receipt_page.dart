import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class ReceiptPage extends ConsumerWidget {
  const ReceiptPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final matches = state.bills.where((bill) => bill.id == id);
    if (matches.isEmpty) {
      return const Center(child: Text('This bill is not in the day book.'));
    }
    final bill = matches.first;
    final shop = state.shop;
    return PbPage(
      kicker: 'Customer bill',
      title: bill.number,
      subtitle: 'Share on WhatsApp or print. Tax lines stay off until GST billing is turned on.',
      actions: [
        PbButton(
          label: 'Back',
          primary: false,
          onPressed: () => context.canPop() ? context.pop() : context.go(rolePath(context, '/bills')),
        ),
        PbButton(label: 'Share on WhatsApp', onPressed: () => showPbToast(context, 'WhatsApp share is ready in the full build. This preview keeps the bill on screen.')),
        if (state.session?.isOwner == true && !bill.voided)
          PbButton(
            label: 'Void bill',
            primary: false,
            onPressed: () {
              final error = ref.read(crmProvider.notifier).voidBill(bill.id);
              showPbToast(context, error ?? 'Bill voided');
            },
          ),
      ],
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 520),
            child: PbCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: PbText.display(28)),
                  Text(state.desk.name, style: PbText.body(14, weight: FontWeight.w700)),
                  Text('${state.desk.address} · ${state.desk.phone}', style: PbText.body(13, color: PbColors.inkSoft)),
                  const SizedBox(height: 12),
                  Text('${fullDate(bill.at)} · ${clock(bill.at)}', style: PbText.body(13)),
                  Text('${bill.customerName} · ${bill.phone}', style: PbText.body(15, weight: FontWeight.w600)),
                  Text(bill.source.label, style: PbText.body(12.5, color: PbColors.muted)),
                  const Divider(height: 28),
                  for (final line in bill.lines)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 8),
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(line.name, style: PbText.body(14, weight: FontWeight.w600)),
                                Text('${line.staffName} · ${line.qty}', style: PbText.body(12, color: PbColors.muted)),
                              ],
                            ),
                          ),
                          Text(inr(line.amount), style: PbText.body(14)),
                        ],
                      ),
                    ),
                  const Divider(height: 28),
                  _row('Subtotal', inr(bill.subtotal)),
                  _row('Discount', inr(bill.discount)),
                  _row('Total', inr(bill.total), strong: true),
                  _row('Paid · ${bill.tender.summary}', inr(bill.tender.total)),
                  if (bill.balance > 1) _row('Balance', inr(bill.balance)),
                  const SizedBox(height: 16),
                  Text('Thank you for visiting ${shop.name}.', style: PbText.body(13, color: PbColors.inkSoft)),
                  if (bill.voided) ...[
                    const SizedBox(height: 8),
                    const PbPill(label: 'Voided', background: PbColors.claySoft, foreground: PbColors.clay),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _row(String label, String value, {bool strong = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: PbText.body(14, weight: strong ? FontWeight.w700 : FontWeight.w400))),
          Text(value, style: strong ? PbText.display(22) : PbText.body(14, weight: FontWeight.w600)),
        ],
      ),
    );
  }
}
