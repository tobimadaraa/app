import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class DodgeListView extends StatelessWidget {
  final List<LeaderboardModel> dodgeList;
  final Function(LeaderboardModel) onRemoveUser;
  final bool isPremium; // ✅ Check if the user is premium

  const DodgeListView({
    super.key,
    required this.dodgeList,
    required this.onRemoveUser,
    required this.isPremium, // ✅ Receive premium status
  });

  @override
  Widget build(BuildContext context) {
    final int itemCount = isPremium
        ? dodgeList.length
        : (dodgeList.length > 5 ? 6 : dodgeList.length); // ✅ Add paywall if >5

    return ListView.separated(
      itemCount: itemCount,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.grey,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
        if (!isPremium && index == 5) {
          return _buildPaywallWidget();
        }

        final user = dodgeList[index];
        return ListTile(
          title: Text('${user.gameName}#${user.tagLine}'),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Cheater Reports: ${user.cheaterReports}'),
              Text('Toxicity Reports: ${user.toxicityReports}'),
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

  /// 🔒 Premium Paywall Widget (Appears at index 5 if non-premium)
  Widget _buildPaywallWidget() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
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
