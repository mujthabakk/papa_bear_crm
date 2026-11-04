import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

void showLeaveModal(BuildContext context) {
  showPbModal<void>(
    context: context,
    kicker: 'Leave request',
    title: 'Ask for leave',
    subtitle: 'The receptionist enters it. The owner approves or rejects.',
    child: const LeaveForm(),
  );
}

class LeavePage extends ConsumerWidget {
  const LeavePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    return PbPage(
      kicker: 'People',
      title: 'Leave',
      subtitle: 'Approved leave marks attendance on its own. Pending requests stay visible at the desk.',
      actions: [
        PbButton(label: 'New request', onPressed: () => showLeaveModal(context)),
      ],
      children: [
        PbSearch(
          hint: 'Search staff or reason',
          results: (query) {
            final visible = state.leaves.where((leave) {
              final name = state.staffById(leave.staffId)?.name.toLowerCase() ?? '';
              return query.isEmpty || name.contains(query) || leave.reason.toLowerCase().contains(query) || leave.type.label.toLowerCase().contains(query);
            }).toList();
            if (visible.isEmpty) return Text('No leave matches that search.', style: PbText.body(14, color: PbColors.muted));
            return Column(
              children: [
                for (final leave in visible)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '/leave/${leave.id}')),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          state.staffById(leave.staffId)?.name ?? 'Staff',
                          style: PbText.body(16, weight: FontWeight.w600),
                        ),
                      ),
                      PbPill(
                        label: leave.status.label,
                        background: switch (leave.status) {
                          LeaveStatus.pending => PbColors.cream,
                          LeaveStatus.approved => PbColors.mossSoft,
                          LeaveStatus.rejected => PbColors.claySoft,
                        },
                        foreground: switch (leave.status) {
                          LeaveStatus.pending => PbColors.honeyDeep,
                          LeaveStatus.approved => PbColors.moss,
                          LeaveStatus.rejected => PbColors.clay,
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${leave.type.label}${leave.halfDay ? ' · half day' : ''} · ${dayLabel(leave.from)} to ${dayLabel(leave.to)}',
                    style: PbText.body(13, color: PbColors.inkSoft),
                  ),
                  Text(leave.reason, style: PbText.body(13.5)),
                  if (leave.decisionNote != null)
                    Text(leave.decisionNote!, style: PbText.body(12.5, color: PbColors.muted)),
                ],
              ),
            ),
          ),
              ],
            );
          },
        ),
      ],
    );
  }

}

class LeaveForm extends ConsumerStatefulWidget {
  const LeaveForm({super.key});

  @override
  ConsumerState<LeaveForm> createState() => _LeaveFormState();
}

class _LeaveFormState extends ConsumerState<LeaveForm> {
  String? _staffId;
  LeaveType _type = LeaveType.casual;
  DateTime? _from;
  DateTime? _to;
  bool _half = false;
  final _reason = TextEditingController();

  @override
  void dispose() {
    _reason.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final staff = ref.watch(crmProvider.select((state) => state.activeStaff));
    final days = [for (var i = 0; i < 14; i++) shopNow().add(Duration(days: i))];
    return FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Submit request',
            onPressed: () {
              if (_staffId == null || _from == null || _to == null) {
                showPbToast(context, 'Choose staff and dates.');
                return;
              }
              final error = ref.read(crmProvider.notifier).addLeave(
                staffId: _staffId!,
                type: _type,
                from: _from!,
                to: _half ? _from! : _to!,
                halfDay: _half,
                reason: _reason.text,
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
          runSpacing: 8,
          children: [
            for (final member in staff)
              PbChoice(label: member.name, selected: _staffId == member.id, onTap: () => setState(() => _staffId = member.id)),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          children: [
            for (final type in LeaveType.values)
              PbChoice(label: type.label, selected: _type == type, onTap: () => setState(() => _type = type)),
          ],
        ),
        const SizedBox(height: 12),
        Text('From', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in days)
              PbChoice(label: dayLabel(day), selected: _from != null && sameDay(_from!, day), onTap: () => setState(() => _from = day)),
          ],
        ),
        const SizedBox(height: 10),
        Text('To', style: PbText.body(12.5, weight: FontWeight.w600, color: PbColors.inkSoft)),
        const SizedBox(height: 6),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final day in days)
              PbChoice(label: dayLabel(day), selected: _to != null && sameDay(_to!, day), onTap: () => setState(() => _to = day)),
          ],
        ),
        const SizedBox(height: 10),
        PbChoice(label: _half ? 'Half day on' : 'Half day off', selected: _half, onTap: () => setState(() => _half = !_half)),
        const SizedBox(height: 10),
        PbField(label: 'Reason', controller: _reason, maxLines: 2),
      ],
    );
  }
}
