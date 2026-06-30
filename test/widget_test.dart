import 'package:flutter_test/flutter_test.dart';
import 'package:fintrack_pro/main.dart';
import 'package:get/get.dart';

void main() {
  testWidgets('FinTrack Pro MVP render test', (WidgetTester tester) async {
    // Build aplikasi kita
    await tester.pumpWidget(const MyApp());

    // Pastikan GetMaterialApp dari GetX berhasil dirender
    expect(find.byType(GetMaterialApp), findsOneWidget);
  });
}
