import 'package:flutter/material.dart';

class LeaderboardToggle extends StatelessWidget {
  final bool showToxicityLeaderboard;
  final VoidCallback onToggleCheater;
  final VoidCallback onToggleToxic;

  const LeaderboardToggle({
    super.key,
    required this.showToxicityLeaderboard,
    required this.onToggleCheater,
    required this.onToggleToxic,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: onToggleCheater,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  showToxicityLeaderboard ? Colors.grey : Colors.blue,
            ),
            child: const Text('Cheater Leaderboard'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: onToggleToxic,
            style: ElevatedButton.styleFrom(
              backgroundColor:
                  showToxicityLeaderboard ? Colors.blue : Colors.grey,
            ),
            child: const Text('Toxicity Leaderboard'),
          ),
        ],
      ),
    );
  }
}
