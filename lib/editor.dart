import 'dart:convert';

import 'package:cert_logic_editor/rule_part.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

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
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (jsonError != null) ...[
            Container(
              width: double.maxFinite,
              color: Colors.red,
              padding: const EdgeInsets.all(4),
              child: Text(
                'An error occured: $jsonError',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
          Expanded(
            child: Row(
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
                  child: InteractiveViewer(
                    constrained: false,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(),
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: transformToWidget(),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Container(
            height: 2,
            color: Colors.black,
          ),
          const Padding(
            padding: EdgeInsets.all(4),
            child: SelectableText(
              'Paste your json on the left side, edit it on the right. Update textfields by pressing ctrl+enter after editing it.',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(4),
            child: SelectableText.rich(
              TextSpan(
                style: const TextStyle(fontSize: 18),
                children: [
                  TextSpan(
                    text: 'Source code on GitHub',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://github.com/ikbendewilliam/certlogic_editor', webOnlyWindowName: '_self');
                      },
                  ),
                  const TextSpan(
                    text: ' | ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'More on CertLogic',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://github.com/ehn-dcc-development/dgc-business-rules/blob/main/certlogic/README.md', webOnlyWindowName: '_self');
                      },
                  ),
                  const TextSpan(
                    text: ' | ',
                    style: TextStyle(color: Colors.black),
                  ),
                  TextSpan(
                    text: 'CertLogic validator',
                    style: const TextStyle(color: Colors.blue),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        launch('https://certlogic-fiddle.vercel.app/', webOnlyWindowName: '_self');
                      },
                  ),
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
