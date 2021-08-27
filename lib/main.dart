import 'package:flutter/material.dart';
import 'my_home_page.dart';
import 'package:journal/blocs/authentication_bloc.dart';
import 'package:journal/blocs/authentication_bloc_provider.dart';
import 'package:journal/blocs/home_bloc.dart';
import 'package:journal/blocs/home_bloc_provider.dart';
import 'package:journal/services/autentication.dart';
import 'package:journal/services/db_firestore.dart';
import 'package:journal/pages/login.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    final AuthenticationService _authenticationService = AuthenticationService();
    final AuthenticationBloc _authenticationBloc = AuthenticationBloc(_authenticationService);

    return AuthenticationBlocProvider(
      authenticationBloc: _authenticationBloc,
      child: StreamBuilder(
        initialData: null,
        stream: _authenticationBloc.user,
        builder: (BuildContext context, AsyncSnapshot snapshot){
          if (snapshot.connectionState == ConnectionState.waiting){
            return Container(
              color: Colors.lightGreen,
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasData){
            return HomeBlocProvider(
              homebloc: HomeBloc(DbFirestoreService(), _authenticationService),
              uid: snapshot.data,
              child: _buildMaterialApp(MyHomePage()),
            );
          } else {
            return _buildMaterialApp(Login());
          }
        }
      ),
    );
  }

  MaterialApp _buildMaterialApp(Widget homePage) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Security Inherited',
      theme: ThemeData(
        primarySwatch: Colors.lightGreen,
        canvasColor: Colors.lightGreen.shade50,
        bottomAppBarColor: Colors.lightGreen,
      ),
      home: homePage,
    );
  }
}