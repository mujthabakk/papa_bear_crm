import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/core/widgets/pb_modal.dart';
import 'package:papa_bear_crm/core/widgets/pb_toast.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

class AttendancePage extends ConsumerWidget {
  const AttendancePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final owner = state.session?.isOwner == true;
    return PbPage(
      kicker: fullDate(shopNow()),
      title: 'Attendance',
      subtitle: owner
          ? 'You can correct today and any past day. The desk can mark today only.'
          : 'Tap a status as people arrive. Past days stay locked.',
      children: [
        for (final member in state.activeStaff)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: PbCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(member.name, style: PbText.body(16, weight: FontWeight.w600)),
                            Text(
                              '${member.roleTitle}${member.checkIn == null ? '' : ' · in ${clock(member.checkIn!)}'}${member.late ? ' · late' : ''}',
                              style: PbText.body(12.5, color: PbColors.muted),
                            ),
                          ],
                        ),
                      ),
                      if (owner)
                        TextButton(
                          onPressed: () => _editPast(context, ref, member),
                          child: Text('Past day', style: PbText.body(13, weight: FontWeight.w600, color: PbColors.honeyDeep)),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final mark in [AttendanceMark.present, AttendanceMark.absent, AttendanceMark.halfDay, AttendanceMark.leave])
                        PbChoice(
                          label: mark.label,
                          selected: member.today == mark,
                          onTap: () {
                            final error = ref.read(crmProvider.notifier).markAttendance(member.id, mark);
                            if (error != null) showPbToast(context, error);
                          },
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        const SizedBox(height: 8),
        Text('This month', style: PbText.display(24)),
        const SizedBox(height: 6),
        Text('Monday is the weekly off. Today follows the marks above.', style: PbText.body(13, color: PbColors.inkSoft)),
        const SizedBox(height: 12),
        for (final member in state.activeStaff.take(4))
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: PbCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(member.name, style: PbText.body(14, weight: FontWeight.w700)),
                  const SizedBox(height: 8),
                  _MonthGrid(member: member),
                ],
              ),
            ),
          ),
      ],
    );
  }

  void _editPast(BuildContext context, WidgetRef ref, StaffMember member) {
    var day = shopNow().subtract(const Duration(days: 1));
    var mark = AttendanceMark.present;
    showPbModal<void>(
      context: context,
      kicker: 'Owner edit',
      title: member.name,
      subtitle: 'Past attendance is owner-only and is written to the activity log.',
      child: StatefulBuilder(
        builder: (context, setLocal) {
          return FormBody(
            footer: ModalFooter(
              children: [
                PbButton(
                  label: 'Save correction',
                  onPressed: () {
                    final error = ref.read(crmProvider.notifier).editPastAttendance(member.id, day, mark);
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
              SizedBox(
                height: 64,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  children: [
                    for (var i = 1; i <= 14; i++)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: PbChoice(
                          label: dayLabel(shopNow().subtract(Duration(days: i))),
                          selected: sameDay(day, shopNow().subtract(Duration(days: i))),
                          onTap: () => setLocal(() => day = shopNow().subtract(Duration(days: i))),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  for (final option in [AttendanceMark.present, AttendanceMark.absent, AttendanceMark.halfDay, AttendanceMark.leave])
                    PbChoice(label: option.label, selected: mark == option, onTap: () => setLocal(() => mark = option)),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class _MonthGrid extends ConsumerWidget {
  const _MonthGrid({required this.member});

  final StaffMember member;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final now = shopNow();
    final days = DateTime(now.year, now.month + 1, 0).day;
    return Wrap(
      spacing: 6,
      runSpacing: 6,
      children: [
        for (var day = 1; day <= days; day++)
          _dot(state.markOn(member, DateTime(now.year, now.month, day)), day),
      ],
    );
  }

  Widget _dot(AttendanceMark mark, int day) {
    final color = switch (mark) {
      AttendanceMark.present => PbColors.moss,
      AttendanceMark.absent => PbColors.clay,
      AttendanceMark.halfDay => PbColors.honeyDeep,
      AttendanceMark.leave => PbColors.tide,
      AttendanceMark.weeklyOff => PbColors.line,
      AttendanceMark.unmarked => PbColors.cream,
    };
    return Container(
      width: 28,
      height: 28,
      alignment: Alignment.center,
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Text(
        '$day',
        style: PbText.body(11, weight: FontWeight.w700, color: mark == AttendanceMark.unmarked || mark == AttendanceMark.weeklyOff ? PbColors.inkSoft : PbColors.paper),
      ),
    );
  }
}
