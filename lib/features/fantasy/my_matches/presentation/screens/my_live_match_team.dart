import 'package:unified_dream247/features/fantasy/menu_items/presentation/providers/user_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/images.dart';
import 'package:unified_dream247/features/fantasy/upcoming_matches/data/models/teams_model.dart';
import 'package:provider/provider.dart';

class MyLiveMatchTeam extends StatelessWidget {
  final TeamsModel data;

  const MyLiveMatchTeam({
    super.key,
    required this.data,
  });

  @override
  Widget build(BuildContext context) {
    final userData =
        Provider.of<UserDataProvider>(context, listen: false).userData;
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          /// ================= LEFT SECTION =================
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// Username
                Text(
                  '${userData?.id ?? "User"} (T${data.teamnumber})',
                  style: GoogleFonts.exo2(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),

                const SizedBox(height: 10),

                /// Points + Role counts row
                Row(
                  children: [
                    _pointsItem(data.totalpoints?.toInt()),
                    _roleItem('WK', data.wicketKeeperCount),
                    _roleItem('BAT', data.batsmancount),
                    _roleItem('AR', data.allroundercount),
                    _roleItem('BOWL', data.bowlercount),
                  ],
                ),
              ],
            ),
          ),

          /// ================= RIGHT SECTION =================
          Row(
            children: [
              _playerCard(
                image: data.captainimage,
                name: data.captain,
                label: 'Captain',
                bgColor: AppColors.mainColor,
              ),
              const SizedBox(width: 8),
              _playerCard(
                image: data.vicecaptainimage,
                name: data.vicecaptain,
                label: 'Vice Captain',
                bgColor: AppColors.green,
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// -------- Points block --------
  Widget _pointsItem(int? points) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Points',
          style: GoogleFonts.exo2(
            fontSize: 10.sp,
            color: AppColors.greyColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          '${points ?? 0}',
          style: GoogleFonts.exo2(
            fontSize: 12.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  /// -------- Role count --------
  Widget _roleItem(String title, int? value) {
    return Padding(
      padding: const EdgeInsets.only(left: 10),
      child: Column(
        children: [
          Text(
            title,
            style: GoogleFonts.exo2(
              fontSize: 10,
              color: AppColors.greyColor,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${value ?? 0}',
            style: GoogleFonts.exo2(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  /// -------- Captain / VC card --------
  Widget _playerCard({
    String? image,
    String? name,
    required String label,
    required Color bgColor,
  }) {
    return Column(
      children: [
        CircleAvatar(
            radius: 24.r,
            backgroundImage: AssetImage(Images.imageDefalutPlayer)),
        const SizedBox(height: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Text(
            label,
            style: GoogleFonts.exo2(
              fontSize: 10,
              color: AppColors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 78,
          child: Text(
            name ?? '',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            textAlign: TextAlign.center,
            style: GoogleFonts.exo2(
              fontSize: 10.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}
