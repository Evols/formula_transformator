
import 'package:flutter/foundation.dart';
import 'package:formula_transformator/core/trivializers/trivializer.dart';
import 'package:formula_transformator/core/values/addition.dart';
import 'package:formula_transformator/core/values/literal_constant.dart';
import 'package:formula_transformator/core/values/multiplication.dart';
import 'package:formula_transformator/core/values/value.dart';
import 'package:formula_transformator/extensions.dart';

@immutable
class EliminateEqGcdTrivializer implements Trivializer {

  const EliminateEqGcdTrivializer();

  @override
  Value? transform(Value value, [bool isEquation = false]) {

    // TODO: equation trivializers

    if (isEquation && value is Addition) {

      // The constant part of each term
      final constantParts = value.terms.map<BigInt>(
        (term) {
          if (term is LiteralConstant) {
            return term.number;
          }
          if (term is Multiplication) {
            return term.factors.fold<BigInt>(
              BigInt.from(1),
              (factorAcc, factor) => factorAcc * (factor is LiteralConstant ? factor.number : BigInt.from(1)),
            );
          }
          return BigInt.from(1);
        }
      ).toList();

      final gcd = 
      // Compute the gcd of all terms
      constantParts.fold<BigInt>(
        BigInt.from(0),
        (gcdAcc, term) => term.gcd(gcdAcc)
      )
      // And if all terms are negative, make it negative
      * (constantParts.where(
        (element) => element >= BigInt.from(0)
      ).isEmpty ? BigInt.from(-1) : BigInt.from(1));

      if (gcd > BigInt.from(1) || gcd < BigInt.from(0)) {
        final newTerms = value.terms.mapIndexed(
          (term, index) {
            if (term is LiteralConstant) {
              return LiteralConstant(term.number ~/ gcd);
            }
            if (term is Multiplication) {
              final constantPart = term.factors.fold<BigInt>(
                BigInt.from(1),
                (factorAcc, factor) => factorAcc * (factor is LiteralConstant ? factor.number : BigInt.from(1)),
              );
              final nonConstantPart = term.factors.where((element) => !(element is LiteralConstant));
              return Multiplication([
                LiteralConstant(constantPart ~/ gcd),
                ...nonConstantPart,
              ]);
            }
            throw UnsupportedError('Internal error in EliminateEqGcdTrivializer');
          },
        ).toList();

        return Addition(newTerms);
      }

      // final newChildren = value.children.where((element) => !(element is Constant)).toList();
      // if (newChildren.length != value.children.length) {
      //   return Multiplication(newChildren);
      // }
    }
    return null;
  }

}
