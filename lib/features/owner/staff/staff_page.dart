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

class StaffPage extends ConsumerStatefulWidget {
  const StaffPage({super.key});

  @override
  ConsumerState<StaffPage> createState() => _StaffPageState();
}

class _StaffPageState extends ConsumerState<StaffPage> {
  String _filter = 'Active';

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(crmProvider.select((state) => state.staff));
    final rows = staff.where((member) {
      if (_filter == 'Active') return member.active;
      if (_filter == 'Inactive') return !member.active;
      return true;
    }).toList();
    return PbPage(
      kicker: 'Owner',
      title: 'Staff',
      subtitle: 'Records, salary and skills. People who have left stay here, marked inactive.',
      actions: [
        PbButton(label: 'Add staff', onPressed: () => _add(context)),
      ],
      children: [
        Wrap(
          spacing: 8,
          children: [
            for (final filter in ['Active', 'Inactive', 'All'])
              PbChoice(label: filter, selected: _filter == filter, onTap: () => setState(() => _filter = filter)),
          ],
        ),
        const SizedBox(height: 12),
        PbSearch(
          hint: 'Search name, code or role',
          results: (query) {
            final visible = rows.where((member) {
              final haystack = '${member.name} ${member.code} ${member.roleTitle} ${member.payKind.label}'.toLowerCase();
              return query.isEmpty || haystack.contains(query);
            }).toList();
            if (visible.isEmpty) return Text('No staff match that search.', style: PbText.body(14, color: PbColors.muted));
            return Column(children: [for (final member in visible) _staffCard(context, member)]);
          },
        ),
      ],
    );
  }

  Widget _staffCard(BuildContext context, StaffMember member) {
    final pay = switch (member.payKind) {
      PayKind.monthly => '${inr(member.monthlySalary)} / month',
      PayKind.daily => '${inr(member.dailyRate)} / day',
      PayKind.hourly => '${inr(member.hourlyRate)} / hour',
      PayKind.salaryPlusCommission => '${inr(member.monthlySalary)} + ${member.commissionPercent.toStringAsFixed(0)}%',
      PayKind.commissionOnly => '${member.commissionPercent.toStringAsFixed(0)}% commission',
    };
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: PbCard(
        onTap: () => context.go(rolePath(context, '/staff/${member.id}')),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('${member.name} · ${member.code}', style: PbText.body(15, weight: FontWeight.w700)),
                  Text(
                    '${member.roleTitle} · ${member.payKind.label} · $pay · ${member.active ? member.today.label : 'Inactive'}',
                    style: PbText.body(12.5, color: PbColors.muted),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_rounded, size: 18),
          ],
        ),
      ),
    );
  }

  void _add(BuildContext context) {
    final name = TextEditingController();
    final phone = TextEditingController();
    final role = TextEditingController(text: 'Stylist');
    final salary = TextEditingController();
    final upi = TextEditingController();
    final skills = <String>{};
    showPbModal<void>(
      context: context,
      kicker: 'New staff',
      title: 'Add someone to the floor',
      child: Consumer(
        builder: (context, ref, _) {
          final services = ref.watch(crmProvider.select((state) => state.services));
          return StatefulBuilder(
            builder: (context, setLocal) {
              return FormBody(
                footer: ModalFooter(
                  children: [
                    PbButton(
                      label: 'Save staff',
                      onPressed: () {
                        final error = ref.read(crmProvider.notifier).addStaff(
                          name: name.text,
                          phone: phone.text,
                          roleTitle: role.text,
                          salary: double.tryParse(salary.text) ?? 0,
                          upi: upi.text,
                          skills: skills.toList(),
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
                  PbField(label: 'Name', controller: name),
                  const SizedBox(height: 8),
                  PbField(label: 'Phone', controller: phone),
                  const SizedBox(height: 8),
                  PbField(label: 'Role', controller: role),
                  const SizedBox(height: 8),
                  PbField(label: 'Monthly salary', controller: salary, number: true),
                  const SizedBox(height: 8),
                  PbField(label: 'UPI or bank note', controller: upi, hint: 'Stored masked on the payslip'),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final service in services)
                        PbChoice(
                          label: service.name,
                          selected: skills.contains(service.name),
                          onTap: () => setLocal(() {
                            if (!skills.add(service.name)) skills.remove(service.name);
                          }),
                        ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
