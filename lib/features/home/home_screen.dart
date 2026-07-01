import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_controller.dart';
import 'widgets/balance_summary_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/wallet_list_section.dart';
import 'widgets/recent_transactions.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final HomeController c = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: RefreshIndicator(
        color: AppColors.primary,
        backgroundColor: AppColors.card,
        onRefresh: () async => await c.loadHomeData(),
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(
              parent: BouncingScrollPhysics()),
          slivers: [
            SliverAppBar(
              expandedHeight: 80.h,
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: true,
              flexibleSpace: FlexibleSpaceBar(
                titlePadding:
                    EdgeInsets.symmetric(horizontal: 24.w, vertical: 16.h),
                title: Text(
                  'FinTrack Pro',
                  style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20.sp,
                      fontWeight: FontWeight.bold),
                ),
              ),
            ),
            SliverToBoxAdapter(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  BalanceSummaryCard()
                      .animate()
                      .fadeIn(duration: 500.ms)
                      .slideY(begin: 0.1, end: 0),
                  SizedBox(height: 24.h),
                  WalletListSection()
                      .animate()
                      .fadeIn(delay: 100.ms)
                      .slideX(begin: 0.1, end: 0),
                  SizedBox(height: 24.h),
                  const QuickActions()
                      .animate()
                      .fadeIn(delay: 200.ms)
                      .slideY(begin: 0.1, end: 0),
                  SizedBox(height: 24.h),
                  RecentTransactions()
                      .animate()
                      .fadeIn(delay: 300.ms)
                      .slideY(begin: 0.1, end: 0),
                  SizedBox(height: 100.h),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
