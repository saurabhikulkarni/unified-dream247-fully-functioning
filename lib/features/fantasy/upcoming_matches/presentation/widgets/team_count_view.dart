import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';

class TeamCountView extends StatelessWidget {
  final int text, selectedPlayers;

  const TeamCountView({
    super.key,
    required this.text,
    required this.selectedPlayers,
  });

  @override
  Widget build(BuildContext context) {
    return Flexible(
      flex: 1,
      child: Container(
        width: 25,
        height: 15,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(2.0),
          color: (text <= selectedPlayers) ? AppColors.green : AppColors.white,
          border: Border.all(color: AppColors.letterColor, width: .2),
        ),
        child: Center(
          child: Text(
            '$text',
            style: TextStyle(
              color: (text <= selectedPlayers)
                  ? AppColors.white
                  : AppColors.letterColor,
              fontSize: 9,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
      ),
    );
  }
}
