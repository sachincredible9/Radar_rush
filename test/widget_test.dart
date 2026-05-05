import 'package:flutter_test/flutter_test.dart';
import 'package:airplane_landing/main.dart';

void main() {
  testWidgets('App should load', (WidgetTester tester) async {
    await tester.pumpWidget(const AirplaneLandingApp());
    expect(find.byType(AirplaneLandingApp), findsOneWidget);
  });
}
