import 'package:flutter_test/flutter_test.dart';
import 'package:fitness_tracker/main.dart';

void main() {
  testWidgets('App launches without errors', (WidgetTester tester) async {
    await tester.pumpWidget(const FitTrackApp());
    expect(find.text('Good Morning'), findsAny);
  });
}
