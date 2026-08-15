import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// pumpWidget wraps a widget in MaterialApp with dark theme.
// Once provider is added as a dependency, extend this with MultiProvider support.
Future<void> pumpWidget(
  WidgetTester tester,
  Widget widget,
) async {
  await tester.pumpWidget(
    MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark(),
      home: widget,
    ),
  );
}
