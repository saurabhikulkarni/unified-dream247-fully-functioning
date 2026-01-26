// ignore_for_file: constant_identifier_names, use_build_context_synchronously
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/app_toast.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_widgets.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/main_button.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/menu_items/data/user_datasource.dart';
import 'package:unified_dream247/features/fantasy/menu_items/domain/use_cases/user_usecases.dart';
import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:provider/provider.dart';

class EditProfile extends StatefulWidget {
  const EditProfile({super.key});

  @override
  State<EditProfile> createState() => _EditProfile();
}

class _EditProfile extends State<EditProfile> {
  // 📝 Only Team Name field - other user details edited in Shop profile
  final TextEditingController _teamNameController = TextEditingController();
  
  UserUsecases userUsecases = UserUsecases(
    UserDatasource(ApiImplWithAccessToken()),
  );

  @override
  void initState() {
    super.initState();
  }

  /// Update only Team Name
  void submitData() async {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    
    if (!AppUtils.isValidTeamName(_teamNameController.text)) {
      appToast('Please enter valid Team Name', context);
      return;
    }
    
    // ✅ Update only team name - preserve all other user details
    await userUsecases
        .updateProfile(
          context,
          _teamNameController.text.trim(),  // ✅ New team name
          userData?.name ?? '',             // Preserve name
          userData?.state ?? '',            // Preserve state
          userData?.gender ?? '',           // Preserve gender
          userData?.city ?? '',             // Preserve city
          userData?.address ?? '',          // Preserve address
          userData?.dob ?? '',              // Preserve dob
          userData?.pincode?.toString() ?? '',  // Preserve pincode
        )
        .then((value) {
          if (value != null) {
            setState(() {
              userData!.team = _teamNameController.text;  // ✅ Update team name
              userData.teamNameUpdateStatus = true;
              
              Provider.of<UserDataProvider>(context, listen: false)
                  .updateUser(userData);
              
              appToast('Team name updated successfully', context);
              Navigator.of(context).pop();
            });
          }
        });
  }

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    
    // ✅ Only initialize team name
    _teamNameController.text = userData?.team ?? '';

    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.editProfile,
      addPadding: false,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.mainColor.withValues(alpha: 0.05),
              AppColors.white,
              AppColors.white,
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const SizedBox(height: 30),
                
                // 📝 Info Section
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.mainColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: AppColors.mainColor.withValues(alpha: 0.3),
                      width: 1,
                    ),
                  ),
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: AppColors.mainColor,
                        size: 28,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Edit Team Name',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.mainColor,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'To edit your name, email, and other personal details, please use the Shop Profile section.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.letterColor,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // 🎯 Team Name Form Card
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lightGrey.withValues(alpha: 0.15),
                        blurRadius: 12,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Label
                      Text(
                        'Team Name',
                        style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w600,
                          color: AppColors.letterColor,
                        ),
                      ),
                      const SizedBox(height: 12),
                      
                      // Team Name Input Field (Only Editable Field)
                      customTextFieldReadOnly(
                        _teamNameController,
                        'Enter your fantasy team name',
                        TextInputType.name,
                        10,
                        false,  // ✅ false = enabled (editable)
                        1,
                      ),
                      
                      const SizedBox(height: 8),
                      Text(
                        'e.g., Dream Warriors, Victory Squad, etc.',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: AppColors.lightGrey,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 30),

                // Submit Button
                MainButton(
                  color: AppColors.mainColor,
                  textColor: Colors.white,
                  onTap: () {
                    submitData();
                  },
                  text: 'Update Team Name',
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
