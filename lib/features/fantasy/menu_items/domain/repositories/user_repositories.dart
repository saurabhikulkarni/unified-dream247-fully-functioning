import 'package:universal_io/io.dart';

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/level_reward_model.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/models/refer_users_model.dart';

abstract class UserRepositories {
  Future<bool?> getUserDetails(BuildContext context);

  Future<bool?> updateProfile(
    BuildContext context,
    String teamName,
    String name,
    String state,
    String gender,
    String city,
    String address,
    String dob,
    String pincode,
  );

  Future<bool?> editTeamName(BuildContext context, bool teamNameUpdateStatus);

  Future<String?> uploadImage(BuildContext context, File userImage);

  // Future<void> uploadImageToS3(
  //     File imageFile, String folderName, String fileName);

  Future<bool?> submitSupportRequest(BuildContext context, String email,
      String mobile, String reason, String message, File supportImage,);

  Future<LevelRewardModel?> loadLevelRewards(BuildContext context);

  Future<List<ReferUserModel>?>? getReferUsers(BuildContext context);
}
