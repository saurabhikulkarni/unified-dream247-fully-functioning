import 'dart:io';

import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/data/models/level_reward_model.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/data/models/refer_users_model.dart';
import 'package:unified_dream247/features/fantasy/features/menu_items/domain/repositories/user_repositories.dart';

class UserUsecases {
  UserRepositories userRepositories;
  UserUsecases(this.userRepositories);

  Future<String?> uploadImage(BuildContext context, File userImage) async {
    var res = await userRepositories.uploadImage(context, userImage);
    if (res != null) {
      return res;
    }
    return "";
  }

  // Future<void> uploadImageToS3(
  //     File imageFile, String folderName, String fileName) async {
  //   var res =
  //       await userRepositories.uploadImageToS3(imageFile, folderName, fileName);
  //   return res;
  // }

  Future<bool?> getUserDetails(BuildContext context) async {
    var res = await userRepositories.getUserDetails(context);
    if (res != null) {
      // updateContestWon(context);
      return true;
    }
    return null;
  }

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
  ) async {
    var res = await userRepositories.updateProfile(
      context,
      teamName,
      name,
      state,
      gender,
      city,
      address,
      dob,
      pincode,
    );
    if (res ?? false) {
      return res;
    }
    return null;
  }

  Future<bool?> editTeamName(
    BuildContext context,
    bool teamNameUpdateStatus,
  ) async {
    var res = await userRepositories.editTeamName(
      context,
      teamNameUpdateStatus,
    );
    if (res ?? false) {
      return res;
    }
    return null;
  }

  Future<void> submitSupportRequest(BuildContext context, String email,
      String mobile, String reason, String message, File supportImage) async {
    var res = await userRepositories.submitSupportRequest(
        context, email, mobile, reason, message, supportImage);
    if (res ?? false) {
      return;
    }
  }

  Future<List<ReferUserModel>?>? getReferUsers(BuildContext context) async {
    var res = await userRepositories.getReferUsers(context);
    if (res != null) {
      return res;
    }
    return null;
  }

  Future<LevelRewardModel?> loadLevelRewards(BuildContext context) async {
    var res = await userRepositories.loadLevelRewards(context);
    if (res != null) {
      return res;
    }
    return null;
  }
}
