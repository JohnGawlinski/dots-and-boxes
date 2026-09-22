import 'package:flutter/material.dart';
import 'game_page.dart';

void main() {
  runApp(const DotsAndBoxesApp());
}

class DotsAndBoxesApp extends StatelessWidget {
  const DotsAndBoxesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Dots & Boxes',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness: Brightness.dark,
        ),
      ),
      home: const MainMenuPage(),
    );
  }
}

class MainMenuPage extends StatelessWidget {
  const MainMenuPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'DOTS & BOXES',
              style: TextStyle(
                fontSize: 40,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 50),

            MenuButton(
              text: 'Singleplayer',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const SingleplayerPage(),
                  ),
                );
              },
            ),

            MenuButton(
              text: 'Multiplayer',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const MultiplayerPage(),
                  ),
                );
              },
            ),

            MenuButton(
              text: 'Tutorial',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TutorialPage(),
                  ),
                );
              },
            ),

            
          ],
        ),
      ),
    );
  }
}

class MenuButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;

  const MenuButton({
    super.key,
    required this.text,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8),
      child: SizedBox(
        width: 220,
        height: 55,
        child: ElevatedButton(
          onPressed: onPressed,
          child: Text(
            text,
            style: const TextStyle(fontSize: 20),
          ),
        ),
      ),
    );
  }
}

class BackMenuButton extends StatelessWidget {
  final VoidCallback onPressed;

  const BackMenuButton({
    super.key,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 140,
      height: 45,
      child: ElevatedButton(
        onPressed: onPressed,
        child: const Text(
          'Back',
          style: TextStyle(
            fontSize: 17,
          ),
        ),
      ),
    );
  }
}

// ---------------- SINGLEPLAYER ----------------

class SingleplayerPage extends StatelessWidget {
  const SingleplayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Select Difficulty',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 30),

              MenuButton(
                text: 'Easy',
                onPressed: () {},
              ),

              MenuButton(
                text: 'Medium',
                onPressed: () {},
              ),

              MenuButton(
                text: 'Hard',
                onPressed: () {},
              ),

              MenuButton(
                text: 'Impossible',
                onPressed: () {},
              ),

              // Extra space before Back
              const SizedBox(height: 35),

              BackMenuButton(
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ---------------- MULTIPLAYER ----------------

class MultiplayerPage extends StatelessWidget {
  const MultiplayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Select Mode',
              style: TextStyle(
                fontSize: 30,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 30),

            MenuButton(
              text: 'Online',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) =>
                        const OnlineMultiplayerPage(),
                  ),
                );
              },
            ),

            MenuButton(
              text: 'Local',
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const GamePage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 35),

BackMenuButton(
  onPressed: () {
    Navigator.pop(context);
  },
),
          ],
        ),
      ),
    );
  }
}

// ---------------- ONLINE MULTIPLAYER ----------------

class OnlineMultiplayerPage extends StatelessWidget {
  const OnlineMultiplayerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Online Multiplayer'),
      ),
      body: const Center(
        child: Text(
          'Online Multiplayer Coming Soon',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ---------------- TUTORIAL ----------------

class TutorialPage extends StatelessWidget {
  const TutorialPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tutorial'),
      ),
      body: const Padding(
        padding: EdgeInsets.all(30),
        child: Center(
          child: Text(
            'Dots & Boxes Tutorial\n\n'
            'Players take turns connecting two adjacent dots.\n\n'
            'Complete the fourth side of a box to claim it.\n\n'
            'The player with the most boxes at the end wins!',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 22),
          ),
        ),
      ),
    );
  }
}