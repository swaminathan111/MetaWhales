import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../../lib/services/env_service.dart';

void main() {
  group('EnvService RAG API Configuration', () {
    setUp(() {
      // Clear environment before each test
      dotenv.clean();
    });

    test('should return RAG API URLs when environment variables are set', () {
      // Set up test environment variables
      dotenv.testLoad(fileInput: '''
OLD_RAG_API_BASE_URL=https://test-old-rag.example.com/api/query
NEW_RAG_API_BASE_URL=https://test-new-rag.example.com/chat
USE_NEW_RAG_API=true
''');

      expect(EnvService.oldRagApiBaseUrl,
          equals('https://test-old-rag.example.com/api/query'));
      expect(EnvService.newRagApiBaseUrl,
          equals('https://test-new-rag.example.com/chat'));
      expect(EnvService.useNewRagApi, isTrue);
      expect(EnvService.selectedRagApiBaseUrl,
          equals('https://test-new-rag.example.com/chat'));
    });

    test('should select old RAG API when USE_NEW_RAG_API is false', () {
      dotenv.testLoad(fileInput: '''
OLD_RAG_API_BASE_URL=https://test-old-rag.example.com/api/query
NEW_RAG_API_BASE_URL=https://test-new-rag.example.com/chat
USE_NEW_RAG_API=false
''');

      expect(EnvService.useNewRagApi, isFalse);
      expect(EnvService.selectedRagApiBaseUrl,
          equals('https://test-old-rag.example.com/api/query'));
    });

    test('should throw exception when OLD_RAG_API_BASE_URL is missing', () {
      dotenv.testLoad(fileInput: '''
NEW_RAG_API_BASE_URL=https://test-new-rag.example.com/chat
USE_NEW_RAG_API=false
''');

      expect(
        () => EnvService.oldRagApiBaseUrl,
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('OLD_RAG_API_BASE_URL environment variable is required'),
        )),
      );
    });

    test('should throw exception when NEW_RAG_API_BASE_URL is missing', () {
      dotenv.testLoad(fileInput: '''
OLD_RAG_API_BASE_URL=https://test-old-rag.example.com/api/query
USE_NEW_RAG_API=true
''');

      expect(
        () => EnvService.newRagApiBaseUrl,
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('NEW_RAG_API_BASE_URL environment variable is required'),
        )),
      );
    });

    test(
        'should throw exception when selectedRagApiBaseUrl is accessed with missing URL',
        () {
      dotenv.testLoad(fileInput: '''
OLD_RAG_API_BASE_URL=https://test-old-rag.example.com/api/query
USE_NEW_RAG_API=true
''');

      expect(
        () => EnvService.selectedRagApiBaseUrl,
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('NEW_RAG_API_BASE_URL environment variable is required'),
        )),
      );
    });

    test('should handle empty string environment variables as missing', () {
      dotenv.testLoad(fileInput: '''
OLD_RAG_API_BASE_URL=
NEW_RAG_API_BASE_URL=https://test-new-rag.example.com/chat
USE_NEW_RAG_API=false
''');

      expect(
        () => EnvService.oldRagApiBaseUrl,
        throwsA(isA<Exception>().having(
          (e) => e.toString(),
          'message',
          contains('OLD_RAG_API_BASE_URL environment variable is required'),
        )),
      );
    });

    test('should default USE_NEW_RAG_API to false when not set', () {
      dotenv.testLoad(fileInput: '''
OLD_RAG_API_BASE_URL=https://test-old-rag.example.com/api/query
NEW_RAG_API_BASE_URL=https://test-new-rag.example.com/chat
''');

      expect(EnvService.useNewRagApi, isFalse);
      expect(EnvService.selectedRagApiBaseUrl,
          equals('https://test-old-rag.example.com/api/query'));
    });
  });
}
