import 'dart:convert';

import 'package:cert_logic_editor/rule_part.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class EditorScreen extends StatefulWidget {
  const EditorScreen({Key? key}) : super(key: key);

  @override
  State<EditorScreen> createState() => EditorScreenState();
}

class EditorScreenState extends State<EditorScreen> {
  final jsonController = TextEditingController();
  Map<String, dynamic>? data;
  List<RulePart>? dataObject;
  String? jsonError;
  final jsonEncoder = const JsonEncoder.withIndent('  ');

  EditorScreenState() {
    jsonController.text = exampleRule;
    jsonController.addListener(_onChangeJson);
    data = jsonDecode(jsonController.value.text);
  }

  @override
  void dispose() {
    jsonController.removeListener(_onChangeJson);
    super.dispose();
  }

  void _onChangeJson() {
    try {
      final converted = jsonDecode(jsonController.value.text);
      if (converted != data) {
        if (!mounted) return;
        setState(() {
          data = converted;
          jsonError = null;
        });
      }
    } catch (e) {
      jsonError = e.toString();
      setState(() {});
    }
  }

  void _onChangeData() {
    final data = dataObject!.map((e) => e.toJson()).toList().fold(<String, dynamic>{}, (Map<String, dynamic> value, element) {
      for (final e in element.entries) {
        value[e.key] = e.value;
      }
      return value;
    });
    final converted = jsonEncoder.convert(data);
    if (converted != jsonController.text) {
      setState(() {
        jsonController.text = jsonEncoder.convert(data);
      });
    }
  }

  List<Widget> transformToWidget() {
    dataObject = data?.entries.map((e) => RulePart.fromJson(e, null)).toList();
    return (dataObject ?? []).map((e) => e.toWidget(_onChangeData)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          Expanded(
            child: TextField(
              controller: jsonController,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              expands: true,
            ),
          ),
          Expanded(
            flex: 2,
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(),
              ),
              child: ListView(
                children: [
                  if (jsonError != null) ...[
                    Container(
                      color: Colors.red,
                      child: Text('An error occured: $jsonError'),
                    ),
                  ],
                  ...transformToWidget(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

const exampleRule = """
{
    "Identifier": "GR-EU-0000",
  "Type": "Acceptance",
  "Country": "EU",
  "Version": "1.0.0",
  "SchemaVersion": "1.0.0",
  "Engine": "CERTLOGIC",
  "EngineVersion": "0.7.5",
  "CertificateType": "General",
  "Description": [
    {
      "lang": "en",
      "desc": "Exactly one type of event."
    },
    {
      "lang": "de",
      "desc": "Es darf nur genau ein Zertifikatstyp enthalten sein."
    },
    {
      "lang": "bg",
      "desc": "Позволено е само едно събитие."
    }
  ],
  "ValidFrom": "2021-06-01T00:00:00Z",
  "ValidTo": "2030-06-01T00:00:00Z",
  "AffectedFields": [
    "r",
    "t",
    "v"
  ],
  "Logic": {
    "===": [
      {
        "reduce": [
          [
            {
              "var": "payload.r"
            },
            {
              "var": "payload.t"
            },
            {
              "var": "payload.v"
            }
          ],
          {
            "+": [
              {
                "var": "accumulator"
              },
              {
                "if": [
                  {
                    "var": "current.0"
                  },
                  1,
                  0
                ]
              }
            ]
          },
          0
        ]
      },
      1
    ]
  }
}
""";
