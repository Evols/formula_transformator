
import 'package:formula_transformator/core/values/value.dart';

abstract class Trivializer {
  Value? transform(Value value);

  const Trivializer();
}