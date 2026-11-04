import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/navigation/destinations.dart';
import 'package:papa_bear_crm/core/navigation/role_path.dart';
import 'package:papa_bear_crm/core/theme/pb_colors.dart';
import 'package:papa_bear_crm/core/theme/pb_theme.dart';
import 'package:papa_bear_crm/core/widgets/bear_mark.dart';
import 'package:papa_bear_crm/core/widgets/pb_controls.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/owner/branches/branches_page.dart';

class AppShell extends ConsumerWidget {
  const AppShell({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wide = MediaQuery.sizeOf(context).width >= 980;
    final session = ref.watch(crmProvider.select((state) => state.session));
    final shop = ref.watch(crmProvider.select((state) => state.shop.name));
    final branch = ref.watch(crmProvider.select((state) => state.desk.name));
    final unread = ref.watch(
      crmProvider.select((state) {
        final role = state.session?.role;
        if (role == null) return 0;
        return state.unreadFor(role);
      }),
    );
    if (session == null) return const SizedBox.shrink();

    final items = session.isOwner ? ownerDestinations : receptionDestinations;
    final location = GoRouterState.of(context).uri.path;
    final logout = ref.read(crmProvider.notifier).logout;
    void openSwitch() => showBranchSwitcher(context);
    void openAlerts() => context.go(rolePath(context, '/notifications'));

    if (wide) {
      return ColoredBox(
        color: PbColors.cream,
        child: Row(
          children: [
            _Sidebar(
              shop: shop,
              branch: branch,
              unread: unread,
              role: session.role.label,
              items: items,
              location: location,
              onLogout: logout,
              onSwitch: openSwitch,
              onAlerts: openAlerts,
            ),
            Expanded(child: child),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: PbColors.cream,
      drawer: Drawer(
        backgroundColor: PbColors.ink,
        width: 252,
        child: _Sidebar(
          shop: shop,
          branch: branch,
          unread: unread,
          role: session.role.label,
          items: items,
          location: location,
          onLogout: logout,
          onSwitch: openSwitch,
          onAlerts: openAlerts,
        ),
      ),
      body: Column(
        children: [
          Builder(
            builder: (barContext) => _MobileBar(
              branch: branch,
              unread: unread,
              onMenu: () => Scaffold.of(barContext).openDrawer(),
              onSwitch: openSwitch,
              onAlerts: openAlerts,
            ),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}

class _Sidebar extends StatelessWidget {
  const _Sidebar({
    required this.shop,
    required this.branch,
    required this.unread,
    required this.role,
    required this.items,
    required this.location,
    required this.onLogout,
    required this.onSwitch,
    required this.onAlerts,
  });

  final String shop;
  final String branch;
  final int unread;
  final String role;
  final List<NavDest> items;
  final String location;
  final VoidCallback onLogout;
  final VoidCallback onSwitch;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 252,
      color: PbColors.ink,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(14, 16, 14, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const BearMark(size: 40, onDark: true),
                  const SizedBox(width: 10),
                  const Expanded(
                    child: Text('PapaBear', style: TextStyle(fontFamily: 'Fraunces', fontSize: 22, color: PbColors.cream)),
                  ),
                  _AlertButton(unread: unread, onPressed: onAlerts),
                ],
              ),
              const SizedBox(height: 4),
              Padding(
                padding: const EdgeInsets.only(left: 4),
                child: Text(shop, style: PbText.body(12, color: const Color(0xFFCBB8A4))),
              ),
              InkWell(
                onTap: () {
                  Scaffold.maybeOf(context)?.closeDrawer();
                  onSwitch();
                },
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(4, 2, 4, 0),
                  child: Row(
                    children: [
                      Expanded(child: Text(branch, style: PbText.body(13, weight: FontWeight.w700, color: PbColors.honey))),
                      const Icon(Icons.unfold_more_rounded, size: 16, color: PbColors.honey),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Expanded(
                child: ListView(
                  children: [
                    for (final item in items) ...[
                    if (items.indexOf(item) == 0 || items[items.indexOf(item) - 1].group != item.group)
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 12, 8, 4),
                        child: Text(item.group.toUpperCase(), style: PbText.body(10, weight: FontWeight.w700, color: PbColors.honey, letterSpacing: 1.1)),
                      ),
                    _NavTile(
                      item: item,
                      selected: navSelected(location, item, items),
                      unread: item.path.endsWith('/notifications') ? unread : 0,
                      onDark: true,
                    ),
                  ],
                  ],
                ),
              ),
              PbCard(
                color: PbColors.inkRaised,
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(role, style: PbText.body(13, weight: FontWeight.w600, color: PbColors.cream)),
                    ),
                    IconButton(
                      onPressed: onLogout,
                      tooltip: 'Sign out',
                      icon: const Icon(Icons.logout_rounded, color: PbColors.honey, size: 20),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MobileBar extends StatelessWidget {
  const _MobileBar({
    required this.branch,
    required this.unread,
    required this.onMenu,
    required this.onSwitch,
    required this.onAlerts,
  });

  final String branch;
  final int unread;
  final VoidCallback onMenu;
  final VoidCallback onSwitch;
  final VoidCallback onAlerts;

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: PbColors.ink,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(8, 6, 8, 8),
          child: Row(
            children: [
              IconButton(onPressed: onMenu, icon: const Icon(Icons.menu_rounded, color: PbColors.cream)),
              const BearMark(size: 34, onDark: true),
              const SizedBox(width: 10),
              Expanded(
                child: InkWell(
                  onTap: onSwitch,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('PapaBear', style: PbText.display(20, color: PbColors.cream, weight: 560)),
                      Text(branch, overflow: TextOverflow.ellipsis, style: PbText.body(12, weight: FontWeight.w700, color: PbColors.honey)),
                    ],
                  ),
                ),
              ),
              _AlertButton(unread: unread, onPressed: onAlerts),
            ],
          ),
        ),
      ),
    );
  }
}

class _AlertButton extends StatelessWidget {
  const _AlertButton({required this.unread, required this.onPressed});

  final int unread;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return IconButton(
      tooltip: 'Notifications',
      onPressed: () {
        Scaffold.maybeOf(context)?.closeDrawer();
        onPressed();
      },
      icon: Badge(
        isLabelVisible: unread > 0,
        label: Text('$unread'),
        backgroundColor: PbColors.honey,
        textColor: PbColors.ink,
        child: const Icon(Icons.notifications_none_rounded, color: PbColors.cream),
      ),
    );
  }
}

class _NavTile extends StatelessWidget {
  const _NavTile({required this.item, required this.selected, required this.unread, required this.onDark});

  final NavDest item;
  final bool selected;
  final int unread;
  final bool onDark;

  @override
  Widget build(BuildContext context) {
    final color = onDark ? (selected ? PbColors.cream : const Color(0xFFD9CBBC)) : PbColors.ink;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Material(
        color: selected ? PbColors.inkRaised : Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: () {
            Scaffold.maybeOf(context)?.closeDrawer();
            context.go(item.path);
          },
          borderRadius: BorderRadius.circular(14),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 11),
            child: Row(
              children: [
                Container(
                  width: 3,
                  height: 16,
                  decoration: BoxDecoration(
                    color: selected ? PbColors.honey : Colors.transparent,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                const SizedBox(width: 10),
                Icon(item.icon, size: 18, color: selected ? PbColors.honey : color),
                const SizedBox(width: 10),
                Expanded(child: Text(item.label, style: PbText.body(14, weight: FontWeight.w600, color: color))),
                if (unread > 0)
                  PbPill(label: '$unread', background: PbColors.honey, foreground: PbColors.ink),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
