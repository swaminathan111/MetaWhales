# RAG API Integration Guide

## 🎯 Overview

The CardSense AI chat has been enhanced with RAG (Retrieval-Augmented Generation) integration to provide more accurate and personalized credit card recommendations. The system now uses your specialized credit card knowledge base API at `https://cardsense-ai.vercel.app/api/query` for superior responses.

## 🚀 What's New

### **Enhanced AI Service Architecture**
- **Primary Service**: RAG API with detailed credit card knowledge
- **Fallback Service**: OpenRouter for general AI assistance  
- **Intelligent Routing**: Automatically switches between services based on availability
- **Context Preservation**: Full conversation history maintained across all services

### **Key Features**
1. **Specialized Credit Card Knowledge**: Direct access to your comprehensive credit card database
2. **Smart Fallback System**: Seamless switching to backup AI if RAG is unavailable
3. **Service Status Monitoring**: Real-time indicators showing which AI service is active
4. **Conversation Persistence**: All interactions saved to Supabase database
5. **Enhanced User Experience**: Better, more accurate credit card recommendations

## 📡 API Integration Details

### **RAG API Endpoint**
```
POST https://cardsense-ai.vercel.app/api/query
Content-Type: application/json
```

### **Request Format**
```json
{
  "messages": [
    {"role": "user", "content": "which card to use to book a movie ticket"},
    {"role": "assistant", "content": "Based on your spending patterns..."},
    {"role": "user", "content": "what about online shopping?"}
  ],
  "stream": false
}
```

### **Response Handling**
The integration handles multiple response formats:
- JSON objects with `content`, `message`, `response`, or `text` fields
- Plain text responses
- Streaming responses (when `stream: true`)

## 🔧 Technical Implementation

### **New Services Added**

#### **1. RagChatService** (`lib/features/chat/services/rag_chat_service.dart`)
- Direct integration with your RAG API
- Supports both streaming and non-streaming responses
- Comprehensive error handling and logging
- Connection testing capabilities

#### **2. EnhancedChatService** 
- Intelligent service routing (RAG → OpenRouter fallback)
- Maintains conversation context across service switches
- Service availability monitoring

#### **3. ServiceStatusIndicator** (`lib/features/chat/widgets/service_status_indicator.dart`)
- Real-time status display in chat header
- Visual indicators for active service type
- Detailed service status dialog

### **Updated Components**

#### **Chat Persistence Service**
- Now uses `EnhancedChatService` instead of direct OpenRouter
- Automatic RAG model selection for better responses
- Enhanced conversation title generation

#### **Home Screen**
- Integrated service status indicator
- Visual feedback for AI service type
- RAG test screen access (debug mode)

## 🎨 User Interface Enhancements

### **Service Status Indicators**
- 🟢 **Enhanced AI**: RAG service active (green indicator)
- 🟠 **Basic AI**: Fallback service active (orange indicator)  
- 🔴 **AI Offline**: No services available (red indicator)

### **Chat Header**
- Service status badge with clickable details
- Visual distinction between enhanced and basic responses
- Service availability monitoring

## 🧪 Testing & Debugging

### **RAG Test Screen**
Access via the orange debug button (🐛) on the home screen:

**Features:**
- Direct RAG API connectivity testing
- Predefined credit card query testing
- Service availability monitoring
- Real-time response analysis

**Test Queries:**
- "Which card should I use for movie tickets?"
- "What are the best cashback credit cards in India?"
- "Which card gives the most rewards for online shopping?"
- "Help me choose between HDFC Regalia and SBI Prime card"

### **Service Monitoring**
```dart
// Check service availability
final availability = ref.watch(chatServiceAvailabilityProvider);
// Returns: {'rag': true/false, 'openrouter': true/false}
```

## 🔄 Fallback Mechanism

### **Automatic Failover**
1. **Primary**: RAG API called first for all requests
2. **Fallback**: If RAG fails, automatically switches to OpenRouter
3. **User Notification**: Fallback responses include service indicator
4. **Context Preservation**: Full conversation history maintained during switches

### **Error Handling**
- Network connectivity issues
- API rate limiting
- Service downtime
- Invalid response formats

## 📊 Expected Improvements

### **Response Quality**
- **Before**: Generic AI responses about credit cards
- **After**: Specific recommendations based on your credit card database
- **Context**: Better understanding of Indian credit card market
- **Personalization**: Responses tailored to user's existing cards

### **User Experience**
- More accurate card recommendations
- Better spending category analysis
- Detailed reward comparisons
- Real-time service status feedback

## 🚀 Deployment Checklist

### **Before Going Live**
1. ✅ Remove debug floating action button from home screen
2. ✅ Verify RAG API endpoint is stable and scaled
3. ✅ Test fallback mechanism thoroughly
4. ✅ Monitor service availability in production
5. ✅ Set up logging and error monitoring

### **Environment Configuration**
```dart
// Production configuration
static const String _baseUrl = 'https://cardsense-ai.vercel.app/api/query';

// For different environments, you can use:
// Development: 'https://dev-cardsense-ai.vercel.app/api/query'
// Staging: 'https://staging-cardsense-ai.vercel.app/api/query'
```

## 🔧 Troubleshooting

### **Common Issues**

#### **RAG API Not Responding**
- Check network connectivity
- Verify API endpoint URL
- Check service status in test screen
- Review logs for error details

#### **Fallback Not Working**
- Verify OpenRouter API key configuration
- Check CORS settings
- Test individual services separately

#### **Context Loss**
- Ensure conversation history is being passed correctly
- Check database persistence settings
- Verify message format conversion

### **Debug Commands**
```dart
// Test RAG connectivity
final ragService = ref.read(ragChatServiceProvider);
await ragService.testConnection();

// Check service availability  
final availability = await ref.read(enhancedChatServiceProvider)
    .checkServiceAvailability();

// Get health status
final health = await ragService.getHealthStatus();
```

## 📈 Monitoring & Analytics

### **Key Metrics to Track**
- RAG API response time
- Success/failure rates
- Fallback frequency
- User satisfaction with responses
- Service availability uptime

### **Logging Points**
- API request/response cycles
- Service switching events
- Error conditions
- Response quality indicators

## 🔮 Future Enhancements

### **Planned Features**
1. **Smart Caching**: Cache frequent queries for faster responses
2. **Response Streaming**: Real-time response display as it's generated
3. **Multi-Model Support**: Integration with additional specialized models
4. **Analytics Dashboard**: Service performance monitoring
5. **A/B Testing**: Compare RAG vs fallback response quality

### **Potential Integrations**
- Voice command processing through RAG
- Image-based card recognition queries
- Real-time offer notifications via RAG
- Personalized spending insights

---

## 🎉 Summary

Your CardSense AI chat now leverages the power of your specialized RAG model to provide:
- **More Accurate**: Responses based on comprehensive credit card data
- **More Reliable**: Intelligent fallback ensures service continuity  
- **More Transparent**: Clear indicators of which AI service is active
- **More Persistent**: All conversations saved with full context

The integration maintains backward compatibility while significantly enhancing the user experience with specialized credit card knowledge! 