# HPACloud Talk iOS - Agent Guide

## Project Overview

**HPACloud Talk iOS** is a fully on-premises audio/video and chat communication app for iOS devices. It connects to HPACloud servers to provide secure messaging, voice calls, video conferences, and file sharing capabilities.

- **Repository**: https://github.com/nextcloud/talk-ios
- **License**: GPLv3 with Apple App Store exception
- **Language**: English (all documentation and code comments in English)

## Technology Stack

### Primary Languages
- **Swift**: ~212 files (primary language for new features)
- **Objective-C**: ~65 headers + ~63 implementations (legacy and core components)
- **Hybrid**: Bridging headers enable interoperability between Swift and Objective-C

### Build System
- **Xcode**: Version 26.2+ (as of current CI configuration)
- **Dependency Manager**: CocoaPods
- **Workspace**: `NextcloudTalk.xcworkspace`
- **Project**: `NextcloudTalk.xcodeproj`
- **Minimum iOS Version**: iOS 15.0

### Key Dependencies (via CocoaPods)
```ruby
# Core networking
AFNetworking 3.2.0

# UI Components
MaterialComponents/ActivityIndicator
Toast ~> 4.0.0
MZTimerLabel

# Media
MobileVLCKit ~> 3.5.0  # Video playback
WebRTC (custom build)    # Video/audio calls
```

### External Dependencies (Git Submodules)
- `ThirdParty/SlackTextViewController` - Chat input UI component
- `ThirdParty/DRCellSlideGestureRecognizer` - Cell swipe gestures

## Project Structure

### Main Application (`NextcloudTalk/`)

The main app is organized into feature-based directories:

| Directory | Description |
|-----------|-------------|
| `Settings/` | App branding, user preferences, user profile, user status |
| `Chat/` | Chat interface, message cells, chat controller, polls, reactions |
| `Calls/` | Call UI, CallKit integration, call controller, participant views |
| `Contacts/` | Contact search, user management, address book integration |
| `Database/` | Realm database models and managers (accounts, rooms, capabilities) |
| `Network/` | API controllers, HTTP networking, WebDAV client |
| `Screensharing/` | Screen capture and sharing functionality |
| `Media Viewer/` | Photo/video viewing capabilities |
| `Maps/` | Location sharing and map display |
| `Security/` | Certificate handling and security utilities |

### Key Source Files

**Core Infrastructure:**
- `AppDelegate.h/m` - Application lifecycle, push notification handling
- `NCAPIController.h/m` - Main API client for HPACloud server communication
- `NCDatabaseManager.h/m` - Realm database management
- `NCSettingsController.h/m` - App settings and configuration

**Branding (IMPORTANT for development):**
- `Settings/NCAppBranding.h` - Branding constants and theming methods
- `Settings/NCAppBranding.m` - Bundle ID, group ID, colors, and app configuration

### App Extensions

The project includes 4 extensions that require separate bundle IDs and entitlements:

1. **ShareExtension** (`ShareExtension/`)
   - Allows sharing content from other apps to HPACloud Talk
   - Uses `ShareViewController` for room selection

2. **NotificationServiceExtension** (`NotificationServiceExtension/`)
   - Processes push notifications before display
   - Rich notification content handling

3. **BroadcastUploadExtension** (`BroadcastUploadExtension/`)
   - Screen recording for screen sharing during calls
   - Socket-based communication with main app

4. **TalkIntents** (`TalkIntents/`)
   - Siri integration and shortcuts support

### Localization

- **48 language translations** in `*.lproj` directories
- Base localization in `Base.lproj/`
- Translation management via Transifex (`.tx/config`)

## Development Setup

### Prerequisites
- macOS with Xcode 26.2+
- CocoaPods (`gem install cocoapods`)
- SwiftLint (optional but recommended)
- Docker (for running integration tests locally)

### Initial Setup
```bash
# Install dependencies
pod install

# Open workspace (not the project!)
open NextcloudTalk.xcworkspace
```

### Bundle Identifier Configuration (Required for Development)

The project uses HPACloud's bundle identifiers by default. To run on your developer account:

1. **Change bundle IDs** for all 5 targets from `com.nextcloud.Talk` to `com.<yourname>.Talk`
2. **Change App Group IDs** from `group.com.nextcloud.Talk` to `group.com.<yourname>.Talk`
3. **Update NCAppBranding.m** to match:
   ```objc
   NSString * const bundleIdentifier = @"com.<yourname>.Talk";
   NSString * const groupIdentifier = @"group.com.<yourname>.Talk";
   ```

Targets to modify:
- NextcloudTalk (main app)
- ShareExtension
- NotificationServiceExtension
- BroadcastUploadExtension
- TalkIntents

## Build Commands

### Build for Testing
```bash
xcodebuild build-for-testing \
    -workspace NextcloudTalk.xcworkspace \
    -scheme NextcloudTalk \
    -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
    -derivedDataPath DerivedData
```

### Run Tests
```bash
xcodebuild test-without-building \
    -xctestrun $(find . -type f -name '*.xctestrun') \
    -destination "platform=iOS Simulator,name=iPhone 16,OS=18.5" \
    -derivedDataPath DerivedData \
    -test-iterations 3 \
    -retry-tests-on-failure
```

### SwiftLint (Code Style Check)
```bash
swiftlint
```

## Testing Strategy

### Test Organization (`NextcloudTalkTests/`)

```
NextcloudTalkTests/
├── Common/          # Shared test utilities and helpers
├── Unit/            # Unit tests for individual components
├── Integration/     # Integration tests requiring server
└── UI/              # UI automation tests
```

### Running Tests Locally

Integration tests require a running HPACloud server:

```bash
# Start Docker-based test server
./start-instance-for-tests.sh

# Then run tests from Xcode or command line
```

The test script:
1. Creates a Docker container with HPACloud server
2. Installs the Talk app (spreed)
3. Sets up test users and rooms via `ci-setup-rooms.sh`
4. Waits for server to be ready

### CI/CD Testing Matrix

GitHub Actions tests against multiple server versions:
- stable23 (PHP 8.0)
- stable31 (PHP 8.3)
- stable32 (PHP 8.3)
- stable33 (PHP 8.3)
- main/master (PHP 8.3)

## Code Style Guidelines

### SwiftLint Configuration (`.swiftlint.yml`)

**Enabled Opt-in Rules:**
- `empty_collection_literal`
- `empty_count`
- `empty_string`
- `explicit_init`
- `file_types_order`
- `unneeded_parentheses_in_closure_argument`

**Disabled Rules:**
- `type_body_length`
- `file_length`
- `function_body_length`
- `line_length`

**Excluded Paths:**
- `Pods/`
- `ThirdParty/`
- `NextcloudTalk/RLMSupport.swift`
- `DerivedData/`

### Coding Conventions

1. **File Headers**: All files must include SPDX license headers:
   ```objc
   /**
    * SPDX-FileCopyrightText: 2024 HPA Cloud and HPACloud contributors
    * SPDX-License-Identifier: GPL-3.0-or-later
    */
   ```

2. **Naming Conventions**:
   - Objective-C classes use `NC` prefix (e.g., `NCAPIController`)
   - Swift files use PascalCase
   - Constants use k-prefix in Objective-C (e.g., `kCapabilitySystemMessages`)

3. **Nullability**: Objective-C headers use nullability annotations (`NS_ASSUME_NONNULL_BEGIN/END`)

4. **Swift Bridging**: Import Swift into Objective-C using `#import "NextcloudTalk-Swift.h"`

## Key Architecture Components

### API Communication (`NCAPIController`)

The main API controller handles all server communication:
- REST API calls to HPACloud Talk endpoints
- Multiple API version support (v1-v4)
- AFNetworking-based session management
- Completion block-based async patterns

### Database Layer (`NCDatabaseManager`)

Uses Realm for local data persistence:
- `TalkAccount` - User account information
- `NCRoom` - Conversation/room data
- `ServerCapabilities` - Server feature flags
- `FederatedCapabilities` - Cross-server capabilities

### Push Notifications (`AppDelegate`)

- PushKit integration for VoIP notifications
- Normal push notifications for messages
- Device token registration with HPACloud push proxy

### Call System

- WebRTC-based media handling
- CallKit integration for native call UI
- Screen sharing via Broadcast Upload extension

## Security Considerations

1. **App Groups**: Used for data sharing between app and extensions
2. **Keychain**: Credentials stored via `NCKeyChainController`
3. **Certificate Pinning**: Available in `CCCertificate`
4. **Push Proxy**: Notifications go through HPACloud's push proxy (not Apple directly)

## CI/CD Workflow

### GitHub Actions

1. **`talk-ios-tests.yml`**: Build and test on macOS runners
2. **`swiftlint.yml`**: Code style validation
3. **`localizable.yml`**: Translation file validation

### Build Environment
- macOS 15 (GitHub Actions)
- Xcode 26.2
- iOS 18.5 Simulator

## Useful Scripts

| Script | Purpose |
|--------|---------|
| `start-instance-for-tests.sh` | Start local Docker test environment |
| `ci-create-docker-server.sh` | Create HPACloud Docker container |
| `ci-install-talk.sh` | Install Talk app in test server |
| `ci-setup-rooms.sh` | Create test rooms and users |
| `ci-wait-for-server.sh` | Wait for server to be ready |
| `generate-localizable-strings-file.sh` | Update translation files |

## Documentation References

- [Push Notifications Setup](docs/notifications.md)
- [WebRTC Library](https://github.com/nextcloud-releases/talk-clients-webrtc)
- [Contributing Guidelines](https://github.com/nextcloud/server/blob/main/.github/CONTRIBUTING.md)
- [Code of Conduct](https://nextcloud.com/community/code-of-conduct/)

## Common Development Tasks

### Adding a New API Endpoint

1. Add completion block typedef in `NCAPIController.h`
2. Declare method in `NCAPIController.h`
3. Implement in `NCAPIController.m`
4. Add unit tests in `NextcloudTalkTests/Unit/`

### Adding Database Schema Changes

1. Update model in `Database/` directory
2. Increment `kTalkDatabaseSchemaVersion` in `NCDatabaseManager.h`
3. Add migration logic if needed

### Adding a New Feature Flag

1. Add capability constant in `NCDatabaseManager.h` (e.g., `kCapabilityNewFeature`)
2. Check capability via `[NCDatabaseManager serverHasTalkCapability:kCapabilityNewFeature]`

## Contact & Support

- **Public Chat**: https://cloud.nextcloud.com/call/c7fz9qpr
- **Issues**: https://github.com/nextcloud/talk-ios/issues
- **TestFlight**: https://testflight.apple.com/join/cxzyr1eO
