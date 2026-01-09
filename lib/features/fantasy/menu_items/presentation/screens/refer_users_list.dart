import 'package:google_fonts/google_fonts.dart';
import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';

class ReferUsersList extends StatefulWidget {
  const ReferUsersList({super.key});

  @override
  State<ReferUsersList> createState() => _ReferUsersList();
}

class _ReferUsersList extends State<ReferUsersList> {
  // Future<List<ReferUserModel>?>? referList;
  // UserUsecases userUsecases =
  //     UserUsecases(UserDatasource(ApiImplWithAccessToken()));

  // Future<void> loadData() async {
  //   referList = userUsecases.getReferUsers(context);
  // }

  @override
  void initState() {
    super.initState();
    // loadData();
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: true,
      headerText: Strings.referedUsers,
      addPadding: false,
      child: Padding(
          padding: const EdgeInsets.all(10),
          child: Center(
            child: Text(
              'NO REFERED USERS',
              style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                  color: AppColors.letterColor),
            ),
          )
          // FutureBuilder(
          //   future: referList,
          //   builder: (context, snapshot) {
          //     if (snapshot.connectionState == ConnectionState.waiting) {
          //       return const Center(child: CircularProgressIndicator());
          //     } else {
          //       List<ReferUserModel> list = snapshot.data ?? [];
          //       return (list.isEmpty)
          //           ? const Center(
          //               child: Text(
          //                 'NO REFERED USERS',
          //                 style: TextStyle(
          //                     fontWeight: FontWeight.w600,
          //                     fontSize: 16,
          //                     color: AppColor.textColor),
          //               ),
          //             )
          //           : ListView.builder(
          //               itemCount: list.length,
          //               itemBuilder: (context, index) {
          //                 ReferUserModel data = list[index];
          //                 return singleListItem(data);
          //               },
          //             );
          //     }
          //   },
          // ),
          ),
    );
  }

  Widget singleListItem(//ReferUserModel data
      ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 5),
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(5),
          border: Border.all(color: AppColors.greyColor, width: 0.15),
          color: AppColors.white),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 25,
                child: ClipOval(child: Text("image")
                    // imageWidget(data.image!)
                    ),
              ),
              const SizedBox(
                width: 10,
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "'{data.team}'",
                    style: const TextStyle(
                        fontWeight: FontWeight.w400,
                        fontSize: 14,
                        color: AppColors.letterColor),
                  ),
                  Text(
                    '{data.username}',
                    style: const TextStyle(
                        fontWeight: FontWeight.w300,
                        fontSize: 12,
                        color: AppColors.greyColor),
                  ),
                ],
              )
            ],
          ),
          Text(
            '${Strings.indianRupee}{data.totalreferAmount}',
            style: GoogleFonts.tomorrow(
                fontWeight: FontWeight.w600,
                fontSize: 14,
                color: AppColors.letterColor),
          ),
        ],
      ),
    );
  }
}
