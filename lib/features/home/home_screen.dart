import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'home_controller.dart';
import 'widgets/balance_summary_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/wallet_list_section.dart';
import 'widgets/recent_transactions.dart';
import '../profile/profile_screen.dart';
import '../../core/theme/app_colors.dart';
import '../../core/widgets/version_footer.dart';

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
              backgroundColor: AppColors.background,
              elevation: 0,
              pinned: true,
              centerTitle: false,
              titleSpacing: 24.w,
              toolbarHeight: 56.h,
              title: Row(
                children: [
                  Image.asset(
                    'assets/images/fintrack-pro.png',
                    width: 32.w,
                    height: 32.w,
                    fit: BoxFit.contain,
                  ),
                  SizedBox(width: 12.w),
                  Text(
                    'FinTrack Pro',
                    style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20.sp,
                        fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              actions: [
                Padding(
                  padding: EdgeInsets.only(right: 24.w),
                  child: GestureDetector(
                    onTap: () => Get.to(() => ProfileScreen(),
                        transition: Transition.rightToLeftWithFade),
                    child: Container(
                      padding: EdgeInsets.all(8.w),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.primary.withOpacity(0.2)),
                      ),
                      child: Icon(Icons.person_outline,
                          color: AppColors.primary, size: 22.sp),
                    ),
                  ),
                ),
              ],
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
                  SizedBox(height: 24.h),
                  VersionFooter(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
