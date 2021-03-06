
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_transformator/cubit/equation_adder_cubit.dart';

class EquationsTextfieldBody extends StatelessWidget {

  const EquationsTextfieldBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) => Container(
    color: Colors.black12,
    padding: EdgeInsets.all(8.0),
    child: Row(children: [
      Expanded(
        child: TextField(
          controller: BlocProvider.of<EquationAdderCubit>(context).textFieldController,
          onChanged: (tempEq) => BlocProvider.of<EquationAdderCubit>(context).updateTextfield(tempEq),
          onSubmitted: (_) => BlocProvider.of<EquationAdderCubit>(context).validateTextfield(context),
        ),
      ),
      IconButton(
        onPressed: () => BlocProvider.of<EquationAdderCubit>(context).validateTextfield(context),
        icon: Icon(Icons.send),
      )
    ]),
  );
}
