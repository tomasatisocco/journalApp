import 'package:flutter/material.dart';
import 'package:journal/blocs/home_bloc.dart';

class HomeBlocProvider extends InheritedWidget{
  final HomeBloc homebloc;
  final String uid;

  HomeBlocProvider({Key? key, required Widget child, required this.homebloc, required this.uid})
  : super(key: key, child: child);

  static HomeBlocProvider of(BuildContext context){
    return (context.dependOnInheritedWidgetOfExactType() as HomeBlocProvider);
  }

  @override
  bool updateShouldNotify(HomeBlocProvider old) =>
    homebloc != old.homebloc;
}