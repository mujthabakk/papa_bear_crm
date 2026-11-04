import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/data/mock/crm_state.dart';
import 'package:papa_bear_crm/data/models/models.dart';

class ReportDef {
  const ReportDef({required this.id, required this.group, required this.title, required this.blurb});

  final String id;
  final String group;
  final String title;
  final String blurb;
}

class ReportRow {
  const ReportRow(this.title, this.value, [this.meta = '', this.href]);

  final String title;
  final String value;
  final String meta;
  final String? href;
}

String? _staffHref(CrmState state, String? name) {
  if (name == null || name.isEmpty) return null;
  final matches = state.staff.where((member) => member.name == name);
  if (matches.isEmpty) return null;
  return '/staff/${matches.first.id}';
}

String? _productHref(CrmState state, String name) {
  final matches = state.products.where((product) => product.name == name);
  if (matches.isEmpty) return null;
  return '/stock/${matches.first.id}';
}

const reportCatalog = <ReportDef>[
  ReportDef(id: 'daily-sales', group: 'Sales', title: 'Daily sales', blurb: 'Bills, discount and payment split for today.'),
  ReportDef(id: 'monthly-sales', group: 'Sales', title: 'Monthly sales', blurb: 'Day by day for this month.'),
  ReportDef(id: 'service-sales', group: 'Sales', title: 'Service-wise sales', blurb: 'How often each service was done.'),
  ReportDef(id: 'product-sales', group: 'Sales', title: 'Product sales', blurb: 'Retail products sold from bills.'),
  ReportDef(id: 'staff-sales', group: 'Sales', title: 'Staff-wise sales', blurb: 'Services and amount per stylist.'),
  ReportDef(id: 'payment-mode', group: 'Sales', title: 'Payment mode', blurb: 'Cash, UPI and card collections.'),
  ReportDef(id: 'discounts', group: 'Sales', title: 'Discount report', blurb: 'Every discount on a saved bill.'),
  ReportDef(id: 'pending-dues', group: 'Sales', title: 'Pending dues', blurb: 'Part-paid bills and the balance.'),
  ReportDef(id: 'today-bookings', group: 'Bookings', title: "Today's bookings", blurb: 'Online and walk-in with status.'),
  ReportDef(id: 'online-vs-walkin', group: 'Bookings', title: 'Online vs walk-in', blurb: 'Count and sales from each source.'),
  ReportDef(id: 'noshow', group: 'Bookings', title: 'No-show and cancellation', blurb: 'Online bookings that did not happen.'),
  ReportDef(id: 'clash', group: 'Bookings', title: 'Clash overrides', blurb: 'Walk-ins the owner forced into a booked time.'),
  ReportDef(id: 'utilisation', group: 'Bookings', title: 'Staff utilisation', blurb: 'Booked minutes against the working day.'),
  ReportDef(id: 'cashbook', group: 'Cash', title: 'Cash in and cash out', blurb: 'Every drawer entry with who entered it.'),
  ReportDef(id: 'day-close', group: 'Cash', title: 'Day close', blurb: 'Expected cash against the count.'),
  ReportDef(id: 'cash-diff', group: 'Cash', title: 'Cash difference', blurb: 'Days where the count did not match.'),
  ReportDef(id: 'expenses', group: 'Cash', title: 'Expenses', blurb: 'Cash out grouped by category.'),
  ReportDef(id: 'profit', group: 'Cash', title: 'Simple profit', blurb: 'Sales minus expenses, stock and salaries.'),
  ReportDef(id: 'current-stock', group: 'Inventory', title: 'Current stock', blurb: 'Quantity and stock value.'),
  ReportDef(id: 'stock-in', group: 'Inventory', title: 'Stock in', blurb: 'Purchases with supplier and bill number.'),
  ReportDef(id: 'stock-out', group: 'Inventory', title: 'Stock out', blurb: 'Sold, used, damaged or expired.'),
  ReportDef(id: 'damaged', group: 'Inventory', title: 'Damaged and expired', blurb: 'Write-offs and their value.'),
  ReportDef(id: 'low-stock', group: 'Inventory', title: 'Low stock', blurb: 'Products under the minimum.'),
  ReportDef(id: 'stock-ledger', group: 'Inventory', title: 'Stock history', blurb: 'In and out with a running note.'),
  ReportDef(id: 'suppliers', group: 'Inventory', title: 'Supplier purchases', blurb: 'What was bought from each supplier.'),
  ReportDef(id: 'daily-attendance', group: 'People', title: 'Daily attendance', blurb: 'Who is in, out, late or on leave.'),
  ReportDef(id: 'monthly-attendance', group: 'People', title: 'Monthly attendance', blurb: 'Present, half day and leave on the salary run.'),
  ReportDef(id: 'late-ot', group: 'People', title: 'Late and overtime', blurb: 'Late days and extra hours.'),
  ReportDef(id: 'leave-report', group: 'People', title: 'Leave report', blurb: 'Requested, approved and rejected.'),
  ReportDef(id: 'salary-register', group: 'People', title: 'Salary register', blurb: 'Net pay and paid status for the month.'),
  ReportDef(id: 'advances', group: 'People', title: 'Advance report', blurb: 'Advance still to recover.'),
  ReportDef(id: 'commission', group: 'People', title: 'Commission', blurb: 'Service commission on the current slips.'),
  ReportDef(id: 'payslips', group: 'People', title: 'Payslips', blurb: 'Open a row from Salary for the full slip.'),
  ReportDef(id: 'customers', group: 'Customers', title: 'Customer list', blurb: 'Phone, visits and spend.'),
  ReportDef(id: 'new-repeat', group: 'Customers', title: 'New vs repeat', blurb: 'First visit this month against returning customers.'),
  ReportDef(id: 'visits', group: 'Customers', title: 'Visit history', blurb: 'Recent bills by customer.'),
  ReportDef(id: 'activity', group: 'Control', title: 'Activity log', blurb: 'Who created or changed shop records.'),
];

List<ReportRow> reportRows(String id, CrmState state) {
  final monthSlips = state.salaries.where((slip) => sameMonth(slip.month, shopNow())).toList();
  switch (id) {
    case 'daily-sales':
      return [
        ReportRow('Bills', '${state.todayBills.length}'),
        ReportRow('Sales', inr(state.todaySales)),
        ReportRow('Discount', inr(state.todayBills.fold(0.0, (s, b) => s + b.discount))),
        ReportRow('Cash / UPI / Card', '${inr(state.cashFromBillsToday)} / ${inr(state.upiToday)} / ${inr(state.cardToday)}'),
      ];
    case 'monthly-sales':
      final byDay = <int, double>{};
      for (final bill in state.monthBills) {
        byDay[bill.at.day] = (byDay[bill.at.day] ?? 0) + bill.total;
      }
      final days = byDay.keys.toList()..sort();
      return [for (final day in days) ReportRow('$day ${monthLabel(shopNow())}', inr(byDay[day]!)), ReportRow('Month total', inr(state.monthSales))];
    case 'service-sales':
      final map = <String, double>{};
      final count = <String, int>{};
      for (final bill in state.monthBills) {
        for (final line in bill.lines.where((line) => !line.isProduct)) {
          map[line.name] = (map[line.name] ?? 0) + line.amount;
          count[line.name] = (count[line.name] ?? 0) + line.qty;
        }
      }
      return [for (final name in map.keys) ReportRow(name, inr(map[name]!), '${count[name]} times')];
    case 'product-sales':
      final map = <String, int>{};
      for (final bill in state.monthBills) {
        for (final line in bill.lines.where((line) => line.isProduct)) {
          map[line.name] = (map[line.name] ?? 0) + line.qty;
        }
      }
      if (map.isEmpty) return [const ReportRow('No product sales this month', '—')];
      return [for (final name in map.keys) ReportRow(name, '${map[name]} sold', '', _productHref(state, name))];
    case 'staff-sales':
      final map = <String, double>{};
      for (final bill in state.monthBills) {
        for (final line in bill.lines.where((line) => !line.isProduct)) {
          map[line.staffName] = (map[line.staffName] ?? 0) + line.amount;
        }
      }
      return [for (final name in map.keys) ReportRow(name, inr(map[name]!), '', _staffHref(state, name))];
    case 'payment-mode':
      return [
        ReportRow('Cash', inr(state.todayBills.fold(0.0, (s, b) => s + b.tender.cash))),
        ReportRow('UPI', inr(state.upiToday)),
        ReportRow('Card', inr(state.cardToday)),
      ];
    case 'discounts':
      final rows = state.monthBills.where((bill) => bill.discount > 0).toList();
      if (rows.isEmpty) return [const ReportRow('No discounts this month', '—')];
      return [for (final bill in rows) ReportRow(bill.number, inr(bill.discount), bill.customerName, '/bills/${bill.id}')];
    case 'pending-dues':
      final rows = state.liveBills.where((bill) => bill.balance > 1).toList();
      if (rows.isEmpty) return [const ReportRow('No pending dues', '₹0')];
      return [for (final bill in rows) ReportRow(bill.customerName, inr(bill.balance), bill.number, '/bills/${bill.id}')];
    case 'today-bookings':
      return [for (final booking in state.todayBookings) ReportRow(booking.customerName, booking.status.label, '${clock(booking.start)} · ${booking.serviceName}', '/bookings/${booking.id}')];
    case 'online-vs-walkin':
      final online = state.monthBills.where((b) => b.source == BookingSource.online);
      final walk = state.monthBills.where((b) => b.source == BookingSource.walkIn);
      return [
        ReportRow('Online bills', '${online.length}', inr(online.fold(0.0, (s, b) => s + b.total))),
        ReportRow('Walk-in bills', '${walk.length}', inr(walk.fold(0.0, (s, b) => s + b.total))),
      ];
    case 'noshow':
      final rows = state.bookings.where((b) => b.status == BookingStatus.noShow || b.status == BookingStatus.cancelled).toList();
      if (rows.isEmpty) return [const ReportRow('No no-shows recorded', '—')];
      return [for (final booking in rows) ReportRow(booking.customerName, booking.status.label, booking.serviceName, '/bookings/${booking.id}')];
    case 'clash':
      if (state.overrides.isEmpty) return [const ReportRow('No overrides yet', 'Online bookings stayed first')];
      return [for (final item in state.overrides) ReportRow(item.staffName, item.serviceName, item.reason)];
    case 'utilisation':
      return [
        for (final member in state.activeStaff)
          ReportRow(
            member.name,
            '${state.todayBookings.where((b) => b.staffId == member.id).fold<int>(0, (s, b) => s + b.minutes)} min',
            'Shift ${(member.endHour - member.startHour) * 60} min',
            '/staff/${member.id}',
          ),
      ];
    case 'cashbook':
      return [
        for (final entry in state.cashEntries.take(20))
          ReportRow(entry.reason, '${entry.kind == CashKind.cashIn ? '+' : '−'}${inr(entry.amount)}', '${entry.category} · ${entry.actor}'),
      ];
    case 'day-close':
      return [
        ReportRow('Expected', inr(state.expectedCash)),
        ReportRow('Counted', state.countedCash == null ? 'Not counted' : inr(state.countedCash!)),
        ReportRow('Difference', state.cashDifference == null ? '—' : inr(state.cashDifference!)),
      ];
    case 'cash-diff':
      final closes = [
        if (state.cashDifference != null) ReportRow(fullDate(shopNow()), inr(state.cashDifference!), 'Counted ${inr(state.countedCash!)}'),
        for (final close in state.desk.pastCloses)
          ReportRow(fullDate(close.at), inr(close.difference), 'Counted ${inr(close.counted)} · expected ${inr(close.expected)}'),
      ];
      if (closes.isEmpty) return [const ReportRow('No counted day yet', 'Close the day to record a difference')];
      return closes;
    case 'expenses':
      final map = <String, double>{};
      for (final entry in state.cashEntries.where((e) => e.kind == CashKind.cashOut)) {
        map[entry.category] = (map[entry.category] ?? 0) + entry.amount;
      }
      return [for (final key in map.keys) ReportRow(key, inr(map[key]!))];
    case 'profit':
      return [
        ReportRow('Sales', inr(state.monthSales), '', '/profit/sales'),
        ReportRow('Expenses', inr(state.monthExpenses), '', '/profit/expenses'),
        ReportRow('Stock purchases', inr(state.monthStockPurchases), '', '/profit/stock'),
        ReportRow('Salaries paid', inr(state.monthSalariesPaid), '', '/profit/salaries'),
        ReportRow('Simple profit', inr(state.monthProfit), '', '/profit/result'),
      ];
    case 'current-stock':
      return [for (final product in state.products) ReportRow(product.name, '${product.qty.toStringAsFixed(0)} ${product.unit}', inr(product.stockValue), '/stock/${product.id}')];
    case 'stock-in':
      final rows = state.stockMoves.where((m) => m.reason == StockReason.purchase).toList();
      return [
        for (final move in rows)
          ReportRow(
            state.products.where((p) => p.id == move.productId).map((p) => p.name).join(),
            '+${move.qty.toStringAsFixed(0)}',
            move.supplier ?? '',
            '/stock/${move.productId}',
          ),
      ];
    case 'stock-out':
      final rows = state.stockMoves.where((m) => m.qty < 0).toList();
      return [for (final move in rows) ReportRow(move.reason.label, move.qty.toStringAsFixed(0), move.note)];
    case 'damaged':
      final rows = state.stockMoves.where((m) => m.reason == StockReason.damaged || m.reason == StockReason.expired).toList();
      if (rows.isEmpty) return [const ReportRow('Nothing written off', '—')];
      return [for (final move in rows) ReportRow(move.note, move.qty.toStringAsFixed(0), move.reason.label)];
    case 'low-stock':
      if (state.lowStock.isEmpty) return [const ReportRow('All products are above minimum', '—')];
      return [for (final product in state.lowStock) ReportRow(product.name, product.qty.toStringAsFixed(0), 'Order up to ${product.minimum.toStringAsFixed(0)}', '/stock/${product.id}')];
    case 'stock-ledger':
      return [for (final move in state.stockMoves.take(16)) ReportRow(move.note, move.qty.toStringAsFixed(0), dayLabel(move.at))];
    case 'suppliers':
      final map = <String, int>{};
      for (final move in state.stockMoves.where((m) => m.supplier != null && m.supplier!.isNotEmpty)) {
        map[move.supplier!] = (map[move.supplier!] ?? 0) + 1;
      }
      return [for (final name in map.keys) ReportRow(name, '${map[name]} entries')];
    case 'daily-attendance':
      return [for (final member in state.activeStaff) ReportRow(member.name, member.today.label, member.late ? 'Late' : member.checkIn == null ? '' : clock(member.checkIn!), '/staff/${member.id}')];
    case 'monthly-attendance':
      return [for (final slip in monthSlips) ReportRow(state.staffById(slip.staffId)?.name ?? '', '${slip.present} present', '${slip.halfDays} half · ${slip.paidLeave} paid leave', _staffHref(state, state.staffById(slip.staffId)?.name))];
    case 'late-ot':
      return [for (final slip in monthSlips) ReportRow(state.staffById(slip.staffId)?.name ?? '', '${slip.lateDays} late', '${slip.overtimeHours.toStringAsFixed(0)} hrs OT', _staffHref(state, state.staffById(slip.staffId)?.name))];
    case 'leave-report':
      return [for (final leave in state.leaves) ReportRow(state.staffById(leave.staffId)?.name ?? '', leave.status.label, leave.type.label, '/leave/${leave.id}')];
    case 'salary-register':
      return [for (final slip in monthSlips) ReportRow(state.staffById(slip.staffId)?.name ?? '', inr(slip.net), slip.status.label, '/salary/${slip.id}')];
    case 'advances':
      return [for (final member in state.staff.where((s) => s.advanceBalance > 0)) ReportRow(member.name, inr(member.advanceBalance), 'Still to recover', '/staff/${member.id}')];
    case 'commission':
      return [for (final slip in monthSlips) ReportRow(state.staffById(slip.staffId)?.name ?? '', inr(slip.commission), state.shop.commissionEnabled ? '${state.shop.commissionPercent.toStringAsFixed(0)}% rule' : 'Off', '/salary/${slip.id}')];
    case 'payslips':
      return [for (final slip in state.salaries) ReportRow(state.staffById(slip.staffId)?.name ?? '', monthLabel(slip.month), inr(slip.net), '/salary/${slip.id}')];
    case 'customers':
      return [for (final customer in state.customers.take(20)) ReportRow(customer.name, customer.phone, '${customer.visits} visits · ${inr(customer.spend)}', '/customers/${customer.id}')];
    case 'new-repeat':
      final fresh = state.customers.where((c) => c.firstVisit != null && sameMonth(c.firstVisit!, shopNow())).length;
      return [
        ReportRow('New this month', '$fresh'),
        ReportRow('Returning', '${state.customers.length - fresh}'),
      ];
    case 'visits':
      return [for (final bill in state.liveBills.take(12)) ReportRow(bill.customerName, inr(bill.total), bill.lines.map((l) => l.name).join(', '), '/bills/${bill.id}')];
    case 'activity':
      return [for (final entry in state.activity.take(20)) ReportRow(entry.actor, entry.action, clock(entry.at))];
    default:
      return [const ReportRow('Nothing to show', '—')];
  }
}
