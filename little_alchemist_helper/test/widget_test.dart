import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:little_alchemist_helper/main.dart';
import 'package:little_alchemist_helper/ui/home_shell.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
  });

  testWidgets('Приложение открывается и показывает оболочку', (WidgetTester tester) async {
    await SharedPreferences.getInstance();
    await tester.pumpWidget(const LittleAlchemistBootstrap());
    await tester.pump();
    bool sawShell = false;
    for (int i = 0; i < 80; i++) {
      await tester.runAsync(() async {
        await Future<void>.delayed(const Duration(milliseconds: 50));
      });
      await tester.pump();
      if (find.byType(HomeShell).evaluate().isNotEmpty) {
        sawShell = true;
        break;
      }
    }
    expect(sawShell, isTrue, reason: 'HomeShell не появился за отведённое время');
    expect(find.text('Little Alchemist Helper'), findsOneWidget);
  });
}
