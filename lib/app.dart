import 'package:ajedrez/game_lobby.dart';
import 'package:flutter/material.dart';

class App extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        appBar: AppBar(title: Text('Sala de jugadores')),
        body: Center(child: GameLobby()),
      ),);
  }
}

