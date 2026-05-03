import 'package:flutter_test/flutter_test.dart';
import 'package:corfu_hub_owner_app/main.dart';

void main() {
  testWidgets('CorfuHubOwnerApp renders owner placeholder',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CorfuHubOwnerApp());
    expect(find.text('Owner App — Coming Soon'), findsOneWidget);
  });
}
