import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'input_controller.dart';
import 'widgets/balance_card.dart';
import 'widgets/type_toggle.dart';
import 'widgets/amount_display.dart';
import 'widgets/note_input.dart';
import 'widgets/category_row.dart';
import 'widgets/numpad_grid.dart';
import '../history/history_screen.dart';
import '../dashboard/dashboard_screen.dart';
import '../category/category_management_screen.dart';
import '../../core/theme/app_colors.dart';

class InputScreen extends StatelessWidget {
  final InputController c = Get.put(InputController());

  InputScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.category, color: AppColors.textPrimary),
            onPressed: () => Get.to(() => CategoryManagementScreen(),
                transition: Transition.rightToLeftWithFade),
          ),
          IconButton(
            icon: const Icon(Icons.pie_chart, color: AppColors.textPrimary),
            onPressed: () => Get.to(() => DashboardScreen(),
                transition: Transition.rightToLeftWithFade),
          ),
          IconButton(
            icon: const Icon(Icons.history, color: AppColors.textPrimary),
            onPressed: () => Get.to(() => HistoryScreen(),
                transition: Transition.rightToLeftWithFade),
          )
        ],
      ),
      body: SafeArea(
        child: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      BalanceCard()
                          .animate()
                          .fadeIn(delay: 100.ms)
                          .slideY(begin: -0.2, end: 0),
                      TypeToggle()
                          .animate()
                          .fadeIn(delay: 150.ms)
                          .slideX(begin: -0.1, end: 0),
                    ],
                  ),
                  AmountDisplay(),
                  Column(
                    children: [
                      NoteInput().animate().fadeIn(delay: 220.ms),
                      CategoryRow().animate().fadeIn(delay: 250.ms),
                      NumpadGrid(),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
