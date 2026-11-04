import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:papa_bear_crm/core/widgets/app_shell.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/features/auth/login_page.dart';
import 'package:papa_bear_crm/features/owner/activity/activity_page.dart';
import 'package:papa_bear_crm/features/owner/branches/branches_page.dart';
import 'package:papa_bear_crm/features/owner/dashboard/dashboard_page.dart';
import 'package:papa_bear_crm/features/owner/reports/report_view_page.dart';
import 'package:papa_bear_crm/features/owner/reports/reports_page.dart';
import 'package:papa_bear_crm/features/owner/salary/payslip_page.dart';
import 'package:papa_bear_crm/features/owner/salary/salary_page.dart';
import 'package:papa_bear_crm/features/owner/settings/control_pages.dart';
import 'package:papa_bear_crm/features/owner/settings/settings_page.dart';
import 'package:papa_bear_crm/features/owner/staff/staff_detail_page.dart';
import 'package:papa_bear_crm/features/owner/staff/staff_page.dart';
import 'package:papa_bear_crm/features/owner/views/money_pages.dart';
import 'package:papa_bear_crm/features/receptionist/bookings/booking_page.dart';
import 'package:papa_bear_crm/features/receptionist/leave/leave_detail_page.dart';
import 'package:papa_bear_crm/features/receptionist/notifications/notification_page.dart';
import 'package:papa_bear_crm/features/receptionist/attendance/attendance_page.dart';
import 'package:papa_bear_crm/features/receptionist/billing/bills_page.dart';
import 'package:papa_bear_crm/features/receptionist/billing/receipt_page.dart';
import 'package:papa_bear_crm/features/receptionist/bookings/bookings_page.dart';
import 'package:papa_bear_crm/features/receptionist/bookings/waiting_page.dart';
import 'package:papa_bear_crm/features/receptionist/cash/cash_page.dart';
import 'package:papa_bear_crm/features/receptionist/cash/day_close_page.dart';
import 'package:papa_bear_crm/features/receptionist/counter/counter_page.dart';
import 'package:papa_bear_crm/features/receptionist/customers/customer_page.dart';
import 'package:papa_bear_crm/features/receptionist/customers/customers_page.dart';
import 'package:papa_bear_crm/features/receptionist/inventory/product_page.dart';
import 'package:papa_bear_crm/features/receptionist/inventory/stock_page.dart';
import 'package:papa_bear_crm/features/receptionist/leave/leave_page.dart';
import 'package:papa_bear_crm/features/receptionist/notifications/notifications_page.dart';
import 'package:papa_bear_crm/features/receptionist/today/today_page.dart';

final routerProvider = Provider<GoRouter>((ref) {
  final refresh = ValueNotifier<int>(0);
  ref.listen(crmProvider.select((state) => state.session?.role), (_, _) {
    refresh.value++;
  });
  ref.onDispose(refresh.dispose);

  return GoRouter(
    initialLocation: '/login',
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(crmProvider).session;
      final location = state.matchedLocation;
      final loggingIn = location == '/login';
      if (session == null) return loggingIn ? null : '/login';
      if (loggingIn) return session.isOwner ? '/owner/dashboard' : '/reception/counter';
      if (!session.isOwner && location.startsWith('/owner')) return '/reception/counter';
      if (session.isOwner && location.startsWith('/reception')) return '/owner/dashboard';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (context, state) => const LoginPage()),
      ShellRoute(
        builder: (context, state, child) => AppShell(child: child),
        routes: [
          GoRoute(
            path: '/reception',
            redirect: (context, state) => state.uri.path == '/reception' ? '/reception/counter' : null,
            routes: [
              ..._deskRoutes(),
              GoRoute(path: 'today', builder: (context, state) => const TodayPage(), routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ReportViewPage(id: state.pathParameters['id']!),
                ),
              ]),
            ],
          ),
          GoRoute(
            path: '/owner',
            redirect: (context, state) => state.uri.path == '/owner' ? '/owner/dashboard' : null,
            routes: [
              GoRoute(path: 'dashboard', builder: (context, state) => const DashboardPage()),
              GoRoute(path: 'branches', builder: (context, state) => const BranchesPage()),
              ..._deskRoutes(),
              GoRoute(path: 'sales', builder: (context, state) => const SalesPage(), routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ReportViewPage(id: state.pathParameters['id']!),
                ),
              ]),
              GoRoute(path: 'expenses', builder: (context, state) => const ExpensesPage(), routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ReportViewPage(id: state.pathParameters['id']!),
                ),
              ]),
              GoRoute(path: 'profit', builder: (context, state) => const ProfitPage(), routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ProfitPartPage(id: state.pathParameters['id']!),
                ),
              ]),
              GoRoute(path: 'staff', builder: (context, state) => const StaffPage(), routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => StaffDetailPage(id: state.pathParameters['id']!),
                ),
              ]),
              GoRoute(path: 'salary', builder: (context, state) => const SalaryPage(), routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => PayslipPage(id: state.pathParameters['id']!),
                ),
              ]),
              GoRoute(path: 'reports', builder: (context, state) => const ReportsPage(), routes: [
                GoRoute(
                  path: ':id',
                  builder: (context, state) => ReportViewPage(id: state.pathParameters['id']!),
                ),
              ]),
              GoRoute(path: 'settings', builder: (context, state) => const SettingsPage(), routes: [
                GoRoute(path: 'shop', builder: (context, state) => const ShopSettingsPage()),
                GoRoute(path: 'services', builder: (context, state) => const ServicesSettingsPage()),
                GoRoute(path: 'skills', builder: (context, state) => const SkillsSettingsPage()),
                GoRoute(path: 'access', builder: (context, state) => const AccessSettingsPage()),
                GoRoute(path: 'categories', builder: (context, state) => const CategoriesSettingsPage()),
                GoRoute(path: 'rules', builder: (context, state) => const RulesSettingsPage()),
                GoRoute(path: 'backup', builder: (context, state) => const BackupSettingsPage()),
              ]),
              GoRoute(path: 'activity', builder: (context, state) => const ActivityPage()),
            ],
          ),
        ],
      ),
    ],
  );
});

List<RouteBase> _deskRoutes() {
  return [
    GoRoute(path: 'counter', builder: (context, state) => const CounterPage()),
    GoRoute(path: 'notifications', builder: (context, state) => const NotificationsPage(), routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) => NotificationPage(id: state.pathParameters['id']!),
      ),
    ]),
    GoRoute(path: 'bookings', builder: (context, state) => const BookingsPage(), routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) => BookingPage(id: state.pathParameters['id']!),
      ),
    ]),
    GoRoute(path: 'waiting', builder: (context, state) => const WaitingPage()),
    GoRoute(
      path: 'bills',
      builder: (context, state) => const BillsPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => ReceiptPage(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: 'cash',
      builder: (context, state) => const CashPage(),
      routes: [
        GoRoute(path: 'day-close', builder: (context, state) => const DayClosePage()),
      ],
    ),
    GoRoute(path: 'attendance', builder: (context, state) => const AttendancePage()),
    GoRoute(path: 'leave', builder: (context, state) => const LeavePage(), routes: [
      GoRoute(
        path: ':id',
        builder: (context, state) => LeaveDetailPage(id: state.pathParameters['id']!),
      ),
    ]),
    GoRoute(
      path: 'stock',
      builder: (context, state) => const StockPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => ProductPage(id: state.pathParameters['id']!),
        ),
      ],
    ),
    GoRoute(
      path: 'customers',
      builder: (context, state) => const CustomersPage(),
      routes: [
        GoRoute(
          path: ':id',
          builder: (context, state) => CustomerPage(id: state.pathParameters['id']!),
        ),
      ],
    ),
  ];
}
