
import 'package:formula_transformator/core/trivializers/trivializer.dart';
import 'package:formula_transformator/core/values/addition.dart';
import 'package:formula_transformator/core/values/constant.dart';
import 'package:formula_transformator/core/values/value.dart';

class AddZeroTrivializer implements Trivializer {

  const AddZeroTrivializer();

  @override
  Value? transform(Value value) {
    if (value is Addition) {
      final newChildren = value.children.where((child) => !(child is Constant && child.number == 0.0)).toList();
      if (newChildren.length != value.children.length) {
        return Addition(newChildren);
      }
    }
    return null;
  }

}