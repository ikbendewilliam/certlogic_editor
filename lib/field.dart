import 'package:cert_logic_editor/rule_schema.dart';
import 'package:cert_logic_editor/select.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class Field extends StatefulWidget {
  final ValueNotifier<RuleSchema>? label;
  final List<RuleSchema>? allowedChildren;
  final ValueNotifier<String?>? value;

  const Field({
    this.label,
    required this.allowedChildren,
    Key? key,
    this.value,
  }) : super(key: key);

  @override
  State<Field> createState() => _FieldState();
}

class _FieldState extends State<Field> {
  late final TextEditingController controller;

  @override
  void initState() {
    super.initState();
    controller = TextEditingController(text: widget.value?.value ?? '');
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16),
      color: Colors.primaries[(widget.label?.value.label ?? '').hashCode % Colors.primaries.length],
      child: Row(
        mainAxisSize: MainAxisSize.max,
        children: [
          const SizedBox(width: 2),
          Select(label: widget.label, allowedChildren: widget.allowedChildren),
          const SizedBox(width: 2),
          Expanded(
            child: TextField(
              controller: controller,
              onEditingComplete: () {
                if (!mounted) return;
                widget.value?.value = controller.text;
              },
            ),
          ),
          const SizedBox(width: 2),
        ],
      ),
    );
  }
}
