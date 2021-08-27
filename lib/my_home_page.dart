import 'dart:html';

import 'package:flutter/material.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/blocs/journal_edit_bloc.dart';
import 'package:journal/blocs/journal_edit_bloc_provider.dart';
import 'package:journal/classes/FormatDates.dart';
import 'package:journal/classes/mood_icons.dart';
import 'package:journal/models/journal.dart';
import 'package:journal/services/db_firestore.dart';
import 'package:journal/pages/edit_entry.dart';

class MyHomePage extends StatefulWidget {
  
  MyHomePage({Key? key}) : super(key: key);

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {

  late AuthenticationBloc _authenticationBloc;
  late HomeBloc _homeBloc;
  late String _uid;
  late MoodIcons _moodIcons = MoodIcons(rotation: 0);
  late FormatDates _formatDates = FormatDates();

  @override
  void didChangeDependencies(){
    super.didChangeDependencies();
    _authenticationBloc = AuthenticationBlocProvider.of(context).authenticationBloc;
    _homeBloc = HomeBlocProvider.of(context).homebloc;
    _uid = HomeBlocProvider.of(context).uid;
  }

  @override
  void dispose(){
    _homeBloc.dispose();
    super.dispose();
  }

  void _addOrEditJournal({required bool add, required Journal journal}){
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (BuildContext context) => JournalEditBlocProvider(
          journalEditBloc: JournalEditBloc(add, DbFirestoreService(), journal),
          child: EditEntry(),
        ),
        fullscreenDialog: true
      ),
    );
  }

  Future<bool> _confirmDeleteJournal() async {
    return await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context){
        return AlertDialog(
          title: Text('Delete Journal'),
          content: Text('Are you sure you would like to Delte?'),
          actions: <Widget>[
            TextButton(
              child: Text('CANCEL'),
              onPressed: (){
                Navigator.pop(context, false);
              }
            ),
            TextButton(
              child: Text('Delete', style: TextStyle(color: Colors.red),),
              onPressed: (){
                Navigator.pop(context, true);
              },
            ),
          ]
        );
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Journal', 
          style: TextStyle(color: Colors.lightGreen.shade800)
        ),
        elevation: 0.0,
        bottom: PreferredSize(
          child: Container(), preferredSize: Size.fromHeight(32.0)
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen, Colors.lightGreen.shade50],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          )
        ),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.exit_to_app,
            color: Colors.lightGreen.shade800,
            ),
            onPressed: (){
              _authenticationBloc.logoutUser.add(true);
            },
          ),
        ],
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        elevation: 0.0,
        child: Container(
          height: 44.0,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [Colors.lightGreen.shade50, Colors.lightGreen],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),
      body: StreamBuilder(
        stream: _homeBloc.listJournal,
        builder: ((BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData){
            return _buildListViewSepareted(snapshot);
          } else {
            return Center(
              child: Container(
                child: Text('Add Journals.')
              ),
            );
          }
        })
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        tooltip: 'Add Journal Entry',
        backgroundColor: Colors.lightGreen.shade300,
        child: Icon(Icons.add),
        onPressed: () async {
          _addOrEditJournal(add: true, journal: Journal(uid: _uid));
        },
      ),
    );
  }

  Widget _buildListViewSepareted(AsyncSnapshot snapshot){
    return ListView.separated(
      itemCount: snapshot.data.length,
      itemBuilder: (BuildContext context, int index){
        String _titleDate = _formatDates.dateFormatShortMonthDayyear(snapshot.data[index].date);
        String _subtitle = snapshot.data[index].mood + "\n" + snapshot.data[index].note;
        return Dismissible(
          key: Key(snapshot.data[index].documentID),
          background: Container(
            color: Colors.red,
            alignment: Alignment.centerLeft,
            padding: EdgeInsets.only(left: 16.0),
            child: Icon(
              Icons.delete,
              color: Colors.white,
            ),
          ),
          child: ListTile(
            leading: Column(
              children: <Widget>[
                Text(_formatDates.dateFormatDayNumber(snapshot.data[index].date),
                  style:  TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 32.0,
                    color: Colors.lightGreen
                  ),
                ),
                Text(_formatDates.dateFormatShortDayName(snapshot.data[index].date)),
              ]
            ),
            trailing: Transform(
              transform: Matrix4.identity()..rotateZ(_moodIcons.getMoodRotation(snapshot.data[index].mood)),
              alignment: Alignment.center,
              child: Icon(_moodIcons.getMoodIcon(snapshot.data[index].mood),
                color: _moodIcons.getMoodColor(snapshot.data[index].mood), 
                size: 43.0
                ,)
            ),
          ),
        );
      },
      separatorBuilder: (BuildContext context, int index){
        return Divider(
          color: Colors.grey,
        );
      }
    );
  }
}