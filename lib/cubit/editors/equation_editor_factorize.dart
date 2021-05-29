
import 'package:flutter/foundation.dart';
import 'package:formula_transformator/core/equation.dart';
import 'package:formula_transformator/core/value_transformators/factorize_transformator.dart';
import 'package:formula_transformator/core/values/addition.dart';
import 'package:formula_transformator/core/values/literal_constant.dart';
import 'package:formula_transformator/core/values/multiplication.dart';
import 'package:formula_transformator/core/values/value.dart';
import 'package:formula_transformator/cubit/equation_editor_cubit.dart';
import 'package:formula_transformator/cubit/equations_cubit.dart';
import 'package:formula_transformator/utils.dart';

enum FactorizeStep { SelectFactor, SelectTerms, Finished }

@immutable
class EquationEditorFactorize extends EquationEditorEditing {

  final FactorizeStep step;
  final List<Value> selectedFactors;
  final List<Value> selectedTerms;

  EquationEditorFactorize(this.step, { this.selectedTerms = const [], this.selectedFactors = const [] });

  @override
  String getStepName() {
    switch (step) {
      case FactorizeStep.SelectFactor: return 'Select the common factor in one of the terms to factor';
      case FactorizeStep.SelectTerms: return 'Select the terms to factor';
      default: return '';
    }
  }

  @override
  bool hasFinished() => step == FactorizeStep.Finished;

  static Value? getCommonFactor(Value v1, Value v2) {
    if (v1 is LiteralConstant && v2 is LiteralConstant) {
      final gcd = v1.number.gcd(v2.number);
      if (gcd != BigInt.from(1)) {
        return LiteralConstant(gcd);
      }
    }
    return v1.isEquivalentTo(v2) ? v1 : null;
  }

  static List<Value> getCommonFactors(List<Value> v1, List<Value> v2) {

    var v1copy = [...v1];
    var v2copy = [...v2];
    var commonFactors = <Value>[];

    for (var v1index = v1copy.length - 1; v1index >= 0; v1index--) {
      for (var v2index = v2copy.length - 1; v2index >= 0; v2index--) {
        final commonFactor = getCommonFactor(v1copy[v1index], v2copy[v2index]);
        if (commonFactor != null) {
          commonFactors.add(commonFactor);
          v1copy.removeAt(v1index);
          v2copy.removeAt(v2index);
          break;
        }
      }
    }

    return commonFactors;
  }

  static bool hasAllFactors(List<Value> factorsToLookFor, List<Value> inMultiplication) {

    var factorsToLookForCopy = [...factorsToLookFor];
    var inMultiplicationCopy = [...inMultiplication];

    for (var factorsIndex = factorsToLookForCopy.length - 1; factorsIndex >= 0; factorsIndex--) {
      for (var multiplicationIndex = inMultiplicationCopy.length - 1; multiplicationIndex >= 0; multiplicationIndex--) {
        final commonFactor = getCommonFactor(factorsToLookForCopy[factorsIndex], inMultiplicationCopy[multiplicationIndex]);
        if (commonFactor != null) {
          factorsToLookForCopy.removeAt(factorsIndex);
          inMultiplicationCopy.removeAt(multiplicationIndex);
          break;
        }
      }
    }

    return factorsToLookForCopy.isEmpty;
  }

  @override
  Selectable isSelectable(Equation equation, Value value) {
    switch (step) {
    case FactorizeStep.SelectFactor:
      if (
        equation.findTree(
          (additionCandidate) => additionCandidate is Addition
          // Check that the addition has a multiplication term, and that this multiplication term has value as one of its factors
          && additionCandidate.terms.where(
            (multiplicateCandidate) => multiplicateCandidate is Multiplication
            // Multiplication term has value as one of its factors
            && multiplicateCandidate.factors.where(
              (factor) => identical(factor, value)
            ).isNotEmpty
            // Multiplication term has the selected factors
            && multiplicateCandidate.factors.where(
              (factor) => selectedFactors.where((selectedFactor) => identical(selectedFactor, factor)).isNotEmpty
            ).length == selectedFactors.length
          ).isNotEmpty
          // Check that the addition has another multiplication term, and that this other multiplication term has is divisible by the selected factors and the new factor
          && additionCandidate.terms.where(
            (otherMultiplicateCandidate) => otherMultiplicateCandidate is Multiplication
            // Not the multiplication that contains value
            && otherMultiplicateCandidate.factors.where(
              (factor) => identical(factor, value)
            ).isEmpty
            // Divisible by the selected factors and the new factor
            && hasAllFactors(
              selectedFactors.where(
                (selectedFactor) => identical(selectedFactor, value)
              ).isNotEmpty ? selectedFactors : [ ...selectedFactors, value ],
              otherMultiplicateCandidate.factors,
            )
          ).isNotEmpty
        ) != null
      ) {
        return (
          selectedFactors.where((e) => identical(e, value)).isNotEmpty
          ? Selectable.MultipleSelected
          : Selectable.MultipleEmpty
        );
      }
      return Selectable.None;

    case FactorizeStep.SelectTerms:
      if (
        equation.findTree(
          (additionCandidate) => additionCandidate is Addition
          // Check that the addition has a multiplication term, and that this multiplication term has value as one of its factors
          && additionCandidate.terms.where(
            (multiplicateCandidate) => multiplicateCandidate is Multiplication
            // Multiplication term has value as one of its factors
            && identical(multiplicateCandidate, value)
            // Divisible by the selected factors and the new factor
            && hasAllFactors(selectedFactors, multiplicateCandidate.factors)
          ).isNotEmpty
          // Check that the addition has another multiplication term, and that this other multiplication term has is divisible by the selected factors and the new factor
          && additionCandidate.terms.where(
            (multiplicateCandidate) => multiplicateCandidate is Multiplication
            // Multiplication term has the selected factors
            && multiplicateCandidate.factors.where(
              (factor) => selectedFactors.where((selectedFactor) => identical(selectedFactor, factor)).isNotEmpty
            ).length == selectedFactors.length
          ).isNotEmpty
        ) != null
      ) {
        return (
          selectedTerms.where((e) => identical(e, value)).isNotEmpty
          ? Selectable.MultipleSelected
          : Selectable.MultipleEmpty
        );
      }
      return Selectable.None;
    default:
      return Selectable.None;
    }
  }

  @override
  bool canValidate() {
    switch (step) {
    case FactorizeStep.SelectFactor:
      return selectedFactors.length > 0;
    case FactorizeStep.SelectTerms:
      return selectedTerms.length > 1;
    default:
      return true;
    }
  }

  @override
  EquationEditorState nextStep(EquationsCubit equationsCubit) {
    final newStep = FactorizeStep.values[step.index + 1];
    if (newStep == FactorizeStep.Finished) {

      for (var equation in equationsCubit.state.equations) {

        final addition = equation.findTree(
          (additionCandidate) => additionCandidate is Addition
          && additionCandidate.terms.where(
            (multiplicateCandidate) => multiplicateCandidate is Multiplication
            // Multiplication term has the selected factors
            && multiplicateCandidate.factors.where(
              (factor) => selectedFactors.where((selectedFactor) => identical(selectedFactor, factor)).isNotEmpty
            ).length == selectedFactors.length
          ).isNotEmpty
        );

        if (addition != null) {
          equationsCubit.addEquations(
            FactorizeTransformator(selectedFactors, selectedTerms).transformValue(addition).map(
              (transformed) => equation.mountAt(addition, transformed)
            ).toList()
          );
        }

      }

      return EquationEditorIdle();
    }
    return EquationEditorFactorize(
      newStep,
      selectedFactors: selectedFactors,
      selectedTerms: selectedTerms,
    );
  }

  @override
  EquationEditorEditing onSelect(Equation equation, Value value) {
    switch (step) {
    case FactorizeStep.SelectFactor:
      return EquationEditorFactorize(
        step,
        selectedFactors: flipExistenceArray<Value>(selectedFactors, value),
        selectedTerms: selectedTerms,
      );
    case FactorizeStep.SelectTerms:
      return EquationEditorFactorize(
        step,
        selectedFactors: selectedFactors,
        selectedTerms: flipExistenceArray<Value>(selectedTerms, value),
      );
    default:
      return this;
    }
  }

}