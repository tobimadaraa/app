import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class DodgeListView extends StatelessWidget {
  final List<LeaderboardModel> dodgeList;
  final Function(LeaderboardModel) onRemoveUser;
  final bool isPremium;
  final bool showPaywall; // NEW parameter

  const DodgeListView({
    super.key,
    required this.dodgeList,
    required this.onRemoveUser,
    required this.isPremium,
    this.showPaywall = true, // default true
  });

  @override
  Widget build(BuildContext context) {
    final int itemCount;
    if (isPremium) {
      itemCount = dodgeList.length;
    } else {
      // If paywall is enabled, show 5 items plus paywall; if disabled, cap at 5.
      itemCount = showPaywall
          ? (dodgeList.length > 5 ? 6 : dodgeList.length)
          : (dodgeList.length > 5 ? 5 : dodgeList.length);
    }

    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.grey,
        thickness: 0.5,
        indent: 10,
        endIndent: 10,
      ),
      itemBuilder: (context, index) {
        if (!isPremium && showPaywall && index == 5) {
          return _buildPaywallWidget();
        }

        final user = dodgeList[index];
        return ListTile(
          title: Text(
            '${user.gameName}#${user.tagLine}',
            style: TextStyle(color: Colors.white),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Cheater Reports: ${user.cheaterReports}',
                style: TextStyle(color: Colors.grey.shade400),
              ),
              Text(
                'Toxicity Reports: ${user.toxicityReports}',
                style: TextStyle(color: Colors.grey.shade400),
              ),
            ],
          ),
          trailing: IconButton(
            icon: const Icon(Icons.person_remove, color: Colors.red),
            iconSize: 20,
            onPressed: () => onRemoveUser(user),
          ),
        );
      },
    );
  }

  Widget _buildPaywallWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withAlpha((0.7 * 255).toInt()), // 70% opacity
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const Icon(Icons.lock, color: Colors.white, size: 35),
          const SizedBox(height: 8),
          const Text(
            "Upgrade to Premium to unlock more than 5 users.",
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {
              // Navigate to the Premium Upgrade Page
              // ignore: avoid_print
              print("Navigate to premium purchase");
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text("Upgrade Now"),
          ),
        ],
      ),
    );
  }
}
