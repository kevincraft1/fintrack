import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'home_controller.dart';
import 'widgets/balance_summary_card.dart';
import 'widgets/quick_actions.dart';
import 'widgets/recent_transactions.dart';
import '../profile/profile_screen.dart';
import '../../core/theme/app_colors.dart';

class HomeScreen extends StatelessWidget {
  final HomeController c = Get.put(HomeController());

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: RefreshIndicator(
          color: AppColors.primary,
          backgroundColor: AppColors.card,
          onRefresh: c.loadHomeData,
          child: CustomScrollView(
            physics: const AlwaysScrollableScrollPhysics(
                parent: BouncingScrollPhysics()),
            slivers: [
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader()
                        .animate()
                        .fadeIn(duration: 400.ms)
                        .slideY(begin: -0.2, end: 0),
                    BalanceSummaryCard()
                        .animate()
                        .fadeIn(delay: 100.ms)
                        .slideY(begin: 0.1, end: 0),
                    const QuickActions()
                        .animate()
                        .fadeIn(delay: 200.ms)
                        .slideX(begin: 0.1, end: 0),
                    RecentTransactions(),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: EdgeInsets.only(left: 24.w, right: 24.w, top: 24.h, bottom: 8.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'FinTrack Pro',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 24.sp,
                  fontWeight: FontWeight.bold,
                  letterSpacing: -0.5,
                ),
              ),
              Text(
                'Kelola keuanganmu hari ini.',
                style:
                    TextStyle(color: AppColors.textSecondary, fontSize: 14.sp),
              ),
            ],
          ),
          GestureDetector(
            onTap: () =>
                Get.to(() => ProfileScreen(), transition: Transition.downToUp),
            child: CircleAvatar(
              radius: 20.r,
              backgroundColor: AppColors.primary.withOpacity(0.2),
              child: Icon(Icons.person, color: AppColors.primary, size: 24.sp),
            ),
          ),
        ],
      ),
    );
  }
}
