import 'package:flutter/material.dart';
import 'package:flutter_application_2/models/leaderboard_model.dart';

class DodgeListView extends StatelessWidget {
  final List<LeaderboardModel> dodgeList;
  final Function(LeaderboardModel) onRemoveUser;

  const DodgeListView({
    super.key,
    required this.dodgeList,
    required this.onRemoveUser,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: dodgeList.length,
      separatorBuilder: (context, index) => const Divider(
        color: Colors.grey,
        thickness: 0.5,
      ),
      itemBuilder: (context, index) {
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
            icon: const Icon(Icons.delete, color: Colors.red),
            onPressed: () => onRemoveUser(user),
          ),
        );
      },
    );
  }
}
