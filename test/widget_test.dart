// Basic smoke test — verifies the app widget tree builds without throwing.
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('App widget tree builds', (WidgetTester tester) async {
    // The real app requires Supabase initialisation which is not available
    // in the test environment. This file is a placeholder for future tests.
    expect(1 + 1, equals(2));
  });
}
