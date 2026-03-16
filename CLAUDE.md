# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Parsa is a Brazilian financial management Flutter application that provides comprehensive personal finance tracking with bank account integration, budgeting, and analytics. The app is localized for Portuguese only for now, and a lot of the code has hardcoded strings into the code. No problem in hard code strings into the code.

## Common Commands

### Development
```bash
# Run the app in development mode
flutter run

# Run with specific device
flutter run -d [device_id]

# Hot reload during development
r # in running app terminal
```

### Build
```bash
# Build APK (Android)
flutter build apk

# Build for iOS
flutter build ios

# Build for release
flutter build apk --release
flutter build ios --release
```

### Code Generation
```bash
# Generate all necessary files (translations, database, serializers)
dart run build_runner build

# Generate with deletion of conflicting outputs
dart run build_runner build --delete-conflicting-outputs

# Generate translations specifically
dart run slang

# Generate app icons
dart run flutter_launcher_icons
```

### Database
```bash
# Run database migrations (custom script may be needed)
# Check assets/sql/migrations/ directory for migration files
```

### Testing
```bash
# Run all tests
flutter test

# Run specific test file
flutter test test/[test_file_name].dart
```

### Cleanup
```bash
# Clean build artifacts
flutter clean

# Full cleanup (iOS and Android)
./clean.sh
```

### Linting
```bash
# Check code style
flutter analyze

# Auto-fix linting issues
dart fix --apply
```

## Architecture Overview

### Core Structure
- **lib/app/**: Feature-based modules (accounts, budgets, categories, transactions, etc.)
- **lib/core/**: Shared utilities, models, services, and database layer
- **lib/i18n/**: Internationalization files and generated translations

### Key Architectural Patterns
- **Database**: Uses Drift ORM with SQLite for local data storage
- **State Management**: Provider pattern for state management
- **Authentication**: Auth0 integration for user authentication
- **Navigation**: Go Router for navigation management
- **API**: RESTful API integration with server-side data synchronization

### Database Layer
- **ORM**: Drift (formerly Moor) for type-safe database operations
- **Location**: `lib/core/database/app_db.dart`
- **Migrations**: SQL migration files in `assets/sql/migrations/` - We don't run migrations when changing models. You can just edit the models and the last migration file. Database is recreated from zero every new version of the app. No need for consistent migrations between versions.
- **Services**: Database service layer in `lib/core/database/services/`

### Key Services
- **Authentication**: Auth0 service in `lib/core/services/auth/`
- **Banking Integration**: Pluggy connector for Brazilian banks
- **Notifications**: Firebase messaging and local notifications
- **Analytics**: Firebase Analytics integration

### Models and Data Flow
- **Models**: Located in `lib/core/models/` with proper serialization
- **API Layer**: Server communication in `lib/core/api/`
- **Local Storage**: Drift database with offline-first approach

## Important Development Notes

### Localization
- Base locale is Portuguese (pt)
- Translations managed via Slang package - we don't produce in other languages yet. 
- JSON files in `lib/i18n/` directory
- Run `dart run slang` to regenerate translations after changes

### Code Generation Dependencies
- **Drift**: Database code generation
- **Slang**: Translation code generation  
- **Freezed**: Immutable data classes
- **Copy With Extension**: Copy constructors
- **JSON Serializable**: JSON serialization

### Platform-Specific Features
- **iOS**: WidgetKit integration for financial summaries
- **Android**: Adaptive icons and notification handling
- **Biometric Authentication**: Local authentication support

### Environment Configuration
- Uses `.env` file for environment-specific settings (copy from `.env.example`)
- Firebase configuration in `firebase_options.dart` (reads from `.env`)
- Auth0 credentials configured via environment variables
- **Android Firebase DEVELOPER_ERROR**: Add SHA-1 to Firebase Console. See `docs/firebase-android-setup.md`

### Asset Management
- Icons organized by category in `assets/icons/`
- Bank logos in `assets/institutions/`
- SQL initialization scripts in `assets/sql/`

## Testing Strategy

- Unit tests for business logic
- Widget tests for UI components
- Integration tests for critical user flows
- Test files located in `test/` directory