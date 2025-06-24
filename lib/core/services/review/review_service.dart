import 'package:flutter/material.dart';
import 'package:in_app_review/in_app_review.dart';
import 'package:parsa/core/providers/user_data_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ReviewService {
  static const String _interactionCountKey = 'review_interaction_count';
  static const String _reviewRequestedKey = 'review_has_been_requested';
  static const int _interactionThreshold = 5;

  // Private constructor to prevent instantiation
  ReviewService._();

  // Singleton instance
  static final ReviewService instance = ReviewService._();

  /// Increments the user interaction counter.
  /// This should be called after a significant positive user action,
  /// like categorizing a transaction or creating a rule.
  Future<void> incrementInteractionCount() async {
    final prefs = await SharedPreferences.getInstance();
    int currentCount = prefs.getInt(_interactionCountKey) ?? 0;
    currentCount++;
    await prefs.setInt(_interactionCountKey, currentCount);
    debugPrint('[ReviewService] Interaction count updated to: $currentCount');
  }

  /// Gets the current interaction count.
  Future<int> getInteractionCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_interactionCountKey) ?? 0;
  }

  /// Resets the interaction counter.
  Future<void> _resetInteractionCount() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_interactionCountKey, 0);
    debugPrint('[ReviewService] Interaction count reset.');
  }

  /// Checks if the conditions to show an in-app review are met and, if so,
  /// displays the review dialog.
  ///
  /// Conditions:
  /// 1. `ask_feedback` is true in user data.
  /// 2. The interaction count has reached the threshold.
  /// 3. A review has not been requested before in this installation.
  Future<void> checkAndShowReviewDialog(BuildContext context) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final bool hasBeenRequested = prefs.getBool(_reviewRequestedKey) ?? false;

      // If already requested, do nothing.
      if (hasBeenRequested) {
        return;
      }

      // Check if user data allows feedback
      final userData = context.read<UserDataProvider>().userData;
      if (userData == null || userData['ask_feedback'] != true) {
        return;
      }

      // Check if interaction threshold is met
      final interactionCount = await getInteractionCount();
      if (interactionCount < _interactionThreshold) {
        return;
      }

      final InAppReview inAppReview = InAppReview.instance;
      if (await inAppReview.isAvailable()) {
        await inAppReview.requestReview();
        // Mark that the review has been requested to avoid asking again.
        await prefs.setBool(_reviewRequestedKey, true);
        // Reset the counter so it doesn't trigger again for other reasons
        // until the app is reinstalled.
        await _resetInteractionCount();
      }
    } catch (e) {
      debugPrint('Error in checkAndShowReviewDialog: $e');
    }
  }
}
