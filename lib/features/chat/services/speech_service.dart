import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:speech_to_text/speech_to_text.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:logger/logger.dart';

class SpeechService {
  final SpeechToText _speechToText = SpeechToText();
  final Logger _logger = Logger();
  bool _isListening = false;
  bool _isAvailable = false;

  bool get isListening => _isListening;
  bool get isAvailable => _isAvailable;

  /// Initialize speech recognition and request permissions
  Future<bool> initialize() async {
    try {
      _logger.d('Initializing speech service...');

      // Request microphone permission
      final permissionStatus = await Permission.microphone.request();
      if (permissionStatus != PermissionStatus.granted) {
        _logger.w('Microphone permission denied');
        return false;
      }

      _isAvailable = await _speechToText.initialize(
        onStatus: (status) {
          _logger.d('Speech status: $status');
          _isListening = status == 'listening';
        },
        onError: (error) {
          _logger.e('Speech error: $error');
          _isListening = false;
        },
        debugLogging: false,
      );

      _logger.i('Speech service initialized: $_isAvailable');
      return _isAvailable;
    } catch (e) {
      _logger.e('Failed to initialize speech service: $e');
      return false;
    }
  }

  /// Start listening for speech
  Future<void> startListening({
    required Function(String) onResult,
    required Function(bool) onListeningStateChanged,
    String localeId = 'en_US',
    Duration listenFor = const Duration(seconds: 10),
    Duration pauseFor = const Duration(seconds: 3),
  }) async {
    if (!_isAvailable) {
      _logger.w('Speech recognition not available');
      return;
    }

    try {
      _logger.d('Starting speech recognition...');

      await _speechToText.listen(
        onResult: (result) {
          _logger.d(
              'Speech result: ${result.recognizedWords} (confidence: ${result.confidence})');
          onResult(result.recognizedWords);
        },
        localeId: localeId,
        listenFor: listenFor,
        pauseFor: pauseFor,
        partialResults: true,
        onSoundLevelChange: (level) {
          // Optional: Use this for visual feedback
        },
        cancelOnError: true,
        listenMode: ListenMode.confirmation,
      );

      _isListening = true;
      onListeningStateChanged(true);
    } catch (e) {
      _logger.e('Failed to start listening: $e');
      _isListening = false;
      onListeningStateChanged(false);
    }
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    try {
      await _speechToText.stop();
      _isListening = false;
      _logger.d('Speech recognition stopped');
    } catch (e) {
      _logger.e('Failed to stop listening: $e');
    }
  }

  /// Cancel speech recognition
  Future<void> cancel() async {
    try {
      await _speechToText.cancel();
      _isListening = false;
      _logger.d('Speech recognition cancelled');
    } catch (e) {
      _logger.e('Failed to cancel speech recognition: $e');
    }
  }

  /// Get available locales for speech recognition
  Future<List<LocaleName>> getAvailableLocales() async {
    try {
      if (!_isAvailable) return [];
      return await _speechToText.locales();
    } catch (e) {
      _logger.e('Failed to get available locales: $e');
      return [];
    }
  }

  /// Check if microphone permission is granted
  Future<bool> hasPermission() async {
    final status = await Permission.microphone.status;
    return status == PermissionStatus.granted;
  }

  /// Request microphone permission
  Future<bool> requestPermission() async {
    final status = await Permission.microphone.request();
    return status == PermissionStatus.granted;
  }
}

// Speech state data class
class SpeechState {
  final bool isListening;
  final bool isAvailable;
  final bool hasPermission;
  final String currentText;
  final String? error;
  final List<LocaleName> availableLocales;

  SpeechState({
    this.isListening = false,
    this.isAvailable = false,
    this.hasPermission = false,
    this.currentText = '',
    this.error,
    this.availableLocales = const [],
  });

  SpeechState copyWith({
    bool? isListening,
    bool? isAvailable,
    bool? hasPermission,
    String? currentText,
    String? error,
    List<LocaleName>? availableLocales,
  }) {
    return SpeechState(
      isListening: isListening ?? this.isListening,
      isAvailable: isAvailable ?? this.isAvailable,
      hasPermission: hasPermission ?? this.hasPermission,
      currentText: currentText ?? this.currentText,
      error: error,
      availableLocales: availableLocales ?? this.availableLocales,
    );
  }

  @override
  String toString() {
    return 'SpeechState(isListening: $isListening, isAvailable: $isAvailable, hasPermission: $hasPermission, currentText: "$currentText", error: $error)';
  }
}

// Speech state notifier
class SpeechStateNotifier extends StateNotifier<SpeechState> {
  final SpeechService _speechService;
  final Logger _logger = Logger();

  SpeechStateNotifier(this._speechService) : super(SpeechState()) {
    _initialize();
  }

  /// Initialize speech service
  Future<void> _initialize() async {
    try {
      final hasPermission = await _speechService.hasPermission();
      final isAvailable = await _speechService.initialize();
      final locales = await _speechService.getAvailableLocales();

      state = state.copyWith(
        isAvailable: isAvailable,
        hasPermission: hasPermission,
        availableLocales: locales,
      );

      _logger.i('Speech state initialized: $state');
    } catch (e) {
      _logger.e('Failed to initialize speech state: $e');
      state = state.copyWith(error: e.toString());
    }
  }

  /// Start listening for speech
  Future<void> startListening({String localeId = 'en_US'}) async {
    if (!state.isAvailable) {
      _logger.w('Speech recognition not available');
      return;
    }

    if (!state.hasPermission) {
      final granted = await _speechService.requestPermission();
      if (!granted) {
        state = state.copyWith(error: 'Microphone permission required');
        return;
      }
      state = state.copyWith(hasPermission: true);
    }

    state = state.copyWith(currentText: '', error: null);

    await _speechService.startListening(
      onResult: (text) {
        state = state.copyWith(currentText: text);
      },
      onListeningStateChanged: (isListening) {
        state = state.copyWith(isListening: isListening);
      },
      localeId: localeId,
    );
  }

  /// Stop listening for speech
  Future<void> stopListening() async {
    await _speechService.stopListening();
    state = state.copyWith(isListening: false);
  }

  /// Cancel speech recognition
  Future<void> cancel() async {
    await _speechService.cancel();
    state = state.copyWith(isListening: false, currentText: '');
  }

  /// Get current recognized text
  String getCurrentText() {
    return state.currentText;
  }

  /// Clear recognized text
  void clearText() {
    state = state.copyWith(currentText: '');
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Request microphone permission
  Future<void> requestPermission() async {
    final granted = await _speechService.requestPermission();
    state = state.copyWith(hasPermission: granted);

    if (granted) {
      // Re-initialize after permission is granted
      await _initialize();
    }
  }
}

// Riverpod providers
final speechServiceProvider = Provider<SpeechService>((ref) {
  return SpeechService();
});

final speechStateProvider =
    StateNotifierProvider<SpeechStateNotifier, SpeechState>((ref) {
  return SpeechStateNotifier(ref.read(speechServiceProvider));
});

// Convenience providers
final isListeningProvider = Provider<bool>((ref) {
  return ref.watch(speechStateProvider).isListening;
});

final speechTextProvider = Provider<String>((ref) {
  return ref.watch(speechStateProvider).currentText;
});

final speechAvailableProvider = Provider<bool>((ref) {
  return ref.watch(speechStateProvider).isAvailable;
});

final speechPermissionProvider = Provider<bool>((ref) {
  return ref.watch(speechStateProvider).hasPermission;
});
