import 'package:flutter/material.dart';

class GamePage extends StatefulWidget {
  const GamePage({super.key});

  @override
  State<GamePage> createState() => _GamePageState();
}

class _GamePageState extends State<GamePage> {
  static const int gridSize = 5;

  int currentPlayer = 1;

  int player1Score = 0;
  int player2Score = 0;

  int? selectedRow;
  int? selectedCol;

  // Key = line location
  // Value = player who claimed the line
  final Map<String, int> horizontalLines = {};
  final Map<String, int> verticalLines = {};

  // Key = box location
  // Value = player who owns the box
  final Map<String, int> boxes = {};

  String horizontalKey(int row, int col) {
    return '$row,$col';
  }

  String verticalKey(int row, int col) {
    return '$row,$col';
  }

  String boxKey(int row, int col) {
    return '$row,$col';
  }

  // --------------------------------------------------
  // INPUT
  // --------------------------------------------------

  void selectDot(int row, int col) {
    // First dot selected.
    if (selectedRow == null || selectedCol == null) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });

      return;
    }

    int firstRow = selectedRow!;
    int firstCol = selectedCol!;

    // Tapping the same dot cancels selection.
    if (firstRow == row && firstCol == col) {
      setState(() {
        selectedRow = null;
        selectedCol = null;
      });

      return;
    }

    int rowDifference = (firstRow - row).abs();
    int colDifference = (firstCol - col).abs();

    bool horizontal =
        rowDifference == 0 && colDifference == 1;

    bool vertical =
        rowDifference == 1 && colDifference == 0;

    // Not adjacent:
    // make this dot the new selected dot.
    if (!horizontal && !vertical) {
      setState(() {
        selectedRow = row;
        selectedCol = col;
      });

      return;
    }

    bool lineAdded = false;

    // ---------------- HORIZONTAL ----------------

    if (horizontal) {
      int lineRow = row;
      int lineCol = firstCol < col ? firstCol : col;

      String key = horizontalKey(lineRow, lineCol);

      if (!horizontalLines.containsKey(key)) {
        horizontalLines[key] = currentPlayer;
        lineAdded = true;
      }
    }

    // ---------------- VERTICAL ----------------

    if (vertical) {
      int lineRow = firstRow < row ? firstRow : row;
      int lineCol = col;

      String key = verticalKey(lineRow, lineCol);

      if (!verticalLines.containsKey(key)) {
        verticalLines[key] = currentPlayer;
        lineAdded = true;
      }
    }

    setState(() {
      selectedRow = null;
      selectedCol = null;

      if (lineAdded) {
  bool completedBox = checkForBoxes();

  if (!completedBox) {
    switchPlayer();
  }

  if (isGameOver()) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      showGameOverScreen();
    });
  }
}
    });
  }

  // --------------------------------------------------
  // GAME LOGIC
  // --------------------------------------------------

  void switchPlayer() {
    currentPlayer = currentPlayer == 1 ? 2 : 1;
  }

  bool checkForBoxes() {
    bool completedNewBox = false;

    for (int row = 0; row < gridSize - 1; row++) {
      for (int col = 0; col < gridSize - 1; col++) {
        String key = boxKey(row, col);

        // Box already belongs to someone.
        if (boxes.containsKey(key)) {
          continue;
        }

        bool top =
            horizontalLines.containsKey(horizontalKey(row, col));

        bool bottom =
            horizontalLines.containsKey(
              horizontalKey(row + 1, col),
            );

        bool left =
            verticalLines.containsKey(verticalKey(row, col));

        bool right =
            verticalLines.containsKey(
              verticalKey(row, col + 1),
            );

        if (top && bottom && left && right) {
          boxes[key] = currentPlayer;

          completedNewBox = true;

          if (currentPlayer == 1) {
            player1Score++;
          } else {
            player2Score++;
          }
        }
      }
    }

    return completedNewBox;
  }

  bool isGameOver() {
  int totalBoxes = (gridSize - 1) * (gridSize - 1);

  return boxes.length == totalBoxes;
}

void showGameOverScreen() {
  String result;

  if (player1Score > player2Score) {
    result = 'Player 1 Wins!';
  } else if (player2Score > player1Score) {
    result = 'Player 2 Wins!';
  } else {
    result = 'Tie Game!';
  }

  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'GAME OVER',
          textAlign: TextAlign.center,
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              result,
              style: const TextStyle(
                fontSize: 26,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              'Player 1: $player1Score',
              style: TextStyle(
                fontSize: 20,
                color: playerColor(1),
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'Player 2: $player2Score',
              style: TextStyle(
                fontSize: 20,
                color: playerColor(2),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();

              setState(() {
                resetGame();
              });
            },
            child: const Text('Play Again'),
          ),

          ElevatedButton(
            onPressed: () {
              Navigator.of(context).popUntil(
                (route) => route.isFirst,
              );
            },
            child: const Text('Main Menu'),
          ),
        ],
      );
    },
  );
}

void resetGame() {
  horizontalLines.clear();
  verticalLines.clear();
  boxes.clear();

  player1Score = 0;
  player2Score = 0;

  currentPlayer = 1;

  selectedRow = null;
  selectedCol = null;
}

  // --------------------------------------------------
  // COLORS
  // --------------------------------------------------

  Color playerColor(int player) {
    if (player == 1) {
      return Colors.blue;
    }

    return Colors.red;
  }

  Color playerLineColor(int player) {
    if (player == 1) {
      return Colors.lightBlueAccent;
    }

    return Colors.redAccent.shade100;
  }

  // --------------------------------------------------
  // DOT
  // --------------------------------------------------

  Widget buildDot(int row, int col) {
    bool selected =
        selectedRow == row && selectedCol == col;

    return GestureDetector(
      onTap: () => selectDot(row, col),
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
              border: selected
                  ? Border.all(
                      color: Colors.white,
                      width: 3,
                    )
                  : null,
            ),
          ),
        ),
      ),
    );
  }

  // --------------------------------------------------
  // HORIZONTAL LINE
  // --------------------------------------------------

  Widget buildHorizontalLine(int row, int col) {
    int? owner =
        horizontalLines[horizontalKey(row, col)];

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

  // --------------------------------------------------
  // VERTICAL LINE
  // --------------------------------------------------

  Widget buildVerticalLine(int row, int col) {
    int? owner =
        verticalLines[verticalKey(row, col)];

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

  // --------------------------------------------------
  // BOX
  // --------------------------------------------------

  Widget buildBox(int row, int col) {
    int? owner = boxes[boxKey(row, col)];

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

  // --------------------------------------------------
  // BOARD
  // --------------------------------------------------

  Widget buildBoard() {
    List<Widget> boardRows = [];

    for (int row = 0; row < gridSize; row++) {
      // Dot / horizontal-line row
      List<Widget> dotRow = [];

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

      // Vertical-line / box row
      if (row < gridSize - 1) {
        List<Widget> boxRow = [];

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

  // --------------------------------------------------
  // PAGE
  // --------------------------------------------------

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dots & Boxes'),
      ),
      body: SafeArea(
        child: Column(
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
              'Tap one dot, then an adjacent dot',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey,
              ),
            ),

            const Spacer(),

            buildBoard(),

            const Spacer(),
          ],
        ),
      ),
    );
  }
}