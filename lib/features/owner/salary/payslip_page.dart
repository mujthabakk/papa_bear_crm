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

class PayslipPage extends ConsumerWidget {
  const PayslipPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final matches = state.salaries.where((slip) => slip.id == id);
    if (matches.isEmpty) return const Center(child: Text('Payslip missing'));
    final slip = matches.first;
    final member = state.staffById(slip.staffId);
    final shop = state.shop;
    final number = 'SAL-${slip.month.year}-${slip.month.month.toString().padLeft(2, '0')}-${member?.code ?? '000'}';
    return PbPage(
      kicker: 'Salary slip',
      title: member?.name ?? 'Staff',
      subtitle: '${monthLabel(slip.month)} · $number',
      actions: [
        PbButton(label: 'Back', primary: false, onPressed: () => context.go(rolePath(context, '/salary'))),
        PbButton(label: 'WhatsApp / PDF', onPressed: () => showPbToast(context, 'Share and PDF export sit on this slip in the full build.')),
        if (slip.status.name == 'unpaid')
          PbButton(label: 'Bonus or deduction', primary: false, onPressed: () => _adjust(context, ref)),
      ],
      children: [
        Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 640),
            child: PbCard(
              padding: const EdgeInsets.all(22),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.name, style: PbText.display(28)),
                  Text(state.desk.name, style: PbText.body(14, weight: FontWeight.w700)),
                  Text('${state.desk.address} · ${state.desk.phone}', style: PbText.body(13, color: PbColors.inkSoft)),
                  const SizedBox(height: 8),
                  Text('SALARY SLIP', style: PbText.body(12, weight: FontWeight.w700, letterSpacing: 1.4, color: PbColors.honeyDeep)),
                  const Divider(height: 24),
                  _pair('Role', member?.roleTitle ?? ''),
                  _pair('Joining', member == null ? '' : '${dayLabel(member.joining)} ${member.joining.year}'),
                  _pair('Payment to', member?.upiMasked ?? ''),
                  _pair('Pay type', slip.payKind.label),
                  _pair(_baseLabel(slip), inr(slip.basePay)),
                  const Divider(height: 24),
                  Wrap(
                    spacing: 16,
                    runSpacing: 8,
                    children: [
                      _stat('Working days', '${slip.workingDays}'),
                      _stat('Present', '${slip.present}'),
                      _stat('Half days', '${slip.halfDays}'),
                      _stat('Paid leave', '${slip.paidLeave}'),
                      _stat('Unpaid', '${slip.unpaidLeave}'),
                      _stat('Late', '${slip.lateDays}'),
                      _stat('Overtime', '${slip.overtimeHours.toStringAsFixed(0)} hrs'),
                    ],
                  ),
                  const Divider(height: 24),
                  Text('Earnings', style: PbText.body(13, weight: FontWeight.w700)),
                  _pair(_baseLabel(slip), inr(slip.basePay)),
                  _pair('Overtime', inr(slip.overtimePay)),
                  if (slip.commission > 0 || slip.payKind == PayKind.commissionOnly || slip.payKind == PayKind.salaryPlusCommission)
                    _pair('Commission${slip.commissionPercent == 0 ? '' : ' · ${slip.commissionPercent.toStringAsFixed(0)}%'}', inr(slip.commission)),
                  _pair('Bonus${slip.bonusReason == null ? '' : ' · ${slip.bonusReason}'}', inr(slip.bonus)),
                  const SizedBox(height: 8),
                  Text('Deductions', style: PbText.body(13, weight: FontWeight.w700)),
                  _pair('Unpaid leave and half days', inr(slip.unpaidDeduction)),
                  _pair('Advance recovery', inr(slip.advanceRecovery)),
                  _pair('Other${slip.deductionReason == null ? '' : ' · ${slip.deductionReason}'}', inr(slip.otherDeduction)),
                  const Divider(height: 24),
                  _pair('Gross', inr(slip.gross)),
                  _pair('Deductions', inr(slip.deductions)),
                  const SizedBox(height: 6),
                  Text('NET PAY', style: PbText.body(12, weight: FontWeight.w700, letterSpacing: 1.2)),
                  Text(inr(slip.net), style: PbText.display(36)),
                  Text(rupeesInWords(slip.net), style: PbText.body(13.5, color: PbColors.inkSoft)),
                  const SizedBox(height: 10),
                  Text(
                    slip.paidOn == null
                        ? 'Not paid yet'
                        : 'Paid by ${slip.paidMode} on ${dayLabel(slip.paidOn!)} · Ref ${slip.reference}',
                    style: PbText.body(13),
                  ),
                  Text('Advance balance ${inr(member?.advanceBalance ?? 0)} · Paid leave allowance ${shop.paidLeavePerYear} days / year', style: PbText.body(12.5, color: PbColors.muted)),
                  const SizedBox(height: 14),
                  Text('This is a computer-generated salary slip.', style: PbText.body(12, color: PbColors.muted)),
                  const SizedBox(height: 8),
                  Text('Authorised signature  ____________', style: PbText.body(13)),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _adjust(BuildContext context, WidgetRef ref) {
    var bonus = true;
    final amount = TextEditingController();
    final reason = TextEditingController();
    showPbModal<void>(
      context: context,
      kicker: 'Adjustment',
      title: 'Bonus or deduction',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          return FormBody(
            footer: ModalFooter(
              children: [
                PbButton(
                  label: 'Add to slip',
                  onPressed: () {
                    final error = ref.read(crmProvider.notifier).addSalaryAdjustment(
                      salaryId: id,
                      bonus: bonus,
                      amount: double.tryParse(amount.text) ?? 0,
                      reason: reason.text,
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
                  PbChoice(label: 'Bonus', selected: bonus, onTap: () => setLocal(() => bonus = true)),
                  PbChoice(label: 'Deduction', selected: !bonus, onTap: () => setLocal(() => bonus = false)),
                ],
              ),
              const SizedBox(height: 10),
              PbField(label: 'Amount', controller: amount, number: true),
              const SizedBox(height: 8),
              PbField(label: 'Reason', controller: reason),
            ],
          );
        },
      ),
    );
  }

  String _baseLabel(SalaryDraft slip) {
    return switch (slip.payKind) {
      PayKind.monthly => 'Monthly salary',
      PayKind.daily => 'Daily wage · ${slip.payableDays.toStringAsFixed(slip.payableDays == slip.payableDays.roundToDouble() ? 0 : 1)} days',
      PayKind.hourly => 'Hourly · ${slip.hoursWorked.toStringAsFixed(0)} hrs',
      PayKind.salaryPlusCommission => 'Monthly salary',
      PayKind.commissionOnly => 'Base pay',
    };
  }

  Widget _pair(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Expanded(child: Text(label, style: PbText.body(13.5, color: PbColors.inkSoft))),
          Text(value, style: PbText.body(13.5, weight: FontWeight.w700)),
        ],
      ),
    );
  }

  Widget _stat(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(value, style: PbText.body(16, weight: FontWeight.w700)),
        Text(label, style: PbText.body(11.5, color: PbColors.muted)),
      ],
    );
  }
}
