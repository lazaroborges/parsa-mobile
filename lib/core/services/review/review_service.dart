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

  // Private constructor for singleton pattern.
  ReviewService._();

  // Singleton instance.
  static final ReviewService instance = ReviewService._();

  /// Increments the counter for a specific user interaction type.
  Future<void> incrementInteractionCount(ReviewInteractionType type) async {
    final prefs = await SharedPreferences.getInstance();
    final key = _interactionCountKeys[type];
    if (key == null) return;

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
