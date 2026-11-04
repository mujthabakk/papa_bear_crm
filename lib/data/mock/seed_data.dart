import 'package:papa_bear_crm/core/format/pb_format.dart';
import 'package:papa_bear_crm/data/mock/crm_state.dart';
import 'package:papa_bear_crm/data/models/models.dart';

CrmState buildSeed() {
  final now = shopNow();
  DateTime at(int daysAgo, int hour, int minute) =>
      DateTime(now.year, now.month, now.day - daysAgo, hour, minute);

  final services = [
    const ServiceOffer(id: 'sv1', name: 'Haircut', price: 350, minutes: 30),
    const ServiceOffer(id: 'sv2', name: 'Beard trim', price: 150, minutes: 20),
    const ServiceOffer(id: 'sv3', name: 'Hair colour', price: 1800, minutes: 90),
    const ServiceOffer(id: 'sv4', name: 'Hair spa', price: 1200, minutes: 60),
    const ServiceOffer(id: 'sv5', name: 'Facial', price: 900, minutes: 45),
    const ServiceOffer(id: 'sv6', name: 'Blow dry', price: 400, minutes: 25),
  ];

  StaffMember member({
    required String id,
    required String name,
    required String code,
    required String role,
    required String phone,
    required DateTime joining,
    required double salary,
    required String upi,
    required List<String> skills,
    required AttendanceMark today,
    double advance = 0,
    int? inHour,
    int? inMinute,
    bool late = false,
    PayKind payKind = PayKind.monthly,
    double dailyRate = 0,
    double hourlyRate = 0,
    double commissionPercent = 0,
  }) {
    return StaffMember(
      id: id,
      name: name,
      code: code,
      roleTitle: role,
      phone: phone,
      joining: joining,
      monthlySalary: salary,
      upiMasked: upi,
      skills: skills,
      startHour: 10,
      endHour: 19,
      active: true,
      today: today,
      advanceBalance: advance,
      checkIn: inHour == null ? null : at(0, inHour, inMinute ?? 0),
      late: late,
      payKind: payKind,
      dailyRate: dailyRate,
      hourlyRate: hourlyRate,
      commissionPercent: commissionPercent,
    );
  }

  final staff = [
    member(
      id: 'st1',
      name: 'Rahul K',
      code: 'EMP-007',
      role: 'Senior Stylist',
      phone: '9847011220',
      joining: DateTime(2024, 3, 12),
      salary: 18000,
      upi: 'UPI ****4521',
      skills: const ['Haircut', 'Hair colour', 'Beard trim'],
      today: AttendanceMark.present,
      advance: 2000,
      inHour: 9,
      inMinute: 52,
      payKind: PayKind.salaryPlusCommission,
      commissionPercent: 10,
    ),
    member(
      id: 'st2',
      name: 'Anil M',
      code: 'EMP-004',
      role: 'Stylist',
      phone: '9847022331',
      joining: DateTime(2023, 11, 2),
      salary: 16000,
      upi: 'UPI ****1180',
      skills: const ['Haircut', 'Blow dry', 'Beard trim'],
      today: AttendanceMark.present,
      advance: 1000,
      inHour: 9,
      inMinute: 40,
    ),
    member(
      id: 'st3',
      name: 'Meera S',
      code: 'EMP-011',
      role: 'Stylist',
      phone: '9847033442',
      joining: DateTime(2024, 6, 18),
      salary: 17000,
      upi: 'UPI ****7742',
      skills: const ['Hair spa', 'Hair colour', 'Blow dry'],
      today: AttendanceMark.present,
      inHour: 10,
      inMinute: 18,
      late: true,
    ),
    member(
      id: 'st4',
      name: 'Divya P',
      code: 'EMP-015',
      role: 'Colourist',
      phone: '9847044553',
      joining: DateTime(2025, 1, 9),
      salary: 16500,
      upi: 'UPI ****2290',
      skills: const ['Facial', 'Hair spa'],
      today: AttendanceMark.present,
      inHour: 10,
      inMinute: 22,
      late: true,
    ),
    member(
      id: 'st5',
      name: 'Teena Jose',
      code: 'EMP-018',
      role: 'Junior Stylist',
      phone: '9847055664',
      joining: DateTime(2025, 8, 1),
      salary: 14000,
      upi: 'UPI ****6631',
      skills: const ['Haircut', 'Blow dry'],
      today: AttendanceMark.present,
      inHour: 9,
      inMinute: 55,
      payKind: PayKind.hourly,
      hourlyRate: 80,
    ),
    member(
      id: 'st6',
      name: 'Suresh T',
      code: 'EMP-002',
      role: 'Helper',
      phone: '9847066775',
      joining: DateTime(2022, 4, 4),
      salary: 12000,
      upi: 'UPI ****9012',
      skills: const ['Beard trim'],
      today: AttendanceMark.present,
      inHour: 9,
      inMinute: 35,
      payKind: PayKind.daily,
      dailyRate: 450,
    ),
    member(
      id: 'st7',
      name: 'Kavya L',
      code: 'EMP-009',
      role: 'Stylist',
      phone: '9847077886',
      joining: DateTime(2024, 2, 14),
      salary: 15500,
      upi: 'UPI ****3344',
      skills: const ['Haircut', 'Facial'],
      today: AttendanceMark.leave,
    ),
    member(
      id: 'st8',
      name: 'Imran H',
      code: 'EMP-021',
      role: 'Helper',
      phone: '9847088997',
      joining: DateTime(2025, 5, 20),
      salary: 11000,
      upi: 'UPI ****7781',
      skills: const ['Beard trim'],
      today: AttendanceMark.absent,
      payKind: PayKind.commissionOnly,
      commissionPercent: 20,
    ),
    StaffMember(
      id: 'st9',
      name: 'Ravi N',
      code: 'EMP-003',
      roleTitle: 'Stylist',
      phone: '9847000112',
      joining: DateTime(2021, 7, 1),
      monthlySalary: 15000,
      upiMasked: 'UPI ****1008',
      skills: const ['Haircut'],
      startHour: 10,
      endHour: 19,
      active: false,
      today: AttendanceMark.unmarked,
      advanceBalance: 0,
    ),
  ];

  Booking booking({
    required String id,
    required String name,
    required String phone,
    required ServiceOffer service,
    required String staffId,
    required DateTime start,
    required BookingStatus status,
    required BookingSource source,
  }) {
    return Booking(
      id: id,
      customerName: name,
      phone: phone,
      serviceId: service.id,
      serviceName: service.name,
      minutes: service.minutes,
      staffId: staffId,
      start: start,
      status: status,
      source: source,
    );
  }

  final bookings = [
    booking(id: 'b1', name: 'Farhan', phone: '9847002201', service: services[0], staffId: 'st1', start: at(0, 9, 0), status: BookingStatus.completed, source: BookingSource.walkIn),
    booking(id: 'b2', name: 'Joseph P', phone: '9847002202', service: services[0], staffId: 'st1', start: at(0, 9, 30), status: BookingStatus.completed, source: BookingSource.online),
    booking(id: 'b3', name: 'Priya Nair', phone: '9847011111', service: services[0], staffId: 'st1', start: at(0, 10, 30), status: BookingStatus.upcoming, source: BookingSource.online),
    booking(id: 'b4', name: 'Aisha Khan', phone: '9847011112', service: services[0], staffId: 'st1', start: at(0, 11, 15), status: BookingStatus.upcoming, source: BookingSource.online),
    booking(id: 'b5', name: 'Sneha Menon', phone: '9847002203', service: services[1], staffId: 'st2', start: at(0, 9, 40), status: BookingStatus.completed, source: BookingSource.walkIn),
    booking(id: 'b6', name: 'Riya K', phone: '9847002204', service: services[5], staffId: 'st2', start: at(0, 10, 20), status: BookingStatus.completed, source: BookingSource.walkIn),
    booking(id: 'b7', name: 'Fathima', phone: '9847011115', service: services[5], staffId: 'st2', start: at(0, 13, 30), status: BookingStatus.upcoming, source: BookingSource.online),
    booking(id: 'b8', name: 'Diya', phone: '9847002205', service: services[3], staffId: 'st3', start: at(0, 9, 0), status: BookingStatus.completed, source: BookingSource.walkIn),
    booking(id: 'b9', name: 'Rohan Das', phone: '9847011113', service: services[3], staffId: 'st3', start: at(0, 10, 0), status: BookingStatus.arrived, source: BookingSource.online),
    booking(id: 'b10', name: 'Ammu R', phone: '9847002206', service: services[4], staffId: 'st4', start: at(0, 10, 5), status: BookingStatus.completed, source: BookingSource.walkIn),
    booking(id: 'b11', name: 'Neel Joseph', phone: '9847011114', service: services[4], staffId: 'st4', start: at(0, 12, 0), status: BookingStatus.upcoming, source: BookingSource.online),
    booking(id: 'b12', name: 'Hari P', phone: '9847002210', service: services[1], staffId: 'st2', start: at(1, 11, 0), status: BookingStatus.noShow, source: BookingSource.online),
    booking(id: 'b13', name: 'Laya M', phone: '9847002211', service: services[3], staffId: 'st3', start: at(1, 15, 0), status: BookingStatus.cancelled, source: BookingSource.online),
    booking(id: 'b14', name: 'Teena walk-in', phone: '9847002212', service: services[5], staffId: 'st5', start: at(0, 11, 0), status: BookingStatus.completed, source: BookingSource.walkIn),
    booking(id: 'b15', name: 'Suresh trim', phone: '9847002213', service: services[1], staffId: 'st6', start: at(0, 10, 30), status: BookingStatus.completed, source: BookingSource.walkIn),
  ];

  Bill makeBill({
    required String id,
    required int number,
    required DateTime when,
    required String name,
    required String phone,
    required BookingSource source,
    required List<BillLine> lines,
    required Tender tender,
    double discount = 0,
    bool voided = false,
    String? note,
  }) {
    return Bill(
      id: id,
      number: 'PB-$number',
      at: when,
      customerName: name,
      phone: phone,
      source: source,
      lines: lines,
      discount: discount,
      tender: tender,
      note: note,
      voided: voided,
    );
  }

  BillLine line(ServiceOffer service, String staffName) => BillLine(
    name: service.name,
    qty: 1,
    price: service.price,
    staffName: staffName,
  );

  final bills = <Bill>[
    makeBill(id: 'bill1', number: 2410, when: at(0, 9, 5), name: 'Farhan', phone: '9847002201', source: BookingSource.walkIn, lines: [line(services[0], 'Rahul K')], tender: const Tender(cash: 350)),
    makeBill(id: 'bill2', number: 2411, when: at(0, 10, 2), name: 'Joseph P', phone: '9847002202', source: BookingSource.online, lines: [line(services[0], 'Rahul K')], tender: const Tender(upi: 350)),
    makeBill(id: 'bill3', number: 2412, when: at(0, 10, 0), name: 'Sneha Menon', phone: '9847002203', source: BookingSource.walkIn, lines: [line(services[1], 'Anil M')], tender: const Tender(cash: 150)),
    makeBill(id: 'bill4', number: 2413, when: at(0, 10, 45), name: 'Riya K', phone: '9847002204', source: BookingSource.walkIn, lines: [line(services[5], 'Anil M')], tender: const Tender(cash: 400)),
    makeBill(id: 'bill5', number: 2414, when: at(0, 10, 5), name: 'Diya', phone: '9847002205', source: BookingSource.walkIn, lines: [line(services[3], 'Meera S')], tender: const Tender(upi: 1200)),
    makeBill(id: 'bill6', number: 2415, when: at(0, 10, 50), name: 'Ammu R', phone: '9847002206', source: BookingSource.walkIn, lines: [line(services[4], 'Divya P')], tender: const Tender(card: 900)),
    makeBill(
      id: 'bill7',
      number: 2416,
      when: at(0, 10, 40),
      name: 'Counter sale',
      phone: '9847002299',
      source: BookingSource.walkIn,
      lines: const [BillLine(name: 'Shampoo 1L', qty: 1, price: 450, staffName: 'Counter', isProduct: true, productId: 'p2')],
      tender: const Tender(cash: 450),
    ),
  ];

  const pastNames = ['Nikhil', 'Sara', 'Adil', 'Gowri', 'Vivek', 'Hana', 'Joel', 'Maya'];
  for (var day = 1; day <= 12; day++) {
    for (var i = 0; i < 2; i++) {
      final service = services[(day + i) % services.length];
      final stylist = staff[(day + i) % 6];
      final mode = (day + i) % 3;
      final price = service.price;
      bills.add(
        makeBill(
          id: 'past-$day-$i',
          number: 2300 + day * 10 + i,
          when: at(day, 11 + i, 15),
          name: pastNames[(day + i) % pastNames.length],
          phone: '98471${(10000 + day * 20 + i).toString()}',
          source: i == 0 ? BookingSource.online : BookingSource.walkIn,
          lines: [line(service, stylist.name)],
          tender: Tender(
            cash: mode == 0 ? price : 0,
            upi: mode == 1 ? price : 0,
            card: mode == 2 ? price : 0,
          ),
          discount: day == 3 && i == 1 ? 50 : 0,
        ),
      );
    }
  }

  bills.add(
    makeBill(
      id: 'bill-due',
      number: 2418,
      when: at(0, 10, 55),
      name: 'Sandeep R',
      phone: '9847002214',
      source: BookingSource.walkIn,
      lines: [line(services[0], 'Anil M')],
      tender: const Tender(cash: 200),
      note: 'Will pay the rest on UPI this evening',
    ),
  );
  bills.add(
    makeBill(
      id: 'bill-void',
      number: 2388,
      when: at(1, 17, 10),
      name: 'Wrong name',
      phone: '9847002215',
      source: BookingSource.walkIn,
      lines: [line(services[1], 'Anil M')],
      tender: const Tender(cash: 150),
      voided: true,
      note: 'Entered on the wrong customer. Voided by the owner.',
    ),
  );
  bills.add(
    makeBill(
      id: 'bill-mask',
      number: 2390,
      when: at(2, 13, 20),
      name: 'Gowri',
      phone: '9847110020',
      source: BookingSource.walkIn,
      lines: const [BillLine(name: 'Face mask', qty: 2, price: 150, staffName: 'Counter', isProduct: true, productId: 'p4')],
      tender: const Tender(upi: 300),
    ),
  );

  final customers = <Customer>[];
  final ordered = [...bills]..sort((a, b) => a.at.compareTo(b.at));
  for (final bill in ordered) {
    if (bill.voided || bill.customerName == 'Counter sale') continue;
    final index = customers.indexWhere((c) => c.phone == bill.phone);
    if (index < 0) {
      customers.add(
        Customer(
          id: 'cu-${bill.phone}',
          name: bill.customerName,
          phone: bill.phone,
          visits: 1,
          spend: bill.total,
          firstVisit: bill.at,
          lastVisit: bill.at,
          gender: bill.customerName.endsWith('a') || bill.customerName == 'Diya' ? 'Female' : 'Male',
        ),
      );
    } else {
      final current = customers[index];
      customers[index] = current.copyWith(
        visits: current.visits + 1,
        spend: current.spend + bill.total,
        lastVisit: bill.at,
      );
    }
  }
  if (customers.isNotEmpty) {
    customers[0] = customers[0].copyWith(notes: 'Prefers Rahul. No ammonia colour.');
  }
  final gowri = customers.indexWhere((customer) => customer.name == 'Gowri');
  if (gowri >= 0) {
    customers[gowri] = customers[gowri].copyWith(notes: 'Buys the face mask every visit.');
  }

  final products = [
    const ProductItem(id: 'p1', name: 'Hair colour 5.0', brand: "L'Oreal", category: 'Colour', unit: 'gram', purchasePrice: 420, sellingPrice: 0, qty: 2, minimum: 6, use: ProductUse.inShop, supplier: 'Hue Traders'),
    const ProductItem(id: 'p2', name: 'Shampoo 1L', brand: 'Dove', category: 'Hair', unit: 'ml', purchasePrice: 280, sellingPrice: 450, qty: 1, minimum: 4, use: ProductUse.retail, supplier: 'Glow Supply'),
    const ProductItem(id: 'p3', name: 'Conditioner 200ml', brand: 'Dove', category: 'Hair', unit: 'ml', purchasePrice: 90, sellingPrice: 220, qty: 14, minimum: 6, use: ProductUse.retail, supplier: 'Glow Supply'),
    const ProductItem(id: 'p4', name: 'Face mask', brand: 'Mamaearth', category: 'Skin', unit: 'piece', purchasePrice: 40, sellingPrice: 150, qty: 18, minimum: 8, use: ProductUse.retail, supplier: 'Glow Supply'),
    const ProductItem(id: 'p5', name: 'Blade pack', brand: 'Gillette', category: 'Tools', unit: 'piece', purchasePrice: 12, sellingPrice: 0, qty: 40, minimum: 10, use: ProductUse.inShop, supplier: 'City Wholesale'),
    const ProductItem(id: 'p6', name: 'Hair serum', brand: 'Streax', category: 'Hair', unit: 'ml', purchasePrice: 210, sellingPrice: 650, qty: 9, minimum: 5, use: ProductUse.retail, supplier: 'Glow Supply'),
  ];

  final stockMoves = [
    StockMove(id: 'sm1', productId: 'p1', reason: StockReason.purchase, qty: 8, at: at(6, 12, 0), actor: 'Reception', note: 'Weekly colour stock', supplier: 'Hue Traders', billNumber: 'HT-441'),
    StockMove(id: 'sm2', productId: 'p2', reason: StockReason.purchase, qty: 6, at: at(4, 15, 10), actor: 'Reception', note: 'Shampoo carton', supplier: 'Glow Supply', billNumber: 'GS-902'),
    StockMove(id: 'sm3', productId: 'p2', reason: StockReason.sold, qty: -1, at: at(0, 10, 40), actor: 'Reception', note: 'Bill PB-2416'),
    StockMove(id: 'sm4', productId: 'p1', reason: StockReason.used, qty: -6, at: at(2, 16, 0), actor: 'Reception', note: 'Colour services'),
    StockMove(id: 'sm5', productId: 'p5', reason: StockReason.damaged, qty: -2, at: at(3, 18, 20), actor: 'Owner', note: 'Rusted blades written off'),
    StockMove(id: 'sm6', productId: 'p3', reason: StockReason.purchase, qty: 12, at: at(5, 11, 0), actor: 'Reception', note: 'Conditioner case', supplier: 'Glow Supply', billNumber: 'GS-918'),
    StockMove(id: 'sm7', productId: 'p4', reason: StockReason.purchase, qty: 24, at: at(7, 14, 0), actor: 'Owner', note: 'Face mask carton', supplier: 'Glow Supply', billNumber: 'GS-880'),
    StockMove(id: 'sm8', productId: 'p4', reason: StockReason.sold, qty: -2, at: at(2, 13, 20), actor: 'Reception', note: 'Bill PB-2390'),
    StockMove(id: 'sm9', productId: 'p4', reason: StockReason.expired, qty: -4, at: at(9, 18, 0), actor: 'Owner', note: 'Masks past the printed date'),
    StockMove(id: 'sm10', productId: 'p6', reason: StockReason.purchase, qty: 10, at: at(8, 12, 30), actor: 'Reception', note: 'Serum restock', supplier: 'Glow Supply', billNumber: 'GS-870'),
    StockMove(id: 'sm11', productId: 'p6', reason: StockReason.sold, qty: -1, at: at(4, 16, 5), actor: 'Reception', note: 'Retail serum'),
    StockMove(id: 'sm12', productId: 'p5', reason: StockReason.used, qty: -8, at: at(1, 19, 0), actor: 'Reception', note: 'Beard trims'),
    StockMove(id: 'sm13', productId: 'p1', reason: StockReason.correction, qty: 1, at: at(3, 19, 10), actor: 'Owner', note: 'Found one tube behind the colour shelf'),
  ];

  final leaves = [
    LeaveRequest(id: 'lv1', staffId: 'st7', type: LeaveType.casual, from: at(0, 0, 0), to: at(0, 0, 0), halfDay: false, reason: 'Family function', status: LeaveStatus.approved, decisionNote: 'Approved last night'),
    LeaveRequest(id: 'lv2', staffId: 'st8', type: LeaveType.sick, from: at(-1, 0, 0), to: at(-1, 0, 0), halfDay: false, reason: 'Fever', status: LeaveStatus.pending),
    LeaveRequest(id: 'lv3', staffId: 'st1', type: LeaveType.casual, from: at(20, 0, 0), to: at(20, 0, 0), halfDay: false, reason: 'Personal work', status: LeaveStatus.approved),
    LeaveRequest(id: 'lv4', staffId: 'st5', type: LeaveType.casual, from: at(4, 0, 0), to: at(4, 0, 0), halfDay: true, reason: 'College exam', status: LeaveStatus.rejected, decisionNote: 'Too many people off that afternoon'),
    LeaveRequest(id: 'lv5', staffId: 'st4', type: LeaveType.sick, from: at(6, 0, 0), to: at(7, 0, 0), halfDay: false, reason: 'Migraine', status: LeaveStatus.approved, decisionNote: 'Two days, paid'),
  ];

  final previous = DateTime(now.year, now.month - 1);
  final current = DateTime(now.year, now.month);

  SalaryDraft slip({
    required StaffMember person,
    required DateTime month,
    required int present,
    int halfDays = 0,
    int paidLeave = 0,
    int unpaidLeave = 0,
    int lateDays = 0,
    double ot = 0,
    double commission = 0,
    double bonus = 0,
    String? bonusReason,
    double advance = 0,
    double other = 0,
    String? otherReason,
    SalaryStatus status = SalaryStatus.unpaid,
    String? paidMode,
    DateTime? paidOn,
    String? reference,
  }) {
    return SalaryDraft(
      id: 'sal-${person.id}-${month.year}-${month.month}',
      staffId: person.id,
      month: month,
      workingDays: 27,
      present: present,
      halfDays: halfDays,
      paidLeave: paidLeave,
      unpaidLeave: unpaidLeave,
      lateDays: lateDays,
      overtimeHours: ot,
      overtimeRate: 100,
      monthlySalary: person.monthlySalary,
      commission: commission,
      payKind: person.payKind,
      dailyRate: person.dailyRate,
      hourlyRate: person.hourlyRate,
      hoursWorked: person.payKind == PayKind.hourly ? (present + halfDays * 0.5) * 8 + ot : 0,
      commissionPercent: person.commissionPercent,
      bonus: bonus,
      bonusReason: bonusReason,
      otherDeduction: other,
      deductionReason: otherReason,
      advanceRecovery: advance,
      status: status,
      paidMode: paidMode,
      paidOn: paidOn,
      reference: reference,
    );
  }

  final rahul = staff[0];
  final salaries = <SalaryDraft>[
    slip(
      person: rahul,
      month: previous,
      present: 24,
      halfDays: 1,
      paidLeave: 1,
      unpaidLeave: 1,
      lateDays: 2,
      ot: 6,
      commission: 2400,
      bonus: 500,
      bonusReason: 'Festival bonus',
      advance: 2000,
      status: SalaryStatus.paid,
      paidMode: 'UPI',
      paidOn: DateTime(now.year, now.month, 1),
      reference: '4581 2290 7731',
    ),
    slip(person: rahul, month: current, present: 2, lateDays: 0, commission: 400),
  ];

  for (final person in staff.where((s) => s.active && s.id != 'st1')) {
    salaries.add(
      slip(
        person: person,
        month: previous,
        present: 25,
        paidLeave: 1,
        lateDays: person.late ? 3 : 0,
        commission: person.payKind == PayKind.commissionOnly
            ? 1600
            : person.payKind == PayKind.salaryPlusCommission
            ? 800
            : person.roleTitle == 'Helper'
            ? 0
            : 800,
        status: SalaryStatus.paid,
        paidMode: 'Bank',
        paidOn: DateTime(now.year, now.month, 1),
        reference: 'NEFT-${person.code}',
      ),
    );
    salaries.add(
      slip(
        person: person,
        month: current,
        present: person.today == AttendanceMark.present ? 2 : 1,
        unpaidLeave: person.today == AttendanceMark.absent ? 1 : 0,
        commission: person.payKind == PayKind.commissionOnly
            ? 600
            : person.payKind == PayKind.salaryPlusCommission
            ? 300
            : person.roleTitle == 'Helper'
            ? 0
            : 300,
      ),
    );
  }

  final cashEntries = [
    CashEntry(id: 'c1', kind: CashKind.cashOut, amount: 150, reason: 'Tea for staff', category: 'Food', at: at(0, 9, 20), actor: 'Reception'),
    CashEntry(id: 'c2', kind: CashKind.cashOut, amount: 400, reason: 'Floor cleaning', category: 'Cleaning', at: at(0, 9, 30), actor: 'Reception'),
    CashEntry(id: 'c3', kind: CashKind.cashOut, amount: 1000, reason: 'Advance to Anil M', category: 'Staff advance', at: at(0, 10, 0), actor: 'Reception'),
    CashEntry(id: 'c4', kind: CashKind.cashOut, amount: 2500, reason: 'Electricity bill', category: 'Electricity', at: at(8, 17, 0), actor: 'Owner'),
    CashEntry(id: 'c5', kind: CashKind.cashOut, amount: 18000, reason: 'Shop rent', category: 'Rent', at: at(10, 11, 0), actor: 'Owner'),
    CashEntry(id: 'c6', kind: CashKind.cashIn, amount: 500, reason: 'Owner added to the drawer', category: 'Others', at: at(0, 9, 10), actor: 'Owner'),
    CashEntry(id: 'c7', kind: CashKind.cashOut, amount: 320, reason: 'Colour tubes', category: 'Products', at: at(6, 12, 20), actor: 'Owner'),
  ];

  final activity = [
    ActivityEntry(id: 'a1', at: at(0, 9, 5), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Opened the day with ₹2,000 in the drawer'),
    ActivityEntry(id: 'a2', at: at(0, 9, 20), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Cash out ₹150 · Tea for staff'),
    ActivityEntry(id: 'a3', at: at(0, 10, 0), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Cash out ₹1,000 · Advance to Anil M'),
    ActivityEntry(id: 'a4', at: at(0, 10, 2), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Created bill PB-2411 · Joseph P · ₹350'),
    ActivityEntry(id: 'a5', at: at(0, 10, 18), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Marked Meera S late'),
    ActivityEntry(id: 'a6', at: at(0, 8, 40), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'MG Road', action: 'Approved Kavya L casual leave'),
    ActivityEntry(id: 'a7', at: at(0, 9, 10), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'MG Road', action: 'Cash in ₹500 · Owner added to the drawer'),
    ActivityEntry(id: 'a8', at: at(1, 16, 40), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'MG Road', action: 'Override: beard trim forced onto Rahul K for Vivek'),
    ActivityEntry(id: 'a9', at: at(1, 17, 12), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'MG Road', action: 'Voided bill PB-2388'),
    ActivityEntry(id: 'a10', at: at(0, 8, 55), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'Edappally', action: 'Opened Edappally with ₹1,500 in the drawer'),
    ActivityEntry(id: 'a11', at: at(1, 18, 5), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'Kakkanad', action: 'Paused Kakkanad for the floor polish'),
    ActivityEntry(id: 'a12', at: at(2, 11, 0), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'MG Road', action: 'Paid last month salary for Rahul K by UPI'),
  ];

  final mgRoad = BranchDesk(
    id: 'mg',
    name: 'MG Road',
    address: 'MG Road, Kochi',
    phone: '+91 98470 22001',
    manager: 'Owner',
    open: true,
    staff: staff,
    bookings: bookings,
    bills: bills.reversed.toList(),
    cashEntries: cashEntries.reversed.toList(),
    products: products,
    stockMoves: stockMoves.reversed.toList(),
    leaves: leaves,
    customers: customers.reversed.toList(),
    waiting: [
      WaitEntry(id: 'w1', name: 'Arun V', phone: '9847099001', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, at: at(0, 10, 50), expected: 'About 35 min'),
      WaitEntry(id: 'w2', name: 'Nandana', phone: '9847099002', serviceId: 'sv5', serviceName: 'Facial', minutes: 45, at: at(0, 10, 58), expected: 'About 50 min'),
      WaitEntry(id: 'w3', name: 'Irfan', phone: '9847099003', serviceId: 'sv2', serviceName: 'Beard trim', minutes: 20, at: at(0, 11, 2), expected: 'About 15 min'),
    ],
    salaries: salaries,
    overrides: [
      ClashOverride(id: 'ov1', at: at(1, 16, 40), staffName: 'Rahul K', customerName: 'Vivek', reason: 'Regular customer. Priya agreed to start 15 minutes later.', actor: 'Owner', serviceName: 'Beard trim'),
      ClashOverride(id: 'ov2', at: at(5, 12, 10), staffName: 'Anil M', customerName: 'Joel', reason: 'The online booking was a no-show and the chair was free.', actor: 'Owner', serviceName: 'Haircut'),
    ],
    attendanceEdits: {
      attendanceKey('st3', at(2, 10, 0)): AttendanceMark.halfDay,
      attendanceKey('st2', at(3, 10, 0)): AttendanceMark.leave,
    },
    pastCloses: [
      DayCloseSnapshot(at: at(1, 20, 0), expected: 4680, counted: 4560),
      DayCloseSnapshot(at: at(2, 20, 0), expected: 5120, counted: 5160),
      DayCloseSnapshot(at: at(3, 20, 0), expected: 4390, counted: 4390),
    ],
    openingCash: 2000,
    countedCash: null,
    dayClosed: false,
    billSequence: 2417,
  );

  return CrmState(
    session: null,
    shop: const ShopSettings(
      name: 'Glow Unisex Salon',
      address: 'Kochi · three branches',
      phone: '+91 98470 22001',
      discountLimitPercent: 10,
      receptionistEnabled: true,
      commissionEnabled: true,
      commissionPercent: 10,
      overtimeRate: 100,
      paidLeavePerYear: 12,
      workingDays: 27,
      weeklyOff: 'Monday',
      expenseCategories: [
        'Rent',
        'Electricity',
        'Products',
        'Food',
        'Cleaning',
        'Staff advance',
        'Owner withdrawal',
        'Salary',
        'Others',
      ],
      ownerPassword: 'owner1234',
      receptionistPassword: 'desk1234',
    ),
    services: services,
    branches: [mgRoad, ..._otherBranches(at)],
    activeBranchId: 'mg',
    activity: activity.reversed.toList(),
    notifications: [
      ShopNotification(
        id: 'n1',
        branchId: 'mg',
        branchName: 'MG Road',
        title: 'Stock is low',
        body: 'Hair colour 5.0 is down to 2g. The minimum is 6g.',
        at: at(0, 9, 10),
        read: false,
        forOwner: true,
        forDesk: true,
      ),
      ShopNotification(
        id: 'n2',
        branchId: 'mg',
        branchName: 'MG Road',
        title: 'Stock is low',
        body: 'Shampoo 1L has 1 bottle left. The minimum is 4.',
        at: at(0, 9, 12),
        read: false,
        forOwner: true,
        forDesk: true,
      ),
      ShopNotification(
        id: 'n3',
        branchId: 'mg',
        branchName: 'MG Road',
        title: 'Leave waiting',
        body: 'Imran H asked for sick leave tomorrow.',
        at: at(0, 8, 50),
        read: false,
        forOwner: true,
        forDesk: false,
      ),
      ShopNotification(
        id: 'n4',
        branchId: 'mg',
        branchName: 'MG Road',
        title: 'Booking soon',
        body: 'Aisha Khan is booked with Rahul K at 11:15. A walk-in haircut for him is blocked.',
        at: at(0, 10, 40),
        read: false,
        forOwner: true,
        forDesk: true,
      ),
      ShopNotification(
        id: 'n5',
        branchId: 'ed',
        branchName: 'Edappally',
        title: 'Leave waiting',
        body: 'Sandra P asked for a half day tomorrow.',
        at: at(0, 9, 5),
        read: false,
        forOwner: true,
        forDesk: false,
      ),
      ShopNotification(
        id: 'n6',
        branchId: 'ed',
        branchName: 'Edappally',
        title: 'Stock is low',
        body: 'Shampoo 1L is down to 2 bottles.',
        at: at(0, 10, 15),
        read: false,
        forOwner: true,
        forDesk: true,
      ),
      ShopNotification(
        id: 'n7',
        branchId: 'kk',
        branchName: 'Kakkanad',
        title: 'Branch paused',
        body: 'Kakkanad is closed for a floor polish. The desk cannot switch to it until you open it.',
        at: at(1, 18, 0),
        read: false,
        forOwner: true,
        forDesk: false,
      ),
    ],
  );
}

List<BranchDesk> _otherBranches(DateTime Function(int daysAgo, int hour, int minute) at) {
  StaffMember person({
    required String id,
    required String name,
    required String code,
    required String role,
    required String phone,
    required List<String> skills,
    required AttendanceMark today,
    int? inHour,
    int? inMinute,
    bool late = false,
    double advance = 0,
    double salary = 15000,
  }) {
    return StaffMember(
      id: id,
      name: name,
      code: code,
      roleTitle: role,
      phone: phone,
      joining: DateTime(2024, 4, 2),
      monthlySalary: salary,
      upiMasked: 'UPI ****2200',
      skills: skills,
      startHour: 10,
      endHour: 19,
      active: true,
      today: today,
      advanceBalance: advance,
      checkIn: inHour == null ? null : at(0, inHour, inMinute ?? 0),
      late: late,
    );
  }

  final today = at(0, 12, 0);
  final month = DateTime(today.year, today.month);
  final lastMonth = DateTime(month.year, month.month - 1);

  SalaryDraft pay({
    required StaffMember member,
    required DateTime slipMonth,
    required int present,
    int lateDays = 0,
    double commission = 0,
    double advance = 0,
    SalaryStatus status = SalaryStatus.unpaid,
    String? paidMode,
    String? reference,
  }) {
    return SalaryDraft(
      id: 'sal-${member.id}-${slipMonth.year}-${slipMonth.month}',
      staffId: member.id,
      month: slipMonth,
      workingDays: 27,
      present: present,
      halfDays: 0,
      paidLeave: status == SalaryStatus.paid ? 1 : 0,
      unpaidLeave: 0,
      lateDays: lateDays,
      overtimeHours: 0,
      overtimeRate: 100,
      monthlySalary: member.monthlySalary,
      commission: commission,
      bonus: 0,
      otherDeduction: 0,
      advanceRecovery: advance,
      status: status,
      paidMode: paidMode,
      paidOn: status == SalaryStatus.paid ? DateTime(month.year, month.month, 1) : null,
      reference: reference,
    );
  }

  final nithin = person(id: 'ed1', name: 'Nithin K', code: 'EMP-101', role: 'Senior Stylist', phone: '9847111001', skills: const ['Haircut', 'Beard trim'], today: AttendanceMark.present, inHour: 9, inMinute: 48, salary: 17000);
  final sandra = person(id: 'ed2', name: 'Sandra P', code: 'EMP-102', role: 'Stylist', phone: '9847111002', skills: const ['Facial', 'Blow dry'], today: AttendanceMark.present, inHour: 10, inMinute: 20, late: true, salary: 15500);
  final jobin = person(id: 'ed3', name: 'Jobin T', code: 'EMP-103', role: 'Helper', phone: '9847111003', skills: const ['Beard trim'], today: AttendanceMark.present, inHour: 9, inMinute: 30, advance: 500, salary: 12000);
  final arya = person(id: 'kk1', name: 'Arya M', code: 'EMP-201', role: 'Stylist', phone: '9847222001', skills: const ['Haircut', 'Hair spa'], today: AttendanceMark.present, inHour: 9, inMinute: 50, salary: 16000);
  final fahad = person(id: 'kk2', name: 'Fahad K', code: 'EMP-202', role: 'Helper', phone: '9847222002', skills: const ['Beard trim'], today: AttendanceMark.halfDay, inHour: 10, inMinute: 5, advance: 300, salary: 11000);

  final edappally = BranchDesk(
    id: 'ed',
    name: 'Edappally',
    address: 'Edappally Junction, Kochi',
    phone: '+91 98470 33002',
    manager: 'Nithin K',
    open: true,
    staff: [nithin, sandra, jobin],
    bookings: [
      Booking(id: 'ed-b1', customerName: 'Lekshmi', phone: '9847112001', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, staffId: 'ed1', start: at(0, 10, 0), status: BookingStatus.completed, source: BookingSource.walkIn),
      Booking(id: 'ed-b2', customerName: 'Devika', phone: '9847112002', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, staffId: 'ed1', start: at(0, 11, 30), status: BookingStatus.upcoming, source: BookingSource.online),
      Booking(id: 'ed-b3', customerName: 'Ann', phone: '9847112004', serviceId: 'sv5', serviceName: 'Facial', minutes: 45, staffId: 'ed2', start: at(0, 12, 30), status: BookingStatus.upcoming, source: BookingSource.online),
      Booking(id: 'ed-b4', customerName: 'Basil', phone: '9847112005', serviceId: 'sv2', serviceName: 'Beard trim', minutes: 20, staffId: 'ed3', start: at(0, 10, 15), status: BookingStatus.completed, source: BookingSource.walkIn),
      Booking(id: 'ed-b5', customerName: 'Reema', phone: '9847112006', serviceId: 'sv6', serviceName: 'Blow dry', minutes: 25, staffId: 'ed2', start: at(1, 14, 0), status: BookingStatus.noShow, source: BookingSource.online),
    ],
    bills: [
      Bill(id: 'ed-bill1', number: 'ED-1101', at: at(0, 10, 5), customerName: 'Lekshmi', phone: '9847112001', source: BookingSource.walkIn, lines: const [BillLine(name: 'Haircut', qty: 1, price: 350, staffName: 'Nithin K')], discount: 0, tender: const Tender(cash: 350)),
      Bill(id: 'ed-bill2', number: 'ED-1102', at: at(0, 10, 20), customerName: 'Basil', phone: '9847112005', source: BookingSource.walkIn, lines: const [BillLine(name: 'Beard trim', qty: 1, price: 150, staffName: 'Jobin T')], discount: 0, tender: const Tender(upi: 150)),
      Bill(id: 'ed-bill3', number: 'ED-1088', at: at(1, 13, 10), customerName: 'Parvathy', phone: '9847112007', source: BookingSource.online, lines: const [BillLine(name: 'Facial', qty: 1, price: 900, staffName: 'Sandra P')], discount: 50, tender: const Tender(card: 850)),
      Bill(id: 'ed-bill4', number: 'ED-1074', at: at(3, 16, 40), customerName: 'Lekshmi', phone: '9847112001', source: BookingSource.walkIn, lines: const [BillLine(name: 'Shampoo 1L', qty: 1, price: 450, staffName: 'Counter', isProduct: true, productId: 'ed-p2')], discount: 0, tender: const Tender(cash: 200), note: 'Balance still open'),
    ],
    cashEntries: [
      CashEntry(id: 'ed-c1', kind: CashKind.cashOut, amount: 80, reason: 'Tea', category: 'Food', at: at(0, 9, 40), actor: 'Reception'),
      CashEntry(id: 'ed-c2', kind: CashKind.cashIn, amount: 300, reason: 'Float from the manager', category: 'Others', at: at(0, 9, 15), actor: 'Nithin K'),
      CashEntry(id: 'ed-c3', kind: CashKind.cashOut, amount: 1200, reason: 'Advance to Jobin T', category: 'Staff advance', at: at(2, 11, 0), actor: 'Owner'),
    ],
    products: const [
      ProductItem(id: 'ed-p1', name: 'Hair colour 5.0', brand: "L'Oreal", category: 'Colour', unit: 'gram', purchasePrice: 420, sellingPrice: 0, qty: 12, minimum: 6, use: ProductUse.inShop, supplier: 'Hue Traders'),
      ProductItem(id: 'ed-p2', name: 'Shampoo 1L', brand: 'Dove', category: 'Hair', unit: 'ml', purchasePrice: 280, sellingPrice: 450, qty: 2, minimum: 4, use: ProductUse.retail, supplier: 'Glow Supply'),
      ProductItem(id: 'ed-p3', name: 'Blade pack', brand: 'Gillette', category: 'Tools', unit: 'piece', purchasePrice: 12, sellingPrice: 0, qty: 22, minimum: 10, use: ProductUse.inShop, supplier: 'City Wholesale'),
      ProductItem(id: 'ed-p4', name: 'Conditioner 200ml', brand: 'Dove', category: 'Hair', unit: 'ml', purchasePrice: 90, sellingPrice: 220, qty: 8, minimum: 4, use: ProductUse.retail, supplier: 'Glow Supply'),
    ],
    stockMoves: [
      StockMove(id: 'ed-sm1', productId: 'ed-p2', reason: StockReason.sold, qty: -1, at: at(3, 16, 40), actor: 'Reception', note: 'Bill ED-1074'),
      StockMove(id: 'ed-sm2', productId: 'ed-p1', reason: StockReason.purchase, qty: 10, at: at(6, 12, 0), actor: 'Owner', note: 'Colour stock', supplier: 'Hue Traders', billNumber: 'HT-510'),
      StockMove(id: 'ed-sm3', productId: 'ed-p3', reason: StockReason.damaged, qty: -3, at: at(4, 18, 0), actor: 'Jobin T', note: 'Blades dropped in the wash basin'),
      StockMove(id: 'ed-sm4', productId: 'ed-p4', reason: StockReason.purchase, qty: 8, at: at(8, 11, 20), actor: 'Reception', note: 'Conditioner', supplier: 'Glow Supply', billNumber: 'GS-940'),
    ],
    leaves: [
      LeaveRequest(id: 'ed-l1', staffId: 'ed2', type: LeaveType.casual, from: at(-1, 0, 0), to: at(-1, 0, 0), halfDay: true, reason: 'Bank work', status: LeaveStatus.pending),
      LeaveRequest(id: 'ed-l2', staffId: 'ed3', type: LeaveType.sick, from: at(5, 0, 0), to: at(5, 0, 0), halfDay: false, reason: 'Fever', status: LeaveStatus.approved, decisionNote: 'One paid day'),
    ],
    customers: [
      Customer(id: 'ed-cu1', name: 'Lekshmi', phone: '9847112001', visits: 4, spend: 1680, gender: 'Female', notes: 'Comes every Saturday.', firstVisit: at(20, 11, 0), lastVisit: at(0, 10, 5)),
      Customer(id: 'ed-cu2', name: 'Basil', phone: '9847112005', visits: 2, spend: 300, gender: 'Male', firstVisit: at(9, 10, 0), lastVisit: at(0, 10, 20)),
      Customer(id: 'ed-cu3', name: 'Parvathy', phone: '9847112007', visits: 3, spend: 2550, gender: 'Female', firstVisit: at(18, 15, 0), lastVisit: at(1, 13, 10)),
      Customer(id: 'ed-cu4', name: 'Devika', phone: '9847112002', visits: 1, spend: 0, gender: 'Female', notes: 'Online booking at 11:30, not billed yet.', firstVisit: at(0, 11, 30), lastVisit: at(0, 11, 30)),
    ],
    waiting: [
      WaitEntry(id: 'ed-w1', name: 'Maya T', phone: '9847112003', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, at: at(0, 10, 55), expected: 'About 20 min'),
      WaitEntry(id: 'ed-w2', name: 'Chris', phone: '9847112008', serviceId: 'sv2', serviceName: 'Beard trim', minutes: 20, at: at(0, 11, 0), expected: 'About 10 min'),
    ],
    salaries: [
      pay(member: nithin, slipMonth: lastMonth, present: 25, commission: 900, status: SalaryStatus.paid, paidMode: 'UPI', reference: 'ED-UPI-101'),
      pay(member: nithin, slipMonth: month, present: 2, commission: 350),
      pay(member: sandra, slipMonth: lastMonth, present: 24, lateDays: 2, commission: 600, status: SalaryStatus.paid, paidMode: 'Bank', reference: 'NEFT-EMP-102'),
      pay(member: sandra, slipMonth: month, present: 2, lateDays: 1, commission: 200),
      pay(member: jobin, slipMonth: lastMonth, present: 26, advance: 500, status: SalaryStatus.paid, paidMode: 'Cash', reference: 'Drawer'),
      pay(member: jobin, slipMonth: month, present: 2),
    ],
    overrides: [
      ClashOverride(id: 'ed-ov1', at: at(2, 15, 10), staffName: 'Sandra P', customerName: 'Ann', reason: 'Walk-in facial while an online blow dry was still 20 minutes away.', actor: 'Owner', serviceName: 'Facial'),
    ],
    attendanceEdits: {
      attendanceKey('ed2', at(2, 10, 0)): AttendanceMark.halfDay,
    },
    pastCloses: [
      DayCloseSnapshot(at: at(1, 20, 0), expected: 2140, counted: 2100),
      DayCloseSnapshot(at: at(2, 20, 0), expected: 1880, counted: 1880),
    ],
    openingCash: 1500,
    countedCash: null,
    dayClosed: false,
    billSequence: 1103,
  );

  final kakkanad = BranchDesk(
    id: 'kk',
    name: 'Kakkanad',
    address: 'Seaport-Airport Road, Kakkanad',
    phone: '+91 98470 44003',
    manager: 'Arya M',
    open: false,
    staff: [arya, fahad],
    bookings: [
      Booking(id: 'kk-b1', customerName: 'Vishnu', phone: '9847223001', serviceId: 'sv2', serviceName: 'Beard trim', minutes: 20, staffId: 'kk2', start: at(1, 16, 0), status: BookingStatus.completed, source: BookingSource.walkIn),
      Booking(id: 'kk-b2', customerName: 'Meera', phone: '9847223002', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, staffId: 'kk1', start: at(0, 10, 0), status: BookingStatus.completed, source: BookingSource.walkIn),
      Booking(id: 'kk-b3', customerName: 'Amal', phone: '9847223003', serviceId: 'sv4', serviceName: 'Hair spa', minutes: 60, staffId: 'kk1', start: at(0, 11, 0), status: BookingStatus.cancelled, source: BookingSource.online),
    ],
    bills: [
      Bill(id: 'kk-bill1', number: 'KK-901', at: at(1, 16, 10), customerName: 'Vishnu', phone: '9847223001', source: BookingSource.walkIn, lines: const [BillLine(name: 'Beard trim', qty: 1, price: 150, staffName: 'Fahad K')], discount: 0, tender: const Tender(upi: 150)),
      Bill(id: 'kk-bill2', number: 'KK-902', at: at(0, 10, 20), customerName: 'Meera', phone: '9847223002', source: BookingSource.walkIn, lines: const [BillLine(name: 'Haircut', qty: 1, price: 350, staffName: 'Arya M')], discount: 0, tender: const Tender(cash: 350)),
      Bill(id: 'kk-bill3', number: 'KK-880', at: at(4, 15, 0), customerName: 'Sreeja', phone: '9847223004', source: BookingSource.online, lines: const [BillLine(name: 'Hair spa', qty: 1, price: 1200, staffName: 'Arya M')], discount: 0, tender: const Tender(upi: 1200)),
    ],
    cashEntries: [
      CashEntry(id: 'kk-c1', kind: CashKind.cashOut, amount: 40, reason: 'Tea before the polish', category: 'Food', at: at(0, 9, 30), actor: 'Arya M'),
      CashEntry(id: 'kk-c2', kind: CashKind.cashOut, amount: 8000, reason: 'Shop rent', category: 'Rent', at: at(9, 11, 0), actor: 'Owner'),
    ],
    products: const [
      ProductItem(id: 'kk-p1', name: 'Hair serum', brand: 'Streax', category: 'Hair', unit: 'ml', purchasePrice: 210, sellingPrice: 650, qty: 1, minimum: 5, use: ProductUse.retail, supplier: 'Glow Supply'),
      ProductItem(id: 'kk-p2', name: 'Shampoo 1L', brand: 'Dove', category: 'Hair', unit: 'ml', purchasePrice: 280, sellingPrice: 450, qty: 6, minimum: 4, use: ProductUse.retail, supplier: 'Glow Supply'),
      ProductItem(id: 'kk-p3', name: 'Hair mask', brand: 'Streax', category: 'Hair', unit: 'piece', purchasePrice: 80, sellingPrice: 0, qty: 3, minimum: 6, use: ProductUse.inShop, supplier: 'Glow Supply'),
    ],
    stockMoves: [
      StockMove(id: 'kk-sm1', productId: 'kk-p1', reason: StockReason.purchase, qty: 6, at: at(10, 12, 0), actor: 'Owner', note: 'Serum box', supplier: 'Glow Supply', billNumber: 'GS-801'),
      StockMove(id: 'kk-sm2', productId: 'kk-p1', reason: StockReason.sold, qty: -2, at: at(3, 17, 0), actor: 'Arya M', note: 'Retail'),
      StockMove(id: 'kk-sm3', productId: 'kk-p3', reason: StockReason.expired, qty: -2, at: at(2, 18, 30), actor: 'Owner', note: 'Opened jars past the date'),
      StockMove(id: 'kk-sm4', productId: 'kk-p2', reason: StockReason.used, qty: -1, at: at(1, 16, 30), actor: 'Fahad K', note: 'Used on a spa'),
    ],
    leaves: [
      LeaveRequest(id: 'kk-l1', staffId: 'kk2', type: LeaveType.casual, from: at(8, 0, 0), to: at(8, 0, 0), halfDay: false, reason: 'Family function', status: LeaveStatus.rejected, decisionNote: 'Need both people that Saturday'),
    ],
    customers: [
      Customer(id: 'kk-cu1', name: 'Vishnu', phone: '9847223001', visits: 2, spend: 500, gender: 'Male', firstVisit: at(12, 16, 0), lastVisit: at(1, 16, 10)),
      Customer(id: 'kk-cu2', name: 'Meera', phone: '9847223002', visits: 1, spend: 350, gender: 'Female', notes: 'Asked to be told when the branch reopens.', firstVisit: at(0, 10, 20), lastVisit: at(0, 10, 20)),
      Customer(id: 'kk-cu3', name: 'Sreeja', phone: '9847223004', visits: 3, spend: 3100, gender: 'Female', firstVisit: at(24, 15, 0), lastVisit: at(4, 15, 0)),
    ],
    waiting: [
      WaitEntry(id: 'kk-w1', name: 'Rinu', phone: '9847223005', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, at: at(0, 10, 40), expected: 'Was waiting when the branch paused'),
    ],
    salaries: [
      pay(member: arya, slipMonth: lastMonth, present: 24, commission: 1100, status: SalaryStatus.paid, paidMode: 'UPI', reference: 'KK-UPI-201'),
      pay(member: arya, slipMonth: month, present: 1, commission: 350),
      pay(member: fahad, slipMonth: lastMonth, present: 25, advance: 300, status: SalaryStatus.paid, paidMode: 'Bank', reference: 'NEFT-EMP-202'),
      pay(member: fahad, slipMonth: month, present: 1),
    ],
    overrides: [
      ClashOverride(id: 'kk-ov1', at: at(4, 15, 20), staffName: 'Arya M', customerName: 'Sreeja', reason: 'Spa ran long and the next online slot was moved.', actor: 'Owner', serviceName: 'Hair spa'),
    ],
    attendanceEdits: const {},
    pastCloses: [
      DayCloseSnapshot(at: at(1, 20, 0), expected: 1620, counted: 1600),
      DayCloseSnapshot(at: at(2, 20, 0), expected: 980, counted: 1100),
    ],
    openingCash: 1000,
    countedCash: 1200,
    dayClosed: true,
    billSequence: 903,
  );

  return [edappally, kakkanad];
}
