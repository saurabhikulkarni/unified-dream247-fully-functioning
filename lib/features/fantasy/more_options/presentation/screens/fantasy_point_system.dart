import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/core/app_constants/strings.dart';
import 'package:Dream247/core/global_widgets/sub_container.dart';
import 'package:Dream247/features/more_options/presentation/widgets/points_system_view.dart';

class FantasyPointsSystem extends StatelessWidget {
  const FantasyPointsSystem({super.key});

  //  final List<GamesGetSet> listGames = AppSingleton.singleton.appData.games!;

  @override
  Widget build(BuildContext context) {
    return SubContainer(
      showAppBar: true,
      showWalletIcon: false,
      headerText: Strings.fantasyPointSystem,
      addPadding: false,
      child: DefaultTabController(
        length: //listGames.length,
            1,
        child: Scaffold(
          backgroundColor: AppColors.mainColor,
          appBar: TabBar(
            indicatorColor: AppColors.white,
            indicatorWeight: 4.0,
            tabs: [
              // for (var item in listGames)
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // SizedBox(
                  //   width: 14,
                  //   height: 14,
                  //   // child: Image.asset(Images.profileImg),
                  //   // CachedNetworkImage(
                  //   //   imageUrl: item.image!,
                  //   //   placeholder: (context, url) =>
                  //   //       const CircularProgressIndicator(),
                  //   //   color: AppColors.white,
                  //   // )
                  // ),
                  Padding(
                    padding: const EdgeInsets.all(5),
                    child: Text(
                      "Cricket",
                      //item.fantasyName!,
                      style: const TextStyle(
                        color: AppColors.white,
                        fontWeight: FontWeight.w600,
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          body: TabBarView(children: [PointsSystemView(gameType: "Cricket")]),
        ),
      ),
    );
  }
}
