import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';

class StaffDetailPage extends ConsumerWidget {
  const StaffDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final member = state.staffById(id);
    if (member == null) return const Center(child: Text('Staff member missing'));
    final slips = state.salaries.where((slip) => slip.staffId == id).toList();
    return PbPage(
      kicker: member.code,
      title: member.name,
      subtitle: '${member.roleTitle} · joined ${dayLabel(member.joining)} ${member.joining.year} · ${member.phone}',
      actions: [
        PbButton(label: 'Back', primary: false, onPressed: () => context.go(rolePath(context, '/staff'))),
        PbButton(
          label: member.active ? 'Mark inactive' : 'Reactivate',
          onPressed: () => ref.read(crmProvider.notifier).setStaffActive(id, !member.active),
        ),
      ],
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: 180, child: MetricTile(label: 'Monthly salary', value: inr(member.monthlySalary))),
            SizedBox(width: 180, child: MetricTile(label: 'Advance balance', value: inr(member.advanceBalance))),
            SizedBox(width: 180, child: MetricTile(label: 'Hours', value: '${member.startHour}:00–${member.endHour}:00')),
          ],
        ),
        const SizedBox(height: 12),
        Text('Payment to ${member.upiMasked}', style: PbText.body(14, color: PbColors.inkSoft)),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final skill in member.skills)
              PbPill(label: skill, background: PbColors.cream, foreground: PbColors.ink),
          ],
        ),
        const SizedBox(height: 16),
        Text('Salary rows', style: PbText.display(22)),
        const SizedBox(height: 8),
        for (final slip in slips)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '/salary/${slip.id}')),
              child: Row(
                children: [
                  Expanded(child: Text('${monthLabel(slip.month)} · ${slip.status.label}', style: PbText.body(14, weight: FontWeight.w600))),
                  Text(inr(slip.net), style: PbText.body(14, weight: FontWeight.w700)),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
