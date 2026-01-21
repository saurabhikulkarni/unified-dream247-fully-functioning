// ignore_for_file: must_be_immutable

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:story_view/story_view.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/winners/data/models/stories_model.dart';

class StoryPage extends StatelessWidget {
  List<StoriesModel> stories;
  int? index;
  StoryPage({super.key, required this.stories, required this.index});
  final StoryController controller = StoryController();

  @override
  Widget build(BuildContext context) {
    List<StoryItem> list = [];
    for (var item in stories[index ?? 0].storyData ?? []) {
      if (item.type == 'image') {
        list.add(
          StoryItem.pageImage(
            url: item.url ?? '',
            controller: controller,
            duration: const Duration(seconds: 10),
          ),
        );
      } else if (item.type == 'video') {
        list.add(
          StoryItem.pageVideo(
            item.url ?? '',
            controller: controller,
            duration: const Duration(seconds: 10),
            loadingWidget: const SizedBox(
              height: 40,
              width: 40,
              // child: LoadingIndicator(
              //   strokeWidth: 1.0,
              //   indicatorType: Indicator.lineSpinFadeLoader,
              //   backgroundColor: AppColor.transparent,
              //   pathBackgroundColor: AppColor.transparent,
              //   colors: [AppColor.textColor, AppColor.greyColor],
              // ),
            ),
          ),
        );
      }
    }
    return Scaffold(
      body: GestureDetector(
        onVerticalDragUpdate: (details) {
          if (details.primaryDelta! > 10) {
            Navigator.pop(context);
          }
        },
        child: Stack(
          children: [
            StoryView(
              controller: controller,
              storyItems: list,
              onStoryShow: (storyItem, index) {},
              onComplete: () {
                index = (index ?? 0) + 1;
                Navigator.pop(context);
                if (index != stories.length) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StoryPage(stories: stories, index: index),
                    ),
                  );
                }
              },
              progressPosition: ProgressPosition.top,
              repeat: false,
              inline: true,
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 8.0,
                vertical: 85,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CircleAvatar(
                        radius: 23,
                        child: ClipOval(
                          child: CachedNetworkImage(
                            imageUrl:
                                stories[index ?? 0].storyProfileImage ?? '',
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${stories[index ?? 0].title}',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                  InkWell(
                    onTap: () => Navigator.of(context).pop(),
                    child: const Icon(
                      Icons.close,
                      color: AppColors.white,
                      size: 25,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
