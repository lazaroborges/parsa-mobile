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
}

class ReviewService {
  // Keys for storing interaction counts in SharedPreferences.
  static const Map<ReviewInteractionType, String> _interactionCountKeys = {
    ReviewInteractionType.transactionEdit: 'review_interaction_transactionEdit',
    ReviewInteractionType.cousinRuleCreation:
        'review_interaction_cousinRuleCreation',
  };

  // Thresholds for each interaction type to trigger a review.
  static const Map<ReviewInteractionType, int> _interactionThresholds = {
    ReviewInteractionType.transactionEdit: 5,
    ReviewInteractionType.cousinRuleCreation: 3,
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

  // New fields for engagement tracking
  bool _hasVisitedTransactionsPage = false;
  bool _hasVisitedInsightsPage = false;

  bool get _isEngaged => _hasVisitedTransactionsPage && _hasVisitedInsightsPage;

  /// Call when the user visits the transactions page.
  void userVisitedTransactionsPage() {
    if (!_hasVisitedTransactionsPage) {
      _hasVisitedTransactionsPage = true;
      debugPrint('[ReviewService] User has visited the transactions page.');
    }
  }

  /// Call when the user visits the insights page.
  void userVisitedInsightsPage() {
    if (!_hasVisitedInsightsPage) {
      _hasVisitedInsightsPage = true;
      debugPrint('[ReviewService] User has visited the insights page.');
    }
  }

  /// Starts the foreground session timer. Should be called when the app is resumed.
  void appResumed() {
    debugPrint('[ReviewService] appResumed called.');
    _foregroundStartTime = DateTime.now();
    debugPrint('[ReviewService] App resumed, starting foreground timer.');
    _resetEngagementFlags();
  }

  /// Pauses the foreground session timer and saves the elapsed time.
  /// Should be called when the app is paused.
  Future<void> appPaused() async {
    debugPrint('[ReviewService] appPaused called.');
    if (_foregroundStartTime == null) {
      debugPrint(
          '[ReviewService] appPaused: _foregroundStartTime is null, returning.');
      return;
    }

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

    // Reset the foreground time counter
    await prefs.setInt(_timeInForegroundKey, 0);

    // Reset engagement flags
    _resetEngagementFlags();

    debugPrint('[ReviewService] All counters have been reset.');
  }

  /// Gets the total foreground time, including the current session's elapsed time.
  Future<int> _getCurrentForegroundTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDuration = prefs.getInt(_timeInForegroundKey) ?? 0;
    debugPrint(
        '[ReviewService] _getCurrentForegroundTime: storedDuration is $storedDuration seconds.');

    var currentSessionDuration = 0;
    if (_foregroundStartTime != null) {
      currentSessionDuration =
          DateTime.now().difference(_foregroundStartTime!).inSeconds;
      debugPrint(
          '[ReviewService] _getCurrentForegroundTime: _foregroundStartTime is $_foregroundStartTime, currentSessionDuration is $currentSessionDuration seconds.');
    } else {
      debugPrint(
          '[ReviewService] _getCurrentForegroundTime: _foregroundStartTime is null.');
    }

    final total = storedDuration + currentSessionDuration;
    debugPrint(
        '[ReviewService] _getCurrentForegroundTime: total foreground time is $total seconds.');
    return total;
  }

  /// Increments the counter for a specific user interaction type.
  Future<void> incrementInteractionCount(
      ReviewInteractionType type, BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _interactionCountKeys[type];
    if (key == null) return;
    final userData = context.read<UserDataProvider>().userData;
    if (userData == null || userData['ask_feedback'] != true) {
      debugPrint(
          '[ReviewService] User has feedback disabled, not incrementing count.');
      return;
    }

    int currentCount = prefs.getInt(key) ?? 0;
    currentCount++;
    await prefs.setInt(key, currentCount);
    debugPrint(
        '[ReviewService] Interaction count for $type updated to: $currentCount');

    await checkAndShowReviewDialog(context);
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

  void _resetEngagementFlags() {
    _hasVisitedTransactionsPage = false;
    _hasVisitedInsightsPage = false;
    debugPrint('[ReviewService] Engagement flags reset.');
  }

  /// Checks if conditions are met to show an in-app review and displays it.
  ///
  /// It iterates through each interaction type, and if any has reached its
  /// threshold, it triggers the review prompt and resets that specific counter.
  Future<void> checkAndShowReviewDialog(BuildContext context) async {
    try {
      debugPrint(
          '[ReviewService] Checking conditions to show review dialog...');

      final userData = context.read<UserDataProvider>().userData;
      if (userData == null || userData['ask_feedback'] != true) {
        debugPrint(
            '[ReviewService] Will not show. User has feedback disabled.');
        return;
      }

      if (!_isEngaged) {
        debugPrint(
            '[ReviewService] Engagement criteria not met. User has not visited both transactions and insights pages in this session.');
        return;
      }
      debugPrint('[ReviewService] Engagement criteria met.');

      final prefs = await SharedPreferences.getInstance();

      // 1. Check if the cumulative foreground time has met the threshold.
      final int foregroundTime = await _getCurrentForegroundTime();
      if (foregroundTime < _timeInForegroundThreshold) {
        debugPrint(
            '[ReviewService] Foreground time threshold not met: $foregroundTime / $_timeInForegroundThreshold seconds.');
        return;
      }
      debugPrint('[ReviewService] Foreground time threshold met.');

      final InAppReview inAppReview = InAppReview.instance;
      final isAvailable = await inAppReview.isAvailable();
      if (!isAvailable) {
        debugPrint(
            '[ReviewService] In-app review is not available on this device.');
        return;
      }
      debugPrint('[ReviewService] In-app review is available.');

      // Check each interaction type against its threshold.
      for (final type in ReviewInteractionType.values) {
        final count = await getInteractionCount(type);
        final threshold = _interactionThresholds[type]!;
        debugPrint(
            '[ReviewService] Checking threshold for $type: Count is $count, Threshold is $threshold');

        if (count >= threshold) {
          debugPrint(
              '[ReviewService] Threshold met for $type. Requesting review.');
          await inAppReview.requestReview();
          debugPrint('[ReviewService] Review requested.');

          _resetEngagementFlags();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_timeInForegroundKey, 0);
          _foregroundStartTime = DateTime.now(); // Restart session timer
          debugPrint('[ReviewService] Cumulative foreground time reset.');

          return;
        }
      }

      debugPrint(
          '[ReviewService] No interaction threshold met. Not showing review.');
    } catch (e) {
      debugPrint('Error in checkAndShowReviewDialog: $e');
    }
  }
}
