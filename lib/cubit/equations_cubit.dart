
import 'package:bloc/bloc.dart';
import 'package:formula_transformator/core/equation.dart';
import 'package:formula_transformator/core/trivializers/trivializers_applier.dart';
import 'package:meta/meta.dart';

part 'equations_state.dart';

class EquationsCubit extends Cubit<EquationsState> {

  EquationsCubit(List<Equation> equations) : super(EquationsState(equations));

  void addEquations(List<Equation> equations, [bool removeOther = false]) {
    final trivialized = equations.map((equation) => applyTrivializersToEq(equation)).toList();
    emit(EquationsState([ ...(removeOther ? [] : state.equations), ...trivialized ]));
  }

}
