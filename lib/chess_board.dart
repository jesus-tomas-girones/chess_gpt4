import 'dart:async';
import 'package:ajedrez/widgets/dialogs.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'chess_game.dart';

class ChessBoard extends StatefulWidget {
  String gameId;
  int maxTimePlayer;

  ChessBoard( {Key? key, required this.gameId, required this.maxTimePlayer})
      : super(key: key);

  @override _ChessBoardState createState() => _ChessBoardState();
}

class _ChessBoardState extends State<ChessBoard> {
  final ChessGame _game = ChessGame();
  int _selectedPieceIndex = -1;
  List<int> _possibleMoves = [];
  bool firstPlayer = true;
  int _moveCounter = 0;
  late int _whiteTimeRemaining;
  late int _blackTimeRemaining;
  late Timer _timer;
  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref('chess_game');
  late StreamSubscription<DatabaseEvent> _moveSubscription;

  @override
  void initState() {
    super.initState();
    _whiteTimeRemaining = widget.maxTimePlayer * 60;
    _blackTimeRemaining = widget.maxTimePlayer * 60;
    _timer = Timer.periodic(Duration(seconds: 1), _updateTime);
    _listenForMoves();
  }

  void _updateTime(Timer timer) {
    setState(() {
      if (_moveCounter == 0) return;
      if (_moveCounter % 2 == 0) _whiteTimeRemaining--;
      else                       _blackTimeRemaining--;
      if (_whiteTimeRemaining == 0) {
        showMyDialog(context, "Fin de partida", "Ganan negras");
      } else if (_blackTimeRemaining == 0) {
        showMyDialog(context, "Fin de partida", "Ganan negras");
      }
    });
  }

  @override void dispose() {
    _moveSubscription?.cancel();
    _timer.cancel();
    super.dispose();
  }

/*  bool _canMovePiece(int row, int col) {
    String piece = _tablero.getPieceAt(row, col);
    return (_moveCounter % 2 == 0 && ChessGame.isWhite(piece)) ||
           (_moveCounter % 2 == 1 && ChessGame.isBlack(piece));
  }*/
  bool _canMovePiece(int row, int col) {
    String piece = _game.getPieceAt(row, col);
    if (_moveCounter == 0) {
      return ChessGame.isWhite(piece);
    } else if (_moveCounter % 2 == 0) {
      return firstPlayer && ChessGame.isWhite(piece);
    } else {
      return !firstPlayer && ChessGame.isBlack(piece);
    }
  }

  void _listenForMoves() {
    _moveSubscription = databaseRef.child('${widget.gameId}/moves')
        .onChildAdded.listen((event) {
      int saveCounter = int.parse(event.snapshot.key as String);
      if (saveCounter == _moveCounter+1) {
        String move = event.snapshot.value as String;
        int fromRow = move.codeUnitAt(1) - '1'.codeUnitAt(0);
        int fromCol = move.codeUnitAt(0) - 'A'.codeUnitAt(0);
        int toRow = move.codeUnitAt(3) - '1'.codeUnitAt(0);
        int toCol = move.codeUnitAt(2) - 'A'.codeUnitAt(0);
        setState(() {
          _game.movePiece(fromRow, fromCol, toRow, toCol);
          _selectedPieceIndex = -1;
          _possibleMoves = [];
          _moveCounter++;
          if (saveCounter == 1) { firstPlayer = false;}
        });
      }});
  }

  @override
  Widget build(BuildContext context) {
    Color highlightColor = firstPlayer ? Colors.blue : Colors.red;
    return Column(
      children: [
        Text('Negras: ${_formatTime(_blackTimeRemaining)}',
          style: TextStyle(fontWeight:
            !firstPlayer && (_moveCounter!=0) ? FontWeight.bold : null)),
        Container(
          width: 400,
          height: 400,
          child: CustomPaint(
            painter: ChessBoardPainter(),
            child: _buildChessPieces(),
          ),
        ),
        Text('Blancas: ${_formatTime(_whiteTimeRemaining)}',
          style: TextStyle(fontWeight:
            firstPlayer && (_moveCounter!=0) ? FontWeight.bold : null)),
        Text('Estado del juego: ${_game.state}'),

      ],
    );
  }

  String _formatTime(int seconds) {
    int minutes = seconds ~/ 60;
    int remainingSeconds = seconds % 60;
    return '${minutes.toString().padLeft(2, '0')}:${remainingSeconds.toString().padLeft(2, '0')}';
  }

  Widget _buildChessPieces() {
    return GridView.builder(
      itemCount: 64,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 8,
      ),
      itemBuilder: (context, index) {
        final row = index ~/ 8;
        final col = index % 8;
        final piece = _game.getPieceAt(row, col);
        final isSelected = _selectedPieceIndex == index;
        final isPossibleMove = _possibleMoves.contains(index);

        return GestureDetector(
          onTap: () {
            if (_selectedPieceIndex==-1 && !_canMovePiece(row, col)) return;
            setState(() {
              if (_selectedPieceIndex == null) {
                _selectedPieceIndex = index;
                _possibleMoves = _calculatePossibleMoves(row, col);
              } else if (isPossibleMove) {
                bool moveIsValid = _game.movePiece2(_selectedPieceIndex, index);
                if (moveIsValid) {
                  String fromCoord = String.fromCharCode('A'.codeUnitAt(0) + (_selectedPieceIndex % 8)) +
                      String.fromCharCode('1'.codeUnitAt(0) + (_selectedPieceIndex ~/ 8));
                  String toCoord = String.fromCharCode('A'.codeUnitAt(0) + (index % 8)) +
                      String.fromCharCode('1'.codeUnitAt(0) + (index ~/ 8));
                  String move = fromCoord + toCoord;
                  _moveCounter++;
                  String moveKey = _moveCounter.toString();
                  databaseRef.child('${widget.gameId}/moves/$moveKey').set(move);
                }
                _selectedPieceIndex = -1;
                _possibleMoves = [];
              } else {
                _selectedPieceIndex = index;
                _possibleMoves = _calculatePossibleMoves(row, col);
              }
            });
          },
          child: Container(
            decoration: BoxDecoration(
              border: isSelected
                  ? Border.all(color: Colors.blue, width: 2) : null,
              color: isPossibleMove ? Colors.green.withOpacity(0.5) : null,
            ),
            child: Center(
              child: Text(
                piece,
                style: TextStyle(fontSize: 40, fontFamily: 'sans-serif'),
              ),),),);
      },);
  }

  List<int> _calculatePossibleMoves(int row, int col) {
    List<int> possibleMoves = [];
    for (int i = 0; i < 64; i++) {
      int toRow = i ~/ 8;
      int toCol = i % 8;
      if (_game.isValidMove(row, col, toRow, toCol)) {
        possibleMoves.add(i);
      }
    }
    return possibleMoves;
  }
}

class ChessBoardPainter extends CustomPainter {
  @override void paint(Canvas canvas, Size size) {
    final squareSize = size.width / 8;
    final lightSquarePaint = Paint()..color = Colors.white;
    final darkSquarePaint = Paint()..color = Colors.grey.shade700;
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        final isLightSquare = (row + col) % 2 == 0;
        final paint = isLightSquare ? lightSquarePaint : darkSquarePaint;
        final rect = Rect.fromLTWH(
            col * squareSize, row * squareSize, squareSize, squareSize);
        canvas.drawRect(rect, paint);
      }
    }
  }

  @override bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return false;
  }
}