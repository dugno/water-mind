import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:water_mind/src/common/constant/app_color.dart';
import 'package:water_mind/src/pages/introduction/introduction_view_model.dart';
import 'package:water_mind/src/pages/introduction/widgets/introduction_page_indicator.dart';
import 'package:water_mind/src/pages/introduction/widgets/introduction_page_item.dart';

@RoutePage()
class IntroductionPage extends ConsumerWidget {
  const IntroductionPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewModel = ref.watch(introductionViewModelProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      backgroundColor: Colors.white,
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
                    // Navigate to the next screen after introduction
                    // context.router.replace(const HomeRoute());
                  },
                  child: const Text(
                    'Skip',
                    style: TextStyle(
                      color: AppColor.primaryColor,
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
                  ref.read(introductionViewModelProvider.notifier).updateCurrentPage(index);
                },
                children: [
                  // Page 1
                  IntroductionPageItem(
                    title: 'Welcome to Water Mind',
                    description: 'Your personal hydration assistant to help you stay healthy and hydrated throughout the day.',
                    image: Image.asset(
                      'assets/images/united_kingdom.png',
                      height: 200,
                    ),
                  ),

                  // Page 2
                  IntroductionPageItem(
                    title: 'Track Your Water Intake',
                    description: 'Set daily goals, track your progress, and get reminders to drink water regularly.',
                    image: Image.asset(
                      'assets/images/france.png',
                      height: 200,
                    ),
                  ),

                  // Page 3
                  IntroductionPageItem(
                    title: 'Stay Healthy',
                    description: 'Proper hydration improves your health, energy levels, and overall well-being.',
                    image: Image.asset(
                      'assets/images/japan.png',
                      height: 200,
                    ),
                  ),
                ],
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
                    activeColor: AppColor.primaryColor,
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
                                ref.read(introductionViewModelProvider.notifier).previousPage();
                              },
                              child: const Text(
                                'Back',
                                style: TextStyle(
                                  color: AppColor.primaryColor,
                                ),
                              ),
                            )
                          : const SizedBox(width: 80.0),

                      // Next/Get Started button
                      ElevatedButton(
                        onPressed: () {
                          if (ref.read(introductionViewModelProvider.notifier).isLastPage()) {
                            // Navigate to the next screen after introduction
                            // context.router.replace(const HomeRoute());
                          } else {
                            ref.read(introductionViewModelProvider.notifier).nextPage();
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColor.primaryColor,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 12.0),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0),
                          ),
                        ),
                        child: Text(
                          ref.read(introductionViewModelProvider.notifier).isLastPage()
                              ? 'Get Started'
                              : 'Next',
                          style: const TextStyle(fontSize: 16.0),
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