import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

class NotificationsPage extends ConsumerWidget {
  const NotificationsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crmProvider);
    final role = state.session?.role;
    final notes = role == null ? const <ShopNotification>[] : state.alertsFor(role);
    final unread = notes.where((note) => !note.read).length;
    return PbPage(
      kicker: state.desk.name,
      title: 'Notifications',
      subtitle: role == UserRole.owner
          ? 'Alerts from every branch. The desk only sees the branch it is working.'
          : 'Alerts for ${state.desk.name}. Leave decisions and stock land here.',
      actions: [
        if (unread > 0)
          PbButton(
            label: 'Mark all read',
            primary: false,
            onPressed: () => ref.read(crmProvider.notifier).markAllNotificationsRead(),
          ),
      ],
      children: [
        if (notes.isEmpty)
          PbCard(
            child: Text('Nothing waiting.', style: PbText.body(15)),
          ),
        for (final note in notes)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: PbCard(
              onTap: () => context.go(rolePath(context, '/notifications/${note.id}')),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 10,
                    height: 10,
                    margin: const EdgeInsets.only(top: 6),
                    decoration: BoxDecoration(
                      color: note.read ? PbColors.line : PbColors.honey,
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(note.title, style: PbText.body(15, weight: FontWeight.w700)),
                        const SizedBox(height: 2),
                        Text(note.body, style: PbText.body(13.5, color: PbColors.inkSoft)),
                        const SizedBox(height: 4),
                        Text(
                          '${note.branchName} · ${dayLabel(note.at)} ${clock(note.at)}',
                          style: PbText.body(12, color: PbColors.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
