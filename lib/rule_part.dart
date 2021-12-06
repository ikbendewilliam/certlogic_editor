import 'package:cert_logic_editor/field.dart';
import 'package:cert_logic_editor/select.dart';
import 'package:flutter/material.dart';

import 'package:cert_logic_editor/rule_schema.dart';

extension BoolParsing on String {
  bool parseBool() {
    return toLowerCase() == 'true';
  }
}

class RulePart {
  late final ValueNotifier<RuleSchema> key;
  late final RulePart? parent;
  List<RulePart>? children; // Description, AffectedFields & logic-parts
  RulePart? child; // Logic
  ValueNotifier<String?>? value;

  RulePart({
    required this.key,
    required this.parent,
    this.children,
    this.child,
  });

  RulePart.value(dynamic value_, this.parent) {
    if (value_ is bool) {
      key = ValueNotifier(RuleSchemas.boolean);
      value = ValueNotifier(value_.toString());
    } else if (value_ is num) {
      key = ValueNotifier(RuleSchemas.number);
      value = ValueNotifier(value_.toString());
    } else if (value_ is String) {
      key = ValueNotifier(RuleSchemas.string);
      value = ValueNotifier(value_.toString());
    } else {
      key = ValueNotifier(RuleSchemas.literal);
      value = ValueNotifier(value_.toString());
    }
  }

  RulePart.fromJson(MapEntry<String, dynamic> json, this.parent) {
    final jsonValue = json.value;
    key = ValueNotifier(RuleSchema.fromCertLogic(json.key));
    if (key.value.hasChild) {
      child = RulePart.fromJson((jsonValue as Map<String, dynamic>).entries.first, this);
    } else if (key.value.hasChildren && jsonValue is List) {
      children = jsonValue.map((jsonElement) {
        if (jsonElement is Map<String, dynamic>) {
          RulePart child;
          if (key.value == RuleSchemas.description) {
            child = RulePart(key: ValueNotifier(RuleSchemas.descriptionChild), parent: this);
          } else {
            child = RulePart(key: ValueNotifier(RuleSchemas.object), parent: this);
          }
          child.children = jsonElement.entries.map((jsonElementChild) => RulePart.fromJson(jsonElementChild, child)).toList();
          return child;
        }
        if (jsonElement is List) {
          final child = RulePart(key: ValueNotifier(RuleSchemas.list), parent: this);
          child.children = jsonElement.map((jsonElementChild) {
            return RulePart.fromJson((jsonElementChild as Map<String, dynamic>).entries.first, child);
          }).toList();
          return child;
        }
        return RulePart.value(jsonElement, this);
      }).toList();
    } else {
      value = ValueNotifier<String?>(jsonValue.toString());
    }
  }

  dynamic toJson() {
    final key_ = key.value.certLogic;
    if (key_.isEmpty) {
      if (child != null) return child!.toJson();
      if (children != null) {
        if (key.value.childrenAreList) {
          return children!.map((e) => e.toJson()).toList();
        } else {
          return children!.map<Map>((e) => e.toJson()).toList().asMap().map((key, value) => MapEntry(value.keys.first, value.values.first));
        }
      }

      return value?.value.toString() ?? '';
    }
    if (child != null) return {key_: child!.toJson()};
    if (children != null) return {key_: children!.map((e) => e.toJson()).toList()};
    if (value != null) {
      if (key.value == RuleSchemas.boolean) return {key_: value!.value?.parseBool() ?? false};
      if (key.value == RuleSchemas.number) return {key_: num.tryParse(value!.value ?? '') ?? 0};
    }
    return {key_: value?.value.toString() ?? ''};
  }

  Widget toWidget(VoidCallback onChangeData) {
    key.addListener(onChangeData);
    if (children != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Select(
            label: key,
            allowedChildren: parent?.key.value.allowedChildren,
          ),
          Container(
            padding: const EdgeInsets.only(left: 16),
            color: Colors.primaries[key.value.label.hashCode % Colors.primaries.length],
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: children!.map((e) => e.toWidget(onChangeData)).toList(),
            ),
          ),
        ],
      );
    }
    if (child != null) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Select(
            label: key,
            allowedChildren: parent?.key.value.allowedChildren,
          ),
          child!.toWidget(onChangeData),
        ],
      );
    }
    value?.addListener(onChangeData);
    return Field(
      label: key,
      allowedChildren: parent?.key.value.allowedChildren,
      value: value,
      key: GlobalKey(),
    );
  }
}
