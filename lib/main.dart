import 'package:cert_logic_editor/editor.dart';
import 'package:cert_logic_editor/rule_schema.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  MyApp({Key? key}) : super(key: key) {
    RuleSchemas.initSchema();
  }

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Cerlogic editor',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const EditorScreen(),
    );
  }
}
