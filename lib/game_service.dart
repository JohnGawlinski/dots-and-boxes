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

  
  Future<bool> areBothPlayersReady(int roomId) async {
    final data = await supabase
        .from('mile2board')
        .select('player1id, player2id')
        .eq('roomid', roomId)
        .maybeSingle();

    if (data == null) {
      return false;
    }

    return data['player1id'] != null &&
        data['player2id'] != null;
  }

  
 Future<String> makeMove({
  required int roomId,
  required int playerId,
  required int row,
  required int col,
  required String direction,
}) async {
  try {
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

  } catch (error, stackTrace) {
    print('MAKE_MOVE ERROR: $error');
    print('ERROR TYPE: ${error.runtimeType}');
    print('STACK TRACE: $stackTrace');

    rethrow;
  }
}

  Future<int> joinRoom({
    required int playerId,
    required int roomId,
  }) async {
    final result = await supabase.rpc(
      'joinroom',
      params: {
        'myid': playerId,
        'roomid': roomId,
      },
    );

    final message = result.toString();

    if (message == 'Room joined as player 1') {
      return 1;
    }

    if (message == 'Room joined as player 2') {
      return 2;
    }

    throw Exception(message);
  } 
  
  
  Future<void> saveRoomCode(String code) async {
    await supabase
        .from('mile2board')
        .update({
          'room_code': code,
          'player1id': 1,
          'player2id': null,
          'horizontal_lines': <String, int>{},
          'vertical_lines': <String, int>{},
          'boxes': <String, int>{},
          'p1_score': 0,
          'p2_score': 0,
          'turn': false,
          'winner': 0,
        })
        .eq('roomid', 1)
        .select('roomid')
        .single();
  }


  Future<bool> verifyRoomCode(String code) async {
  final room = await supabase
      .from('mile2board')
      .select('room_code')
      .eq('roomid', 1)
      .maybeSingle();

  if (room == null) {
    return false;
  }

  return room['room_code'] == code;
  }

  Future<bool> joinAsPlayer2(String code) async {
    final result = await supabase.rpc(
      'join_room_as_player2',
      params: {
        'entered_code': code,
      },
    );

    return result == true;
  }
}
