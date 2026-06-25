
import 'package:flutter_test/flutter_test.dart';

import 'package:project/app/code_cryptogram_app.dart';

void main() {
  testWidgets('App navigation test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const CryptogramApp());

    // Verify that we are on the Home Screen.
    expect(find.text('CODE BUSTERS'), findsOneWidget);
    expect(find.text('PLAY'), findsOneWidget);

    // Tap the PLAY button and trigger a frame.
    await tester.tap(find.text('PLAY'));
    await tester.pumpAndSettle();

    // Now we should be on the Game Screen.
    // Verify that 'SOLUTION' is displayed.
    expect(find.text('SOLUTION'), findsOneWidget);
    expect(find.text('LEVEL 1'), findsOneWidget);
  });
}
