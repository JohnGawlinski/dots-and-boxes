import 'dart:math';

/// Single line on the board, using the same coordinates as GamePage
class AiMove {
   final bool horizontal;
   final int row;
   final int col;

   const AiMove(this.horizontal, this.row, this.col);

   @override
   bool operator ==(Object other) =>
      other is AiMove &&
      other.horizontal == horizontal &&
      other.row == row &&
      other.col == col;

   @override
   int get hashCode => Object.hash(horizontal, row, col);
}

/// Read-only view of the board AI uses to view game
class AiBoard {
   final int gridSize;
   final Map<String, int> horizontalLines;
   final Map<String, int> verticalLines;

   const AiBoard(this.gridSize, this.horizontalLines, this.verticalLines);

   bool _h(int r, int c) => horizontalLines.containsKey('$r,$c');
   bool _v(int r, int c) => verticalLines.containsKey('$r,$c');

   /// Every line not drawn yet
   List<AiMove> availableMoves() {
      final moves = <AiMove>[];

      for (int r = 0; r < gridSize; r++) {
         for (int c = 0; c < gridSize - 1; c++) {
            if (!_h(r,c)) moves.add(AiMove(true, r, c));
         }
      }

      for (int r = 0; r < gridSize - 1; r++) {
         for (int c = 0; c < gridSize; c++) {
            if (!_v(r,c)) moves.add(AiMove(false, r, c));
         }
      }

      return moves;
   }

   /// How many of lines of a box are filled
   int boxSidesFilled(int r, int c) {
      int count = 0;
      if (_h(r,c)) count++;
      if (_h(r+1,c)) count++;
      if (_v(r,c)) count++;
      if (_v(r,c+1)) count++;
      return count;
   }

   /// Boxes that share this line
   List<List<int>> boxesTouching(AiMove move) {
      final touched = <List<int>>[];

      if (move.horizontal) {
         if (move.row-1 >= 0) touched.add([move.row-1, move.col]);
         if (move.row <= gridSize-2) touched.add([move.row, move.col]);
      } else {
         if (move.col-1 >= 0) touched.add([move.row, move.col-1]);
         if (move.col <= gridSize-2) touched.add([move.row, move.col]);
      }

      return touched;
   }

   /// Boxes completed by this line
   int boxesCompletedBy(AiMove move) {
      int count = 0;
      for (final box in boxesTouching(move)) {
         if (boxSidesFilled(box[0], box[1]) == 3) count++;
      }
      return count;
   }
}

/// AI levels - Previous levels build upon each other
class DotsBoxesAI {
   static const double attackMin = 0.2;
   static const double attackMax = 0.9;
   static const double attackStep = 0.05;
   static const double attackStart = 0.5;

   final int level;
   final Random _random;

   /// "AI Weight" is used to determine whether a scoring move is taken when
   /// a random roll is above the weight. A lower threshold means a more
   /// aggressive AI. It drops by the attackStep each pass on an attack and
   /// rises each attack.
   double attackThreshold = attackStart;

   DotsBoxesAI({required this.level, Random? random})
      : _random = random ?? Random();

   /// New Game
   void reset(){
      attackThreshold = attackStart;
   }

   AiMove? chooseMove(
      int gridSize,
      Map<String, int> horizontalLines,
      Map<String, int> verticalLines,
   ) {
      final board = AiBoard(gridSize, horizontalLines, verticalLines);
      final moves = board.availableMoves();

      if (moves.isEmpty) return null;

      switch (level) {
         case 1:
            return level1Move(moves);
         case 2:
            return level2Move(moves, board);
         default:
            return level3Move(moves, board);
      }
   }

   /// Level 1 - Basic Gameplay
   AiMove level1Move(List<AiMove> moves) {
      return moves[_random.nextInt(moves.length)];
   }

   /// Level 2 - Score Orientation
   AiMove level2Move(List<AiMove> moves, AiBoard board) {
      final scoring = scoringMoves(moves, board);

      if (scoring.isNotEmpty) {
         final best = board.boxesCompletedBy(scoring.first);
         final bestMoves = scoring
            .where((m) => board.boxesCompletedBy(m) == best)
            .toList();
         return level1Move(bestMoves);
      }

      return level1Move(moves);
   }

   /// Level 3 - Chaining
   AiMove level3Move(List<AiMove> moves, AiBoard board) {
      final scoring = scoringMoves(moves, board);
      final declined = <AiMove>{};

      for (final move in scoring) {
         final roll = _random.nextDouble();
            
         if (roll > attackThreshold) {
            /// Attack Success
            attackThreshold = min(attackMax, attackThreshold + attackStep);
            return move;
         } else {
            /// Attack Failed
            attackThreshold = max(attackMin, attackThreshold - attackStep);
            declined.add(move);
         }
      }

      final remaining = moves.where((m) => !declined.contains(m)).toList();

      /// Only Scoring Moves rejected remain
      if (remaining.isEmpty) {
         return level1Move(declined.toList());
      }

      return level2Move(remaining, board);
   }

   /// Moves that complete at least one box, with most coming first
   List<AiMove> scoringMoves(List<AiMove> moves, AiBoard board) {
      final scoring = moves.where((m) => board.boxesCompletedBy(m) > 0).toList();

      scoring.sort((a,b) => board.boxesCompletedBy(b).compareTo(board.boxesCompletedBy(a)),);

      return scoring;
   }
}
