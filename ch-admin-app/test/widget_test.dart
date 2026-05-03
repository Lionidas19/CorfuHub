import 'package:flutter_test/flutter_test.dart';
import 'package:corfu_hub_admin_app/main.dart';

void main() {
  testWidgets('CorfuHubAdminApp renders admin placeholder',
      (WidgetTester tester) async {
    await tester.pumpWidget(const CorfuHubAdminApp());
    expect(find.text('Admin App — Coming Soon'), findsOneWidget);
  });
}
