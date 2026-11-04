import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papa_bear_crm/data/mock/crm_controller.dart';
import 'package:papa_bear_crm/data/mock/seed_data.dart';

void main() {
  test('each branch keeps its own counter', () {
    final state = buildSeed();
    expect(state.desk.name, 'MG Road');
    expect(state.branches, hasLength(3));
    expect(state.staff.any((person) => person.name == 'Rahul K'), isTrue);
    expect(state.unreadFor(UserRole.owner), 7);
    expect(state.unreadFor(UserRole.receptionist), 3);

    final container = ProviderContainer();
    addTearDown(container.dispose);
    final crm = container.read(crmProvider.notifier);
    expect(crm.switchBranch('kk'), isNotNull);

    crm.login(UserRole.owner, 'owner1234');
    expect(crm.switchBranch('ed'), isNull);
    final ed = container.read(crmProvider);
    expect(ed.desk.name, 'Edappally');
    expect(ed.staff.any((person) => person.name == 'Nithin K'), isTrue);
    expect(ed.staff.any((person) => person.name == 'Rahul K'), isFalse);
    expect(ed.todaySales, 350);

    expect(crm.switchBranch('kk'), isNull);
    expect(container.read(crmProvider).desk.name, 'Kakkanad');
    expect(container.read(crmProvider).dayClosed, isTrue);
    expect(crm.switchBranch('ed'), isNull);

    crm.login(UserRole.receptionist, 'desk1234');
    expect(crm.switchBranch('kk'), 'Kakkanad is paused. Ask the owner to open it.');
    expect(container.read(crmProvider).desk.name, 'Edappally');
  });
}
