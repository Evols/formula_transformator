
import 'package:flutter/foundation.dart';
import 'package:formula_transformator/core/equation.dart';
import 'package:formula_transformator/core/value_transformators/develop_transformator.dart';
import 'package:formula_transformator/core/trivializers/trivializers_applier.dart';
import 'package:formula_transformator/core/values/addition.dart';
import 'package:formula_transformator/core/values/multiplication.dart';
import 'package:formula_transformator/core/values/value.dart';
import 'package:formula_transformator/cubit/equation_editor_cubit.dart';
import 'package:formula_transformator/cubit/equations_cubit.dart';
import 'package:formula_transformator/utils.dart';

enum DevelopStep { Select, Finished }

@immutable
class EquationEditorDevelop extends EquationEditorEditing {

  final DevelopStep step;
  final List<Value> selectedTerms;

  EquationEditorDevelop(this.step, { this.selectedTerms = const [] });

  @override
  String getStepName() {
    switch (step) {
      case DevelopStep.Select: return 'Select the terms to develop';
      default: return '';
    }
  }

  @override
  bool hasFinished() => step == DevelopStep.Finished;

  @override
  Selectable isSelectable(Equation equation, Value value) {
    switch (step) {
    case DevelopStep.Select:
      if (
        equation.findTree(
          (treeIt) => treeIt is Multiplication && treeIt.factors.where(
            (factor) => factor is Addition && factor.terms.where(
              (term) => identical(term, value)
            ).isNotEmpty && factor.terms.where(
              (term) => selectedTerms.where(
                (term2) => identical(term, term2)
              ).isNotEmpty
            ).length == selectedTerms.length
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
    case DevelopStep.Select:
      return selectedTerms.length > 0;
    default:
      return true;
    }
  }

  @override
  EquationEditorState nextStep(EquationsCubit equationsCubit) {
    final newStep = DevelopStep.values[step.index + 1];
    if (newStep == DevelopStep.Finished) {

      for (var equation in equationsCubit.state.equations) {

        final multiplication = equation.findTree(
          (treeIt) => treeIt is Multiplication && treeIt.factors.where(
            (factor) => factor is Addition && factor.terms.where(
              (term) => selectedTerms.where(
                (term2) => identical(term, term2)
              ).isNotEmpty
            ).length == selectedTerms.length
          ).isNotEmpty
        );

        if (multiplication != null) {
          equationsCubit.addEquations(
            DevelopTransformator(selectedTerms).transformValue(multiplication).map(
              (transformed) => applyTrivializersToEq(equation.mountAt(multiplication, transformed)).deepClone()
            ).toList()
          );
        }

      }

      return EquationEditorIdle();
    }
    return EquationEditorDevelop(
      newStep,
      selectedTerms: selectedTerms,
    );
  }

  @override
  EquationEditorEditing onSelect(Equation equation, Value value) {
    switch (step) {
    case DevelopStep.Select:
      return EquationEditorDevelop(
        step,
        selectedTerms: flipExistenceArray<Value>(selectedTerms, value),
      );
    default:
      return this;
    }
  }

}
