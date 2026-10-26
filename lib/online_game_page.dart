
import 'package:flutter/material.dart';
import 'game_service.dart';

class OnlineGamePage extends StatefulWidget {
  final int roomId;
  final int playerId;

  const OnlineGamePage({
    super.key,
    required this.roomId,
    required this.playerId,
  });

  @override
  State<OnlineGamePage> createState() => _OnlineGamePageState();
}

class _OnlineGamePageState extends State<OnlineGamePage> {
  static const int gridSize = 5;

  final GameService gameService = GameService();

  Map<String, int> horizontalLines = {};
  Map<String, int> verticalLines = {};
  Map<String, int> boxes = {};

  int currentPlayer = 1;
  int player1Score = 0;
  int player2Score = 0;

  int? selectedRow;
  int? selectedCol;

  bool isSubmittingMove = false;

  // Temporary testing ID.
  // Room 1 currently has player1id = 1.
  final int playerId = 1;

  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    loadGame();
  }


Future<void> selectDot(int row, int col) async {
  if (isSubmittingMove) return;

  if (selectedRow == null || selectedCol == null) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
    return;
  }

  final firstRow = selectedRow!;
  final firstCol = selectedCol!;

  if (firstRow == row && firstCol == col) {
    setState(() {
      selectedRow = null;
      selectedCol = null;
    });
    return;
  }

  final rowDifference = (firstRow - row).abs();
  final colDifference = (firstCol - col).abs();

  final horizontal = rowDifference == 0 && colDifference == 1;
  final vertical = rowDifference == 1 && colDifference == 0;

  if (!horizontal && !vertical) {
    setState(() {
      selectedRow = row;
      selectedCol = col;
    });
    return;
  }

  final lineRow = horizontal
      ? row
      : (firstRow < row ? firstRow : row);

  final lineCol = vertical
      ? col
      : (firstCol < col ? firstCol : col);

  setState(() {
    selectedRow = null;
    selectedCol = null;
    isSubmittingMove = true;
  });

  try {
    final result = await gameService.makeMove(
      roomId: widget.roomId,
      playerId: playerId,
      row: lineRow,
      col: lineCol,
      direction: horizontal ? 'horizontal' : 'vertical',
    );

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(result)),
    );

    await loadGame();
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Move failed: $error')),
    );
  } finally {
    if (mounted) {
      setState(() {
        isSubmittingMove = false;
      });
    }
  }
}


  Future<void> loadGame() async {
    try {
      final data = await gameService.getGame(widget.roomId);

      if (!mounted) return;

      setState(() {
        horizontalLines = Map<String, int>.from(
          data['horizontalLines'] ?? {},
        );

        verticalLines = Map<String, int>.from(
          data['verticalLines'] ?? {},
        );

        boxes = Map<String, int>.from(
          data['boxes'] ?? {},
        );

        currentPlayer = data['currentPlayer'] ?? 1;
        player1Score = data['player1Score'] ?? 0;
        player2Score = data['player2Score'] ?? 0;

        isLoading = false;
        errorMessage = null;
      });
    } catch (error) {
      if (!mounted) return;

      setState(() {
        isLoading = false;
        errorMessage = error.toString();
      });
    }
  }

  String lineKey(int row, int col) => '$row,$col';

  Color playerColor(int player) {
    return player == 1 ? Colors.blue : Colors.red;
  }

  Color playerLineColor(int player) {
    return player == 1
        ? Colors.lightBlueAccent
        : Colors.redAccent.shade100;
  }

  
Widget buildDot(int row, int col) {
  final selected =
      selectedRow == row && selectedCol == col;

  return GestureDetector(
    onTap: isSubmittingMove ? null : () => selectDot(row, col),
    behavior: HitTestBehavior.opaque,
    child: SizedBox(
      width: 30,
      height: 30,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 100),
          width: selected ? 22 : 16,
          height: selected ? 22 : 16,
          decoration: BoxDecoration(
            color: selected
                ? playerColor(currentPlayer)
                : Colors.white,
            shape: BoxShape.circle,
          ),
        ),
      ),
    ),
  );
}


  Widget buildHorizontalLine(int row, int col) {
    final owner = horizontalLines[lineKey(row, col)];

    return SizedBox(
      width: 50,
      height: 30,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: 50,
          height: owner == null ? 3 : 7,
          color: owner == null
              ? Colors.grey.shade700
              : playerLineColor(owner),
        ),
      ),
    );
  }

  Widget buildVerticalLine(int row, int col) {
    final owner = verticalLines[lineKey(row, col)];

    return SizedBox(
      width: 30,
      height: 50,
      child: Center(
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          width: owner == null ? 3 : 7,
          height: 50,
          color: owner == null
              ? Colors.grey.shade700
              : playerLineColor(owner),
        ),
      ),
    );
  }

  Widget buildBox(int row, int col) {
    final owner = boxes[lineKey(row, col)];

    return SizedBox(
      width: 50,
      height: 50,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        color: owner == null
            ? Colors.transparent
            : playerColor(owner),
        alignment: Alignment.center,
        child: owner == null
            ? null
            : Text(
                'P$owner',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  Widget buildBoard() {
    final List<Widget> boardRows = [];

    for (int row = 0; row < gridSize; row++) {
      final List<Widget> dotRow = [];

      for (int col = 0; col < gridSize; col++) {
        dotRow.add(buildDot(row, col));

        if (col < gridSize - 1) {
          dotRow.add(buildHorizontalLine(row, col));
        }
      }

      boardRows.add(
        Row(
          mainAxisSize: MainAxisSize.min,
          children: dotRow,
        ),
      );

      if (row < gridSize - 1) {
        final List<Widget> boxRow = [];

        for (int col = 0; col < gridSize; col++) {
          boxRow.add(buildVerticalLine(row, col));

          if (col < gridSize - 1) {
            boxRow.add(buildBox(row, col));
          }
        }

        boardRows.add(
          Row(
            mainAxisSize: MainAxisSize.min,
            children: boxRow,
          ),
        );
      }
    }

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: boardRows,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Online Game - Room ${widget.roomId}'),
      ),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : errorMessage != null
                ? Center(child: Text('Error: $errorMessage'))
                : Column(
                    children: [
                      const SizedBox(height: 20),

                      Text(
                        'Player $currentPlayer\'s Turn',
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.bold,
                          color: playerColor(currentPlayer),
                        ),
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Player 1: $player1Score',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: playerColor(1),
                            ),
                          ),

                          const SizedBox(width: 30),

                          Text(
                            'Player 2: $player2Score',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: playerColor(2),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      const Text(
                        'Online Board (View Only)',
                        style: TextStyle(color: Colors.grey),
                      ),

                      const Spacer(),

                      buildBoard(),

                      const Spacer(),

                      ElevatedButton(
                        onPressed: loadGame,
                        child: const Text('Refresh Board'),
                      ),

                      const SizedBox(height: 20),
                    ],
                  ),
      ),
    );
  }
}
