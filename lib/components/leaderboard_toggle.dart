import 'package:flutter/material.dart';
import 'package:flutter_application_2/shared/classes/shared_components.dart';

class LeaderboardToggle extends StatelessWidget {
  final LeaderboardType selectedLeaderboard;
  final Function(LeaderboardType) onSelectLeaderboard;

  const LeaderboardToggle({
    super.key,
    required this.selectedLeaderboard,
    required this.onSelectLeaderboard,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          ElevatedButton(
            onPressed: () => onSelectLeaderboard(LeaderboardType.ranked),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedLeaderboard == LeaderboardType.ranked
                  ? Colors.blue
                  : Colors.grey,
            ),
            child: const Text('Ranked'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => onSelectLeaderboard(LeaderboardType.cheater),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedLeaderboard == LeaderboardType.cheater
                  ? Colors.blue
                  : Colors.grey,
            ),
            child: const Text('Cheater'),
          ),
          const SizedBox(width: 10),
          ElevatedButton(
            onPressed: () => onSelectLeaderboard(LeaderboardType.toxicity),
            style: ElevatedButton.styleFrom(
              backgroundColor: selectedLeaderboard == LeaderboardType.toxicity
                  ? Colors.blue
                  : Colors.grey,
            ),
            child: const Text('Toxicity'),
          ),
        ],
      ),
    );
  }
}
