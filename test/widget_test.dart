import 'package:flutter_test/flutter_test.dart';
import 'package:mi_bolsillo/main.dart';

void main() {
  testWidgets('App arranca sin errores', (WidgetTester tester) async {
    await tester.pumpWidget(const MiBolsilloApp());
    expect(find.text('MiBolsillo'), findsOneWidget);
  });
}
