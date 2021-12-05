import 'package:collection/collection.dart';

class RuleSchema {
  final String label;
  final String certLogic;
  List<RuleSchema> allowedChildren;
  bool hasChild;
  bool get hasChildren => allowedChildren.isNotEmpty && !hasChild;

  RuleSchema(
    this.certLogic,
    this.label, {
    this.allowedChildren = const [],
    this.hasChild = false,
  });

  static RuleSchema fromCertLogic(String certLogic) {
    return RuleSchemas.all.firstWhereOrNull((element) => element.certLogic == certLogic) ?? RuleSchemas.string;
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is RuleSchema && other.label == label && other.certLogic == certLogic;
  }

  @override
  int get hashCode {
    return label.hashCode ^ certLogic.hashCode;
  }

  @override
  String toString() {
    return 'RuleSchema(label: $label, certLogic: $certLogic, hasChild: $hasChild)';
  }
}

class RuleSchemas {
  static initSchema() {
    final hasLogicChildren = [
      equals,
      reduce,
      variable,
      plus,
      if_,
      and,
      smallerThan,
      smallerThanOrEqual,
      greaterThan,
      greaterThanOrEqual,
      in_,
      after,
      before,
      notAfter,
      notBefore,
      not,
      plusTime,
    ];
    final logicChildren = [
      ...hasLogicChildren,
      object,
      string,
      number,
      boolean,
      duration,
    ];
    logic.allowedChildren = logicChildren;
    object.allowedChildren = logicChildren;
    for (final child in hasLogicChildren) {
      child.allowedChildren = logicChildren;
    }
  }

  static final all = [
    object,
    string,
    number,
    boolean,
    duration,
    identifier,
    type,
    country,
    version,
    schemaVersion,
    engine,
    engineVersion,
    certificateType,
    language,
    descriptionDescription,
    descriptionChild,
    description,
    validFrom,
    validTo,
    affectedFields,
    logic,
    equals,
    reduce,
    variable,
    plus,
    if_,
    and,
    smallerThan,
    smallerThanOrEqual,
    greaterThan,
    greaterThanOrEqual,
    in_,
    after,
    before,
    notAfter,
    notBefore,
    not,
    plusTime,
  ];

  static final baseOptions = [
    identifier,
    type,
    country,
    version,
    schemaVersion,
    engine,
    engineVersion,
    certificateType,
    description,
    validFrom,
    validTo,
    affectedFields,
    logic,
  ];

  static final object = RuleSchema('', 'Object');
  static final string = RuleSchema('', 'String');
  static final number = RuleSchema('', 'Number');
  static final boolean = RuleSchema('', 'Boolean');
  static final duration = RuleSchema('', 'Duration');
  static final identifier = RuleSchema('Identifier', 'Identifier');
  static final type = RuleSchema('Type', 'Type');
  static final country = RuleSchema('Country', 'Country');
  static final version = RuleSchema('Version', 'Version');
  static final schemaVersion = RuleSchema('SchemaVersion', 'Schema version');
  static final engine = RuleSchema('Engine', 'Engine');
  static final engineVersion = RuleSchema('EngineVersion', 'Engine version');
  static final certificateType = RuleSchema('CertificateType', 'Certificate type');
  static final language = RuleSchema('lang', 'Language');
  static final descriptionDescription = RuleSchema('desc', 'Description');
  static final descriptionChild = RuleSchema('', 'Description object', allowedChildren: [language, descriptionDescription]);
  static final description = RuleSchema('Description', 'Description', allowedChildren: [descriptionChild]);
  static final validFrom = RuleSchema('ValidFrom', 'Valid From');
  static final validTo = RuleSchema('ValidTo', 'Valid To');
  static final affectedFields = RuleSchema('AffectedFields', 'Affected fields', allowedChildren: [string]);
  static final logic = RuleSchema('Logic', 'Logic', hasChild: true);
  static final equals = RuleSchema('===', 'Equals');
  static final reduce = RuleSchema('reduce', 'Reduce');
  static final variable = RuleSchema('var', 'Variable');
  static final plus = RuleSchema('+', 'Plus');
  static final if_ = RuleSchema('if', 'If');
  static final and = RuleSchema('and', 'And');
  static final smallerThan = RuleSchema('<', 'Smaller than');
  static final smallerThanOrEqual = RuleSchema('<=', 'Smaller than or equal');
  static final greaterThan = RuleSchema('>', 'Greater than');
  static final greaterThanOrEqual = RuleSchema('>=', 'Greater than or equal');
  static final in_ = RuleSchema('in', 'In');
  static final after = RuleSchema('after', 'After');
  static final before = RuleSchema('before', 'Before');
  static final notAfter = RuleSchema('not-after', 'Not after');
  static final notBefore = RuleSchema('not-before', 'Not before');
  static final not = RuleSchema('!', 'Not');
  static final plusTime = RuleSchema('plusTime', 'Time plus');
}
