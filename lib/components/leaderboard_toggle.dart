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
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildToggleButton("Ranked", LeaderboardType.ranked),
        const SizedBox(width: 12), // ✅ Spacing
        _buildToggleButton("Cheater", LeaderboardType.cheater),
        const SizedBox(width: 12),
        _buildToggleButton("Toxicity", LeaderboardType.toxicity),
        const SizedBox(width: 12),
        _buildToggleButton(
            "Honours", LeaderboardType.honour), // ✅ New Honours Button
      ],
    );
  }

  /// **🔥 Dynamic Toggle Button**
  Widget _buildToggleButton(String text, LeaderboardType type) {
    final bool isSelected = type == selectedLeaderboard;

    return ElevatedButton(
      onPressed: () => onSelectLeaderboard(type),
      style: ElevatedButton.styleFrom(
        backgroundColor: isSelected ? Colors.blue : Colors.grey,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10), // ✅ Rounded corners
        ),
        padding: const EdgeInsets.symmetric(
            horizontal: 18, vertical: 12), // ✅ Good button size
      ),
      child: Text(
        text,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
      ),
    );
  }
}
