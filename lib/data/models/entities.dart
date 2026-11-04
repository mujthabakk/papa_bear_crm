import 'package:papa_bear_crm/data/models/enums.dart';

class Session {
  const Session({required this.role, required this.displayName});

  final UserRole role;
  final String displayName;

  bool get isOwner => role.isOwner;
}

class ShopSettings {
  const ShopSettings({
    required this.name,
    required this.address,
    required this.phone,
    required this.discountLimitPercent,
    required this.receptionistEnabled,
    required this.commissionEnabled,
    required this.commissionPercent,
    required this.overtimeRate,
    required this.paidLeavePerYear,
    required this.workingDays,
    required this.weeklyOff,
    required this.expenseCategories,
    required this.ownerPassword,
    required this.receptionistPassword,
  });

  final String name;
  final String address;
  final String phone;
  final double discountLimitPercent;
  final bool receptionistEnabled;
  final bool commissionEnabled;
  final double commissionPercent;
  final double overtimeRate;
  final int paidLeavePerYear;
  final int workingDays;
  final String weeklyOff;
  final List<String> expenseCategories;
  final String ownerPassword;
  final String receptionistPassword;

  ShopSettings copyWith({
    String? name,
    String? address,
    String? phone,
    double? discountLimitPercent,
    bool? receptionistEnabled,
    bool? commissionEnabled,
    double? commissionPercent,
    double? overtimeRate,
    int? paidLeavePerYear,
    int? workingDays,
    String? weeklyOff,
    List<String>? expenseCategories,
    String? ownerPassword,
    String? receptionistPassword,
  }) {
    return ShopSettings(
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      discountLimitPercent: discountLimitPercent ?? this.discountLimitPercent,
      receptionistEnabled: receptionistEnabled ?? this.receptionistEnabled,
      commissionEnabled: commissionEnabled ?? this.commissionEnabled,
      commissionPercent: commissionPercent ?? this.commissionPercent,
      overtimeRate: overtimeRate ?? this.overtimeRate,
      paidLeavePerYear: paidLeavePerYear ?? this.paidLeavePerYear,
      workingDays: workingDays ?? this.workingDays,
      weeklyOff: weeklyOff ?? this.weeklyOff,
      expenseCategories: expenseCategories ?? this.expenseCategories,
      ownerPassword: ownerPassword ?? this.ownerPassword,
      receptionistPassword: receptionistPassword ?? this.receptionistPassword,
    );
  }
}

class StaffMember {
  const StaffMember({
    required this.id,
    required this.name,
    required this.code,
    required this.roleTitle,
    required this.phone,
    required this.joining,
    required this.monthlySalary,
    required this.upiMasked,
    required this.skills,
    required this.startHour,
    required this.endHour,
    required this.active,
    required this.today,
    required this.advanceBalance,
    this.checkIn,
    this.checkOut,
    this.late = false,
    this.overtimeHours = 0,
    this.payKind = PayKind.monthly,
    this.dailyRate = 0,
    this.hourlyRate = 0,
    this.commissionPercent = 0,
  });

  final String id;
  final String name;
  final String code;
  final String roleTitle;
  final String phone;
  final DateTime joining;
  final double monthlySalary;
  final String upiMasked;
  final List<String> skills;
  final int startHour;
  final int endHour;
  final bool active;
  final AttendanceMark today;
  final double advanceBalance;
  final DateTime? checkIn;
  final DateTime? checkOut;
  final bool late;
  final double overtimeHours;
  final PayKind payKind;
  final double dailyRate;
  final double hourlyRate;
  final double commissionPercent;

  StaffMember copyWith({
    String? name,
    String? roleTitle,
    String? phone,
    double? monthlySalary,
    String? upiMasked,
    List<String>? skills,
    int? startHour,
    int? endHour,
    bool? active,
    AttendanceMark? today,
    double? advanceBalance,
    DateTime? checkIn,
    DateTime? checkOut,
    bool? late,
    double? overtimeHours,
    PayKind? payKind,
    double? dailyRate,
    double? hourlyRate,
    double? commissionPercent,
    bool clearCheckIn = false,
    bool clearCheckOut = false,
  }) {
    return StaffMember(
      id: id,
      name: name ?? this.name,
      code: code,
      roleTitle: roleTitle ?? this.roleTitle,
      phone: phone ?? this.phone,
      joining: joining,
      monthlySalary: monthlySalary ?? this.monthlySalary,
      upiMasked: upiMasked ?? this.upiMasked,
      skills: skills ?? this.skills,
      startHour: startHour ?? this.startHour,
      endHour: endHour ?? this.endHour,
      active: active ?? this.active,
      today: today ?? this.today,
      advanceBalance: advanceBalance ?? this.advanceBalance,
      checkIn: clearCheckIn ? null : (checkIn ?? this.checkIn),
      checkOut: clearCheckOut ? null : (checkOut ?? this.checkOut),
      late: late ?? this.late,
      overtimeHours: overtimeHours ?? this.overtimeHours,
      payKind: payKind ?? this.payKind,
      dailyRate: dailyRate ?? this.dailyRate,
      hourlyRate: hourlyRate ?? this.hourlyRate,
      commissionPercent: commissionPercent ?? this.commissionPercent,
    );
  }
}

class ServiceOffer {
  const ServiceOffer({
    required this.id,
    required this.name,
    required this.price,
    required this.minutes,
  });

  final String id;
  final String name;
  final double price;
  final int minutes;

  ServiceOffer copyWith({String? name, double? price, int? minutes}) {
    return ServiceOffer(
      id: id,
      name: name ?? this.name,
      price: price ?? this.price,
      minutes: minutes ?? this.minutes,
    );
  }
}

class Booking {
  const Booking({
    required this.id,
    required this.customerName,
    required this.phone,
    required this.serviceId,
    required this.serviceName,
    required this.minutes,
    required this.staffId,
    required this.start,
    required this.status,
    required this.source,
  });

  final String id;
  final String customerName;
  final String phone;
  final String serviceId;
  final String serviceName;
  final int minutes;
  final String staffId;
  final DateTime start;
  final BookingStatus status;
  final BookingSource source;

  DateTime get end => start.add(Duration(minutes: minutes));

  Booking copyWith({BookingStatus? status, String? customerName, String? phone}) {
    return Booking(
      id: id,
      customerName: customerName ?? this.customerName,
      phone: phone ?? this.phone,
      serviceId: serviceId,
      serviceName: serviceName,
      minutes: minutes,
      staffId: staffId,
      start: start,
      status: status ?? this.status,
      source: source,
    );
  }
}

class BillLine {
  const BillLine({
    required this.name,
    required this.qty,
    required this.price,
    required this.staffName,
    this.isProduct = false,
    this.productId,
  });

  final String name;
  final int qty;
  final double price;
  final String staffName;
  final bool isProduct;
  final String? productId;

  double get amount => price * qty;
}

class Tender {
  const Tender({this.cash = 0, this.upi = 0, this.card = 0});

  final double cash;
  final double upi;
  final double card;

  double get total => cash + upi + card;

  String get summary {
    final parts = <String>[];
    if (cash > 0) parts.add('Cash');
    if (upi > 0) parts.add('UPI');
    if (card > 0) parts.add('Card');
    return parts.isEmpty ? 'Unpaid' : parts.join(' + ');
  }
}

class Bill {
  const Bill({
    required this.id,
    required this.number,
    required this.at,
    required this.customerName,
    required this.phone,
    required this.source,
    required this.lines,
    required this.discount,
    required this.tender,
    this.note,
    this.voided = false,
  });

  final String id;
  final String number;
  final DateTime at;
  final String customerName;
  final String phone;
  final BookingSource source;
  final List<BillLine> lines;
  final double discount;
  final Tender tender;
  final String? note;
  final bool voided;

  double get subtotal => lines.fold(0, (sum, line) => sum + line.amount);
  double get total => subtotal - discount;
  double get balance => total - tender.total;

  Bill copyWith({bool? voided}) {
    return Bill(
      id: id,
      number: number,
      at: at,
      customerName: customerName,
      phone: phone,
      source: source,
      lines: lines,
      discount: discount,
      tender: tender,
      note: note,
      voided: voided ?? this.voided,
    );
  }
}

class CashEntry {
  const CashEntry({
    required this.id,
    required this.kind,
    required this.amount,
    required this.reason,
    required this.category,
    required this.at,
    required this.actor,
    this.fromBill = false,
  });

  final String id;
  final CashKind kind;
  final double amount;
  final String reason;
  final String category;
  final DateTime at;
  final String actor;
  final bool fromBill;
}

class ProductItem {
  const ProductItem({
    required this.id,
    required this.name,
    required this.brand,
    required this.category,
    required this.unit,
    required this.purchasePrice,
    required this.sellingPrice,
    required this.qty,
    required this.minimum,
    required this.use,
    required this.supplier,
  });

  final String id;
  final String name;
  final String brand;
  final String category;
  final String unit;
  final double purchasePrice;
  final double sellingPrice;
  final double qty;
  final double minimum;
  final ProductUse use;
  final String supplier;

  bool get low => qty <= minimum;
  double get stockValue => qty * purchasePrice;

  ProductItem copyWith({double? qty, double? sellingPrice, double? minimum, double? purchasePrice}) {
    return ProductItem(
      id: id,
      name: name,
      brand: brand,
      category: category,
      unit: unit,
      purchasePrice: purchasePrice ?? this.purchasePrice,
      sellingPrice: sellingPrice ?? this.sellingPrice,
      qty: qty ?? this.qty,
      minimum: minimum ?? this.minimum,
      use: use,
      supplier: supplier,
    );
  }
}

class StockMove {
  const StockMove({
    required this.id,
    required this.productId,
    required this.reason,
    required this.qty,
    required this.at,
    required this.actor,
    required this.note,
    this.supplier,
    this.billNumber,
  });

  final String id;
  final String productId;
  final StockReason reason;
  final double qty;
  final DateTime at;
  final String actor;
  final String note;
  final String? supplier;
  final String? billNumber;
}

class LeaveRequest {
  const LeaveRequest({
    required this.id,
    required this.staffId,
    required this.type,
    required this.from,
    required this.to,
    required this.halfDay,
    required this.reason,
    required this.status,
    this.decisionNote,
  });

  final String id;
  final String staffId;
  final LeaveType type;
  final DateTime from;
  final DateTime to;
  final bool halfDay;
  final String reason;
  final LeaveStatus status;
  final String? decisionNote;

  LeaveRequest copyWith({LeaveStatus? status, String? decisionNote}) {
    return LeaveRequest(
      id: id,
      staffId: staffId,
      type: type,
      from: from,
      to: to,
      halfDay: halfDay,
      reason: reason,
      status: status ?? this.status,
      decisionNote: decisionNote ?? this.decisionNote,
    );
  }
}

class Customer {
  const Customer({
    required this.id,
    required this.name,
    required this.phone,
    required this.visits,
    required this.spend,
    this.gender,
    this.notes,
    this.firstVisit,
    this.lastVisit,
  });

  final String id;
  final String name;
  final String phone;
  final String? gender;
  final String? notes;
  final int visits;
  final double spend;
  final DateTime? firstVisit;
  final DateTime? lastVisit;

  Customer copyWith({
    String? name,
    String? gender,
    String? notes,
    int? visits,
    double? spend,
    DateTime? lastVisit,
  }) {
    return Customer(
      id: id,
      name: name ?? this.name,
      phone: phone,
      gender: gender ?? this.gender,
      notes: notes ?? this.notes,
      visits: visits ?? this.visits,
      spend: spend ?? this.spend,
      firstVisit: firstVisit,
      lastVisit: lastVisit ?? this.lastVisit,
    );
  }
}

class WaitEntry {
  const WaitEntry({
    required this.id,
    required this.name,
    required this.phone,
    required this.serviceId,
    required this.serviceName,
    required this.minutes,
    required this.at,
    required this.expected,
  });

  final String id;
  final String name;
  final String phone;
  final String serviceId;
  final String serviceName;
  final int minutes;
  final DateTime at;
  final String expected;
}

class ActivityEntry {
  const ActivityEntry({
    required this.id,
    required this.at,
    required this.actor,
    required this.roleLabel,
    required this.action,
    this.branchName = '',
  });

  final String id;
  final DateTime at;
  final String actor;
  final String roleLabel;
  final String action;
  final String branchName;
}

class ShopNotification {
  const ShopNotification({
    required this.id,
    required this.branchId,
    required this.branchName,
    required this.title,
    required this.body,
    required this.at,
    required this.read,
    required this.forOwner,
    required this.forDesk,
  });

  final String id;
  final String branchId;
  final String branchName;
  final String title;
  final String body;
  final DateTime at;
  final bool read;
  final bool forOwner;
  final bool forDesk;

  ShopNotification copyWith({bool? read}) {
    return ShopNotification(
      id: id,
      branchId: branchId,
      branchName: branchName,
      title: title,
      body: body,
      at: at,
      read: read ?? this.read,
      forOwner: forOwner,
      forDesk: forDesk,
    );
  }
}

class DayCloseSnapshot {
  const DayCloseSnapshot({required this.at, required this.expected, required this.counted});

  final DateTime at;
  final double expected;
  final double counted;

  double get difference => counted - expected;
}

class BranchDesk {
  const BranchDesk({
    required this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.manager,
    required this.open,
    required this.staff,
    required this.bookings,
    required this.bills,
    required this.cashEntries,
    required this.products,
    required this.stockMoves,
    required this.leaves,
    required this.customers,
    required this.waiting,
    required this.salaries,
    required this.overrides,
    required this.attendanceEdits,
    this.pastCloses = const [],
    required this.openingCash,
    required this.countedCash,
    required this.dayClosed,
    required this.billSequence,
  });

  final String id;
  final String name;
  final String address;
  final String phone;
  final String manager;
  final bool open;
  final List<StaffMember> staff;
  final List<Booking> bookings;
  final List<Bill> bills;
  final List<CashEntry> cashEntries;
  final List<ProductItem> products;
  final List<StockMove> stockMoves;
  final List<LeaveRequest> leaves;
  final List<Customer> customers;
  final List<WaitEntry> waiting;
  final List<SalaryDraft> salaries;
  final List<ClashOverride> overrides;
  final Map<String, AttendanceMark> attendanceEdits;
  final List<DayCloseSnapshot> pastCloses;
  final double openingCash;
  final double? countedCash;
  final bool dayClosed;
  final int billSequence;

  BranchDesk copyWith({
    String? name,
    String? address,
    String? phone,
    String? manager,
    bool? open,
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
    List<DayCloseSnapshot>? pastCloses,
    double? openingCash,
    Object? countedCash = _keep,
    bool? dayClosed,
    int? billSequence,
  }) {
    return BranchDesk(
      id: id,
      name: name ?? this.name,
      address: address ?? this.address,
      phone: phone ?? this.phone,
      manager: manager ?? this.manager,
      open: open ?? this.open,
      staff: staff ?? this.staff,
      bookings: bookings ?? this.bookings,
      bills: bills ?? this.bills,
      cashEntries: cashEntries ?? this.cashEntries,
      products: products ?? this.products,
      stockMoves: stockMoves ?? this.stockMoves,
      leaves: leaves ?? this.leaves,
      customers: customers ?? this.customers,
      waiting: waiting ?? this.waiting,
      salaries: salaries ?? this.salaries,
      overrides: overrides ?? this.overrides,
      attendanceEdits: attendanceEdits ?? this.attendanceEdits,
      pastCloses: pastCloses ?? this.pastCloses,
      openingCash: openingCash ?? this.openingCash,
      countedCash: identical(countedCash, _keep) ? this.countedCash : countedCash as double?,
      dayClosed: dayClosed ?? this.dayClosed,
      billSequence: billSequence ?? this.billSequence,
    );
  }
}

const _keep = Object();

class ClashOverride {
  const ClashOverride({
    required this.id,
    required this.at,
    required this.staffName,
    required this.customerName,
    required this.reason,
    required this.actor,
    required this.serviceName,
  });

  final String id;
  final DateTime at;
  final String staffName;
  final String customerName;
  final String reason;
  final String actor;
  final String serviceName;
}

class SalaryDraft {
  const SalaryDraft({
    required this.id,
    required this.staffId,
    required this.month,
    required this.workingDays,
    required this.present,
    required this.halfDays,
    required this.paidLeave,
    required this.unpaidLeave,
    required this.lateDays,
    required this.overtimeHours,
    required this.overtimeRate,
    required this.monthlySalary,
    required this.commission,
    required this.bonus,
    required this.advanceRecovery,
    required this.status,
    this.payKind = PayKind.monthly,
    this.dailyRate = 0,
    this.hourlyRate = 0,
    this.hoursWorked = 0,
    this.commissionPercent = 0,
    this.bonusReason,
    this.otherDeduction = 0,
    this.deductionReason,
    this.paidMode,
    this.paidOn,
    this.reference,
  });

  final String id;
  final String staffId;
  final DateTime month;
  final int workingDays;
  final int present;
  final int halfDays;
  final int paidLeave;
  final int unpaidLeave;
  final int lateDays;
  final double overtimeHours;
  final double overtimeRate;
  final double monthlySalary;
  final double commission;
  final PayKind payKind;
  final double dailyRate;
  final double hourlyRate;
  final double hoursWorked;
  final double commissionPercent;
  final double bonus;
  final String? bonusReason;
  final double otherDeduction;
  final String? deductionReason;
  final double advanceRecovery;
  final SalaryStatus status;
  final String? paidMode;
  final DateTime? paidOn;
  final String? reference;

  double get perDay => workingDays == 0 ? 0 : monthlySalary / workingDays;
  double get unpaidDays => unpaidLeave + (halfDays * 0.5);
  double get payableDays => present + (halfDays * 0.5);
  bool get _keepsMonthlyBase => payKind == PayKind.monthly || payKind == PayKind.salaryPlusCommission;
  double get basePay => switch (payKind) {
    PayKind.monthly || PayKind.salaryPlusCommission => monthlySalary,
    PayKind.daily => dailyRate * payableDays,
    PayKind.hourly => hourlyRate * hoursWorked,
    PayKind.commissionOnly => 0,
  };
  double get unpaidDeduction => _keepsMonthlyBase ? unpaidDays * perDay : 0;
  double get overtimePay => overtimeHours * overtimeRate;
  double get gross => basePay + overtimePay + commission + bonus;
  double get deductions => unpaidDeduction + advanceRecovery + otherDeduction;
  double get net => gross - deductions;

  SalaryDraft copyWith({
    double? bonus,
    String? bonusReason,
    double? otherDeduction,
    String? deductionReason,
    double? advanceRecovery,
    double? commission,
    SalaryStatus? status,
    String? paidMode,
    DateTime? paidOn,
    String? reference,
  }) {
    return SalaryDraft(
      id: id,
      staffId: staffId,
      month: month,
      workingDays: workingDays,
      present: present,
      halfDays: halfDays,
      paidLeave: paidLeave,
      unpaidLeave: unpaidLeave,
      lateDays: lateDays,
      overtimeHours: overtimeHours,
      overtimeRate: overtimeRate,
      monthlySalary: monthlySalary,
      commission: commission ?? this.commission,
      payKind: payKind,
      dailyRate: dailyRate,
      hourlyRate: hourlyRate,
      hoursWorked: hoursWorked,
      commissionPercent: commissionPercent,
      bonus: bonus ?? this.bonus,
      bonusReason: bonusReason ?? this.bonusReason,
      otherDeduction: otherDeduction ?? this.otherDeduction,
      deductionReason: deductionReason ?? this.deductionReason,
      advanceRecovery: advanceRecovery ?? this.advanceRecovery,
      status: status ?? this.status,
      paidMode: paidMode ?? this.paidMode,
      paidOn: paidOn ?? this.paidOn,
      reference: reference ?? this.reference,
    );
  }
}
