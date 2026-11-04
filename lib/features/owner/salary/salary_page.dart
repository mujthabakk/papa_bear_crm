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
import 'package:papa_bear_crm/data/mock/crm_state.dart';
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
      subtitle: 'Monthly, daily, hourly, salary plus commission, or commission only. Create a slip for the month you are looking at.',
      actions: [
        PbButton(label: 'Create payroll', icon: Icons.add_rounded, onPressed: () => _create(context)),
        PbChoice(label: monthLabel(DateTime(shopNow().year, shopNow().month)), selected: sameMonth(_month, shopNow()), onTap: () => setState(() => _month = DateTime(shopNow().year, shopNow().month))),
        PbChoice(label: monthLabel(previous), selected: sameMonth(_month, previous), onTap: () => setState(() => _month = previous)),
      ],
      children: [
        PbSearch(
          hint: 'Search staff or pay type',
          results: (query) {
            final visible = rows.where((slip) {
              final name = state.staffById(slip.staffId)?.name.toLowerCase() ?? '';
              return query.isEmpty || name.contains(query) || slip.payKind.label.toLowerCase().contains(query);
            }).toList();
            if (visible.isEmpty) {
              return Text('No slips for this search.', style: PbText.body(14, color: PbColors.muted));
            }
            return Column(
              children: [
                for (final slip in visible) _slipCard(context, state, slip),
              ],
            );
          },
        ),
      ],
    );
  }

  Widget _slipCard(BuildContext context, CrmState state, SalaryDraft slip) {
    return Padding(
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
                    '${slip.payKind.label} · gross ${inr(slip.gross)} · ${slip.status.label}',
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
    );
  }

  void _create(BuildContext context) {
    final state = ref.read(crmProvider);
    final people = state.activeStaff;
    if (people.isEmpty) {
      showPbToast(context, 'Add staff before creating payroll.');
      return;
    }
    var staffId = people.first.id;
    var kind = people.first.payKind;
    final monthly = TextEditingController(text: people.first.monthlySalary == 0 ? '' : people.first.monthlySalary.toStringAsFixed(0));
    final daily = TextEditingController(text: people.first.dailyRate == 0 ? '' : people.first.dailyRate.toStringAsFixed(0));
    final hourly = TextEditingController(text: people.first.hourlyRate == 0 ? '' : people.first.hourlyRate.toStringAsFixed(0));
    final hours = TextEditingController(text: '48');
    final days = TextEditingController(text: '2');
    final percent = TextEditingController(text: people.first.commissionPercent == 0 ? '10' : people.first.commissionPercent.toStringAsFixed(0));
    showPbModal<void>(
      context: context,
      kicker: 'Payroll',
      title: 'Create a salary',
      subtitle: 'Pick how this person is paid. Commission uses their service sales in ${monthLabel(_month)}.',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          void pick(String id) {
            final person = people.firstWhere((member) => member.id == id);
            staffId = id;
            kind = person.payKind;
            monthly.text = person.monthlySalary == 0 ? '' : person.monthlySalary.toStringAsFixed(0);
            daily.text = person.dailyRate == 0 ? '' : person.dailyRate.toStringAsFixed(0);
            hourly.text = person.hourlyRate == 0 ? '' : person.hourlyRate.toStringAsFixed(0);
            percent.text = person.commissionPercent == 0 ? '10' : person.commissionPercent.toStringAsFixed(0);
            setLocal(() {});
          }

          final needsMonthly = kind == PayKind.monthly || kind == PayKind.salaryPlusCommission;
          final needsPercent = kind == PayKind.salaryPlusCommission || kind == PayKind.commissionOnly;
          return FormBody(
            footer: ModalFooter(
              children: [
                PbButton(
                  label: 'Save payroll',
                  onPressed: () {
                    final error = ref.read(crmProvider.notifier).createPayroll(
                      staffId: staffId,
                      month: _month,
                      kind: kind,
                      monthly: double.tryParse(monthly.text) ?? 0,
                      dailyRate: double.tryParse(daily.text) ?? 0,
                      hourlyRate: double.tryParse(hourly.text) ?? 0,
                      hoursWorked: double.tryParse(hours.text) ?? 0,
                      presentDays: int.tryParse(days.text) ?? 0,
                      commissionPercent: double.tryParse(percent.text) ?? 0,
                    );
                    if (error != null) {
                      showPbToast(context, error);
                      return;
                    }
                    Navigator.pop(context);
                    showPbToast(context, 'Payroll saved for ${monthLabel(_month)}');
                  },
                ),
              ],
            ),
            children: [
              Text('Staff', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final person in people)
                    PbChoice(label: person.name, selected: staffId == person.id, onTap: () => pick(person.id)),
                ],
              ),
              const SizedBox(height: 12),
              Text('Pay type', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
              const SizedBox(height: 6),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final option in PayKind.values)
                    PbChoice(label: option.label, selected: kind == option, onTap: () => setLocal(() => kind = option)),
                ],
              ),
              const SizedBox(height: 12),
              if (needsMonthly) ...[
                PbField(label: 'Monthly salary', controller: monthly, number: true),
                const SizedBox(height: 8),
              ],
              if (kind == PayKind.daily) ...[
                PbField(label: 'Daily wage', controller: daily, number: true),
                const SizedBox(height: 8),
                PbField(label: 'Days worked this month', controller: days, number: true),
                const SizedBox(height: 8),
              ],
              if (kind == PayKind.hourly) ...[
                PbField(label: 'Hourly rate', controller: hourly, number: true),
                const SizedBox(height: 8),
                PbField(label: 'Hours worked this month', controller: hours, number: true),
                const SizedBox(height: 8),
              ],
              if (needsPercent) PbField(label: 'Commission percent', controller: percent, number: true, hint: 'Taken from their service sales'),
            ],
          );
        },
      ),
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
