import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:papa_bear_crm/app/papa_bear_app.dart';

void main() {
  testWidgets('login offers both shop roles', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: PapaBearApp()));
    expect(find.text('PapaBear'), findsWidgets);
    expect(find.text('Reception'), findsOneWidget);
    expect(find.text('Owner / Manager'), findsOneWidget);
  });

  testWidgets('reception password opens the counter', (tester) async {
    tester.view.physicalSize = const Size(1280, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ProviderScope(child: PapaBearApp()));
    await tester.enterText(find.byType(TextField), 'desk1234');
    await tester.tap(find.text('Enter the counter'));
    await tester.pumpAndSettle();
    expect(find.text('Counter'), findsWidgets);
    expect(find.text('Check availability'), findsOneWidget);
    expect(find.text('Cash in hand'), findsOneWidget);
  });
}
