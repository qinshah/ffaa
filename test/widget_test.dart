import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ffaa/main.dart';

void main() {
  testWidgets('FFAA app smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const FfaaApp());

    // Verify that the app title is displayed
    expect(find.text('应用程序'), findsOneWidget);
    
    // Verify that the search field is present
    expect(find.byType(TextField), findsOneWidget);
    
    // Verify that the view toggle button is present
    expect(find.byIcon(Icons.view_list), findsOneWidget);
  });
}