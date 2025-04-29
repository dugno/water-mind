import 'package:flutter/material.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'introduction_view_model.g.dart';

/// State class for the introduction screen
class IntroductionState {
  final int currentPage;
  final PageController pageController;
  final int totalPages;

  const IntroductionState({
    required this.currentPage,
    required this.pageController,
    required this.totalPages,
  });

  /// Creates a copy of this state with the given fields replaced
  IntroductionState copyWith({
    int? currentPage,
    PageController? pageController,
    int? totalPages,
  }) {
    return IntroductionState(
      currentPage: currentPage ?? this.currentPage,
      pageController: pageController ?? this.pageController,
      totalPages: totalPages ?? this.totalPages,
    );
  }
}

/// Provider for the introduction view model
@riverpod
class IntroductionViewModel extends _$IntroductionViewModel {
  static const int _totalPages = 3;

  @override
  IntroductionState build() {
    final pageController = PageController();
    
    // Dispose the page controller when the provider is disposed
    ref.onDispose(() {
      pageController.dispose();
    });
    
    return IntroductionState(
      currentPage: 0,
      pageController: pageController,
      totalPages: _totalPages,
    );
  }

  /// Navigate to the next page
  void nextPage() {
    if (state.currentPage < state.totalPages - 1) {
      state.pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      state = state.copyWith(currentPage: state.currentPage + 1);
    }
  }

  /// Navigate to the previous page
  void previousPage() {
    if (state.currentPage > 0) {
      state.pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      state = state.copyWith(currentPage: state.currentPage - 1);
    }
  }

  /// Jump to a specific page
  void goToPage(int page) {
    if (page >= 0 && page < state.totalPages) {
      state.pageController.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
      state = state.copyWith(currentPage: page);
    }
  }

  /// Update the current page (called when page changes from swipe)
  void updateCurrentPage(int page) {
    state = state.copyWith(currentPage: page);
  }

  /// Check if this is the last page
  bool isLastPage() {
    return state.currentPage == state.totalPages - 1;
  }
}
