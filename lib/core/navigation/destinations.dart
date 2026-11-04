import 'package:flutter/material.dart';

class NavDest {
  const NavDest({
    required this.path,
    required this.label,
    required this.icon,
    required this.group,
  });

  final String path;
  final String label;
  final IconData icon;
  final String group;
}

const receptionDestinations = <NavDest>[
  NavDest(path: '/reception/counter', label: 'Counter', icon: Icons.storefront_rounded, group: 'Desk'),
  NavDest(path: '/reception/notifications', label: 'Notifications', icon: Icons.notifications_rounded, group: 'Desk'),
  NavDest(path: '/reception/bookings', label: 'Bookings', icon: Icons.calendar_view_day_rounded, group: 'Desk'),
  NavDest(path: '/reception/waiting', label: 'Waiting list', icon: Icons.hourglass_bottom_rounded, group: 'Desk'),
  NavDest(path: '/reception/bills', label: 'Bills', icon: Icons.receipt_long_rounded, group: 'Desk'),
  NavDest(path: '/reception/cash', label: 'Cash', icon: Icons.account_balance_wallet_rounded, group: 'Money'),
  NavDest(path: '/reception/cash/day-close', label: 'Day close', icon: Icons.lock_clock_rounded, group: 'Money'),
  NavDest(path: '/reception/attendance', label: 'Attendance', icon: Icons.how_to_reg_rounded, group: 'People'),
  NavDest(path: '/reception/leave', label: 'Leave', icon: Icons.event_busy_rounded, group: 'People'),
  NavDest(path: '/reception/customers', label: 'Customers', icon: Icons.people_alt_rounded, group: 'People'),
  NavDest(path: '/reception/stock', label: 'Stock', icon: Icons.inventory_2_rounded, group: 'Stock'),
  NavDest(path: '/reception/today', label: 'Today summary', icon: Icons.summarize_rounded, group: 'Today'),
];

const ownerDestinations = <NavDest>[
  NavDest(path: '/owner/dashboard', label: 'Dashboard', icon: Icons.grid_view_rounded, group: 'Office'),
  NavDest(path: '/owner/branches', label: 'Branches', icon: Icons.account_tree_rounded, group: 'Office'),
  NavDest(path: '/owner/notifications', label: 'Notifications', icon: Icons.notifications_rounded, group: 'Office'),
  NavDest(path: '/owner/counter', label: 'Counter', icon: Icons.storefront_rounded, group: 'Desk'),
  NavDest(path: '/owner/bookings', label: 'Bookings', icon: Icons.calendar_view_day_rounded, group: 'Desk'),
  NavDest(path: '/owner/waiting', label: 'Waiting list', icon: Icons.hourglass_bottom_rounded, group: 'Desk'),
  NavDest(path: '/owner/bills', label: 'Bills', icon: Icons.receipt_long_rounded, group: 'Desk'),
  NavDest(path: '/owner/cash', label: 'Cash', icon: Icons.account_balance_wallet_rounded, group: 'Money'),
  NavDest(path: '/owner/cash/day-close', label: 'Day close', icon: Icons.lock_clock_rounded, group: 'Money'),
  NavDest(path: '/owner/sales', label: 'Sales', icon: Icons.point_of_sale_rounded, group: 'Money'),
  NavDest(path: '/owner/expenses', label: 'Expenses', icon: Icons.receipt_rounded, group: 'Money'),
  NavDest(path: '/owner/profit', label: 'Profit', icon: Icons.trending_up_rounded, group: 'Money'),
  NavDest(path: '/owner/attendance', label: 'Attendance', icon: Icons.how_to_reg_rounded, group: 'People'),
  NavDest(path: '/owner/leave', label: 'Leave', icon: Icons.event_busy_rounded, group: 'People'),
  NavDest(path: '/owner/customers', label: 'Customers', icon: Icons.people_alt_rounded, group: 'People'),
  NavDest(path: '/owner/staff', label: 'Staff', icon: Icons.badge_rounded, group: 'People'),
  NavDest(path: '/owner/salary', label: 'Salary', icon: Icons.payments_rounded, group: 'People'),
  NavDest(path: '/owner/stock', label: 'Stock', icon: Icons.inventory_2_rounded, group: 'Stock'),
  NavDest(path: '/owner/reports', label: 'All reports', icon: Icons.insights_rounded, group: 'Reports'),
  NavDest(path: '/owner/settings', label: 'Settings', icon: Icons.tune_rounded, group: 'Control'),
  NavDest(path: '/owner/settings/shop', label: 'Shop details', icon: Icons.store_rounded, group: 'Control'),
  NavDest(path: '/owner/settings/services', label: 'Services and prices', icon: Icons.content_cut_rounded, group: 'Control'),
  NavDest(path: '/owner/settings/skills', label: 'Skills and hours', icon: Icons.schedule_rounded, group: 'Control'),
  NavDest(path: '/owner/settings/access', label: 'Logins', icon: Icons.key_rounded, group: 'Control'),
  NavDest(path: '/owner/settings/categories', label: 'Expense categories', icon: Icons.category_rounded, group: 'Control'),
  NavDest(path: '/owner/settings/rules', label: 'Salary rules', icon: Icons.rule_rounded, group: 'Control'),
  NavDest(path: '/owner/settings/backup', label: 'Backup', icon: Icons.cloud_download_rounded, group: 'Control'),
  NavDest(path: '/owner/activity', label: 'Activity', icon: Icons.history_rounded, group: 'Control'),
];

bool navSelected(String location, NavDest item, List<NavDest> all) {
  final matches = location == item.path || location.startsWith('${item.path}/');
  if (!matches) return false;
  return !all.any(
    (other) =>
        other.path != item.path &&
        other.path.length > item.path.length &&
        (location == other.path || location.startsWith('${other.path}/')),
  );
}
