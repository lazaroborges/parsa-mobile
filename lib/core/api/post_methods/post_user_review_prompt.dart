import 'package:http/http.dart' as http;
import 'package:parsa/core/services/auth/auth0_class.dart';
import 'package:parsa/main.dart';

class PostUserReviewPrompt {
  static Future<bool> updateReviewPromptTimestamp() async {
    try {
      final auth0Provider = Auth0Provider.instance;
      final credentials = await auth0Provider.credentials;

      if (credentials == null) {
        print('User not authenticated, cannot update review prompt timestamp.');
        return false;
      }

      final response = await http.post(
        Uri.parse('$apiEndpoint/users/update-review-prompt/'),
        headers: {
          'Content-Type': 'application/json; charset=utf-8',
          'Authorization': 'Bearer ${credentials.accessToken}',
        },
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        print('Successfully updated review prompt timestamp.');
        return true;
      } else {
        print(
            'Failed to update review prompt timestamp: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating review prompt timestamp: $e');
      return false;
    }
  }
}
