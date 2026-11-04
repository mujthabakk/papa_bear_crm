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
  ];

  final leaves = [
    LeaveRequest(id: 'lv1', staffId: 'st7', type: LeaveType.casual, from: at(0, 0, 0), to: at(0, 0, 0), halfDay: false, reason: 'Family function', status: LeaveStatus.approved, decisionNote: 'Approved last night'),
    LeaveRequest(id: 'lv2', staffId: 'st8', type: LeaveType.sick, from: at(-1, 0, 0), to: at(-1, 0, 0), halfDay: false, reason: 'Fever', status: LeaveStatus.pending),
    LeaveRequest(id: 'lv3', staffId: 'st1', type: LeaveType.casual, from: at(20, 0, 0), to: at(20, 0, 0), halfDay: false, reason: 'Personal work', status: LeaveStatus.approved),
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
        commission: person.roleTitle == 'Helper' ? 0 : 800,
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
        commission: person.roleTitle == 'Helper' ? 0 : 300,
      ),
    );
  }

  final cashEntries = [
    CashEntry(id: 'c1', kind: CashKind.cashOut, amount: 150, reason: 'Tea for staff', category: 'Food', at: at(0, 9, 20), actor: 'Reception'),
    CashEntry(id: 'c2', kind: CashKind.cashOut, amount: 400, reason: 'Floor cleaning', category: 'Cleaning', at: at(0, 9, 30), actor: 'Reception'),
    CashEntry(id: 'c3', kind: CashKind.cashOut, amount: 1000, reason: 'Advance to Anil M', category: 'Staff advance', at: at(0, 10, 0), actor: 'Reception'),
    CashEntry(id: 'c4', kind: CashKind.cashOut, amount: 2500, reason: 'Electricity bill', category: 'Electricity', at: at(8, 17, 0), actor: 'Owner'),
    CashEntry(id: 'c5', kind: CashKind.cashOut, amount: 18000, reason: 'Shop rent', category: 'Rent', at: at(10, 11, 0), actor: 'Owner'),
  ];

  final activity = [
    ActivityEntry(id: 'a1', at: at(0, 9, 5), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Opened the day with ₹2,000 in the drawer'),
    ActivityEntry(id: 'a2', at: at(0, 9, 20), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Cash out ₹150 · Tea for staff'),
    ActivityEntry(id: 'a3', at: at(0, 10, 0), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Cash out ₹1,000 · Advance to Anil M'),
    ActivityEntry(id: 'a4', at: at(0, 10, 2), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Created bill PB-2411 · Joseph P · ₹350'),
    ActivityEntry(id: 'a5', at: at(0, 10, 18), actor: 'Reception', roleLabel: 'Reception', branchName: 'MG Road', action: 'Marked Meera S late'),
    ActivityEntry(id: 'a6', at: at(0, 8, 40), actor: 'Owner', roleLabel: 'Owner / Manager', branchName: 'MG Road', action: 'Approved Kavya L casual leave'),
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
      WaitEntry(
        id: 'w1',
        name: 'Arun V',
        phone: '9847099001',
        serviceId: 'sv1',
        serviceName: 'Haircut',
        minutes: 30,
        at: at(0, 10, 50),
        expected: 'About 35 min',
      ),
    ],
    salaries: salaries,
    overrides: const [],
    attendanceEdits: const {},
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
  }) {
    return StaffMember(
      id: id,
      name: name,
      code: code,
      roleTitle: role,
      phone: phone,
      joining: DateTime(2024, 4, 2),
      monthlySalary: 15000,
      upiMasked: 'UPI ****2200',
      skills: skills,
      startHour: 10,
      endHour: 19,
      active: true,
      today: today,
      advanceBalance: 0,
      checkIn: inHour == null ? null : at(0, inHour, inMinute ?? 0),
      late: late,
    );
  }

  final edappally = BranchDesk(
    id: 'ed',
    name: 'Edappally',
    address: 'Edappally Junction, Kochi',
    phone: '+91 98470 33002',
    manager: 'Nithin K',
    open: true,
    staff: [
      person(id: 'ed1', name: 'Nithin K', code: 'EMP-101', role: 'Senior Stylist', phone: '9847111001', skills: const ['Haircut', 'Beard trim'], today: AttendanceMark.present, inHour: 9, inMinute: 48),
      person(id: 'ed2', name: 'Sandra P', code: 'EMP-102', role: 'Stylist', phone: '9847111002', skills: const ['Facial', 'Blow dry'], today: AttendanceMark.present, inHour: 10, inMinute: 20, late: true),
      person(id: 'ed3', name: 'Jobin T', code: 'EMP-103', role: 'Helper', phone: '9847111003', skills: const ['Beard trim'], today: AttendanceMark.present, inHour: 9, inMinute: 30),
    ],
    bookings: [
      Booking(id: 'ed-b1', customerName: 'Lekshmi', phone: '9847112001', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, staffId: 'ed1', start: at(0, 10, 0), status: BookingStatus.completed, source: BookingSource.walkIn),
      Booking(id: 'ed-b2', customerName: 'Devika', phone: '9847112002', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, staffId: 'ed1', start: at(0, 11, 30), status: BookingStatus.upcoming, source: BookingSource.online),
    ],
    bills: [
      Bill(
        id: 'ed-bill1',
        number: 'ED-1101',
        at: at(0, 10, 5),
        customerName: 'Lekshmi',
        phone: '9847112001',
        source: BookingSource.walkIn,
        lines: const [BillLine(name: 'Haircut', qty: 1, price: 350, staffName: 'Nithin K')],
        discount: 0,
        tender: const Tender(cash: 350),
      ),
    ],
    cashEntries: [
      CashEntry(id: 'ed-c1', kind: CashKind.cashOut, amount: 80, reason: 'Tea', category: 'Food', at: at(0, 9, 40), actor: 'Reception'),
    ],
    products: const [
      ProductItem(id: 'ed-p1', name: 'Hair colour 5.0', brand: "L'Oreal", category: 'Colour', unit: 'gram', purchasePrice: 420, sellingPrice: 0, qty: 12, minimum: 6, use: ProductUse.inShop, supplier: 'Hue Traders'),
      ProductItem(id: 'ed-p2', name: 'Shampoo 1L', brand: 'Dove', category: 'Hair', unit: 'ml', purchasePrice: 280, sellingPrice: 450, qty: 2, minimum: 4, use: ProductUse.retail, supplier: 'Glow Supply'),
      ProductItem(id: 'ed-p3', name: 'Blade pack', brand: 'Gillette', category: 'Tools', unit: 'piece', purchasePrice: 12, sellingPrice: 0, qty: 22, minimum: 10, use: ProductUse.inShop, supplier: 'City Wholesale'),
    ],
    stockMoves: [
      StockMove(id: 'ed-sm1', productId: 'ed-p2', reason: StockReason.sold, qty: -1, at: at(0, 10, 12), actor: 'Reception', note: 'Retail bottle'),
    ],
    leaves: [
      LeaveRequest(id: 'ed-l1', staffId: 'ed2', type: LeaveType.casual, from: at(-1, 0, 0), to: at(-1, 0, 0), halfDay: true, reason: 'Bank work', status: LeaveStatus.pending),
    ],
    customers: [
      Customer(id: 'ed-cu1', name: 'Lekshmi', phone: '9847112001', visits: 1, spend: 350, gender: 'Female', firstVisit: at(0, 10, 5), lastVisit: at(0, 10, 5)),
    ],
    waiting: [
      WaitEntry(id: 'ed-w1', name: 'Maya T', phone: '9847112003', serviceId: 'sv1', serviceName: 'Haircut', minutes: 30, at: at(0, 10, 55), expected: 'About 20 min'),
    ],
    salaries: const [],
    overrides: const [],
    attendanceEdits: const {},
    openingCash: 1500,
    countedCash: null,
    dayClosed: false,
    billSequence: 1102,
  );

  final kakkanad = BranchDesk(
    id: 'kk',
    name: 'Kakkanad',
    address: 'Seaport-Airport Road, Kakkanad',
    phone: '+91 98470 44003',
    manager: 'Arya M',
    open: false,
    staff: [
      person(id: 'kk1', name: 'Arya M', code: 'EMP-201', role: 'Stylist', phone: '9847222001', skills: const ['Haircut', 'Hair spa'], today: AttendanceMark.unmarked),
      person(id: 'kk2', name: 'Fahad K', code: 'EMP-202', role: 'Helper', phone: '9847222002', skills: const ['Beard trim'], today: AttendanceMark.unmarked),
    ],
    bookings: const [],
    bills: [
      Bill(
        id: 'kk-bill1',
        number: 'KK-901',
        at: at(1, 16, 10),
        customerName: 'Vishnu',
        phone: '9847223001',
        source: BookingSource.walkIn,
        lines: const [BillLine(name: 'Beard trim', qty: 1, price: 150, staffName: 'Fahad K')],
        discount: 0,
        tender: const Tender(upi: 150),
      ),
    ],
    cashEntries: const [],
    products: const [
      ProductItem(id: 'kk-p1', name: 'Hair serum', brand: 'Streax', category: 'Hair', unit: 'ml', purchasePrice: 210, sellingPrice: 650, qty: 1, minimum: 5, use: ProductUse.retail, supplier: 'Glow Supply'),
      ProductItem(id: 'kk-p2', name: 'Shampoo 1L', brand: 'Dove', category: 'Hair', unit: 'ml', purchasePrice: 280, sellingPrice: 450, qty: 6, minimum: 4, use: ProductUse.retail, supplier: 'Glow Supply'),
    ],
    stockMoves: const [],
    leaves: const [],
    customers: [
      Customer(id: 'kk-cu1', name: 'Vishnu', phone: '9847223001', visits: 1, spend: 150, gender: 'Male', firstVisit: at(1, 16, 10), lastVisit: at(1, 16, 10)),
    ],
    waiting: const [],
    salaries: const [],
    overrides: const [],
    attendanceEdits: const {},
    openingCash: 1000,
    countedCash: 1200,
    dayClosed: true,
    billSequence: 902,
  );

  return [edappally, kakkanad];
}
