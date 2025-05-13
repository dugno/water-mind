import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/history/water_history_page.dart';
import 'package:water_mind/src/pages/home/home_page.dart';
import 'package:water_mind/src/pages/home/home_view_model.dart';

/// Provider for the current navigation index
final navigationIndexProvider = StateProvider<int>((ref) => 0);

/// Main navigation page with bottom navigation
@RoutePage()
class MainNavigationPage extends ConsumerWidget {
  /// Constructor
  const MainNavigationPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentIndex = ref.watch(navigationIndexProvider);

    return Scaffold(
      backgroundColor: AppColor.secondaryColor,
      body: IndexedStack(
        index: currentIndex,
        children: const [
          HomePage(),
          WaterHistoryPage(),
        ],
      ),
      floatingActionButton: AnimatedAddButton(
        onPressed: () {
          // Only call addWaterIntakeEntry if we're on the home page
          if (currentIndex == 0) {
            final homeViewModel = ref.read(homeViewModelProvider.notifier);
            homeViewModel.addWaterIntakeEntry();
          }
        },
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: Container(
        height: 93,
        decoration: BoxDecoration(
          color: AppColor.thirdColor,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: BottomNavigationBar(
            backgroundColor: AppColor.thirdColor,
            currentIndex: currentIndex,
            onTap: (index) {
              ref.read(navigationIndexProvider.notifier).state = index;
            },
            elevation: 0,
            selectedItemColor: Colors.white,
            unselectedItemColor: Colors.white.withOpacity(0.5),
            selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold),
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(
                icon: const Icon(Icons.home),
                label: context.l10n.home,
              ),
              BottomNavigationBarItem(
                icon: const Icon(Icons.history),
                label: context.l10n.history,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Animated Floating Action Button with pulse effect
class AnimatedAddButton extends StatefulWidget {
  /// The function to call when the button is pressed
  final VoidCallback onPressed;

  /// Constructor
  const AnimatedAddButton({
    super.key,
    required this.onPressed,
  });

  @override
  State<AnimatedAddButton> createState() => _AnimatedAddButtonState();
}

class _AnimatedAddButtonState extends State<AnimatedAddButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    // Scale animation for button press effect
    _scaleAnimation = Tween<double>(begin: 1.0, end: 0.95).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.2, curve: Curves.easeInOut),
      ),
    );

    // Pulse animation for shadow
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColor.primaryColor.withOpacity(0.3),
                  blurRadius: 12 * _pulseAnimation.value,
                  spreadRadius: 2 * _pulseAnimation.value,
                ),
              ],
            ),
            child: FloatingActionButton.large(
              onPressed: () {
                // Add haptic feedback
                HapticFeedback.mediumImpact();

                // Call the provided onPressed function
                widget.onPressed();
              },
              backgroundColor: AppColor.primaryColor,
              elevation: 0,
              shape: const CircleBorder(),
              child: const Icon(Icons.add, color: Colors.white, size: 36),
            ),
          ),
        );
      },
    );
  }
}
