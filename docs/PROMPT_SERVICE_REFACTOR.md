# Prompt Service Refactoring

## Overview

This refactoring moves the OpenRouter system prompt from inline code to a separate file for better maintainability, version control, and collaboration.

## Changes Made

### 1. Created System Prompt File
- **File**: `lib/assets/prompts/cardsense_system_prompt.md`
- **Content**: Clean, well-structured CardSense AI system prompt
- **Format**: Markdown for better readability and editing

### 2. Updated pubspec.yaml
- Added `lib/assets/prompts/` to the assets section
- Ensures the prompt file is included in the app bundle

### 3. Created PromptService
- **File**: `lib/services/prompt_service.dart`
- **Features**:
  - Loads system prompt from assets
  - Caches prompt for performance
  - Provides fallback prompt if file loading fails
  - Validates prompt contains required sections
  - Supports loading custom prompts for testing

### 4. Updated OpenRouterService
- **File**: `lib/features/chat/services/openrouter_service.dart`
- **Changes**:
  - Removed inline system prompt (was corrupted with chat logs)
  - Added import for PromptService
  - Uses `PromptService.getSystemPrompt()` to load prompt dynamically
  - Cleaner, more maintainable code

### 5. Created Demo Application
- **File**: `example/prompt_service_demo.dart`
- **Purpose**: Demonstrates PromptService functionality
- **Features**: Shows prompt content, validation status, and allows cache refresh

## Benefits

### 1. **Maintainability**
- System prompt is now in a dedicated file
- Easy to edit without touching code
- Better version control for prompt changes
- Clear separation of concerns

### 2. **Collaboration**
- Non-technical team members can edit prompts
- Prompt changes don't require code review
- Easy to A/B test different prompts
- Better tracking of prompt evolution

### 3. **Performance**
- Prompt is cached after first load
- Fallback mechanism ensures reliability
- Validation ensures prompt integrity

### 4. **Flexibility**
- Support for multiple prompt files
- Easy to switch between prompt versions
- Custom prompts for testing/development

## Usage

### Loading System Prompt
```dart
import 'package:cardsense_ai/services/prompt_service.dart';

// Load the default system prompt
final prompt = await PromptService.getSystemPrompt();

// Validate the prompt
final isValid = PromptService.validatePrompt(prompt);

// Clear cache (useful for hot reload)
PromptService.clearCache();
```

### Using in OpenRouter Service
```dart
// In sendMessage method
final systemPrompt = await PromptService.getSystemPrompt();
messages.add({
  'role': 'system',
  'content': systemPrompt,
});
```

### Loading Custom Prompts
```dart
// Load a custom prompt file
final customPrompt = await PromptService.loadCustomPrompt(
  'lib/assets/prompts/custom_prompt.md'
);
```

## File Structure
```
lib/
├── assets/
│   └── prompts/
│       └── cardsense_system_prompt.md    # Main system prompt
├── services/
│   └── prompt_service.dart               # Prompt loading service
└── features/
    └── chat/
        └── services/
            └── openrouter_service.dart   # Updated to use PromptService

example/
└── prompt_service_demo.dart              # Demo application

pubspec.yaml                              # Updated with assets
```

## Testing

### Run Demo Application
```bash
flutter run example/prompt_service_demo.dart
```

### Verify Integration
1. The demo app should load and display the system prompt
2. Prompt should be marked as "Valid"
3. Content should show the full CardSense AI prompt
4. Refresh button should reload the prompt

## Future Enhancements

1. **Multiple Prompt Versions**: Support for A/B testing different prompts
2. **Remote Prompts**: Load prompts from a remote server
3. **Prompt Templates**: Support for parameterized prompts
4. **Prompt Analytics**: Track prompt performance and effectiveness
5. **Prompt Editor**: In-app prompt editing for development

## Migration Notes

- The old inline prompt was corrupted with chat logs
- New prompt is clean and properly formatted
- All existing functionality is preserved
- No breaking changes to the API
- Improved error handling and fallback mechanisms

## Validation

The PromptService validates that prompts contain required sections:
- `# CardSense AI`
- `ROLE AND PERSONALITY`
- `OUTPUT FORMAT`
- `BEHAVIORAL CONSTRAINTS`

This ensures prompt integrity and prevents runtime issues. 