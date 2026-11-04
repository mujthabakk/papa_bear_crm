import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';

class NotificationPage extends ConsumerStatefulWidget {
  const NotificationPage({super.key, required this.id});

  final String id;

  @override
  ConsumerState<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends ConsumerState<NotificationPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(crmProvider.notifier).markNotificationRead(widget.id);
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(crmProvider);
    final matches = state.notifications.where((note) => note.id == widget.id);
    return PbPage(
      kicker: 'Notification',
      title: matches.isEmpty ? 'Already cleared' : matches.first.title,
      subtitle: matches.isEmpty ? null : '${matches.first.branchName} · ${dayLabel(matches.first.at)} ${clock(matches.first.at)}',
      actions: [
        PbButton(label: 'Notifications', primary: false, onPressed: () => context.go(rolePath(context, '/notifications'))),
        if (matches.isNotEmpty && !matches.first.read)
          PbButton(
            label: 'Mark read',
            onPressed: () => ref.read(crmProvider.notifier).markNotificationRead(widget.id),
          ),
      ],
      children: [
        PbCard(
          child: Text(
            matches.isEmpty ? 'This alert is not in the list anymore.' : matches.first.body,
            style: PbText.body(16, color: PbColors.inkSoft),
          ),
        ),
      ],
    );
  }
}
