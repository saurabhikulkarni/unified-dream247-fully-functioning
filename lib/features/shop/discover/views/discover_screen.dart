import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:unified_dream247/features/shop/constants.dart';
import 'package:unified_dream247/features/shop/models/category_model.dart';
import 'package:unified_dream247/features/shop/route/route_constants.dart';
import 'package:unified_dream247/features/shop/screens/search/views/components/search_form.dart';

class DiscoverScreen extends StatelessWidget {
  const DiscoverScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(defaultPadding),
              child: GestureDetector(
                onTap: () {
                  Navigator.pushNamed(context, searchScreenRoute);
                },
                child: const AbsorbPointer(
                  child: SearchForm(isEnabled: false),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(
                  horizontal: defaultPadding, vertical: defaultPadding / 2),
              child: Text(
                "Categories",
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ),
            // While loading use 👇
            // const Expanded(
            //   child: DiscoverCategoriesSkelton(),
            // ),
            Expanded(
              child: ListView.builder(
                itemCount: demoCategories.length,
                itemBuilder: (context, index) {
                  final category = demoCategories[index];
                  
                  return Column(
                    children: [
                      ListTile(
                        leading: SvgPicture.asset(
                          category.svgSrc!,
                          height: 24,
                          width: 24,
                          colorFilter: ColorFilter.mode(
                            Theme.of(context).iconTheme.color!,
                            BlendMode.srcIn,
                          ),
                        ),
                        title: Text(
                          category.title,
                          style: const TextStyle(fontSize: 14),
                        ),
                        trailing: Icon(
                          Icons.arrow_forward_ios,
                          size: 16,
                          color: Theme.of(context).iconTheme.color,
                        ),
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            categoryProductsScreenRoute,
                            arguments: {
                              'categoryName': category.title,
                              'categoryId': category.title.toLowerCase(),
                            },
                          );
                        },
                      ),
                      if (index < demoCategories.length - 1) 
                        const Divider(height: 1),
                    ],
                  );
                },
              ),
            )
          ],
        ),
      ),
    );
  }
}
