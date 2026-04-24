import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:frontend/main.dart';

void main() {
  testWidgets('HostalApp renders without crashing', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: HostalApp()));
    await tester.pump();

    expect(
      find.byType(MaterialApp),
      findsNothing, // MaterialApp.router is used, not MaterialApp
    );
    expect(
      find.byType(Router<Object>),
      findsOneWidget,
    );
  });
}
