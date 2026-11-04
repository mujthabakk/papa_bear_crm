import 'package:flutter_test/flutter_test.dart';
import 'package:papa_bear_crm/data/mock/seed_data.dart';

void main() {
  test('walk-in haircut is blocked when Rahul is booked at 11:15', () {
    final state = buildSeed();
    final result = state.checkAvailability(serviceId: 'sv1', staffId: 'st1');

    expect(result.blocked, isTrue);
    expect(result.detail, contains('11:15'));
    expect(result.options.any((slot) => slot.staff.name == 'Anil M' && slot.now), isTrue);
    expect(result.options.any((slot) => slot.staff.name == 'Rahul K' && slot.label.contains('11:45')), isTrue);
  });
}
