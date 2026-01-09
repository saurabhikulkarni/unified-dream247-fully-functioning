import 'package:flutter/material.dart';
import 'package:Dream247/core/app_constants/app_colors.dart';

class ExpansionTileWidget extends StatefulWidget {
  final String? title;
  final Widget? child;
  const ExpansionTileWidget({super.key, this.title, this.child});

  @override
  State<ExpansionTileWidget> createState() => _FamilyExpensionTileState();
}

class _FamilyExpensionTileState extends State<ExpansionTileWidget> {
  bool _isTileExpanded = false;
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.lightYellow.withAlpha(27),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.transparent),
      ),
      child: Theme(
        data: Theme.of(context).copyWith(
          dividerColor: AppColors.transparent,
          splashColor: AppColors.transparent,
        ),
        child: ExpansionTile(
          title: Text(
            widget.title ?? '',
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w400),
          ),
          trailing: Icon(
            _isTileExpanded ? Icons.arrow_drop_up : Icons.arrow_drop_down,
          ),
          children: <Widget>[
            Container(
              margin: const EdgeInsets.all(15),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: widget.child,
              ),
            ),
          ],
          onExpansionChanged: (bool val) {
            setState(() {
              _isTileExpanded = val;
            });
          },
        ),
      ),
    );
  }
}
