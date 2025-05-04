import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/core/routing/app_router.dart';
import 'package:water_mind/src/core/utils/app_localizations_helper.dart';
import 'package:water_mind/src/pages/introduction/introduction_view_model.dart';
import 'package:water_mind/src/pages/introduction/widgets/introduction_page_indicator.dart';
import 'package:water_mind/src/pages/introduction/widgets/introduction_page_item.dart';

@RoutePage()
class IntroductionPage extends ConsumerWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(introductionViewModelProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: TextButton(
                  onPressed: () {
                    // Navigate to the getting started flow
                    context.router.replace(GettingStartedRoute());
                  },
                  child: Text(
                    context.l10n.skip,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            // Page view
            Expanded(
              child: PageView(
                controller: viewModel.pageController,
                onPageChanged: (index) {
                  ref
                      .read(introductionViewModelProvider.notifier)
                      .updateCurrentPage(index);
                },
                children: [
                  // Page 1
                  IntroductionPageItem(
                    title: context.l10n.welcome,
                    description:
                        'Your personal hydration assistant to help you stay healthy and hydrated throughout the day.',
                    image: Image.asset(
                      'assets/images/united_kingdom.png',
                      height: 200,
                    ),
                  ),

                  // Page 2
                  IntroductionPageItem(
                    title: 'Track Your Water Intake',
                    description:
                        'Set daily goals, track your progress, and get reminders to drink water regularly.',
                    image: Image.asset(
                      'assets/images/france.png',
                      height: 200,
                    ),
                  ),
                  // Page 3
                  IntroductionPageItem(
                    title: 'Stay Healthy',
                    description:
                        'Proper hydration improves your health, energy levels, and overall well-being.',
                    image: Image.asset(
                      'assets/images/japan.png',
                      height: 200,
                    ),
                  ),
                ],
              ),
            ),

            // Water intake example button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: OutlinedButton(
                onPressed: () {
                  context.router.push(const WaterIntakeExampleRoute());
                },
                child: const Text('Try Water Intake Calculator'),
              ),
            ),

            // Page indicator and buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  // Page indicator
                  IntroductionPageIndicator(
                    pageCount: viewModel.totalPages,
                    currentPage: viewModel.currentPage,
                    activeColor: theme.colorScheme.primary,
                  ),

                  const SizedBox(height: 32.0),

                  // Navigation buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Back button (hidden on first page)
                      viewModel.currentPage > 0
                          ? TextButton(
                              onPressed: () {
                                ref
                                    .read(
                                        introductionViewModelProvider.notifier)
                                    .previousPage();
                              },
                              child: Text(context.l10n.back),
                            )
                          : const SizedBox(width: 80.0),

                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: () {
                          if (ref
                              .read(introductionViewModelProvider.notifier)
                              .isLastPage()) {
                            // Navigate to the getting started flow
                            context.router.replace(GettingStartedRoute());
                          } else {
                            ref
                                .read(introductionViewModelProvider.notifier)
                                .nextPage();
                          }
                        },
                        child: Text(
                          ref
                                  .read(introductionViewModelProvider.notifier)
                                  .isLastPage()
                              ? context.l10n.getStarted
                              : context.l10n.next,
                        ),
                      ),
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
