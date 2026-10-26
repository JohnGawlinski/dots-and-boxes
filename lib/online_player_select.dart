
import 'package:flutter/material.dart';
import 'online_game_page.dart';

class OnlinePlayerSelectPage extends StatelessWidget {
  const OnlinePlayerSelectPage({super.key});

  void openGame(BuildContext context, int playerId) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OnlineGamePage(
          roomId: 1,
          playerId: playerId,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Multiplayer'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Choose Your Player',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 40),

            ElevatedButton(
              onPressed: () => openGame(context, 1),
              child: const Text('Player 1'),
            ),

            const SizedBox(height: 20),

            ElevatedButton(
              onPressed: () => openGame(context, 2),
              child: const Text('Player 2'),
            ),

            const SizedBox(height: 40),

            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Back'),
            ),
          ],
        ),
      ),
    );
  }
}
