import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:Dream247/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';
import 'package:Dream247/features/upcoming_matches/data/models/expert_advice_model.dart';
import 'package:Dream247/features/upcoming_matches/data/upcoming_match_datsource.dart';
import 'package:Dream247/features/upcoming_matches/domain/use_cases/upcoming_match_usecase.dart';

class ExpertAdviceScreen extends StatefulWidget {
  const ExpertAdviceScreen({super.key});

  @override
  State<ExpertAdviceScreen> createState() => _ExpertAdviceScreenState();
}

class _ExpertAdviceScreenState extends State<ExpertAdviceScreen> {
  Future<List<ExpertAdviceModel>?>? adviceList;
  UpcomingMatchUsecase upcomingMatchUsecase = UpcomingMatchUsecase(
      UpcomingMatchDatsource(ApiImpl(), ApiImplWithAccessToken()));

  @override
  void initState() {
    super.initState();
    getExpertAdvice();
  }

  getExpertAdvice() {
    adviceList = upcomingMatchUsecase.getExpertAdvice(context);
    setState(() {});
  }

  void _showAdviceDetails(
      BuildContext context, ExpertAdviceModel advice, int index) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return ClipRRect(
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(28),
            topRight: Radius.circular(28),
          ),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              decoration: BoxDecoration(
                color: AppColors.white.withValues(alpha: 0.9),
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(28),
                  topRight: Radius.circular(28),
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.blackColor.withValues(alpha: 0.1),
                    blurRadius: 12,
                    offset: const Offset(0, -3),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      margin: const EdgeInsets.only(bottom: 16),
                      decoration: BoxDecoration(
                        color: AppColors.lightGrey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                  const Text(
                    "Expert Insight",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.mainColor,
                    ),
                  ),
                  const SizedBox(height: 18),
                  Text(
                    advice.content ?? "",
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                      fontWeight: FontWeight.w500,
                      color: AppColors.blackColor,
                    ),
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton.icon(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.done_all_rounded,
                      color: AppColors.white,
                    ),
                    label: const Text(
                      "Got it!",
                      style: TextStyle(color: AppColors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.mainColor,
                      minimumSize: const Size(double.infinity, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgColor,
      appBar: AppBar(
        title: Text(
          "Expert Advice",
          style: GoogleFonts.exo2(
              color: AppColors.black,
              fontSize: 16.0,
              fontWeight: FontWeight.w600),
        ),
        centerTitle: true,
      ),
      body: FutureBuilder(
        future: adviceList,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text("Error: ${snapshot.error}"),
            );
          } else if (snapshot.hasData) {
            final adviceList = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: adviceList.length,
              itemBuilder: (context, index) {
                final advice = adviceList[index];
                return GestureDetector(
                  onTap: () => _showAdviceDetails(context, advice, index),
                  child: Container(
                    margin: EdgeInsets.symmetric(vertical: 5.0, horizontal: 8),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        color: AppColors.lightCard),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppColors.black,
                        child: Text(
                          "${index + 1}",
                          style: const TextStyle(color: AppColors.white),
                        ),
                      ),
                      title: Text(
                        advice.title ?? "",
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      trailing: const Icon(Icons.arrow_forward_ios_rounded,
                          size: 18, color: AppColors.blackColor),
                    ),
                  ),
                );
              },
            );
          } else {
            return const Center(child: Text("No advice available."));
          }
        },
      ),
    );
  }
}
