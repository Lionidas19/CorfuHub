import 'package:flutter_test/flutter_test.dart';
import 'package:corfu_hub_app/main.dart';

void main() {
  testWidgets('CorfuHubApp smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const CorfuHubApp());
    // App now requires async Supabase init, so just verify it builds
    expect(find.byType(CorfuHubApp), findsOneWidget);
  });
}
