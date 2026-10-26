
import 'dart:async';
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

  Timer? checkTimer;
  int? playerId;
  int? playerNumber;

  String status = 'Connecting to Room 1...';
  bool isChecking = false;
  bool gameStarted = false;

  @override
  void initState() {
    super.initState();
    joinRoom();
  }

  Future<void> joinRoom() async {
    try {
      final id = Random.secure().nextInt(2000000000) + 1;

      final assignedNumber = await gameService.joinRoom(
        playerId: id,
        roomId: roomId,
      );

      if (!mounted) return;

      playerId = id;
      playerNumber = assignedNumber;

      setState(() {
        status = assignedNumber == 1
            ? 'Waiting for Player 2...'
            : 'Waiting for game to start...';
      });

      // Check immediately, then once every 2 seconds.
      await checkRoom();

      if (!mounted || gameStarted) return;

      checkTimer = Timer.periodic(
        const Duration(seconds: 2),
        (_) => checkRoom(),
      );
    } catch (error) {
      if (!mounted) return;

      setState(() {
        status = 'Unable to join room:\n$error';
      });
    }
  }

  Future<void> checkRoom() async {
    if (isChecking || gameStarted || !mounted) return;

    isChecking = true;

    try {
      final ready = await gameService.areBothPlayersReady(roomId);

      if (!mounted || gameStarted) return;

      if (ready && playerId != null) {
        gameStarted = true;
        checkTimer?.cancel();

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => OnlineGamePage(
              roomId: roomId,
              playerId: playerId!,
            ),
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() {
          status = 'Error checking room:\n$error';
        });
      }
    } finally {
      isChecking = false;
    }
  }

  @override
  void dispose() {
    checkTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Matchmaking'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 30),
              const Text(
                'Searching for opponent...',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                status,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(height: 12),
              Text(
                playerNumber == null
                    ? 'Room 1'
                    : 'Room 1 - Player $playerNumber',
              ),
            ],
          ),
        ),
      ),
    );
  }
}
