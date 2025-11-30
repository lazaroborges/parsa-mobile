# Flutter Integration Guide - Parsa Go API

This guide explains how to integrate your Flutter app with the Parsa Go API for authentication and data management.

## Table of Contents
- [Authentication Overview](#authentication-overview)
- [OAuth 2.0 Flow (Google)](#oauth-20-flow-google)
- [Password Authentication](#password-authentication)
- [JWT Token Management](#jwt-token-management)
- [Making Authenticated Requests](#making-authenticated-requests)
- [API Endpoint Reference](#api-endpoint-reference)
- [Flutter Implementation Examples](#flutter-implementation-examples)

## Authentication Overview

The Parsa Go API supports two authentication methods:

1. **OAuth 2.0** (Google) - Recommended for production
2. **Email/Password** - Traditional authentication

Both methods return a JWT token that must be included in subsequent API requests.

### Authentication Response

All successful authentication returns:

```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "user": {
    "id": 123,
    "email": "user@example.com",
    "name": "John Doe",
    "firstName": "John",
    "lastName": "Doe",
    "oauthProvider": "google",
    "avatarUrl": "https://...",
    "createdAt": "2025-01-15T10:30:00Z",
    "updatedAt": "2025-01-15T10:30:00Z"
  }
}
```

### JWT Structure

The custom JWT implementation uses:
- **Algorithm**: HS256 (HMAC-SHA256)
- **Expiration**: 24 hours
- **Claims**: `userId`, `email`, `iat`, `exp`

## OAuth 2.0 Flow (Google)

### Flow Diagram

```
Flutter App → GET /api/auth/oauth/url → Receive auth URL
     ↓
Open browser with auth URL → User authenticates with Google
     ↓
Google redirects → /api/auth/oauth/callback?code=...
     ↓
Backend processes → Returns JWT token → Flutter receives token
```

### Step-by-Step Implementation

#### 1. Request OAuth URL

**Endpoint**: `GET /api/auth/oauth/url`

**Response**:
```json
{
  "url": "https://accounts.google.com/o/oauth2/v2/auth?client_id=...&state=..."
}
```

**Flutter Code**:
```dart
Future<String> getGoogleAuthUrl() async {
  final response = await http.get(
    Uri.parse('${baseUrl}/api/auth/oauth/url'),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return data['url'];
  }

  throw Exception('Failed to get auth URL');
}
```

#### 2. Open OAuth URL in Browser

Use `url_launcher` or `webview_flutter` to open the auth URL:

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> initiateGoogleLogin() async {
  final authUrl = await getGoogleAuthUrl();

  if (await canLaunchUrl(Uri.parse(authUrl))) {
    await launchUrl(
      Uri.parse(authUrl),
      mode: LaunchMode.externalApplication,
    );
  }
}
```

#### 3. Handle OAuth Callback

The API handles the callback automatically at `/api/auth/oauth/callback?code=...&state=...`

**Important Notes**:
- The callback endpoint automatically creates or finds the user
- It sets an `access_token` HttpOnly cookie (for web)
- It redirects to `/oauth-callback` page

**For Flutter Mobile Apps**:

Since mobile apps can't access HttpOnly cookies, you have two options:

**Option A: Deep Link Handling** (Recommended)

Configure your Google OAuth redirect URL to use a deep link:

```dart
// In your app's deep link handler
Future<void> handleDeepLink(Uri uri) async {
  if (uri.path == '/oauth-callback' && uri.queryParameters.containsKey('code')) {
    final code = uri.queryParameters['code'];

    // Exchange code for token via your API
    final token = await exchangeCodeForToken(code);
    await saveToken(token);

    // Navigate to home screen
    Navigator.pushReplacementNamed(context, '/home');
  }
}
```

**Option B: Modify API to Return Token in Redirect**

You may need to modify the callback handler to support mobile by returning the token as a query parameter or using a custom URL scheme.

#### 4. Alternative: Create Mobile-Specific OAuth Endpoint

Add a mobile-friendly endpoint that returns the token in the response body:

```dart
// Request to a modified endpoint (you would need to add this to the API)
Future<AuthResponse> completeOAuthLogin(String code) async {
  final response = await http.post(
    Uri.parse('${baseUrl}/api/auth/oauth/mobile'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({'code': code}),
  );

  if (response.statusCode == 200) {
    final data = jsonDecode(response.body);
    return AuthResponse.fromJson(data);
  }

  throw Exception('OAuth login failed');
}
```

## Password Authentication

### Registration

**Endpoint**: `POST /api/auth/register`

**Request**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123",
  "name": "John Doe"
}
```

**Response**: Same as [Authentication Response](#authentication-response)

**Flutter Code**:
```dart
class AuthService {
  final String baseUrl;

  AuthService(this.baseUrl);

  Future<AuthResponse> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      return AuthResponse.fromJson(jsonDecode(response.body));
    }

    throw Exception('Registration failed: ${response.body}');
  }
}
```

### Login

**Endpoint**: `POST /api/auth/login`

**Request**:
```json
{
  "email": "user@example.com",
  "password": "securePassword123"
}
```

**Response**: Same as [Authentication Response](#authentication-response)

**Flutter Code**:
```dart
Future<AuthResponse> login({
  required String email,
  required String password,
}) async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/login'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'email': email,
      'password': password,
    }),
  );

  if (response.statusCode == 200) {
    return AuthResponse.fromJson(jsonDecode(response.body));
  } else if (response.statusCode == 400 &&
             response.body.contains('OAuth authentication')) {
    throw Exception('This account uses Google Sign-In');
  }

  throw Exception('Login failed: ${response.body}');
}
```

### Logout

**Endpoint**: `POST /api/auth/logout`

**Response**: 204 No Content

**Flutter Code**:
```dart
Future<void> logout() async {
  final response = await http.post(
    Uri.parse('$baseUrl/api/auth/logout'),
  );

  if (response.statusCode == 204) {
    // Clear local token storage
    await secureStorage.delete(key: 'jwt_token');
  }
}
```

## JWT Token Management

### Storing the Token

Use `flutter_secure_storage` for secure token storage:

```dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class TokenStorage {
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

### Token Expiration Handling

Tokens expire after 24 hours. Implement automatic logout:

```dart
import 'dart:convert';

class JwtHelper {
  static DateTime? getExpiryDate(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return null;

      // Decode payload (second part)
      final payload = parts[1];
      final normalized = base64Url.normalize(payload);
      final decoded = utf8.decode(base64Url.decode(normalized));
      final Map<String, dynamic> claims = jsonDecode(decoded);

      if (claims['exp'] != null) {
        return DateTime.fromMillisecondsSinceEpoch(claims['exp'] * 1000);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  static bool isTokenExpired(String token) {
    final expiryDate = getExpiryDate(token);
    if (expiryDate == null) return true;
    return DateTime.now().isAfter(expiryDate);
  }
}
```

## Making Authenticated Requests

All protected endpoints require the JWT token in the `Authorization` header.

### HTTP Client with Automatic Token Injection

```dart
class ApiClient {
  final String baseUrl;
  final TokenStorage tokenStorage;

  ApiClient(this.baseUrl, this.tokenStorage);

  Future<Map<String, String>> _getHeaders() async {
    final token = await tokenStorage.getToken();

    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  Future<http.Response> get(String endpoint) async {
    final headers = await _getHeaders();
    return http.get(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }

  Future<http.Response> post(String endpoint, {Object? body}) async {
    final headers = await _getHeaders();
    return http.post(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
      body: body != null ? jsonEncode(body) : null,
    );
  }

  Future<http.Response> delete(String endpoint) async {
    final headers = await _getHeaders();
    return http.delete(
      Uri.parse('$baseUrl$endpoint'),
      headers: headers,
    );
  }
}
```

### Usage Example

```dart
// Get user profile
final response = await apiClient.get('/api/users/me');

if (response.statusCode == 200) {
  final user = User.fromJson(jsonDecode(response.body));
} else if (response.statusCode == 401) {
  // Token expired or invalid - logout user
  await logout();
}
```

## API Endpoint Reference

### Public Endpoints

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/auth/oauth/url` | Get Google OAuth authorization URL |
| `GET` | `/api/auth/oauth/callback` | OAuth callback (handled by browser) |
| `POST` | `/api/auth/register` | Register with email/password |
| `POST` | `/api/auth/login` | Login with email/password |
| `POST` | `/api/auth/logout` | Logout (clears cookie) |
| `GET` | `/health` | Health check |

### Protected Endpoints (Require JWT)

| Method | Endpoint | Description |
|--------|----------|-------------|
| `GET` | `/api/users/me` | Get current user profile |
| `GET` | `/api/accounts` | List user's accounts |
| `POST` | `/api/accounts` | Create new account |
| `GET` | `/api/accounts/{id}` | Get account details |
| `DELETE` | `/api/accounts/{id}` | Delete account |
| `GET` | `/api/transactions` | List all transactions |
| `POST` | `/api/transactions` | Create transaction |
| `GET` | `/api/transactions/{id}` | Get transaction details |
| `PUT` | `/api/transactions/{id}` | Update transaction |
| `DELETE` | `/api/transactions/{id}` | Delete transaction |

### Account API Examples

```dart
// List accounts
Future<List<Account>> getAccounts() async {
  final response = await apiClient.get('/api/accounts');

  if (response.statusCode == 200) {
    final List<dynamic> data = jsonDecode(response.body);
    return data.map((json) => Account.fromJson(json)).toList();
  }

  throw Exception('Failed to load accounts');
}

// Create account
Future<Account> createAccount({
  required String name,
  required String type,
  required String currency,
  required double balance,
}) async {
  final response = await apiClient.post(
    '/api/accounts',
    body: {
      'name': name,
      'type': type,
      'currency': currency,
      'balance': balance,
    },
  );

  if (response.statusCode == 201) {
    return Account.fromJson(jsonDecode(response.body));
  }

  throw Exception('Failed to create account');
}

// Delete account
Future<void> deleteAccount(int accountId) async {
  final response = await apiClient.delete('/api/accounts/$accountId');

  if (response.statusCode != 204) {
    throw Exception('Failed to delete account');
  }
}
```

## Flutter Implementation Examples

### Complete Auth Service

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class AuthService {
  final String baseUrl;
  final _storage = const FlutterSecureStorage();
  static const _tokenKey = 'jwt_token';
  static const _userKey = 'user_data';

  AuthService(this.baseUrl);

  // OAuth Flow
  Future<String> getGoogleAuthUrl() async {
    final response = await http.get(
      Uri.parse('$baseUrl/api/auth/oauth/url'),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['url'];
    }

    throw Exception('Failed to get auth URL');
  }

  // Password Registration
  Future<User> register({
    required String email,
    required String password,
    required String name,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'name': name,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveAuthData(data['token'], data['user']);
      return User.fromJson(data['user']);
    }

    throw Exception('Registration failed: ${response.body}');
  }

  // Password Login
  Future<User> login({
    required String email,
    required String password,
  }) async {
    final response = await http.post(
      Uri.parse('$baseUrl/api/auth/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await _saveAuthData(data['token'], data['user']);
      return User.fromJson(data['user']);
    }

    throw Exception('Login failed: ${response.body}');
  }

  // Logout
  Future<void> logout() async {
    await http.post(Uri.parse('$baseUrl/api/auth/logout'));
    await _storage.delete(key: _tokenKey);
    await _storage.delete(key: _userKey);
  }

  // Get current user
  Future<User?> getCurrentUser() async {
    final userData = await _storage.read(key: _userKey);
    if (userData != null) {
      return User.fromJson(jsonDecode(userData));
    }
    return null;
  }

  // Check if logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: _tokenKey);
    if (token == null) return false;

    // Check if token is expired
    return !JwtHelper.isTokenExpired(token);
  }

  // Private helper
  Future<void> _saveAuthData(String token, Map<String, dynamic> user) async {
    await _storage.write(key: _tokenKey, value: token);
    await _storage.write(key: _userKey, value: jsonEncode(user));
  }
}
```

### User Model

```dart
class User {
  final int id;
  final String email;
  final String name;
  final String firstName;
  final String lastName;
  final String? oauthProvider;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime updatedAt;

  User({
    required this.id,
    required this.email,
    required this.name,
    required this.firstName,
    required this.lastName,
    this.oauthProvider,
    this.avatarUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      email: json['email'],
      name: json['name'],
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      oauthProvider: json['oauthProvider'],
      avatarUrl: json['avatarUrl'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'firstName': firstName,
      'lastName': lastName,
      'oauthProvider': oauthProvider,
      'avatarUrl': avatarUrl,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }
}
```

### Login Screen Example

```dart
class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService('http://localhost:8080');
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  Future<void> _loginWithPassword() async {
    setState(() => _isLoading = true);

    try {
      final user = await _authService.login(
        email: _emailController.text,
        password: _passwordController.text,
      );

      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Login failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => _isLoading = true);

    try {
      final authUrl = await _authService.getGoogleAuthUrl();

      // Launch OAuth URL
      await launchUrl(
        Uri.parse(authUrl),
        mode: LaunchMode.externalApplication,
      );

      // Handle the callback through deep linking or custom URL scheme
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('OAuth initiation failed: $e')),
      );
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              keyboardType: TextInputType.emailAddress,
            ),
            SizedBox(height: 16),
            TextField(
              controller: _passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _isLoading ? null : _loginWithPassword,
              child: _isLoading
                  ? CircularProgressIndicator()
                  : Text('Login'),
            ),
            SizedBox(height: 16),
            OutlinedButton.icon(
              onPressed: _isLoading ? null : _loginWithGoogle,
              icon: Icon(Icons.login),
              label: Text('Sign in with Google'),
            ),
          ],
        ),
      ),
    );
  }
}
```

## Important Notes

### CORS Configuration

Ensure your Flutter app's domain is added to the `ALLOWED_HOSTS` environment variable:

```bash
ALLOWED_HOSTS=localhost,yourdomain.com,your-flutter-app.com
```

### Mobile OAuth Considerations

For mobile apps, you may need to:

1. Configure a custom URL scheme in your Flutter app
2. Register the URL scheme with Google OAuth console
3. Handle deep links to capture the OAuth callback
4. Consider implementing a mobile-specific OAuth endpoint that returns JSON instead of redirecting

### Security Best Practices

1. Always use HTTPS in production
2. Store tokens in `flutter_secure_storage`, never in SharedPreferences
3. Implement token refresh logic before expiration
4. Clear tokens on logout
5. Handle 401 responses globally to logout users
6. Validate token expiration before making requests

## Migration from Auth0

If migrating from Auth0:

1. **Replace Auth0 SDK** → Remove Auth0 packages
2. **Update Login Flow** → Use endpoints above instead of Auth0 methods
3. **Token Storage** → Same approach, just different token format
4. **User Profile** → Map Auth0 user fields to Parsa User model
5. **Refresh Tokens** → Current implementation doesn't support refresh tokens (24h expiration only)

## Next Steps

1. Set up environment variables (base URL, etc.)
2. Implement the `AuthService` class
3. Create user model classes
4. Build login/register UI
5. Implement protected routes with auth guards
6. Test OAuth flow end-to-end
7. Add error handling and loading states

## Support

For issues or questions about the API:
- Repository: https://github.com/lazaroborges/parsa-go
- Check API server logs for detailed error messages
- Ensure environment variables are correctly configured
