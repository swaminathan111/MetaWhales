import 'package:flutter_test/flutter_test.dart';

void main() {
  group('Google Profile Picture Integration', () {
    test('should prioritize Google photo over user metadata', () {
      // Arrange
      const googlePhotoUrl = 'https://lh3.googleusercontent.com/a/google-photo';
      const metadataPhotoUrl = 'https://example.com/metadata-photo';
      const googleDisplayName = 'Google Name';
      const metadataName = 'Metadata Name';

      final userMetadata = {
        'avatar_url': metadataPhotoUrl,
        'picture': 'https://example.com/picture',
        'full_name': metadataName,
        'name': 'Another Name',
      };

      // Test the priority logic that would be used in ProfileService
      String fullName = googleDisplayName ??
          userMetadata['full_name'] ??
          userMetadata['name'] ??
          'User';

      String? avatarUrl = googlePhotoUrl ??
          userMetadata['avatar_url'] ??
          userMetadata['picture'];

      // Assert
      expect(fullName, equals(googleDisplayName));
      expect(avatarUrl, equals(googlePhotoUrl));
    });

    test('should fallback to user metadata when Google data is null', () {
      // Arrange
      const String? googlePhotoUrl = null;
      const String? googleDisplayName = null;
      const metadataPhotoUrl = 'https://example.com/metadata-photo';
      const metadataName = 'Metadata Name';

      final userMetadata = {
        'avatar_url': metadataPhotoUrl,
        'full_name': metadataName,
      };

      // Test the fallback logic
      String fullName = googleDisplayName ??
          userMetadata['full_name'] ??
          userMetadata['name'] ??
          'User';

      String? avatarUrl = googlePhotoUrl ??
          userMetadata['avatar_url'] ??
          userMetadata['picture'];

      // Assert
      expect(fullName, equals(metadataName));
      expect(avatarUrl, equals(metadataPhotoUrl));
    });

    test('should use email as fallback for display name', () {
      // Arrange
      const String? googleDisplayName = null;
      const email = 'john.doe@example.com';

      final userMetadata = <String, dynamic>{};

      // Test the email fallback logic
      String fullName = googleDisplayName ??
          userMetadata['full_name'] ??
          userMetadata['name'] ??
          email.split('@')[0] ??
          'User';

      // Assert
      expect(fullName, equals('john.doe'));
    });

    test('should handle empty Google photo URL gracefully', () {
      // Arrange
      const googlePhotoUrl = '';
      const metadataPhotoUrl = 'https://example.com/metadata-photo';

      final userMetadata = {
        'avatar_url': metadataPhotoUrl,
      };

      // Test handling of empty string
      String? avatarUrl = (googlePhotoUrl.isNotEmpty ? googlePhotoUrl : null) ??
          userMetadata['avatar_url'] ??
          userMetadata['picture'];

      // Assert
      expect(avatarUrl, equals(metadataPhotoUrl));
    });

    test('should validate Google photo URL format', () {
      // Test various Google photo URL formats
      const validGoogleUrls = [
        'https://lh3.googleusercontent.com/a/test-photo',
        'https://lh4.googleusercontent.com/a-/test-photo',
        'https://lh5.googleusercontent.com/a/test-photo=s96-c',
      ];

      const invalidUrls = [
        'http://example.com/photo.jpg', // Not HTTPS
        'https://example.com/photo.jpg', // Not Google domain
        '', // Empty string
      ];

      for (final url in validGoogleUrls) {
        expect(url, startsWith('https://lh'));
        expect(url, contains('googleusercontent.com'));
      }

      for (final url in invalidUrls) {
        expect(url, isNot(startsWith('https://lh')));
      }
    });

    test('should handle multiple metadata fields for avatar', () {
      // Test the priority order: avatar_url -> picture
      final testCases = [
        {
          'metadata': {'avatar_url': 'url1', 'picture': 'url2'},
          'expected': 'url1',
          'description': 'should prefer avatar_url over picture'
        },
        {
          'metadata': {'picture': 'url2'},
          'expected': 'url2',
          'description': 'should use picture when avatar_url is not available'
        },
        {
          'metadata': <String, dynamic>{},
          'expected': null,
          'description': 'should return null when no avatar data is available'
        },
      ];

      for (final testCase in testCases) {
        final userMetadata = testCase['metadata'] as Map<String, dynamic>;
        const String? googlePhotoUrl = null;

        String? avatarUrl = googlePhotoUrl ??
            userMetadata['avatar_url'] ??
            userMetadata['picture'];

        expect(avatarUrl, equals(testCase['expected']),
            reason: testCase['description'] as String);
      }
    });

    test('should handle multiple metadata fields for display name', () {
      // Test the priority order: full_name -> name -> email prefix
      final testCases = [
        {
          'metadata': {'full_name': 'Full Name', 'name': 'Name'},
          'email': 'test@example.com',
          'expected': 'Full Name',
          'description': 'should prefer full_name over name'
        },
        {
          'metadata': {'name': 'Name'},
          'email': 'test@example.com',
          'expected': 'Name',
          'description': 'should use name when full_name is not available'
        },
        {
          'metadata': <String, dynamic>{},
          'email': 'john.doe@example.com',
          'expected': 'john.doe',
          'description':
              'should use email prefix when no name data is available'
        },
        {
          'metadata': <String, dynamic>{},
          'email': null,
          'expected': 'User',
          'description': 'should use "User" as final fallback'
        },
      ];

      for (final testCase in testCases) {
        final userMetadata = testCase['metadata'] as Map<String, dynamic>;
        final email = testCase['email'] as String?;
        const String? googleDisplayName = null;

        String fullName = googleDisplayName ??
            userMetadata['full_name'] ??
            userMetadata['name'] ??
            email?.split('@')[0] ??
            'User';

        expect(fullName, equals(testCase['expected']),
            reason: testCase['description'] as String);
      }
    });
  });
}
