class ChessGame {
//  static const whitePieces = ['♖', '♘', '♗', '♔', '♕', '♗', '♘', '♖'];
//  static const blackPieces = ['♜', '♞', '♝', '♚', '♛', '♝', '♞', '♜'];
  List<List<String>> _board = List.generate(8, (_) => List.filled(8, ''));
  bool _whiteTurn = true;
  String state =
      'playing'; // playing, check_white, check_black, checkmate_white, checkmate_black, draw

  ChessGame() {
    _initializeBoard();
  }

  void _initializeBoard() {
    _board=[
      ['♜','♞','♝','♚','♛','♝','♞','♜'],
      ['♟','♟','♟','♟','♟','♟','♟','♟'],
      [''  ,'' , '' ,'' , '' , '' ,'' , '' ],
      [''  ,'' , '' ,'' , '' , '' ,'' , '' ],
      [''  ,'' , '' ,'' , '' , '' ,'' , '' ],
      [''  ,'' , '' ,'' , '' , '' ,'' , '' ],
      ['♙','♙','♙','♙','♙','♙','♙','♙'],
      ['♖','♘','♗','♔','♕','♗','♘','♖']
     ];}

/*  void _initializeBoard() {
    for (int col = 0; col < 8; col++) {
      _board[0][col] = blackPieces[col];
      _board[1][col] = '♟';
      _board[6][col] = '♙';
      _board[7][col] = whitePieces[col];
    }
  }*/

  String getPieceAt(int row, int col) {
    return _board[row][col];
  }

  bool movePiece(int fromRow, int fromCol, int toRow, int toCol) {
    if (fromRow < 0 || fromRow >= 8 || fromCol < 0 || fromCol >= 8 ||
        toRow < 0 || toRow >= 8 || toCol < 0 || toCol >= 8) return false;
    final piece = _board[fromRow][fromCol];
    if (piece.isEmpty || isWhite(piece) != _whiteTurn) return false;
    if (!isValidMove(fromRow, fromCol, toRow, toCol)) return false;
    _board[fromRow][fromCol] = '';
    _board[toRow][toCol] = piece;
    _whiteTurn = !_whiteTurn;
    setState();
    return true;
  }

  bool movePiece2(int fromIndex, int toIndex) {
    final fromRow = fromIndex ~/ 8;
    final fromCol = fromIndex % 8;
    final toRow = toIndex ~/ 8;
    final toCol = toIndex % 8;
    return movePiece(fromRow, fromCol, toRow, toCol);
  }

  bool isValidMove(int fromRow, int fromCol, int toRow, int toCol) {
    final piece = _board[fromRow][fromCol];
    final targetPiece = _board[toRow][toCol];
    final rowDiff = (toRow - fromRow).abs();
    final colDiff = (toCol - fromCol).abs();
  /*  if (isWhite(piece) != _whiteTurn) {
      return false;
    }  OjO ...................... */
    // la casilla de destino está vacía o contiene una pieza del color opuesto
    if (targetPiece.isNotEmpty && isWhite(piece) == isWhite(targetPiece))
      return false;

    bool isPathClear(int rowStep, int colStep) {
      int row = fromRow + rowStep;
      int col = fromCol + colStep;
      while (row != toRow || col != toCol) {
        if (_board[row][col].isNotEmpty) return false;
        row += rowStep;
        col += colStep;
      }
      return true;
    }

    switch (piece) {
      case '♙':
        if (colDiff == 0 && targetPiece.isEmpty && toRow < fromRow) {
          return rowDiff == 1 || (fromRow == 6 && rowDiff == 2);
        } else if (colDiff == 1 &&
            targetPiece.isNotEmpty &&
            !isWhite(targetPiece) &&
            toRow < fromRow) {
          return rowDiff == 1;
        }
        return false;
      case '♟':
        if (colDiff == 0 && targetPiece.isEmpty && toRow > fromRow) {
          return rowDiff == 1 || (fromRow == 1 && rowDiff == 2);
        } else if (colDiff == 1 &&
            targetPiece.isNotEmpty &&
            isWhite(targetPiece) &&
            toRow > fromRow) {
          return rowDiff == 1;
        }
        return false;
      case '♘':
      case '♞':
        return (rowDiff == 2 && colDiff == 1) || (rowDiff == 1 && colDiff == 2);
      case '♗':
      case '♝':
        if (rowDiff == colDiff) {
          int rowStep = toRow > fromRow ? 1 : -1;
          int colStep = toCol > fromCol ? 1 : -1;
          return isPathClear(rowStep, colStep);
        }
        return false;
      case '♖':
      case '♜':
        if (rowDiff == 0 || colDiff == 0) {
          int rowStep = rowDiff == 0 ? 0 : (toRow > fromRow ? 1 : -1);
          int colStep = colDiff == 0 ? 0 : (toCol > fromCol ? 1 : -1);
          return isPathClear(rowStep, colStep);
        }
        return false;
      case '♕':
      case '♛':
        if (rowDiff == colDiff) {
          int rowStep = toRow > fromRow ? 1 : -1;
          int colStep = toCol > fromCol ? 1 : -1;
          return isPathClear(rowStep, colStep);
        } else if (rowDiff == 0 || colDiff == 0) {
          int rowStep = rowDiff == 0 ? 0 : (toRow > fromRow ? 1 : -1);
          int colStep = colDiff == 0 ? 0 : (toCol > fromCol ? 1 : -1);
          return isPathClear(rowStep, colStep);
        }
        return false;
      case '♔':
      case '♚':
        // TODO: Validar movimientos de enroque
        return rowDiff <= 1 && colDiff <= 1;
      default:
        return false;
    }
  }

  void setState() {
    if (isCheckmate(_whiteTurn)) {
      state = _whiteTurn ? 'checkmate_black' : 'checkmate_white';
    } else if (isCheck(_whiteTurn)) {
      state = _whiteTurn ? 'check_white' : 'check_black';
    } else if (isDraw()) {
      state = 'draw';
    } else {
      state = 'playing';
    }
  }

  bool isDraw() {
    // TODO: Implementar la lógica para verificar si hay tablas
    return false;
  }

  List<int>? findKingPosition(bool isWhiteKing) {
    String kingSymbol = isWhiteKing ? '♔' : '♚';

    for (int row = 0; row < 8; row++)
      for (int col = 0; col < 8; col++)
        if (_board[row][col] == kingSymbol) return [row, col];
    return null; // Esto no debería suceder si el tablero es válido y tiene un rey.
  }

  bool isCheck(bool isWhiteKing) {
    List<int>? kingPosition = findKingPosition(isWhiteKing);
    if (kingPosition == null) return false;
    int kingRow = kingPosition[0];
    int kingCol = kingPosition[1];
    // Verificar si alguna pieza enemiga puede atacar al rey
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        String piece = _board[row][col];
        if (piece.isNotEmpty && isWhite(piece) != isWhiteKing) {
          // Verificar si la pieza enemiga en (row, col) puede moverse a la posición del rey
          if (isValidMove(row, col, kingRow, kingCol)) {
            return true;
          }
        }
      }
    }
    return false;
  }

  bool isCheckmate(bool isWhiteKing) =>
      isCheck(isWhiteKing) && isKingStalemate(isWhiteKing);

  bool isKingStalemate(bool isWhiteKing) {
    for (int row = 0; row < 8; row++) {
      for (int col = 0; col < 8; col++) {
        String piece = _board[row][col];
        if (piece.isNotEmpty && isWhite(piece) == isWhiteKing) {
          for (int newRow = 0; newRow < 8; newRow++) {
            for (int newCol = 0; newCol < 8; newCol++) {
              if (isValidMove(row, col, newRow, newCol)) {
                // Realizar el movimiento y verificar si el rey sigue en jaque
                String originalTarget = _board[newRow][newCol];
                _board[newRow][newCol] = piece;
                _board[row][col] = '';

                bool kingStillInCheck = isCheck(isWhiteKing);

                // Deshacer el movimiento
                _board[row][col] = piece;
                _board[newRow][newCol] = originalTarget;

                // Si el rey no está en jaque después del movimiento, no es jaque mate
                if (!kingStillInCheck) {
                  return false;
                }
              }
            }
          }
        }
      }
    }
    return true;
  }

  static bool isWhite(String piece) => '♔♕♖♗♘♙'.contains(piece);

  static bool isBlack(String piece) => '♚♛♜♝♞♟'.contains(piece);

  @override
  String toString() => _board.map((row) => row.join(' ')).join('\n');
}
