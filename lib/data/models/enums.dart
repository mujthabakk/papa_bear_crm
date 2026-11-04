enum UserRole { owner, receptionist }

enum BookingStatus { upcoming, arrived, completed, noShow, cancelled }

enum BookingSource { online, walkIn }

enum AttendanceMark { present, absent, halfDay, leave, weeklyOff, unmarked }

enum LeaveType { casual, sick, unpaid }

enum LeaveStatus { pending, approved, rejected }

enum CashKind { cashIn, cashOut }

enum ProductUse { retail, inShop }

enum StockReason { purchase, sold, used, damaged, expired, correction }

enum SalaryStatus { unpaid, paid }

extension UserRoleX on UserRole {
  String get label => switch (this) {
    UserRole.owner => 'Owner / Manager',
    UserRole.receptionist => 'Reception',
  };

  bool get isOwner => this == UserRole.owner;
}

extension BookingStatusX on BookingStatus {
  String get label => switch (this) {
    BookingStatus.upcoming => 'Upcoming',
    BookingStatus.arrived => 'Arrived',
    BookingStatus.completed => 'Done',
    BookingStatus.noShow => 'No-show',
    BookingStatus.cancelled => 'Cancelled',
  };
}

extension BookingSourceX on BookingSource {
  String get label => switch (this) {
    BookingSource.online => 'Online',
    BookingSource.walkIn => 'Walk-in',
  };
}

extension AttendanceMarkX on AttendanceMark {
  String get label => switch (this) {
    AttendanceMark.present => 'Present',
    AttendanceMark.absent => 'Absent',
    AttendanceMark.halfDay => 'Half day',
    AttendanceMark.leave => 'Leave',
    AttendanceMark.weeklyOff => 'Weekly off',
    AttendanceMark.unmarked => 'Not marked',
  };
}

extension LeaveTypeX on LeaveType {
  String get label => switch (this) {
    LeaveType.casual => 'Casual',
    LeaveType.sick => 'Sick',
    LeaveType.unpaid => 'Unpaid',
  };
}

extension LeaveStatusX on LeaveStatus {
  String get label => switch (this) {
    LeaveStatus.pending => 'Pending',
    LeaveStatus.approved => 'Approved',
    LeaveStatus.rejected => 'Rejected',
  };
}

extension CashKindX on CashKind {
  String get label => switch (this) {
    CashKind.cashIn => 'Cash in',
    CashKind.cashOut => 'Cash out',
  };
}

extension ProductUseX on ProductUse {
  String get label => switch (this) {
    ProductUse.retail => 'For sale',
    ProductUse.inShop => 'Used in services',
  };
}

extension StockReasonX on StockReason {
  String get label => switch (this) {
    StockReason.purchase => 'Stock in',
    StockReason.sold => 'Sold',
    StockReason.used => 'Used in service',
    StockReason.damaged => 'Damaged',
    StockReason.expired => 'Expired',
    StockReason.correction => 'Count correction',
  };
}

extension SalaryStatusX on SalaryStatus {
  String get label => switch (this) {
    SalaryStatus.unpaid => 'Unpaid',
    SalaryStatus.paid => 'Paid',
  };
}
