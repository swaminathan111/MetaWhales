# OpenRouter AI Chat & Speech-to-Text Setup Guide

This guide will help you set up the AI chat functionality with OpenRouter and speech-to-text features in your CardSense AI app.

## 🚀 Features Implemented

### ✅ AI Chat Integration
- **OpenRouter API Integration** - Access to multiple AI models (GPT-4, Claude, Llama, etc.)
- **Real-time Chat** - Instant responses with typing indicators
- **Model Selection** - Choose from various AI models including free options
- **Conversation History** - Maintains context throughout the chat session
- **Error Handling** - Graceful fallbacks when API calls fail

### ✅ Speech-to-Text Integration
- **Voice Input** - Tap and hold mic button to speak
- **Real-time Transcription** - See your words appear as you speak
- **Permission Management** - Automatic microphone permission requests
- **Visual Feedback** - Mic button changes color when listening
- **Auto-send** - Automatically sends message when speech ends

## 📋 Setup Instructions

### 1. Environment Configuration

Create your environment files with the following content:

**`.env.dev`** (Development):
```env
# Development Environment Configuration

# Supabase Configuration
SUPABASE_URL=your_supabase_url_here
SUPABASE_ANON_KEY=your_supabase_anon_key_here
SUPABASE_SERVICE_ROLE_KEY=your_supabase_service_role_key_here

# OpenRouter Configuration
OPENROUTER_API_KEY=your_openrouter_api_key_here
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1

# App Configuration
APP_NAME=CardSense AI
APP_URL=https://cardsense.ai
ENVIRONMENT=development

# Default AI Model
DEFAULT_AI_MODEL=openai/gpt-4o-mini

# Feature Flags
ENABLE_SPEECH_TO_TEXT=true
ENABLE_AI_CHAT=true
ENABLE_ANALYTICS=false
```

**`.env.prod`** (Production):
```env
# Production Environment Configuration

# Supabase Configuration
SUPABASE_URL=your_production_supabase_url
SUPABASE_ANON_KEY=your_production_supabase_anon_key
SUPABASE_SERVICE_ROLE_KEY=your_production_supabase_service_role_key

# OpenRouter Configuration
OPENROUTER_API_KEY=your_production_openrouter_api_key
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1

# App Configuration
APP_NAME=CardSense AI
APP_URL=https://cardsense.ai
ENVIRONMENT=production

# Default AI Model
DEFAULT_AI_MODEL=openai/gpt-4o-mini

# Feature Flags
ENABLE_SPEECH_TO_TEXT=true
ENABLE_AI_CHAT=true
ENABLE_ANALYTICS=true
```

### 2. Get OpenRouter API Key

1. Visit [OpenRouter.ai](https://openrouter.ai/)
2. Sign up for an account
3. Go to [API Keys](https://openrouter.ai/keys)
4. Create a new API key
5. Copy the key and add it to your `.env.dev` and `.env.prod` files

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Platform-Specific Setup

#### Android
The following permissions are already added to `android/app/src/main/AndroidManifest.xml`:
- `RECORD_AUDIO` - For microphone access
- `INTERNET` - For API calls
- `BLUETOOTH*` - For Bluetooth headset support

#### iOS
The following permissions are already added to `ios/Runner/Info.plist`:
- `NSMicrophoneUsageDescription` - Microphone access explanation
- `NSSpeechRecognitionUsageDescription` - Speech recognition explanation

## 🎯 Usage

### AI Chat Features
1. **Text Input**: Type messages in the chat input field
2. **Voice Input**: Tap the microphone button and speak
3. **Model Selection**: Access different AI models through the chat service
4. **Conversation Context**: The AI remembers previous messages in the conversation

### Available AI Models
- **Free Models**: Llama 3.1 8B, Mistral 7B
- **Premium Models**: GPT-4o, Claude 3 Sonnet, Gemini Pro
- **Cost-Effective**: GPT-4o Mini (recommended default)

### Speech-to-Text Features
1. **Start Listening**: Tap the microphone button
2. **Visual Feedback**: Button turns red when listening
3. **Real-time Transcription**: See text appear as you speak
4. **Auto-send**: Message sends automatically when speech ends
5. **Manual Control**: Tap again to stop listening manually

## 🔧 Customization

### Changing Default AI Model
Update the `DEFAULT_AI_MODEL` in your environment files:
```env
# For faster, cheaper responses
DEFAULT_AI_MODEL=openai/gpt-4o-mini

# For higher quality responses
DEFAULT_AI_MODEL=openai/gpt-4o

# For free usage (with rate limits)
DEFAULT_AI_MODEL=meta-llama/llama-3.1-8b-instruct:free
```

### Customizing AI Personality
Edit the system prompt in `lib/features/chat/services/chat_service.dart`:
```dart
ChatCompletionMessage.system(
  content: '''Your custom AI assistant personality here...''',
),
```

### Speech Recognition Settings
Modify speech settings in `lib/features/chat/services/speech_service.dart`:
```dart
await _speechService.startListening(
  localeId: 'en_US', // Change language
  listenFor: Duration(seconds: 10), // Max listening time
  pauseFor: Duration(seconds: 3), // Pause before stopping
);
```

## 🚨 Troubleshooting

### Common Issues

1. **"OpenRouter API key not found"**
   - Ensure your `.env.dev` file exists and contains `OPENROUTER_API_KEY`
   - Restart the app after adding environment variables

2. **"Microphone permission denied"**
   - Check device settings and grant microphone permission
   - On iOS, ensure Info.plist descriptions are user-friendly

3. **"Speech recognition not available"**
   - Ensure device has speech recognition capabilities
   - Check internet connection (required for speech processing)

4. **API Rate Limits**
   - Use free models for testing: `meta-llama/llama-3.1-8b-instruct:free`
   - Monitor usage on OpenRouter dashboard

### Debug Mode
Enable debug logging by setting:
```dart
debugLogging: true
```
in the speech service initialization.

## 💰 Cost Optimization

### Free Models
- `meta-llama/llama-3.1-8b-instruct:free`
- `mistralai/mistral-7b-instruct:free`

### Cost-Effective Models
- `openai/gpt-4o-mini` (recommended)
- `anthropic/claude-3-haiku`

### Monitor Usage
- Check OpenRouter dashboard regularly
- Set up usage alerts
- Use free models for development/testing

## 🔐 Security Best Practices

1. **Never commit `.env` files** to version control
2. **Use different API keys** for development and production
3. **Implement rate limiting** in production
4. **Monitor API usage** regularly
5. **Rotate API keys** periodically

## 📱 Testing

### Test Speech Recognition
1. Grant microphone permission when prompted
2. Tap microphone button in chat
3. Speak clearly and wait for transcription
4. Verify message is sent automatically

### Test AI Chat
1. Send a text message about credit cards
2. Verify AI responds with relevant information
3. Test conversation context with follow-up questions
4. Try different types of financial questions

## 🎉 You're All Set!

Your CardSense AI app now has:
- ✅ Advanced AI chat with multiple model options
- ✅ Voice-to-text input with real-time feedback
- ✅ Proper error handling and fallbacks
- ✅ Production-ready architecture
- ✅ Cost optimization features

Enjoy building with AI! 🚀 