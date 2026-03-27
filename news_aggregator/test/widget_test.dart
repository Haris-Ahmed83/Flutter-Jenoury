import 'package:flutter_test/flutter_test.dart';
import 'package:news_aggregator/main.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    await tester.pumpWidget(const NewsFlowApp());
    expect(find.text('NewsFlow'), findsOneWidget);
  });
}
