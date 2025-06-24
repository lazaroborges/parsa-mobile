import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Defines the types of user interactions that can trigger an in-app review.
enum ReviewInteractionType {
  /// When a user edits or creates a transaction.
  transactionEdit,

  /// When a user accepts a "cousin" rule to categorize similar transactions.
  cousinRuleCreation,

  /// When a user creates a budget.
  budgetCreation,
}

class ReviewService {
  // Keys for storing interaction counts in SharedPreferences.
  static const Map<ReviewInteractionType, String> _interactionCountKeys = {
    ReviewInteractionType.transactionEdit: 'review_interaction_transactionEdit',
    ReviewInteractionType.cousinRuleCreation:
        'review_interaction_cousinRuleCreation',
    ReviewInteractionType.budgetCreation: 'review_interaction_budgetCreation',
  };

  // Thresholds for each interaction type to trigger a review.
  static const Map<ReviewInteractionType, int> _interactionThresholds = {
    ReviewInteractionType.transactionEdit: 5,
    ReviewInteractionType.cousinRuleCreation: 3,
    ReviewInteractionType.budgetCreation: 1,
  };

  // New constants for foreground time tracking
  static const String _timeInForegroundKey =
      'review_foreground_time_in_seconds';
  static const int _timeInForegroundThreshold = 200; // in seconds

  // Private constructor for singleton pattern.
  ReviewService._();

  // Singleton instance.
  static final ReviewService instance = ReviewService._();

  // New field to track session start time
  DateTime? _foregroundStartTime;

  /// Starts the foreground session timer. Should be called when the app is resumed.
  void appResumed() {
    _foregroundStartTime = DateTime.now();
    debugPrint('[ReviewService] App resumed, starting foreground timer.');
  }

  /// Pauses the foreground session timer and saves the elapsed time.
  /// Should be called when the app is paused.
  Future<void> appPaused() async {
    if (_foregroundStartTime == null) return;

    final sessionDuration = DateTime.now().difference(_foregroundStartTime!);
    _foregroundStartTime = null;

    final prefs = await SharedPreferences.getInstance();
    int currentDuration = prefs.getInt(_timeInForegroundKey) ?? 0;
    currentDuration += sessionDuration.inSeconds;

    await prefs.setInt(_timeInForegroundKey, currentDuration);
    debugPrint(
        '[ReviewService] App paused. Session duration: ${sessionDuration.inSeconds}s. Total foreground time: ${currentDuration}s.');
  }

  /// Resets all review-related counters and timers in SharedPreferences.
  /// This should be called when a user logs out.
  Future<void> resetAllCounters() async {
    final prefs = await SharedPreferences.getInstance();

    // Reset all interaction counters
    for (final key in _interactionCountKeys.values) {
      await prefs.setInt(key, 0);
    }

    // Reset the foreground time counter
    await prefs.setInt(_timeInForegroundKey, 0);

    debugPrint('[ReviewService] All counters have been reset.');
  }

  /// Increments the counter for a specific user interaction type.
  Future<void> incrementInteractionCount(
      ReviewInteractionType type, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _interactionCountKeys[type];
    if (key == null) return;
    final userData = context.read<UserDataProvider>().userData;
    if (userData == null || userData['ask_feedback'] != true) {
      return;
    }

    int currentCount = prefs.getInt(key) ?? 0;
    currentCount++;
    await prefs.setInt(key, currentCount);
    debugPrint(
        '[ReviewService] Interaction count for $type updated to: $currentCount');
  }

  /// Gets the current interaction count for a specific type.
  Future<int> getInteractionCount(ReviewInteractionType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _interactionCountKeys[type];
    if (key == null) return 0;
    return prefs.getInt(key) ?? 0;
  }

  /// Resets the interaction counter for a specific type, typically after a
  /// review has been shown.
  Future<void> _resetInteractionCount(ReviewInteractionType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _interactionCountKeys[type];
    if (key == null) return;
    await prefs.setInt(key, 0);
    debugPrint('[ReviewService] Interaction count for $type reset.');
  }

  /// Checks if conditions are met to show an in-app review and displays it.
  ///
  /// It iterates through each interaction type, and if any has reached its
  /// threshold, it triggers the review prompt and resets that specific counter.
  Future<void> checkAndShowReviewDialog(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // 1. Check if the cumulative foreground time has met the threshold.
      final int foregroundTime = prefs.getInt(_timeInForegroundKey) ?? 0;
      if (foregroundTime < _timeInForegroundThreshold) {
        debugPrint(
            '[ReviewService] Foreground time threshold not met: $foregroundTime / $_timeInForegroundThreshold seconds.');
        return;
      }

      final userData = context.read<UserDataProvider>().userData;
      if (userData == null || userData['ask_feedback'] != true) {
        return;
      }

      final InAppReview inAppReview = InAppReview.instance;
      if (!await inAppReview.isAvailable()) {
        return;
      }

      // Check each interaction type against its threshold.
      for (final type in ReviewInteractionType.values) {
        final count = await getInteractionCount(type);
        final threshold = _interactionThresholds[type]!;

        if (count >= threshold) {
          debugPrint(
              '[ReviewService] Threshold met for $type. Requesting review.');
          await inAppReview.requestReview();

          // Reset the counter for this specific type and exit.
          await _resetInteractionCount(type);
          return;
        }
      }
    } catch (e) {
      debugPrint('Error in checkAndShowReviewDialog: $e');
    }
  }
}
