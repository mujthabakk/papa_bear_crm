import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/data/models/models.dart';

class SlotSuggestion {
  const SlotSuggestion({
    required this.staff,
    required this.start,
    required this.now,
    required this.label,
  });

  final StaffMember staff;
  final DateTime start;
  final bool now;
  final String label;
}

class Availability {
  const Availability({
    required this.service,
    required this.blocked,
    required this.headline,
    required this.detail,
    required this.options,
    this.requested,
  });

  final ServiceOffer service;
  final StaffMember? requested;
  final bool blocked;
  final String headline;
  final String detail;
  final List<SlotSuggestion> options;
}

class CrmState {
  const CrmState({
    required this.session,
    required this.shop,
    required this.services,
    required this.branches,
    required this.activeBranchId,
    required this.activity,
    required this.notifications,
  });

  final Session? session;
  final ShopSettings shop;
  final List<ServiceOffer> services;
  final List<BranchDesk> branches;
  final String activeBranchId;
  final List<ActivityEntry> activity;
  final List<ShopNotification> notifications;

  BranchDesk get desk => branches.firstWhere((branch) => branch.id == activeBranchId);

  List<StaffMember> get staff => desk.staff;
  List<Booking> get bookings => desk.bookings;
  List<Bill> get bills => desk.bills;
  List<CashEntry> get cashEntries => desk.cashEntries;
  List<ProductItem> get products => desk.products;
  List<StockMove> get stockMoves => desk.stockMoves;
  List<LeaveRequest> get leaves => desk.leaves;
  List<Customer> get customers => desk.customers;
  List<WaitEntry> get waiting => desk.waiting;
  List<SalaryDraft> get salaries => desk.salaries;
  List<ClashOverride> get overrides => desk.overrides;
  Map<String, AttendanceMark> get attendanceEdits => desk.attendanceEdits;
  double get openingCash => desk.openingCash;
  double? get countedCash => desk.countedCash;
  bool get dayClosed => desk.dayClosed;
  int get billSequence => desk.billSequence;

  List<ShopNotification> alertsFor(UserRole role) {
    return notifications.where((note) {
      final audience = role == UserRole.owner ? note.forOwner : note.forDesk;
      if (!audience) return false;
      if (role == UserRole.owner) return true;
      return note.branchId == activeBranchId;
    }).toList();
  }

  int unreadFor(UserRole role) => alertsFor(role).where((note) => !note.read).length;

  List<StaffMember> get activeStaff => staff.where((s) => s.active).toList();

  List<Bill> get liveBills => bills.where((b) => !b.voided).toList();

  List<Bill> get todayBills =>
      liveBills.where((b) => sameDay(b.at, shopNow())).toList();

  List<Bill> get monthBills =>
      liveBills.where((b) => sameMonth(b.at, shopNow())).toList();

  List<Booking> get todayBookings {
    final rows = bookings.where((b) => sameDay(b.start, shopNow())).toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return rows;
  }

  double _sumBills(List<Bill> rows) => rows.fold(0, (sum, bill) => sum + bill.total);

  double get todaySales => _sumBills(todayBills);
  double get monthSales => _sumBills(monthBills);

  double get weekSales => _sumBills(
    liveBills.where((b) => shopNow().difference(b.at).inDays <= 6 && !b.at.isAfter(shopNow().add(const Duration(hours: 12)))).toList(),
  );

  double get cashFromBillsToday =>
      todayBills.fold(0, (sum, bill) => sum + bill.tender.cash);

  double get upiToday => todayBills.fold(0, (sum, bill) => sum + bill.tender.upi);

  double get cardToday => todayBills.fold(0, (sum, bill) => sum + bill.tender.card);

  double get manualInToday => cashEntries
      .where((e) => e.kind == CashKind.cashIn && sameDay(e.at, shopNow()))
      .fold(0, (sum, e) => sum + e.amount);

  double get manualOutToday => cashEntries
      .where((e) => e.kind == CashKind.cashOut && sameDay(e.at, shopNow()))
      .fold(0, (sum, e) => sum + e.amount);

  double get expectedCash =>
      openingCash + cashFromBillsToday + manualInToday - manualOutToday;

  double? get cashDifference =>
      countedCash == null ? null : countedCash! - expectedCash;

  int get presentCount =>
      activeStaff.where((s) => s.today == AttendanceMark.present || s.today == AttendanceMark.halfDay).length;

  int get absentCount =>
      activeStaff.where((s) => s.today == AttendanceMark.absent).length;

  int get leaveCount =>
      activeStaff.where((s) => s.today == AttendanceMark.leave).length;

  int get onlineToday =>
      todayBookings.where((b) => b.source == BookingSource.online).length;

  int get walkInToday => todayBills.where((b) => b.source == BookingSource.walkIn).length;

  List<ProductItem> get lowStock => products.where((p) => p.low).toList();

  List<LeaveRequest> get pendingLeaves =>
      leaves.where((l) => l.status == LeaveStatus.pending).toList();

  double get monthExpenses => cashEntries
      .where((e) => e.kind == CashKind.cashOut && sameMonth(e.at, shopNow()) && e.category != 'Salary' && e.category != 'Staff advance')
      .fold(0, (sum, e) => sum + e.amount);

  double get monthStockPurchases => stockMoves
      .where((m) => m.reason == StockReason.purchase && sameMonth(m.at, shopNow()))
      .fold(0, (sum, m) {
        final product = _product(m.productId);
        final price = product?.purchasePrice ?? 0;
        return sum + (m.qty.abs() * price);
      });

  double get monthSalariesPaid => salaries
      .where((s) => sameMonth(s.month, shopNow()) && s.status == SalaryStatus.paid)
      .fold(0, (sum, s) => sum + s.net);

  double get monthProfit => monthSales - monthExpenses - monthStockPurchases - monthSalariesPaid;

  StaffMember? staffById(String id) {
    for (final member in staff) {
      if (member.id == id) return member;
    }
    return null;
  }

  ServiceOffer? serviceById(String id) {
    for (final service in services) {
      if (service.id == id) return service;
    }
    return null;
  }

  ProductItem? _product(String id) {
    for (final product in products) {
      if (product.id == id) return product;
    }
    return null;
  }

  Customer? customerByPhone(String phone) {
    final clean = digits(phone);
    for (final customer in customers) {
      if (customer.phone == clean) return customer;
    }
    return null;
  }

  AttendanceMark markOn(StaffMember member, DateTime day) {
    final edited = attendanceEdits[attendanceKey(member.id, day)];
    if (edited != null) return edited;
    if (sameDay(day, shopNow())) return member.today;
    if (day.isAfter(shopNow())) return AttendanceMark.unmarked;
    if (day.weekday == DateTime.monday) return AttendanceMark.weeklyOff;
    final n = (member.code.hashCode + day.day).abs() % 11;
    if (n == 0) return AttendanceMark.absent;
    if (n == 1) return AttendanceMark.halfDay;
    if (n == 2) return AttendanceMark.leave;
    return AttendanceMark.present;
  }

  Availability checkAvailability({required String serviceId, String? staffId}) {
    final service = serviceById(serviceId)!;
    final requested = staffId == null ? null : staffById(staffId);
    final eligible = activeStaff.where((member) {
      final onFloor = member.today != AttendanceMark.absent && member.today != AttendanceMark.leave;
      return onFloor && member.skills.contains(service.name);
    }).toList();

    final options = <SlotSuggestion>[];
    for (final member in eligible) {
      final slot = _nextSlot(member, service);
      if (slot != null) options.add(slot);
    }
    options.sort((a, b) {
      if (a.now != b.now) return a.now ? -1 : 1;
      return a.start.compareTo(b.start);
    });

    if (requested != null && (requested.today == AttendanceMark.absent || requested.today == AttendanceMark.leave)) {
      return Availability(
        service: service,
        requested: requested,
        blocked: true,
        headline: '${requested.name} is not on the floor',
        detail: '${requested.name} is marked ${requested.today.label.toLowerCase()} today, so they are hidden from walk-ins.',
        options: options.where((slot) => slot.staff.id != requested.id).toList(),
      );
    }

    if (requested != null && !requested.skills.contains(service.name)) {
      return Availability(
        service: service,
        requested: requested,
        blocked: true,
        headline: '${requested.name} does not do ${service.name}',
        detail: 'Pick another stylist, or choose a service on their skill list.',
        options: options,
      );
    }

    final requestedSlot = requested == null
        ? null
        : options.cast<SlotSuggestion?>().firstWhere(
            (slot) => slot!.staff.id == requested.id,
            orElse: () => null,
          );

    final blocked = requested != null && (requestedSlot == null || !requestedSlot.now);
    if (!blocked && requested != null) {
      return Availability(
        service: service,
        requested: requested,
        blocked: false,
        headline: '${requested.name} is free now',
        detail: 'A ${service.name.toLowerCase()} fits before the next online booking.',
        options: [requestedSlot!, ...options.where((slot) => slot.staff.id != requested.id)],
      );
    }

    if (!blocked) {
      final freeNow = options.where((slot) => slot.now).toList();
      return Availability(
        service: service,
        blocked: freeNow.isEmpty,
        headline: freeNow.isEmpty ? 'Nobody is free for this service' : 'Free right now',
        detail: freeNow.isEmpty
            ? 'Add the customer to the waiting list, or offer the next open time.'
            : '${freeNow.map((slot) => slot.staff.name).join(', ')} can start a ${service.name.toLowerCase()} now.',
        options: options,
      );
    }

    final conflict = _conflict(requested, service);
    final when = conflict == null ? 'later' : clock(conflict.start);
    return Availability(
      service: service,
      requested: requested,
      blocked: true,
      headline: 'Walk-in blocked',
      detail: conflict == null
          ? '${requested.name} does not have a long enough gap for ${service.name}.'
          : '${requested.name} has an online booking at $when. This ${service.name.toLowerCase()} would not finish in time. Online bookings stay first.',
      options: [
        ...options.where((slot) => slot.staff.id != requested.id && slot.now),
        if (requestedSlot != null) requestedSlot,
        ...options.where((slot) => slot.staff.id != requested.id && !slot.now),
      ],
    );
  }

  SlotSuggestion? _nextSlot(StaffMember member, ServiceOffer service) {
    final day = shopNow();
    var cursor = day;
    final open = DateTime(day.year, day.month, day.day, member.startHour);
    if (cursor.isBefore(open)) cursor = open;
    final close = DateTime(day.year, day.month, day.day, member.endHour);

    bool hits(DateTime start) {
      final finish = start.add(Duration(minutes: service.minutes));
      if (finish.isAfter(close)) return true;
      for (final booking in todayBookings) {
        if (booking.staffId != member.id) continue;
        if (booking.status != BookingStatus.upcoming && booking.status != BookingStatus.arrived) {
          continue;
        }
        if (start.isBefore(booking.end) && booking.start.isBefore(finish)) return true;
      }
      return false;
    }

    if (!hits(cursor)) {
      return SlotSuggestion(staff: member, start: cursor, now: true, label: 'Free now');
    }
    var probe = cursor;
    while (probe.isBefore(close)) {
      probe = probe.add(const Duration(minutes: 15));
      if (!hits(probe)) {
        return SlotSuggestion(
          staff: member,
          start: probe,
          now: false,
          label: 'Free at ${clock(probe)}',
        );
      }
    }
    return null;
  }

  Booking? _conflict(StaffMember member, ServiceOffer service) {
    final finish = shopNow().add(Duration(minutes: service.minutes));
    for (final booking in todayBookings) {
      if (booking.staffId != member.id) continue;
      if (booking.status != BookingStatus.upcoming && booking.status != BookingStatus.arrived) {
        continue;
      }
      if (shopNow().isBefore(booking.end) && booking.start.isBefore(finish)) return booking;
    }
    return null;
  }

  CrmState copyWith({
    Object? session = _unset,
    ShopSettings? shop,
    List<ServiceOffer>? services,
    List<BranchDesk>? branches,
    String? activeBranchId,
    List<ActivityEntry>? activity,
    List<ShopNotification>? notifications,
    List<StaffMember>? staff,
    List<Booking>? bookings,
    List<Bill>? bills,
    List<CashEntry>? cashEntries,
    List<ProductItem>? products,
    List<StockMove>? stockMoves,
    List<LeaveRequest>? leaves,
    List<Customer>? customers,
    List<WaitEntry>? waiting,
    List<SalaryDraft>? salaries,
    List<ClashOverride>? overrides,
    Map<String, AttendanceMark>? attendanceEdits,
    double? openingCash,
    Object? countedCash = _unset,
    bool? dayClosed,
    int? billSequence,
  }) {
    final deskTouched = staff != null ||
        bookings != null ||
        bills != null ||
        cashEntries != null ||
        products != null ||
        stockMoves != null ||
        leaves != null ||
        customers != null ||
        waiting != null ||
        salaries != null ||
        overrides != null ||
        attendanceEdits != null ||
        openingCash != null ||
        !identical(countedCash, _unset) ||
        dayClosed != null ||
        billSequence != null;
    final targetId = activeBranchId ?? this.activeBranchId;
    var nextBranches = branches ?? this.branches;
    if (deskTouched) {
      nextBranches = [
        for (final branch in nextBranches)
          if (branch.id == targetId)
            branch.copyWith(
              staff: staff,
              bookings: bookings,
              bills: bills,
              cashEntries: cashEntries,
              products: products,
              stockMoves: stockMoves,
              leaves: leaves,
              customers: customers,
              waiting: waiting,
              salaries: salaries,
              overrides: overrides,
              attendanceEdits: attendanceEdits,
              openingCash: openingCash,
              countedCash: identical(countedCash, _unset) ? branch.countedCash : countedCash as double?,
              dayClosed: dayClosed,
              billSequence: billSequence,
            )
          else
            branch,
      ];
    }
    return CrmState(
      session: identical(session, _unset) ? this.session : session as Session?,
      shop: shop ?? this.shop,
      services: services ?? this.services,
      branches: nextBranches,
      activeBranchId: targetId,
      activity: activity ?? this.activity,
      notifications: notifications ?? this.notifications,
    );
  }
}

const _unset = Object();
