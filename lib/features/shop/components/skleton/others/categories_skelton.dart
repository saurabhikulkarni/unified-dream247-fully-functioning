import 'package:flutter/material.dart';

import 'package:unified_dream247/features/shop/constants.dart';
import '../skelton.dart';

class CategoriesSkelton extends StatelessWidget {
  const CategoriesSkelton({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: List.generate(
          5,
          (_) => const Padding(
            padding: EdgeInsets.only(left: defaultPadding),
            child: Skeleton(
              height: 32,
              width: 96,
            ),
          ),
        ),
      ),
    );
  }
}