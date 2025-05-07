import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/history/water_history_page.dart';
import 'package:water_mind/src/pages/home/home_page.dart';

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
      body: IndexedStack(
        index: currentIndex,
        children: const [
          // Home tab
          HomePage(),

          // History tab
          WaterHistoryPage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) {
          ref.read(navigationIndexProvider.notifier).state = index;
        },
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
    );
  }
}
