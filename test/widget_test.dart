import 'package:flutter_test/flutter_test.dart';
import 'package:login_5/main.dart';

void main() {
  testWidgets('App smoke test - verifies LoginPage loads', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // Verify title JEJAKKU and LOGIN button are displayed.
    expect(find.text('JEJAKKU'), findsOneWidget);
    expect(find.text('LOGIN'), findsOneWidget);
  });
}
