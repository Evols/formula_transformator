
import 'package:formula_transformator/trivializers/trivializer.dart';
import 'package:formula_transformator/values/addition.dart';
import 'package:formula_transformator/values/multiplication.dart';
import 'package:formula_transformator/values/value.dart';

class SingleChildTrivializer implements Trivializer {

  const SingleChildTrivializer();

  @override
  Value? transform(Value value) {
    if (value is Addition || value is Multiplication) {
      final children = value.getChildren();
      if (children.length == 1) {
        return children[0];
      }
    }
    return null;
  }

}
