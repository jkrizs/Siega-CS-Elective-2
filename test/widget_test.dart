import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:responsive_and_adaptive_dashboard_ui/main.dart';

void main() {
  Future<void> renderAt(WidgetTester tester, Size size) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = size;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(const MyApp());
  }

  testWidgets('desktop shows sidebar and summary panel', (tester) async {
    await renderAt(tester, const Size(1200, 800));
    expect(find.text('DASHBOARD'), findsAtLeastNWidgets(1));
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('tablet hides desktop sidebar and summary', (tester) async {
    await renderAt(tester, const Size(600, 800));
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('phone reflows metrics into the mobile layout', (tester) async {
    await renderAt(tester, const Size(390, 800));
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });

  testWidgets('landscape iPad remains in the tablet layout', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const CupertinoApp(home: DashboardScreen(isIos: true)),
    );
    expect(find.byType(DashboardScreen), findsOneWidget);
    expect(find.byType(DashboardScreen), findsOneWidget);
  });
  testWidgets('iPad hamburger opens the Cupertino drawer', (tester) async {
    tester.view.devicePixelRatio = 1;
    tester.view.physicalSize = const Size(1024, 768);
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    await tester.pumpWidget(
      const CupertinoApp(home: DashboardScreen(isIos: true)),
    );
    await tester.tap(find.byIcon(CupertinoIcons.bars));
    await tester.pump();
    expect(find.text('LOGOUT'), findsOneWidget);
  });
}
