import 'package:cert_logic_editor/rule_schema.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Select extends StatefulWidget {
  final ValueNotifier<RuleSchema>? label;
  final List<RuleSchema>? allowedChildren;

  const Select({
    required this.label,
    required this.allowedChildren,
    Key? key,
  }) : super(key: key);

  @override
  State<Select> createState() => _SelectState();
}

class _SelectState extends State<Select> {
  late final ValueNotifier<RuleSchema?>? label;

  @override
  void initState() {
    super.initState();
    label = widget.label;
  }

  @override
  Widget build(BuildContext context) {
    if (label == null) return const SizedBox();
    return DropdownButton<RuleSchema>(
      items: (widget.allowedChildren ?? RuleSchemas.baseOptions)
          .map(
            (e) => DropdownMenuItem(
              child: Text(e.label),
              value: e,
            ),
          )
          .toList(),
      onChanged: (newValue) {
        if (!mounted) return;
        setState(() {
          label?.value = newValue ?? RuleSchemas.string;
        });
      },
      value: label?.value,
    );
  }
}
