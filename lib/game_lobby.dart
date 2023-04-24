import 'dart:async';
import 'package:ajedrez/widgets/dialogs.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chess_board.dart';

class GameLobby extends StatefulWidget {
  @override
  _GameLobbyState createState() => _GameLobbyState();
}

class _GameLobbyState extends State<GameLobby> {
  final TextEditingController _gameIdController = TextEditingController();
  final DatabaseReference _rootRef =
      FirebaseDatabase.instance.ref().child('chess_game');
  late StreamSubscription<DatabaseEvent> _subscription;
  int _maxTimePlayer = 30;

  @override
  void dispose() {
    _gameIdController.dispose();
    _subscription?.cancel();
    super.dispose();
  }

  void _openGame(String gameId, int maxTimePlayer) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Scaffold(
                  appBar: AppBar(title: Text('Partida $gameId')),
                  body: Center(
                    child: ChessBoard(gameId: gameId, maxTimePlayer: maxTimePlayer),
                  ),)));
  }

  Future<void> _createGame() async {
    String gameId = _gameIdController.text.trim();
    if (gameId.isNotEmpty) {
      DataSnapshot snapshot = (await _rootRef.child(gameId).once()).snapshot;
      if (snapshot.value == null) {
        await _rootRef.child(gameId).update({'time': _maxTimePlayer, 'state': 'open'});
        showLoadingDialog(
            context: context,
            message: 'Esperando a que el oponente se una',
            onCancel: () => _subscription.cancel());
        _subscription = _rootRef.child('$gameId/state').onValue.listen((event) {
          if (event.snapshot.value == 'confirm') {
            _subscription.cancel();
            _rootRef.child('$gameId/state').set('playing');
            Navigator.of(context).pop(); // Cierra el diálogo de espera
            _openGame(gameId, _maxTimePlayer);
          }
        });
      } else {
        showMyDialog(context, 'ERROR',
            'El identificador de partida ya está en uso. Por favor, elija otro.');
      }
    }
  }

  Future<void> _joinGame(String gameId) async {
    await _rootRef.child('$gameId/state').set('confirm');
    showLoadingDialog(
        context: context,
        message: 'Comprobando que el oponente sigue conectado',
        onCancel: () => _subscription.cancel());
    _subscription = _rootRef.child('$gameId/state').onValue.listen((event) {
      if (event.snapshot.value == 'playing') {
        _subscription.cancel();
        _rootRef.child('$gameId/time').once().then((DatabaseEvent event) {
          _maxTimePlayer = event.snapshot.value as int;
          Navigator.of(context).pop(); // Cierra el diálogo de espera
          _openGame(gameId, _maxTimePlayer);
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(height: 20),
        Center(
          child: Text("Crear partida",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            SizedBox(width: 10),
            Expanded(
              child: TextField(
                controller: _gameIdController,
                decoration: InputDecoration(
                  labelText: "Identificador de partida",
                ),
              ),
            ),
            SizedBox(width: 10),
            DropdownButton<int>(
              value: _maxTimePlayer,
              items: generateDropdownItems(),
              onChanged: (int? value) {
                setState(() {
                  _maxTimePlayer = value!;
                });
              },
            ),
            SizedBox(width: 10),
            ElevatedButton(
              onPressed: _createGame,
              child: Text(
                "Crear nueva partida",
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            ),
            SizedBox(width: 10),
          ],
        ),
        SizedBox(height: 50),
        Center(
          child: Text(
            "Unirse a partida",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        SizedBox(height: 10),
        Expanded(
          child: StreamBuilder<DatabaseEvent>(
            stream: _rootRef.onValue,
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                Map<String, dynamic>? games =
                    snapshot.data?.snapshot.value as Map<String, dynamic>?;
                if (games != null) {
                  List<String> openGames = games.entries
                      .where((entry) => entry.value['state'] == 'open')
                      .map((entry) => entry.key)
                      .toList();
                  if (openGames.isEmpty)
                    return Center(child: Text("No hay partidas disponibles"));
                  return ListView.builder(
                    itemCount: openGames.length,
                    itemBuilder: (context, index) {
                      String gameId = openGames.elementAt(index);
                      return Center(
                        child:
                          ListTile(
                        title: Text(gameId),
                        onTap: () => _joinGame(gameId),
                      )
                      );
                    },
                  );
                } else {
                  return Center(child: Text("No hay partidas disponibles"));
                }
              } else if (snapshot.hasError) {
                return Center(
                    child: Text("Error al cargar las partidas disponibles"));
              } else {
                return Center(child: CircularProgressIndicator());
              }
            },
          ),
        ),
      ],
    );
  }
}

List<int> timeValues = [1, 5, 10, 15, 20, 25, 30, 40, 50, 60];

List<DropdownMenuItem<int>> generateDropdownItems() {
  List<DropdownMenuItem<int>> items = [];
  for (int value in timeValues) {
    items.add(
      DropdownMenuItem(
        child: Text("$value minutos"),
        value: value,
      ),
    );
  }
  return items;
}
