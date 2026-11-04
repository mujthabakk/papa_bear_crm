import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class SalaryPage extends ConsumerStatefulWidget {
  const SalaryPage({super.key});

  @override
  ConsumerState<SalaryPage> createState() => _SalaryPageState();
}

class _SalaryPageState extends ConsumerState<SalaryPage> {
  late DateTime _month = DateTime(shopNow().year, shopNow().month);

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);
    final previous = DateTime(shopNow().year, shopNow().month - 1);
    final rows = state.salaries.where((slip) => sameMonth(slip.month, _month)).toList();
    return PbPage(
      kicker: 'Payroll',
      title: 'Salary',
      subtitle: 'Calculated from attendance, leave and advances. Add a bonus or deduction, then mark paid.',
      actions: [
        PbChoice(label: monthLabel(DateTime(shopNow().year, shopNow().month)), selected: sameMonth(_month, shopNow()), onTap: () => setState(() => _month = DateTime(shopNow().year, shopNow().month))),
        PbChoice(label: monthLabel(previous), selected: sameMonth(_month, previous), onTap: () => setState(() => _month = previous)),
      ],
      children: [
        for (final slip in rows)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(state.staffById(slip.staffId)?.name ?? 'Staff', style: PbText.body(15, weight: FontWeight.w700)),
                        Text(
                          'Gross ${inr(slip.gross)} · deductions ${inr(slip.deductions)} · ${slip.status.label}',
                          style: PbText.body(12.5, color: PbColors.muted),
                        ),
                      ],
                    ),
                  ),
                  Text(inr(slip.net), style: PbText.body(16, weight: FontWeight.w700)),
                  const SizedBox(width: 8),
                  PbButton(label: 'Slip', primary: false, onPressed: () => context.go(rolePath(context, '/salary/${slip.id}'))),
                  if (slip.status == SalaryStatus.unpaid) ...[
                    const SizedBox(width: 8),
                    PbButton(label: 'Pay', onPressed: () => _pay(context, slip)),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _pay(BuildContext context, SalaryDraft slip) {
    var mode = 'UPI';
    final reference = TextEditingController();
    showPbModal<void>(
      context: context,
      kicker: 'Mark paid',
      title: 'Pay ${inr(slip.net)}',
      subtitle: 'Cash payments leave the drawer. UPI and bank do not.',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          return FormBody(
            footer: ModalFooter(
              children: [
                PbButton(
                  label: 'Confirm payment',
                  onPressed: () {
                    final error = ref.read(crmProvider.notifier).markSalaryPaid(
                      salaryId: slip.id,
                      mode: mode,
                      reference: reference.text,
                    );
                    if (error != null) {
                      showPbToast(context, error);
                      return;
                    }
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
            children: [
              Wrap(
                spacing: 8,
                children: [
                  for (final option in ['Cash', 'UPI', 'Bank'])
                    PbChoice(label: option, selected: mode == option, onTap: () => setLocal(() => mode = option)),
                ],
              ),
              const SizedBox(height: 12),
              PbField(label: 'Reference', controller: reference, hint: 'UPI ref or note'),
            ],
          );
        },
      ),
    );
  }
}
