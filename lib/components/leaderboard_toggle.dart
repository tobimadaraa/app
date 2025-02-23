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
      mainAxisAlignment:
          MainAxisAlignment.spaceEvenly, // Distribute buttons evenly
      children: [
        Expanded(child: _buildToggleButton("Ranked", LeaderboardType.ranked)),
        Expanded(child: _buildToggleButton("Cheater", LeaderboardType.cheater)),
        Expanded(
            child: _buildToggleButton("Toxicity", LeaderboardType.toxicity)),
        Expanded(child: _buildToggleButton("Honours", LeaderboardType.honour)),
      ],
    );
  }

  /// **Dynamic Toggle Button with white background and black text**
  Widget _buildToggleButton(String text, LeaderboardType type) {
    final bool isSelected = type == selectedLeaderboard;
    final BorderSide borderSide = isSelected
        ? const BorderSide(color: Colors.black, width: 2)
        : BorderSide(color: Colors.black.withValues(alpha: 0.5), width: 1);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 4), // Add small spacing
      child: ElevatedButton(
        onPressed: () => onSelectLeaderboard(type),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.white, // White background
          foregroundColor: Colors.black, // Black text
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10), // Rounded corners
            side: borderSide,
          ),
          padding: const EdgeInsets.symmetric(vertical: 8), // Vertical padding
        ),
        child: FittedBox(
          child: Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold, // Smaller bold text
            ),
          ),
        ),
      ),
    );
  }
}
