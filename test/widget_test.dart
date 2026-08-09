import 'package:flutter_test/flutter_test.dart';
import 'package:onam/main.dart';

void main() {
  testWidgets('Onam Fund App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const OnamFundApp());
    expect(find.byType(OnamFundApp), findsOneWidget);
  });
}
