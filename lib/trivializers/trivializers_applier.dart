
import 'constant_computation_trivializer.dart';
import 'mult_one_trivializer.dart';
import 'mult_zero_trivializer.dart';
import 'single_child_trivializer.dart';
import 'trivializer.dart';
import 'package:formula_transformator/utils.dart';
import 'package:formula_transformator/values/value.dart';

import 'add_zero_trivializer.dart';

const trivializers = <Trivializer>[
  AddZeroTrivializer(),
  MultOneTrivializer(),
  MultZeroTrivializer(),
  SingleChildTrivializer(),
  ConstantComputationTrivializer(),
];

Value apply_trivializers(Value value) {
  var tempValue = value;
  var applied = true;
  while (applied) {
    applied = false;
    for (var trivializer in trivializers) {
      var transformed = mountValueAt(tempValue, (e) => trivializer.transform(e));
      if (transformed != null) {
        tempValue = transformed;
        applied = true;
        break;
      }
    }
  }
  return tempValue;
}
