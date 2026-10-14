import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mi_app/main.dart';

void main() {
  testWidgets('configura el titulo y renderiza la pantalla inicial', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const MyApp(home: Scaffold(body: Text('EduRA lista'))),
    );

    final app = tester.widget<MaterialApp>(find.byType(MaterialApp));
    expect(app.title, 'EduRA · Ciencias Naturales');
    expect(find.text('EduRA lista'), findsOneWidget);
  });
}
