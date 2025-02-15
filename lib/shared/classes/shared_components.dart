import 'package:flutter_application_2/models/leaderboard_model.dart';
import 'package:flutter_application_2/repository/user_repository.dart';
import 'package:get/get.dart';

//import 'package:get/get_core/src/get_main.dart';

String newUserId = '';
String newTagLine = '';
String? globalUsernameError;
String? globalTagLineError;
late Future<List<LeaderboardModel>> leaderboardFuture;
final UserRepository userRepository = Get.put(
  UserRepository(),
); // Dependency injection

enum LeaderboardType { ranked, cheater, toxicity }
