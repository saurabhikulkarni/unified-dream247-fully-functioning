import 'package:flutter/material.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl.dart';
import 'package:unified_dream247/features/fantasy/core/api_server_constants/api_server_impl/api_impl_header.dart';
import 'package:unified_dream247/features/fantasy/core/app_constants/app_colors.dart';
import 'package:unified_dream247/features/fantasy/core/global_widgets/common_shimmer_view_widget.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/data/models/fantasy_points_system_model.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/data/more_datasource.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/domain/use_cases/more_usecases.dart';
import 'package:unified_dream247/features/fantasy/more_options/presentation/widgets/expansion_tile_widget.dart';

class PointsSystemView extends StatefulWidget {
  final String gameType;
  const PointsSystemView({super.key, required this.gameType});

  @override
  State<PointsSystemView> createState() => _PointsSystemView();
}

class _PointsSystemView extends State<PointsSystemView> {
  MoreUsecases moreUsecases = MoreUsecases(
    MoreDatasource(ApiImpl(), ApiImplWithAccessToken()),
  );

  Future<List<FantasyPointsSystemData>?> _fetchPointsSystem() async {
    try {
      final data = await moreUsecases.pointsSystem(context);
      return data;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FC),
      body: RefreshIndicator(
        color: AppColors.mainColor,
        onRefresh: () {
          return _fetchPointsSystem();
        },
        child: FutureBuilder<List<FantasyPointsSystemData>?>(
          future: _fetchPointsSystem(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              // --- Shimmer while loading ---
              return ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
                  child: const ShimmerWidget(height: 70),
                ),
              );
            }

            if (snapshot.hasError) {
              // --- Error fallback shimmer ---
              return ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(10.0).copyWith(bottom: 0),
                  child: const ShimmerWidget(height: 70),
                ),
              );
            }

            if (snapshot.hasData && snapshot.data!.isNotEmpty) {
              List<FantasyPointsSystemData> list = snapshot.data!;

              return DefaultTabController(
                length: list.length,
                child: Scaffold(
                  backgroundColor: const Color(0xFFF7F9FC),
                  appBar: PreferredSize(
                    preferredSize: const Size.fromHeight(60),
                    child: Container(
                      decoration: BoxDecoration(
                        color: AppColors.white,
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.lightGrey.withValues(alpha: 0.15),
                            blurRadius: 8,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: TabBar(
                        isScrollable: true,
                        tabAlignment: TabAlignment.start,
                        indicator: BoxDecoration(
                          borderRadius: BorderRadius.circular(50),
                          color: AppColors.mainColor.withValues(alpha: 0.15),
                        ),
                        indicatorPadding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 8,
                        ),
                        labelPadding: const EdgeInsets.symmetric(
                          horizontal: 14,
                          vertical: 10,
                        ),
                        labelColor: AppColors.mainColor,
                        unselectedLabelColor: AppColors.letterColor,
                        labelStyle: const TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                        ),
                        tabs: [
                          for (var item in list)
                            Text(
                              item.formatName ?? '',
                              style: const TextStyle(letterSpacing: 0.3),
                            ),
                        ],
                      ),
                    ),
                  ),
                  body: TabBarView(
                    children: [
                      for (var item in list)
                        item.format != null && item.format!.isNotEmpty
                            ? _buildSingleFormat(item.format!)
                            : const Center(child: Text('No data available')),
                    ],
                  ),
                ),
              );
            }

            return const Center(
              child: Text(
                'No Points System Available',
                style: TextStyle(
                  color: AppColors.letterColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // --- Single Format Section ---
  Widget _buildSingleFormat(List<Format> data) {
    if (data.isNotEmpty) data[0].expended = true;

    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFF9FBFD), Color(0xFFF1F5FA)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: SingleChildScrollView(
        physics: const AlwaysScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 10),
              child: Center(
                child: Text(
                  "Here's how your team earns points",
                  style: TextStyle(
                    color: AppColors.letterColor,
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                    letterSpacing: 0.2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            for (var item in data)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: SingleSystem(data: item),
              ),
          ],
        ),
      ),
    );
  }
}

// --- Expansion Section ---
class SingleSystem extends StatefulWidget {
  final Format data;
  const SingleSystem({super.key, required this.data});

  @override
  State<SingleSystem> createState() => _SingleSystemState();
}

class _SingleSystemState extends State<SingleSystem> {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: AppColors.lightGrey.withValues(alpha: 0.08),
            blurRadius: 6,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ExpansionTileWidget(
        title: '${widget.data.roleName}',
        child: Padding(
          padding: const EdgeInsets.only(top: 6, bottom: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (var action in widget.data.actions ?? [])
                SingleAction(action),
            ],
          ),
        ),
      ),
    );
  }
}

// --- Each Points Row ---
class SingleAction extends StatelessWidget {
  final PointsSystemActions data;
  const SingleAction(this.data, {super.key});

  @override
  Widget build(BuildContext context) {
    bool isPositive = (data.value ?? 0) >= 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 12),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.lightCard,
          borderRadius: BorderRadius.circular(8),
        ),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                '${data.type}',
                style: const TextStyle(
                  color: AppColors.letterColor,
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
              ),
            ),
            Text(
              '${data.value}',
              style: TextStyle(
                color: isPositive ? AppColors.green : Colors.red,
                fontWeight: FontWeight.w700,
                fontSize: 13.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
