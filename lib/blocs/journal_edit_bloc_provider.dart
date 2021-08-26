import 'package:flutter/material.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/models/journal.dart';

class JournalEditBlocProvider extends InheritedWidget{
  final JournalEditBloc journalEditBloc;
  final bool add;
  final Journal journal;
  
  const JournalEditBlocProvider(
    {required Key key,required Widget child,required this.journalEditBloc, required this.add, required this.journal}) 
    : super(key: key, child: child);
  
  static JournalEditBlocProvider of(BuildContext context){
    return (context.dependOnInheritedWidgetOfExactType<JournalEditBlocProvider>() as
    JournalEditBlocProvider);
  }
    @override
    bool updateShouldNotify(JournalEditBlocProvider old) => false;
}