
import 'dart:math';

import 'package:flutter/material.dart';
import 'game_service.dart';
import 'online_game_page.dart';

class JoinRoomPage extends StatefulWidget {
  const JoinRoomPage({super.key});

  @override
  State<JoinRoomPage> createState() => _JoinRoomPageState();
}

class _JoinRoomPageState extends State<JoinRoomPage> {
  final GameService gameService = GameService();

  static const int roomId = 1;

  String status = 'Joining Room 1...';

  @override
  void initState() {
    super.initState();
    joinRoom();
  }

  
  
Future<void> joinRoom() async {
  // Generate the player ID before the try block.
  final int playerId = Random.secure().nextInt(2000000000) + 1;

  try {
    final int playerNumber = await gameService.joinRoom(
      roomId: roomId,
      playerId: playerId,
    );

    if (!mounted) return;

    debugPrint('Joined as Player $playerNumber');

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
        builder: (context) => OnlineGamePage(
          roomId: roomId,
          playerId: playerId,
        ),
      ),
    );
  } catch (error) {
    if (!mounted) return;

    setState(() {
      status = 'Unable to join room:\n$error';
    });
  }
}



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Multiplayer'),
      ),
      body: Center(
        child: Text(
          status,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
