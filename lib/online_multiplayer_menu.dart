
import 'package:flutter/material.dart';

class OnlineMultiplayerMenu extends StatefulWidget {
  const OnlineMultiplayerMenu({super.key});

  @override
  State<OnlineMultiplayerMenu> createState() =>
      _OnlineMultiplayerMenuState();
}

class _OnlineMultiplayerMenuState
    extends State<OnlineMultiplayerMenu> {
  final TextEditingController roomController =
      TextEditingController();

  @override
  void dispose() {
    roomController.dispose();
    super.dispose();
  }

  void hostGame() {
    // Next step: create a room in Supabase
    // and assign the host as Player 1.
  }

  void joinGame() {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Join Game'),
        content: TextField(
          controller: roomController,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Room Code',
            hintText: 'Enter room code',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              final roomId =
                  int.tryParse(roomController.text.trim());

              if (roomId == null) return;

              Navigator.pop(dialogContext);

              // Next step: join this room through Supabase
              // and assign the player as Player 2.
            },
            child: const Text('Join'),
          ),
        ],
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
              'Online Multiplayer',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 40),
            ElevatedButton(
              onPressed: hostGame,
              child: const Text('Host Game'),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: joinGame,
              child: const Text('Join Game'),
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
