import 'package:flutter_test/flutter_test.dart';
import 'package:quizzcd55/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const QuizzApp());
    expect(find.text('IA Challenge'), findsOneWidget);
  });
}
