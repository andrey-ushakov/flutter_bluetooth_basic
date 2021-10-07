import 'package:flutter_test/flutter_test.dart';
// import 'package:battery/battery.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sample test', (WidgetTester tester) async {
    expect(2+2, equals(4));
  });
}
