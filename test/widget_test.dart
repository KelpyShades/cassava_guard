import 'package:cassava_guard/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Login screen renders', (WidgetTester tester) async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await tester.pumpWidget(const CassavaGuardApp(startLoggedIn: false));
    await tester.pumpAndSettle();
    expect(find.textContaining('CassavaGuard'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });
}
