
import 'dart:math';
import 'package:flutter/material.dart';
import 'game_service.dart';

class OnlinePlayerSelectPage extends StatefulWidget {
  const OnlinePlayerSelectPage({super.key});

  @override
  State<OnlinePlayerSelectPage> createState() =>
      _OnlinePlayerSelectPageState();
}

class _OnlinePlayerSelectPageState
    extends State<OnlinePlayerSelectPage> {
  final TextEditingController codeController =
      TextEditingController();

  String? roomCode;
  String? message;

  Future<void> selectPlayer1() async {
  final code = (Random.secure().nextInt(900000) + 100000)
      .toString();

  try {
    await GameService().saveRoomCode(code);

    if (!mounted) return;

    setState(() {
      roomCode = code;
      message = null;
    });
  } catch (error) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Error creating room: $error'),
      ),
    );
  }
}

  void selectPlayer2() {
    setState(() {
      roomCode = null;
      message = 'Enter the room code from Player 1.';
    });
  }

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Multiplayer'),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Choose Your Player',
                style: TextStyle(fontSize: 26),
              ),

              const SizedBox(height: 30),

              ElevatedButton(
                onPressed: selectPlayer1,
                child: const Text('Player 1'),
              ),

              const SizedBox(height: 15),

              ElevatedButton(
                onPressed: selectPlayer2,
                child: const Text('Player 2'),
              ),

              const SizedBox(height: 30),

              if (roomCode != null) ...[
                const Text('Your Room Code:'),
                const SizedBox(height: 10),
                SelectableText(
                  roomCode!,
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text('Waiting for Player 2...'),
              ],

              if (message != null) ...[
                Text(message!),
                const SizedBox(height: 15),
                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'Room Code',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                ElevatedButton(
                  onPressed: () async {
                    final code = codeController.text.trim();

                    if (code.length != 6 || int.tryParse(code) == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Enter a valid 6-digit code.'),
                        ),
                      );
                      return;
                    }

                    try {
                      final isValid =
                          await GameService().verifyRoomCode(code);

                      if (!mounted) return;

                      if (isValid) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Room found! Code matches.'),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Invalid room code.'),
                          ),
                        );
                      }
                    } catch (error) {
                      if (!mounted) return;

                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Error joining room: $error'),
                        ),
                      );
                    }
                  },
                  child: const Text('Join Room'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
