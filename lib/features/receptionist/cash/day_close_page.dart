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

class DayClosePage extends ConsumerStatefulWidget {
  const DayClosePage({super.key});

  @override
  ConsumerState<DayClosePage> createState() => _DayClosePageState();
}

class _DayClosePageState extends ConsumerState<DayClosePage> {
  final _counted = TextEditingController();

  @override
  void dispose() {
    _counted.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);
    final outs = state.cashEntries.where((e) => e.kind.name == 'cashOut' && sameDay(e.at, shopNow()));
    final outText = outs.isEmpty ? 'None' : outs.map((e) => '${e.reason} ${inr(e.amount)}').join(', ');
    return PbPage(
      kicker: 'Day close · ${dayLabel(shopNow())}',
      title: 'Count the drawer',
      subtitle: 'The owner gets this summary. In this preview the WhatsApp send stays on the screen.',
      actions: [
        PbButton(label: 'Back to cash', primary: false, onPressed: () => context.go(rolePath(context, '/cash'))),
      ],
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 560),
            child: PbCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(state.shop.name, style: PbText.display(26)),
                  Text('${state.desk.name} · ${state.desk.address}', style: PbText.body(13, color: PbColors.inkSoft)),
                  const SizedBox(height: 12),
                  _line('Customers on the board', '${state.todayBookings.length}'),
                  _line('Total sales', inr(state.todaySales)),
                  _line('Cash / UPI / Card', '${inr(state.cashFromBillsToday)} / ${inr(state.upiToday)} / ${inr(state.cardToday)}'),
                  _line('Opening cash', inr(state.openingCash)),
                  _line('Cash sales', inr(state.cashFromBillsToday)),
                  _line('Other cash in', inr(state.manualInToday)),
                  _line('Cash out', inr(state.manualOutToday)),
                  Text(outText, style: PbText.body(12.5, color: PbColors.muted)),
                  const Divider(height: 24),
                  _line('Expected cash in hand', inr(state.expectedCash)),
                  _line('Staff present / absent / leave', '${state.presentCount} / ${state.absentCount} / ${state.leaveCount}'),
                  _line('Low stock items', '${state.lowStock.length}'),
                  const SizedBox(height: 12),
                  PbField(label: 'Actual cash counted', controller: _counted, number: true, hint: 'Count the notes'),
                  if (state.cashDifference != null) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Difference ${inr(state.cashDifference!)}',
                      style: PbText.body(14, weight: FontWeight.w700, color: state.cashDifference == 0 ? PbColors.moss : PbColors.clay),
                    ),
                  ],
                  const SizedBox(height: 14),
                  PbButton(
                    label: state.dayClosed ? 'Day is locked' : 'Close the day',
                    expand: true,
                    onPressed: state.dayClosed
                        ? null
                        : () {
                            final error = ref.read(crmProvider.notifier).closeDay(double.tryParse(_counted.text) ?? -1);
                            showPbToast(context, error ?? 'Day closed. Summary is ready for the owner.');
                          },
                  ),
                  if (state.dayClosed && state.session?.isOwner == true) ...[
                    const SizedBox(height: 8),
                    PbButton(
                      label: 'Unlock day',
                      primary: false,
                      expand: true,
                      onPressed: () {
                        ref.read(crmProvider.notifier).unlockDay();
                        showPbToast(context, 'Day unlocked');
                      },
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _line(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Expanded(child: Text(label, style: PbText.body(14, color: PbColors.inkSoft))),
          Text(value, style: PbText.body(14, weight: FontWeight.w700)),
        ],
      ),
    );
  }
}
