import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:parsa/core/api/post_methods/post_user_review_prompt.dart';

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
    }
  }

  /// Call when the user visits the insights page.
  void userVisitedInsightsPage() {
    if (!_hasVisitedInsightsPage) {
      _hasVisitedInsightsPage = true;
    }
  }

  /// Starts the foreground session timer. Should be called when the app is resumed.
  void appResumed() {
    _foregroundStartTime = DateTime.now();
    _resetEngagementFlags();
  }

  /// Pauses the foreground session timer and saves the elapsed time.
  /// Should be called when the app is paused.
  Future<void> appPaused() async {
    if (_foregroundStartTime == null) {
      return;
    }

    final sessionDuration = DateTime.now().difference(_foregroundStartTime!);
    _foregroundStartTime = null;

    final prefs = await SharedPreferences.getInstance();
    int currentDuration = prefs.getInt(_timeInForegroundKey) ?? 0;
    currentDuration += sessionDuration.inSeconds;

    await prefs.setInt(_timeInForegroundKey, currentDuration);
  }

  /// Resets all review-related counters and timers in SharedPreferences.
  /// This should be called when a user logs out.
  Future<void> resetAllCounters() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_timeInForegroundKey, 0);
    _resetEngagementFlags();
  }

  /// Gets the total foreground time, including the current session's elapsed time.
  Future<int> _getCurrentForegroundTime() async {
    final prefs = await SharedPreferences.getInstance();
    final storedDuration = prefs.getInt(_timeInForegroundKey) ?? 0;

    var currentSessionDuration = 0;
    if (_foregroundStartTime != null) {
      currentSessionDuration =
          DateTime.now().difference(_foregroundStartTime!).inSeconds;
    }

    return storedDuration + currentSessionDuration;
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
  }

  void _resetEngagementFlags() {
    _hasVisitedTransactionsPage = false;
    _hasVisitedInsightsPage = false;
  }

  /// Checks if conditions are met to show an in-app review and displays it.
  Future<void> checkAndShowReviewDialog(BuildContext context) async {
    try {
      final userData = context.read<UserDataProvider>().userData;
      if (userData == null || userData['ask_feedback'] != true) {
        return;
      }

      if (!_isEngaged) {
        return;
      }

      final int foregroundTime = await _getCurrentForegroundTime();
      if (foregroundTime < _timeInForegroundThreshold) {
        return;
      }

      final InAppReview inAppReview = InAppReview.instance;
      final isAvailable = await inAppReview.isAvailable();
      if (!isAvailable) {
        return;
      }

      // Check each interaction type against its threshold.
      for (final type in ReviewInteractionType.values) {
        final count = await getInteractionCount(type);
        final threshold = _interactionThresholds[type]!;

        if (count >= threshold) {
          debugPrint('[ReviewService] Showing in-app review prompt');
          await inAppReview.requestReview();

          // Update the review prompt timestamp on the server
          final success =
              await PostUserReviewPrompt.updateReviewPromptTimestamp();
          debugPrint(
              '[ReviewService] Review prompt timestamp update ${success ? 'successful' : 'failed'}');

          _resetEngagementFlags();
          final prefs = await SharedPreferences.getInstance();
          await prefs.setInt(_timeInForegroundKey, 0);
          _foregroundStartTime = DateTime.now();

          return;
        }
      }
    } catch (e) {
      debugPrint('[ReviewService] Error showing review dialog: $e');
    }
  }
}
