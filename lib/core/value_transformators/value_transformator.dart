
import 'package:formula_transformator/core/values/value.dart';

abstract class ValueTransformator {
  List<Value> transform(Value value);
}