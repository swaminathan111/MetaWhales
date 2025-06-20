# Google Profile Picture Integration

## Overview

The MetaWhales app now automatically fetches and displays user profile pictures when users sign up or sign in using Google Authentication. This feature enhances the user experience by providing personalized avatars throughout the application.

## How It Works

### 1. Profile Picture Extraction

When a user authenticates with Google, the app extracts the following information:
- **Profile Picture URL**: Available via `GoogleSignInAccount.photoUrl`
- **Display Name**: Available via `GoogleSignInAccount.displayName`

### 2. Priority System

The app uses a priority system to determine the best profile information to use:

#### For Profile Pictures:
1. **Google Photo URL** (highest priority)
2. **User Metadata `avatar_url`**
3. **User Metadata `picture`**
4. **Default Avatar** (generated from initials)

#### For Display Names:
1. **Google Display Name** (highest priority)
2. **User Metadata `full_name`**
3. **User Metadata `name`**
4. **Email prefix** (part before @)
5. **"User"** (final fallback)

### 3. Database Storage

Profile information is stored in the `user_profiles` table with the following fields:
- `avatar_url`: Stores the profile picture URL
- `full_name`: Stores the user's display name

## Implementation Details

### ProfileService Enhancement

The `ProfileService.ensureUserProfile()` method has been enhanced to accept Google profile data:

```dart
Future<void> ensureUserProfile({
  String? googlePhotoUrl,
  String? googleDisplayName,
}) async {
  // Profile creation logic with Google data priority
}
```

### AuthProvider Updates

Both `signInWithGoogle()` and `signUpWithGoogle()` methods now accept additional parameters:

```dart
Future<void> signInWithGoogle({
  required String idToken,
  required String accessToken,
  String? photoUrl,        // New parameter
  String? displayName,     // New parameter
}) async {
  // Authentication logic
}
```

### Login/Signup Screen Integration

The authentication screens now pass Google profile data during authentication:

```dart
await ref.read(authProvider.notifier).signInWithGoogle(
  idToken: googleAuth.idToken ?? '',
  accessToken: googleAuth.accessToken!,
  photoUrl: googleUser.photoUrl,        // Profile picture URL
  displayName: googleUser.displayName,  // Display name
);
```

## UserAvatar Widget

A new `UserAvatar` widget has been created to display user profile pictures throughout the app:

### Features:
- **Network Image Loading**: Displays Google profile pictures
- **Error Handling**: Falls back to default avatar on load errors
- **Loading States**: Shows loading indicator while fetching images
- **Customizable**: Adjustable size, border, and colors
- **Initials Fallback**: Generates attractive initials-based avatars

### Usage:

```dart
// Basic usage
UserAvatar()

// Customized usage
UserAvatar(
  size: 60,
  showBorder: true,
  borderColor: Colors.blue,
)
```

## Data Flow

```mermaid
graph TD
    A[User clicks Google Sign In] --> B[Google Authentication]
    B --> C[Extract photoUrl & displayName]
    C --> D[Pass to AuthProvider]
    D --> E[Call ProfileService.ensureUserProfile()]
    E --> F[Apply Priority Logic]
    F --> G[Store in Database]
    G --> H[UserAvatar Widget Displays Image]
```

## Security Considerations

### URL Validation
- Only HTTPS URLs are accepted for profile pictures
- Google profile pictures use `https://lh*.googleusercontent.com/` domains
- Invalid URLs gracefully fall back to default avatars

### Privacy
- Profile pictures are only fetched with user consent (during Google sign-in)
- Users can update their profile pictures later through profile settings
- No sensitive data is logged in profile picture URLs

## Error Handling

The implementation includes comprehensive error handling:

### Network Errors
- Image loading failures show default avatar
- Network timeouts gracefully handled
- CORS issues automatically resolved with fallbacks

### Data Validation
- Empty or null URLs are handled gracefully
- Invalid URL formats trigger fallback mechanisms
- Database errors don't prevent app functionality

### Logging
All profile picture operations are logged using the centralized logging system:

```dart
AppLogger.info('Profile creation data', 
  userId: user.id,
  fullName: fullName,
  avatarUrl: avatarUrl,
  googlePhotoUrl: googlePhotoUrl,
  googleDisplayName: googleDisplayName,
);
```

## Testing

Comprehensive tests are included in `test/services/google_profile_test.dart`:

- **Priority Logic Testing**: Verifies correct priority order for profile data
- **Fallback Mechanisms**: Tests all fallback scenarios
- **URL Validation**: Validates Google photo URL formats
- **Edge Cases**: Handles empty strings, null values, and invalid data

### Running Tests

```bash
flutter test test/services/google_profile_test.dart
```

## Configuration

No additional configuration is required. The feature works automatically when:
1. Google Authentication is properly configured
2. Users sign in/up with Google
3. `UserAvatar` widget is used in the UI

## Troubleshooting

### Profile Picture Not Displaying

1. **Check Network Connection**: Ensure device has internet access
2. **Verify Google Photo URL**: Check if URL is valid and accessible
3. **Check Logs**: Look for image loading errors in app logs
4. **Clear Cache**: Try clearing app cache and re-authenticating

### Default Avatar Showing Instead of Google Photo

1. **Verify Authentication**: Ensure user signed in with Google (not email)
2. **Check Database**: Verify `avatar_url` field in `user_profiles` table
3. **URL Accessibility**: Test if Google photo URL is accessible in browser
4. **CORS Issues**: Web apps may have cross-origin restrictions

### Performance Considerations

- Profile pictures are cached by the Flutter `Image.network` widget
- Large images are automatically resized by Google's servers using URL parameters
- Default avatars are generated locally for better performance

## Future Enhancements

### Planned Features:
1. **Profile Picture Upload**: Allow users to upload custom profile pictures
2. **Image Cropping**: Let users crop and adjust their profile pictures
3. **Multiple Avatar Options**: Provide alternative avatar styles
4. **Social Media Integration**: Support profile pictures from other providers

### Technical Improvements:
1. **Caching Strategy**: Implement advanced caching for better performance
2. **Image Optimization**: Automatic image compression and format conversion
3. **Offline Support**: Cache profile pictures for offline viewing
4. **Progressive Loading**: Implement progressive image loading

## API Reference

### ProfileService Methods

```dart
// Enhanced profile creation with Google data
Future<void> ensureUserProfile({
  String? googlePhotoUrl,
  String? googleDisplayName,
});

// Get current user profile (includes avatar_url)
Future<Map<String, dynamic>?> getCurrentUserProfile();

// Update user profile (can update avatar_url)
Future<void> updateUserProfile(Map<String, dynamic> updates);
```

### UserAvatar Widget Properties

```dart
UserAvatar({
  double size = 40,           // Avatar size in pixels
  bool showBorder = false,    // Whether to show border
  Color? borderColor,         // Border color (defaults to primary)
});
```

## Database Schema

The `user_profiles` table includes these relevant fields:

```sql
CREATE TABLE user_profiles (
  id UUID PRIMARY KEY,
  email TEXT,
  full_name TEXT,           -- Stores display name from Google
  avatar_url TEXT,          -- Stores Google profile picture URL
  created_at TIMESTAMP,
  updated_at TIMESTAMP
);
```

## Conclusion

The Google Profile Picture Integration provides a seamless way to personalize the user experience in MetaWhales. By automatically fetching and displaying user profile pictures from Google, the app creates a more engaging and personalized interface while maintaining security and performance standards.

The implementation follows best practices for error handling, security, and user privacy, ensuring a robust and reliable feature that enhances the overall user experience. 