import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/utils/icons_manager.dart';

class DodgeListView extends StatelessWidget {
  final List<LeaderboardModel> dodgeList;
  final Function(LeaderboardModel) onRemoveUser;
  final bool isPremium;
  final bool showPaywall;

  const DodgeListView({
    super.key,
    required this.dodgeList,
    required this.onRemoveUser,
    required this.isPremium,
    required this.showPaywall,
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

    return dodgeList.isEmpty
        ? const Center(
            child: Text(
              "No players in Dodge List",
              style: TextStyle(color: Colors.white, fontSize: 16),
            ),
          )
        : ListView.builder(
            itemCount: itemCount,
            itemBuilder: (context, index) {
              if (!isPremium && showPaywall && index == 5) {
                return _buildPaywallWidget();
              }

              final user = dodgeList[index];

              return Container(
                decoration: BoxDecoration(
                  color: const Color(0xff2c3154),
                  borderRadius: index == 0
                      ? const BorderRadius.vertical(top: Radius.circular(16))
                      : BorderRadius.zero,
                ),
                child: Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 8),
                      leading: CircleAvatar(
                        radius: 30,
                        backgroundColor: Colors.transparent,
                        backgroundImage: AssetImage(
                            IconManager.getIconByIndex(user.iconIndex)),
                      ),
                      title: Text(
                        '${user.gameName}#${user.tagLine}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          height: 1.0,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Cheater Reports: ${user.cheaterReports}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                          Text(
                            'Toxicity Reports: ${user.toxicityReports}',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[400],
                            ),
                          ),
                        ],
                      ),
                      trailing: IconButton(
                        icon:
                            const Icon(Icons.person_remove, color: Colors.red),
                        iconSize: 20,
                        onPressed: () => onRemoveUser(user),
                      ),
                    ),
                    if (index != dodgeList.length - 1)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Divider(
                          color: Colors.grey[800],
                          thickness: 1,
                          height: 1,
                        ),
                      ),
                  ],
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
