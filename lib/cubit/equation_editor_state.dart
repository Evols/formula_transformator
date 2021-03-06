part of 'equation_editor_cubit.dart';

@immutable
abstract class EquationEditorState {}

@immutable
class EquationEditorIdle extends EquationEditorState {}

enum Selectable {
  None, SingleEmpty, SingleSelected, MultipleEmpty, MultipleSelected,
}

abstract class EquationEditorEditing extends EquationEditorState {

  bool hasFinished();
  String getStepName();
  Selectable isSelectable(Equation equation, Expression expression);
  bool canValidate();

  EquationEditorState nextStep(EquationsCubit equationsCubit);
  EquationEditorEditing onSelect(Equation equation, Expression expression);

  EquationEditorEditing();

}
