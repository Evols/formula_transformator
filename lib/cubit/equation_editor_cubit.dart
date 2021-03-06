
import 'package:bloc/bloc.dart';
import 'package:formula_transformator/core/equation.dart';
import 'package:formula_transformator/core/expressions/expression.dart';
import 'package:formula_transformator/cubit/editors/equation_editor_delta_2nd_deg.dart';
import 'package:formula_transformator/cubit/equations_cubit.dart';
import 'package:formula_transformator/cubit/editors/equation_editor_develop.dart';
import 'package:formula_transformator/cubit/editors/equation_editor_dioph.dart';
import 'package:formula_transformator/cubit/editors/equation_editor_factorize.dart';
import 'package:formula_transformator/cubit/editors/equation_editor_inject.dart';
import 'package:formula_transformator/cubit/editors/equation_editor_reorganize.dart';
import 'package:meta/meta.dart';

part 'equation_editor_state.dart';

class EquationEditorCubit extends Cubit<EquationEditorState> {

  final EquationsCubit equationsCubit;
  EquationEditorCubit(this.equationsCubit) : super(EquationEditorIdle());

  void startDevelopping() {
    emit(EquationEditorDevelop(DevelopStep.Select));
  }

  void startFactoring() {
    emit(EquationEditorFactorize(FactorizeStep.SelectFactor));
  }

  void startDioph() {
    emit(EquationEditorDioph(DiophStep.SelectTerms));
  }

  void startInject() {
    emit(EquationEditorInject(InjectStep.SelectSubstitute));
  }

  void startReorganize() {
    emit(EquationEditorReorganize(ReorganizeStep.Select));
  }

  void startDelta2ndDeg() {
    emit(EquationEditorDelta2ndDeg(Delta2ndDegStep.SelectVar));
  }

  void cancel() {
    emit(EquationEditorIdle());
  }

  void nextStep() {
    var inState = state;
    if (inState is EquationEditorEditing) {
      emit(inState.nextStep(equationsCubit));
    }
  }

  void onSelect(Equation equation, Expression expression) {
    var inState = state;
    if (inState is EquationEditorEditing) {
      emit(inState.onSelect(equation, expression));
    }
  }

}
