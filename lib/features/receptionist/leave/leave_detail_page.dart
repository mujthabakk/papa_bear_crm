import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

class LeaveDetailPage extends ConsumerWidget {
  const LeaveDetailPage({super.key, required this.id});

  final String id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final matches = state.leaves.where((leave) => leave.id == id);
    if (matches.isEmpty) {
      return PbPage(
        kicker: 'Leave',
        title: 'Not on this branch',
        actions: [
          PbButton(label: 'Leave', primary: false, onPressed: () => context.go(rolePath(context, '/leave'))),
        ],
        children: [Text('This request is not on ${state.desk.name}.', style: PbText.body(15))],
      );
    }
    final leave = matches.first;
    final name = state.staffById(leave.staffId)?.name ?? 'Staff';
    final owner = state.session?.isOwner == true;
    return PbPage(
      kicker: leave.status.label,
      title: name,
      subtitle: '${leave.type.label}${leave.halfDay ? ' · half day' : ''} · ${dayLabel(leave.from)} to ${dayLabel(leave.to)}',
      actions: [
        PbButton(label: 'Leave', primary: false, onPressed: () => context.go(rolePath(context, '/leave'))),
        if (owner) PbButton(label: 'Staff card', primary: false, onPressed: () => context.go(rolePath(context, '/staff/${leave.staffId}'))),
        if (owner && leave.status == LeaveStatus.pending)
          PbButton(label: 'Decide', onPressed: () => showLeaveDecision(context, ref, leave)),
      ],
      children: [
        PbCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(leave.reason, style: PbText.body(16)),
              if (leave.decisionNote != null) ...[
                const SizedBox(height: 8),
                Text(leave.decisionNote!, style: PbText.body(13.5, color: PbColors.muted)),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

void showLeaveDecision(BuildContext context, WidgetRef ref, LeaveRequest leave) {
  final note = TextEditingController();
  showPbModal<void>(
    context: context,
    kicker: 'Decision',
    title: ref.read(crmProvider).staffById(leave.staffId)?.name ?? 'Leave',
    subtitle: leave.reason,
    child: FormBody(
      footer: ModalFooter(
        children: [
          PbButton(
            label: 'Reject',
            primary: false,
            onPressed: () {
              ref.read(crmProvider.notifier).decideLeave(leave.id, LeaveStatus.rejected, note.text);
              Navigator.pop(context);
            },
          ),
          PbButton(
            label: 'Approve',
            onPressed: () {
              ref.read(crmProvider.notifier).decideLeave(leave.id, LeaveStatus.approved, note.text);
              Navigator.pop(context);
            },
          ),
        ],
      ),
      children: [
        PbField(label: 'Note for the desk', controller: note, hint: 'Optional'),
      ],
    ),
  );
}
