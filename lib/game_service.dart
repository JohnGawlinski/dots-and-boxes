import 'package:supabase_flutter/supabase_flutter.dart';

class GameService {
  final SupabaseClient supabase = Supabase.instance.client;

  Future<Map<String, dynamic>> getGame(int roomId) async {
    final data = await supabase
        .from('mile2board')
        .select()
        .eq('roomid', roomId)
        .single();

    return {
      'roomid': data['roomid'],
      'horizontalLines':
          Map<String, int>.from(data['horizontal_lines'] ?? {}),
      'verticalLines':
          Map<String, int>.from(data['vertical_lines'] ?? {}),
      'boxes': Map<String, int>.from(data['boxes'] ?? {}),
      'player1Score': data['p1_score'] ?? 0,
      'player2Score': data['p2_score'] ?? 0,
      'currentPlayer': data['turn'] == true ? 2 : 1,
      'winner': data['winner'] ?? 0,
    };
  }

  
Future<String> makeMove({
  required int roomId,
  required int playerId,
  required int row,
  required int col,
  required String direction,
}) async {
  final result = await supabase.rpc(
    'make_move',
    params: {
      'x': row,
      'y': col,
      'direction': direction,
      'roomid': roomId,
      'playerid': playerId,
    },
  );

  return result.toString();
}

}
