import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/strings.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/sub_container.dart';
import 'package:unified_dream247/features/fantasy/core/utils/app_utils.dart';
import 'package:unified_dream247/features/fantasy/features/landing/data/models/notification_model.dart';

class NotificationPage extends StatefulWidget {
  const NotificationPage({super.key});

  @override
  State<NotificationPage> createState() => _NotificationPageState();
}

class _NotificationPageState extends State<NotificationPage> {
  Future<List<NotificationModel>?>? notificationList;

  @override
  void initState() {
    super.initState();
    // notificationList = HomeServices.getNotifications(context);
  }

  @override
  Widget build(BuildContext context) {
    return SubContainer(
        showAppBar: true,
        showWalletIcon: false,
        headerText: Strings.notifications,
        addPadding: true,
        child: FutureBuilder(
            future: notificationList,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return ListView.builder(
                    itemCount: 20,
                    itemBuilder: (context, index) {
                      return ShimmerWidget(
                        margin: const EdgeInsets.all(10).copyWith(bottom: 0),
                        height: 70,
                      );
                    });
              } else if (snapshot.hasError) {
                return Center(
                  child: Text(
                    'Error: ${snapshot.error}',
                    style: const TextStyle(color: AppColors.mainLightColor),
                  ),
                );
              } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return const Center(
                  child: Padding(
                    padding: EdgeInsets.all(10),
                    child: Text(
                      'No Notifications',
                      style: TextStyle(
                        color: AppColors.black,
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                    ),
                  ),
                );
              } else {
                return ListView.builder(
                  itemCount: snapshot.data?.length,
                  itemBuilder: (context, index) {
                    return singleNotification(snapshot.data![index]);
                  },
                );
              }
            }));
  }

  Widget singleNotification(NotificationModel data) {
    return Container(
      padding: const EdgeInsets.all(10),
      margin: const EdgeInsets.all(10).copyWith(bottom: 0),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.black, width: 0.4),
      ),
      child: Row(
        children: [
          Image.asset(
            Images.verified,
            width: 45,
            height: 45,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(1),
                  child: Text(
                    data.title ?? '',
                    style: const TextStyle(
                      color: AppColors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(1),
                  child: Text(
                    AppUtils.formatDateTime(data.createdAt!),
                    style: const TextStyle(
                      color: Color(0xFF808080),
                      fontWeight: FontWeight.w400,
                      fontSize: 11,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
