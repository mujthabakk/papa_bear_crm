import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/data/mock/crm_state.dart';
import 'package:papa_bear_crm/data/mock/seed_data.dart';
import 'package:papa_bear_crm/data/models/models.dart';

export 'package:papa_bear_crm/data/models/models.dart';

final crmProvider = NotifierProvider<CrmController, CrmState>(CrmController.new);

class CrmController extends Notifier<CrmState> {
  @override
  CrmState build() => buildSeed();

  String _id() => DateTime.now().microsecondsSinceEpoch.toString();

  void _commit(CrmState next, String action) {
    final session = state.session;
    final branch = next.desk;
    final at = shopNow().add(Duration(minutes: state.activity.length));
    final alert = _alert(next, action);
    state = next.copyWith(
      activity: [
        ActivityEntry(
          id: _id(),
          at: at,
          actor: session?.displayName ?? 'System',
          roleLabel: session?.role.label ?? 'System',
          action: action,
          branchName: branch.name,
        ),
        ...next.activity,
      ],
      notifications: [
        if (alert != null) alert,
        ...next.notifications,
      ],
    );
  }

  ShopNotification? _alert(CrmState next, String action) {
    final branch = next.desk;
    final lower = action.toLowerCase();
    String? title;
    var forOwner = true;
    var forDesk = false;
    var body = action;
    if (lower.startsWith('leave request')) {
      title = 'Leave waiting';
    } else if (lower.startsWith('approved leave') || lower.startsWith('rejected leave')) {
      title = 'Leave decided';
      forOwner = false;
      forDesk = true;
    } else if (lower.startsWith('day closed')) {
      title = 'Day closed';
      forDesk = true;
    } else if (lower.startsWith('day unlocked')) {
      title = 'Day unlocked';
      forDesk = true;
    } else if (lower.startsWith('override:')) {
      title = 'Clash override';
    } else if (lower.startsWith('added branch') || lower.startsWith('paused ') || lower.startsWith('opened ')) {
      title = 'Branch change';
      forDesk = true;
    } else if (_newlyLow(next)) {
      title = 'Stock is low';
      forDesk = true;
      body = next.products.where((product) => product.low).map((product) => product.name).take(2).join(', ');
      body = '$body needs a refill at ${branch.name}.';
    }
    if (title == null) return null;
    return ShopNotification(
      id: _id(),
      branchId: branch.id,
      branchName: branch.name,
      title: title,
      body: body,
      at: shopNow(),
      read: false,
      forOwner: forOwner,
      forDesk: forDesk,
    );
  }

  bool _newlyLow(CrmState next) {
    if (next.activeBranchId != state.activeBranchId) return false;
    for (final product in next.products) {
      if (!product.low) continue;
      final prior = state.products.where((item) => item.id == product.id);
      if (prior.isEmpty || !prior.first.low) return true;
    }
    return false;
  }

  String? login(UserRole role, String password) {
    final shop = state.shop;
    if (role == UserRole.receptionist && !shop.receptionistEnabled) {
      return 'The receptionist login is disabled.';
    }
    final expected = role == UserRole.owner ? shop.ownerPassword : shop.receptionistPassword;
    if (password.trim() != expected) return 'Password does not match this login.';
    state = state.copyWith(
      session: Session(
        role: role,
        displayName: role == UserRole.owner ? 'Owner' : 'Reception',
      ),
    );
    return null;
  }

  void logout() {
    _commit(state, 'Signed out');
    state = state.copyWith(session: null);
  }

  String? markAttendance(String staffId, AttendanceMark mark) {
    if (state.dayClosed && !(state.session?.isOwner ?? false)) {
      return 'The day is closed.';
    }
    final member = state.staffById(staffId);
    if (member == null) return 'Staff member was not found.';
    final present = mark == AttendanceMark.present || mark == AttendanceMark.halfDay;
    final staff = [
      for (final person in state.staff)
        if (person.id == staffId)
          person.copyWith(
            today: mark,
            checkIn: present ? (person.checkIn ?? shopNow()) : null,
            clearCheckIn: !present,
            clearCheckOut: !present,
            late: present && (person.checkIn ?? shopNow()).isAfter(
              DateTime(shopNow().year, shopNow().month, shopNow().day, person.startHour, 10),
            ),
          )
        else
          person,
    ];
    _commit(state.copyWith(staff: staff), 'Marked ${member.name} ${mark.label.toLowerCase()}');
    return null;
  }

  String? editPastAttendance(String staffId, DateTime day, AttendanceMark mark) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can edit past attendance.';
    final member = state.staffById(staffId);
    if (member == null) return 'Staff member was not found.';
    final edits = {...state.attendanceEdits, attendanceKey(staffId, day): mark};
    var next = state.copyWith(attendanceEdits: edits);
    if (sameDay(day, shopNow())) {
      final error = markAttendance(staffId, mark);
      if (error != null) return error;
      state = state.copyWith(attendanceEdits: edits);
      return null;
    }
    _commit(next, 'Edited attendance for ${member.name} on ${dayLabel(day)}');
    return null;
  }

  String? addLeave({
    required String staffId,
    required LeaveType type,
    required DateTime from,
    required DateTime to,
    required bool halfDay,
    required String reason,
  }) {
    if (reason.trim().isEmpty) return 'Add a reason for the leave.';
    final start = from.isBefore(to) ? from : to;
    final end = to.isAfter(from) ? to : from;
    final request = LeaveRequest(
      id: _id(),
      staffId: staffId,
      type: type,
      from: DateTime(start.year, start.month, start.day),
      to: DateTime(end.year, end.month, end.day),
      halfDay: halfDay,
      reason: reason.trim(),
      status: LeaveStatus.pending,
    );
    final name = state.staffById(staffId)?.name ?? 'Staff';
    _commit(state.copyWith(leaves: [request, ...state.leaves]), 'Leave request for $name');
    return null;
  }

  String? decideLeave(String id, LeaveStatus status, String note) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can decide leave.';
    if (status == LeaveStatus.pending) return 'Choose approve or reject.';
    LeaveRequest? request;
    final leaves = [
      for (final leave in state.leaves)
        if (leave.id == id)
          request = leave.copyWith(status: status, decisionNote: note.trim().isEmpty ? null : note.trim())
        else
          leave,
    ];
    if (request == null) return 'Leave request was not found.';
    var staff = state.staff;
    if (status == LeaveStatus.approved && !request.from.isAfter(shopNow()) && !request.to.isBefore(DateTime(shopNow().year, shopNow().month, shopNow().day))) {
      staff = [
        for (final person in staff)
          if (person.id == request.staffId)
            person.copyWith(today: AttendanceMark.leave, clearCheckIn: true, clearCheckOut: true, late: false)
          else
            person,
      ];
    }
    final name = state.staffById(request.staffId)?.name ?? 'Staff';
    _commit(
      state.copyWith(leaves: leaves, staff: staff),
      '${status == LeaveStatus.approved ? 'Approved' : 'Rejected'} leave for $name',
    );
    return null;
  }

  String? addCash({
    required CashKind kind,
    required double amount,
    required String category,
    required String reason,
  }) {
    if (state.dayClosed) return 'The day is closed.';
    if (amount <= 0) return 'Enter an amount.';
    if (reason.trim().isEmpty) return 'Add a reason.';
    final entry = CashEntry(
      id: _id(),
      kind: kind,
      amount: amount,
      reason: reason.trim(),
      category: category,
      at: shopNow(),
      actor: state.session?.displayName ?? 'Reception',
    );
    var staff = state.staff;
    if (kind == CashKind.cashOut && category == 'Staff advance') {
      final match = staff.where((s) => reason.toLowerCase().contains(s.name.split(' ').first.toLowerCase()));
      if (match.isNotEmpty) {
        final person = match.first;
        staff = [
          for (final member in staff)
            if (member.id == person.id) member.copyWith(advanceBalance: member.advanceBalance + amount) else member,
        ];
      }
    }
    _commit(
      state.copyWith(cashEntries: [entry, ...state.cashEntries], staff: staff),
      '${kind.label} ${inr(amount)} · ${reason.trim()}',
    );
    return null;
  }

  String? createBill({
    required String name,
    required String phone,
    required List<BillLine> lines,
    required double discount,
    required Tender tender,
    String? bookingId,
    String? note,
    String? gender,
  }) {
    if (state.dayClosed) return 'The day is closed. The owner can unlock it.';
    final cleanPhone = digits(phone);
    if (name.trim().isEmpty) return 'Add the customer name.';
    if (cleanPhone.length < 10) return 'Enter a 10-digit phone number.';
    if (lines.isEmpty) return 'Add a service or a product.';
    final subtotal = lines.fold<double>(0, (sum, line) => sum + line.amount);
    if (discount < 0 || discount > subtotal) return 'That discount does not fit this bill.';
    final isOwner = state.session?.isOwner ?? false;
    final limit = subtotal * state.shop.discountLimitPercent / 100;
    if (!isOwner && discount > limit + 0.01) {
      return 'Desk discount limit is ${state.shop.discountLimitPercent.toStringAsFixed(0)}%.';
    }
    final total = subtotal - discount;
    if (tender.cash < 0 || tender.upi < 0 || tender.card < 0) return 'Payment cannot be negative.';
    if (tender.total - total > 0.5) return 'Payment is higher than the bill.';

    final products = [...state.products];
    final moves = [...state.stockMoves];
    for (final line in lines.where((item) => item.isProduct)) {
      final index = products.indexWhere((product) => product.id == line.productId);
      if (index < 0) return 'A product on this bill is missing.';
      if (products[index].qty < line.qty) {
        return '${products[index].name} does not have enough stock.';
      }
      products[index] = products[index].copyWith(qty: products[index].qty - line.qty);
      moves.insert(
        0,
        StockMove(
          id: _id(),
          productId: products[index].id,
          reason: StockReason.sold,
          qty: -line.qty.toDouble(),
          at: shopNow(),
          actor: state.session?.displayName ?? 'Reception',
          note: 'Sold on a bill',
        ),
      );
    }

    BookingSource source = BookingSource.walkIn;
    if (bookingId != null) {
      final match = state.bookings.where((booking) => booking.id == bookingId);
      if (match.isEmpty) return 'That booking is no longer on the board.';
      source = match.first.source;
    }

    final bill = Bill(
      id: _id(),
      number: 'PB-${state.billSequence}',
      at: shopNow(),
      customerName: name.trim(),
      phone: cleanPhone,
      source: source,
      lines: lines,
      discount: discount,
      tender: tender,
      note: note,
    );

    var bookings = state.bookings;
    if (bookingId != null) {
      bookings = [
        for (final booking in bookings)
          if (booking.id == bookingId)
            booking.copyWith(status: BookingStatus.completed, customerName: name.trim(), phone: cleanPhone)
          else
            booking,
      ];
    }

    final customers = [...state.customers];
    final existing = customers.indexWhere((customer) => customer.phone == cleanPhone);
    if (existing < 0) {
      customers.insert(
        0,
        Customer(
          id: _id(),
          name: name.trim(),
          phone: cleanPhone,
          visits: 1,
          spend: bill.total,
          firstVisit: bill.at,
          lastVisit: bill.at,
          notes: note,
          gender: gender,
        ),
      );
    } else {
      final customer = customers[existing];
      customers[existing] = customer.copyWith(
        name: name.trim(),
        visits: customer.visits + 1,
        spend: customer.spend + bill.total,
        lastVisit: bill.at,
        notes: note ?? customer.notes,
        gender: gender ?? customer.gender,
      );
    }

    _commit(
      state.copyWith(
        bills: [bill, ...state.bills],
        billSequence: state.billSequence + 1,
        products: products,
        stockMoves: moves,
        bookings: bookings,
        customers: customers,
      ),
      'Created bill ${bill.number} · ${bill.customerName} · ${inr(bill.total)}',
    );
    return null;
  }

  String? voidBill(String id) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can void a bill.';
    final bill = state.bills.where((item) => item.id == id);
    if (bill.isEmpty) return 'Bill was not found.';
    final products = [...state.products];
    final moves = [...state.stockMoves];
    for (final line in bill.first.lines.where((item) => item.isProduct && !bill.first.voided)) {
      final index = products.indexWhere((product) => product.id == line.productId);
      if (index >= 0) {
        products[index] = products[index].copyWith(qty: products[index].qty + line.qty);
        moves.insert(
          0,
          StockMove(
            id: _id(),
            productId: line.productId!,
            reason: StockReason.correction,
            qty: line.qty.toDouble(),
            at: shopNow(),
            actor: 'Owner',
            note: 'Restored after void ${bill.first.number}',
          ),
        );
      }
    }
    _commit(
      state.copyWith(
        bills: [
          for (final item in state.bills)
            if (item.id == id) item.copyWith(voided: true) else item,
        ],
        products: products,
        stockMoves: moves,
      ),
      'Voided bill ${bill.first.number}',
    );
    return null;
  }

  String? setBookingStatus(String id, BookingStatus status) {
    final booking = state.bookings.where((item) => item.id == id);
    if (booking.isEmpty) return 'Booking was not found.';
    _commit(
      state.copyWith(
        bookings: [
          for (final item in state.bookings)
            if (item.id == id) item.copyWith(status: status) else item,
        ],
      ),
      'Marked ${booking.first.customerName} ${status.label.toLowerCase()}',
    );
    return null;
  }

  String addArrivedWalkIn({
    required String serviceId,
    required String staffId,
    String name = 'Walk-in',
    String phone = '',
  }) {
    final service = state.serviceById(serviceId)!;
    final member = state.staffById(staffId)!;
    final booking = Booking(
      id: _id(),
      customerName: name,
      phone: digits(phone),
      serviceId: service.id,
      serviceName: service.name,
      minutes: service.minutes,
      staffId: member.id,
      start: shopNow(),
      status: BookingStatus.arrived,
      source: BookingSource.walkIn,
    );
    _commit(state.copyWith(bookings: [booking, ...state.bookings]), 'Walk-in added with ${member.name}');
    return booking.id;
  }

  String? overrideClash({
    required String serviceId,
    required String staffId,
    required String reason,
    String name = 'Walk-in',
    String phone = '',
  }) {
    if (!(state.session?.isOwner ?? false)) return null;
    if (reason.trim().isEmpty) return null;
    final service = state.serviceById(serviceId)!;
    final member = state.staffById(staffId)!;
    final booking = Booking(
      id: _id(),
      customerName: name,
      phone: digits(phone),
      serviceId: service.id,
      serviceName: service.name,
      minutes: service.minutes,
      staffId: member.id,
      start: shopNow(),
      status: BookingStatus.arrived,
      source: BookingSource.walkIn,
    );
    final clash = ClashOverride(
      id: _id(),
      at: shopNow(),
      staffName: member.name,
      customerName: name,
      reason: reason.trim(),
      actor: 'Owner',
      serviceName: service.name,
    );
    _commit(
      state.copyWith(
        bookings: [booking, ...state.bookings],
        overrides: [clash, ...state.overrides],
      ),
      'Override: ${service.name} forced onto ${member.name}. ${reason.trim()}',
    );
    return booking.id;
  }

  String? addWaiting({
    required String name,
    required String phone,
    required String serviceId,
    required String expected,
  }) {
    final clean = digits(phone);
    if (name.trim().isEmpty || clean.length < 10) return 'Name and phone are required.';
    final service = state.serviceById(serviceId);
    if (service == null) return 'Choose a service.';
    final entry = WaitEntry(
      id: _id(),
      name: name.trim(),
      phone: clean,
      serviceId: service.id,
      serviceName: service.name,
      minutes: service.minutes,
      at: shopNow(),
      expected: expected,
    );
    _commit(state.copyWith(waiting: [entry, ...state.waiting]), 'Waiting list: ${entry.name}');
    return null;
  }

  void removeWaiting(String id) {
    final entry = state.waiting.where((item) => item.id == id);
    _commit(
      state.copyWith(waiting: state.waiting.where((item) => item.id != id).toList()),
      entry.isEmpty ? 'Updated the waiting list' : 'Removed ${entry.first.name} from the waiting list',
    );
  }

  String? stockIn({
    required String productId,
    required double qty,
    required String supplier,
    required double purchasePrice,
    required String billNumber,
  }) {
    if (qty <= 0) return 'Enter a quantity.';
    final products = [
      for (final product in state.products)
        if (product.id == productId)
          product.copyWith(qty: product.qty + qty, purchasePrice: purchasePrice > 0 ? purchasePrice : product.purchasePrice)
        else
          product,
    ];
    final name = state.products.firstWhere((product) => product.id == productId).name;
    final move = StockMove(
      id: _id(),
      productId: productId,
      reason: StockReason.purchase,
      qty: qty,
      at: shopNow(),
      actor: state.session?.displayName ?? 'Reception',
      note: 'Stock in',
      supplier: supplier.trim(),
      billNumber: billNumber.trim(),
    );
    _commit(state.copyWith(products: products, stockMoves: [move, ...state.stockMoves]), 'Stock in · $name · $qty');
    return null;
  }

  String? stockOut({
    required String productId,
    required double qty,
    required StockReason reason,
    required String note,
  }) {
    if (qty <= 0) return 'Enter a quantity.';
    final product = state.products.firstWhere((item) => item.id == productId);
    if (product.qty < qty) return '${product.name} does not have enough stock.';
    final products = [
      for (final item in state.products)
        if (item.id == productId) item.copyWith(qty: item.qty - qty) else item,
    ];
    final move = StockMove(
      id: _id(),
      productId: productId,
      reason: reason,
      qty: -qty,
      at: shopNow(),
      actor: state.session?.displayName ?? 'Reception',
      note: note.trim().isEmpty ? reason.label : note.trim(),
    );
    _commit(state.copyWith(products: products, stockMoves: [move, ...state.stockMoves]), '${reason.label} · ${product.name}');
    return null;
  }

  String? correctStock(String productId, double qty, String note) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can correct stock.';
    if (qty < 0) return 'Quantity cannot be negative.';
    final product = state.products.firstWhere((item) => item.id == productId);
    final delta = qty - product.qty;
    final products = [
      for (final item in state.products)
        if (item.id == productId) item.copyWith(qty: qty) else item,
    ];
    final move = StockMove(
      id: _id(),
      productId: productId,
      reason: StockReason.correction,
      qty: delta,
      at: shopNow(),
      actor: 'Owner',
      note: note.trim().isEmpty ? 'Physical count' : note.trim(),
    );
    _commit(state.copyWith(products: products, stockMoves: [move, ...state.stockMoves]), 'Stock correction · ${product.name}');
    return null;
  }

  String? addStaff({
    required String name,
    required String phone,
    required String roleTitle,
    required double salary,
    required String upi,
    required List<String> skills,
  }) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can add staff.';
    if (name.trim().isEmpty || digits(phone).length < 10) return 'Name and phone are required.';
    final person = StaffMember(
      id: _id(),
      name: name.trim(),
      code: 'EMP-${100 + state.staff.length}',
      roleTitle: roleTitle.trim().isEmpty ? 'Stylist' : roleTitle.trim(),
      phone: digits(phone),
      joining: shopNow(),
      monthlySalary: salary,
      upiMasked: upi.trim().isEmpty ? 'UPI not set' : upi.trim(),
      skills: skills,
      startHour: 10,
      endHour: 19,
      active: true,
      today: AttendanceMark.unmarked,
      advanceBalance: 0,
    );
    final draft = SalaryDraft(
      id: 'sal-${person.id}-${shopNow().year}-${shopNow().month}',
      staffId: person.id,
      month: DateTime(shopNow().year, shopNow().month),
      workingDays: state.shop.workingDays,
      present: 0,
      halfDays: 0,
      paidLeave: 0,
      unpaidLeave: 0,
      lateDays: 0,
      overtimeHours: 0,
      overtimeRate: state.shop.overtimeRate,
      monthlySalary: salary,
      commission: 0,
      bonus: 0,
      advanceRecovery: 0,
      status: SalaryStatus.unpaid,
    );
    _commit(
      state.copyWith(staff: [...state.staff, person], salaries: [...state.salaries, draft]),
      'Added staff ${person.name}',
    );
    return null;
  }

  String? setStaffActive(String id, bool active) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can change this.';
    final person = state.staffById(id);
    _commit(
      state.copyWith(
        staff: [
          for (final member in state.staff)
            if (member.id == id) member.copyWith(active: active) else member,
        ],
      ),
      '${active ? 'Reactivated' : 'Marked inactive'} ${person?.name ?? 'staff'}',
    );
    return null;
  }

  String? createPayroll({
    required String staffId,
    required DateTime month,
    required PayKind kind,
    required double monthly,
    required double dailyRate,
    required double hourlyRate,
    required double hoursWorked,
    required int presentDays,
    required double commissionPercent,
  }) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can create payroll.';
    final person = state.staffById(staffId);
    if (person == null) return 'Pick a staff member.';
    if ((kind == PayKind.monthly || kind == PayKind.salaryPlusCommission) && monthly <= 0) {
      return 'Enter the monthly salary.';
    }
    if (kind == PayKind.daily && dailyRate <= 0) return 'Enter the daily wage.';
    if (kind == PayKind.hourly && (hourlyRate <= 0 || hoursWorked < 0)) return 'Enter the hourly rate and hours.';
    if ((kind == PayKind.salaryPlusCommission || kind == PayKind.commissionOnly) && commissionPercent < 0) {
      return 'Enter the commission percent.';
    }
    final existing = state.salaries.where((slip) => slip.staffId == staffId && sameMonth(slip.month, month)).toList();
    if (existing.any((slip) => slip.status == SalaryStatus.paid)) {
      return 'This month is already paid.';
    }
    final prior = existing.isEmpty ? null : existing.first;
    final sales = state.liveBills.fold<double>(0, (sum, bill) {
      if (!sameMonth(bill.at, month)) return sum;
      return sum + bill.lines.where((line) => !line.isProduct && line.staffName == person.name).fold(0.0, (lineSum, line) => lineSum + line.amount);
    });
    final earnsCommission = kind == PayKind.salaryPlusCommission || kind == PayKind.commissionOnly;
    final draft = SalaryDraft(
      id: prior?.id ?? 'sal-$staffId-${month.year}-${month.month}',
      staffId: staffId,
      month: DateTime(month.year, month.month),
      workingDays: state.shop.workingDays,
      present: kind == PayKind.daily ? presentDays : (prior?.present ?? presentDays),
      halfDays: prior?.halfDays ?? 0,
      paidLeave: prior?.paidLeave ?? 0,
      unpaidLeave: prior?.unpaidLeave ?? 0,
      lateDays: prior?.lateDays ?? 0,
      overtimeHours: prior?.overtimeHours ?? 0,
      overtimeRate: state.shop.overtimeRate,
      monthlySalary: monthly,
      commission: earnsCommission ? sales * commissionPercent / 100 : 0,
      bonus: prior?.bonus ?? 0,
      bonusReason: prior?.bonusReason,
      otherDeduction: prior?.otherDeduction ?? 0,
      deductionReason: prior?.deductionReason,
      advanceRecovery: prior?.advanceRecovery ?? 0,
      status: SalaryStatus.unpaid,
      payKind: kind,
      dailyRate: dailyRate,
      hourlyRate: hourlyRate,
      hoursWorked: hoursWorked,
      commissionPercent: commissionPercent,
    );
    _commit(
      state.copyWith(
        staff: [
          for (final member in state.staff)
            if (member.id == staffId)
              member.copyWith(
                payKind: kind,
                monthlySalary: monthly,
                dailyRate: dailyRate,
                hourlyRate: hourlyRate,
                commissionPercent: commissionPercent,
              )
            else
              member,
        ],
        salaries: [
          if (prior == null) draft,
          for (final slip in state.salaries)
            if (slip.id == prior?.id) draft else slip,
        ],
      ),
      'Payroll for ${person.name}: ${kind.label}',
    );
    return null;
  }

  String? addSalaryAdjustment({
    required String salaryId,
    required bool bonus,
    required double amount,
    required String reason,
  }) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can adjust salary.';
    if (amount <= 0 || reason.trim().isEmpty) return 'Amount and reason are required.';
    final salaries = [
      for (final slip in state.salaries)
        if (slip.id == salaryId)
          bonus
              ? slip.copyWith(bonus: slip.bonus + amount, bonusReason: reason.trim())
              : slip.copyWith(otherDeduction: slip.otherDeduction + amount, deductionReason: reason.trim())
        else
          slip,
    ];
    _commit(state.copyWith(salaries: salaries), '${bonus ? 'Bonus' : 'Deduction'} ${inr(amount)} · ${reason.trim()}');
    return null;
  }

  String? markSalaryPaid({
    required String salaryId,
    required String mode,
    required String reference,
  }) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can mark salary paid.';
    final slip = state.salaries.where((item) => item.id == salaryId);
    if (slip.isEmpty) return 'Salary row was not found.';
    if (slip.first.status == SalaryStatus.paid) return 'This salary is already paid.';
    final person = state.staffById(slip.first.staffId);
    var cash = state.cashEntries;
    var staff = state.staff;
    if (mode == 'Cash') {
      cash = [
        CashEntry(
          id: _id(),
          kind: CashKind.cashOut,
          amount: slip.first.net,
          reason: 'Salary ${person?.name ?? ''}',
          category: 'Salary',
          at: shopNow(),
          actor: 'Owner',
        ),
        ...cash,
      ];
    }
    if (slip.first.advanceRecovery > 0 && person != null) {
      staff = [
        for (final member in staff)
          if (member.id == person.id)
            member.copyWith(advanceBalance: (member.advanceBalance - slip.first.advanceRecovery).clamp(0, 9999999).toDouble())
          else
            member,
      ];
    }
    _commit(
      state.copyWith(
        salaries: [
          for (final item in state.salaries)
            if (item.id == salaryId)
              item.copyWith(
                status: SalaryStatus.paid,
                paidMode: mode,
                paidOn: shopNow(),
                reference: reference.trim().isEmpty ? 'Paid' : reference.trim(),
              )
            else
              item,
        ],
        cashEntries: cash,
        staff: staff,
      ),
      'Paid salary for ${person?.name ?? 'staff'} by $mode',
    );
    return null;
  }

  String? closeDay(double counted) {
    if (counted < 0) return 'Counted cash cannot be negative.';
    final difference = counted - state.expectedCash;
    _commit(
      state.copyWith(countedCash: counted, dayClosed: true),
      'Day closed. Difference ${inr(difference)}',
    );
    return null;
  }

  String? unlockDay() {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can unlock the day.';
    _commit(state.copyWith(dayClosed: false), 'Day unlocked');
    return null;
  }

  void updateShop({String? name, String? address, String? phone}) {
    _commit(
      state.copyWith(
        shop: state.shop.copyWith(name: name, address: address, phone: phone),
      ),
      'Updated shop details',
    );
  }

  void setDiscountLimit(double percent) {
    _commit(
      state.copyWith(shop: state.shop.copyWith(discountLimitPercent: percent)),
      'Desk discount limit set to ${percent.toStringAsFixed(0)}%',
    );
  }

  void setCommission(bool enabled, double percent) {
    _commit(
      state.copyWith(
        shop: state.shop.copyWith(commissionEnabled: enabled, commissionPercent: percent),
      ),
      enabled ? 'Commission on at ${percent.toStringAsFixed(0)}%' : 'Commission turned off',
    );
  }

  void setReceptionistEnabled(bool enabled) {
    _commit(
      state.copyWith(shop: state.shop.copyWith(receptionistEnabled: enabled)),
      enabled ? 'Receptionist login enabled' : 'Receptionist login disabled',
    );
  }

  String? setPassword({required bool owner, required String password}) {
    if (password.trim().length < 4) return 'Use at least 4 characters.';
    _commit(
      state.copyWith(
        shop: owner
            ? state.shop.copyWith(ownerPassword: password.trim())
            : state.shop.copyWith(receptionistPassword: password.trim()),
      ),
      owner ? 'Owner password updated' : 'Receptionist password updated',
    );
    return null;
  }

  void addCategory(String name) {
    final clean = name.trim();
    if (clean.isEmpty || state.shop.expenseCategories.contains(clean)) return;
    _commit(
      state.copyWith(shop: state.shop.copyWith(expenseCategories: [...state.shop.expenseCategories, clean])),
      'Added expense category $clean',
    );
  }

  String? addService({required String name, required double price, required int minutes}) {
    if (name.trim().isEmpty || price <= 0 || minutes <= 0) return 'Name, price and duration are required.';
    final service = ServiceOffer(id: _id(), name: name.trim(), price: price, minutes: minutes);
    _commit(state.copyWith(services: [...state.services, service]), 'Added service ${service.name}');
    return null;
  }

  String? switchBranch(String id) {
    final matches = state.branches.where((branch) => branch.id == id);
    if (matches.isEmpty) return 'That branch is not on this shop.';
    final branch = matches.first;
    if (!branch.open && !(state.session?.isOwner ?? false)) {
      return '${branch.name} is paused. Ask the owner to open it.';
    }
    if (id == state.activeBranchId) return null;
    _commit(state.copyWith(activeBranchId: id), 'Switched to ${branch.name}');
    return null;
  }

  String? addBranch({
    required String name,
    required String address,
    required String phone,
    required String manager,
  }) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can add a branch.';
    if (name.trim().isEmpty) return 'Name the branch.';
    final desk = BranchDesk(
      id: _id(),
      name: name.trim(),
      address: address.trim().isEmpty ? 'Address not set' : address.trim(),
      phone: phone.trim(),
      manager: manager.trim().isEmpty ? 'Owner' : manager.trim(),
      open: true,
      staff: const [],
      bookings: const [],
      bills: const [],
      cashEntries: const [],
      products: const [],
      stockMoves: const [],
      leaves: const [],
      customers: const [],
      waiting: const [],
      salaries: const [],
      overrides: const [],
      attendanceEdits: const {},
      openingCash: 0,
      countedCash: null,
      dayClosed: false,
      billSequence: 1001,
    );
    _commit(
      state.copyWith(branches: [...state.branches, desk], activeBranchId: desk.id),
      'Added branch ${desk.name}',
    );
    return null;
  }

  String? updateBranch({
    required String id,
    required String name,
    required String address,
    required String phone,
    required String manager,
  }) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can edit a branch.';
    if (name.trim().isEmpty) return 'Name the branch.';
    final branches = [
      for (final branch in state.branches)
        if (branch.id == id)
          branch.copyWith(
            name: name.trim(),
            address: address.trim(),
            phone: phone.trim(),
            manager: manager.trim().isEmpty ? 'Owner' : manager.trim(),
          )
        else
          branch,
    ];
    _commit(state.copyWith(branches: branches), 'Updated branch ${name.trim()}');
    return null;
  }

  String? setBranchOpen(String id, bool open) {
    if (!(state.session?.isOwner ?? false)) return 'Only the owner can open or pause a branch.';
    final branches = [
      for (final branch in state.branches)
        if (branch.id == id) branch.copyWith(open: open) else branch,
    ];
    final name = branches.firstWhere((branch) => branch.id == id).name;
    _commit(state.copyWith(branches: branches), open ? 'Opened $name' : 'Paused $name');
    return null;
  }

  void markNotificationRead(String id) {
    state = state.copyWith(
      notifications: [
        for (final note in state.notifications)
          if (note.id == id) note.copyWith(read: true) else note,
      ],
    );
  }

  void markAllNotificationsRead() {
    final role = state.session?.role;
    if (role == null) return;
    final visible = state.alertsFor(role).map((note) => note.id).toSet();
    state = state.copyWith(
      notifications: [
        for (final note in state.notifications)
          if (visible.contains(note.id)) note.copyWith(read: true) else note,
      ],
    );
  }

  String? updateService(String id, {required double price, required int minutes}) {
    if (price <= 0 || minutes <= 0) return 'Price and duration are required.';
    _commit(
      state.copyWith(
        services: [
          for (final service in state.services)
            if (service.id == id) service.copyWith(price: price, minutes: minutes) else service,
        ],
      ),
      'Updated a service price',
    );
    return null;
  }
}
