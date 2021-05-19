import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:formula_transformator/core/values/addition.dart';
import 'package:formula_transformator/core/values/constant.dart';
import 'package:formula_transformator/core/values/multiplication.dart';
import 'package:formula_transformator/core/values/variable.dart';
import 'package:formula_transformator/cubit/equations_cubit.dart';
import 'package:formula_transformator/utils.dart';
import 'package:formula_transformator/widgets/equation_widget.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Formula transformator',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Formula transformator'),
    );
  }
}

class MyHomePage extends StatelessWidget {

  MyHomePage({ Key? key, required this.title }) : super(key: key);

  final String title;

  @override
  Widget build(BuildContext context) {

    // y=p=7789 ; q=2281 ; c=pq=17766709, a=2^7=128 ; b=q%a=2281%128=105

    // Right one
    final eq1 = Addition([
      Multiplication([
        Variable("y"),
        Addition([
          Multiplication([
            Constant(128),
            Variable("x"),
          ]),
          Constant(105),
        ]),
      ]),
      Constant(-17766709),
    ]);

    // Wrong one
    final eq2 = Addition([
      Multiplication([
        Variable("y"),
        Addition([
          Multiplication([
            Constant(128),
            Variable("x"),
          ]),
          Constant(97),
        ]),
      ]),
      Constant(-17766709),
    ]);

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: MultiBlocProvider(
        providers: [
          BlocProvider<EquationsCubit>(create: (context) => EquationsCubit([ eq1, eq2 ])),
        ],
        child: Column(
          children: [
            Expanded(
              child: BlocBuilder<EquationsCubit, EquationsState>(
                builder: (context, state) => ListView.builder(
                  itemCount: state.equations.length,
                  itemBuilder: (context, index) => Card(
                    child: Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          EquationWidget(state.equations[index]),
                          Row(
                            children: [
                              latexToWidget('(${index+1})', 0.8),
                              DropdownButton<String>(
                                selectedItemBuilder: (context) => [ Container() ],
                                iconSize: 24,
                                elevation: 16,
                                underline: Container(),
                                onChanged: (String? newValue) {},
                                items: ['One', 'Two', 'Free', 'Four']
                                  .map<DropdownMenuItem<String>>((value) => DropdownMenuItem<String>(
                                    value: value,
                                    child: Text(value),
                                  ))
                                  .toList(),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Container(
              color: Colors.black12,
              padding: EdgeInsets.all(8.0),
              child: TextField(),
            ),
          ],
        ),
      ),
    );
  }
}