# RAG API Configuration Guide

This guide explains how to configure the RAG API URLs in your environment files.

## Environment Variables

Add the following variables to your `.env.dev` and `.env.prod` files:

```env
# RAG API Configuration
OLD_RAG_API_BASE_URL=https://cardsense-ai.vercel.app/api/query
NEW_RAG_API_BASE_URL=https://card-sense-ai-rag.vercel.app/chat

# Set to 'true' to use the new RAG API, 'false' to use the old one
USE_NEW_RAG_API=true
```

## API Differences

### Old API Format
- **Endpoint**: `https://cardsense-ai.vercel.app/api/query`
- **Request Format**: 
  ```json
  {
    "messages": [
      {"role": "user", "content": "Your question here"}
    ],
    "stream": false
  }
  ```
- **Response Format**: 
  ```json
  {
    "answer": "Response text here",
    "sources": [...]
  }
  ```

### New API Format
- **Endpoint**: `https://card-sense-ai-rag.vercel.app/chat`
- **Request Format**: 
  ```json
  {
    "question": "Your question here"
  }
  ```
- **Response Format**: 
  ```json
  {
    "response_text": "Response text here",
    "response_id": "unique_response_id"
  }
  ```

## Switching Between APIs

To switch between the old and new RAG APIs:

1. **Use New API**: Set `USE_NEW_RAG_API=true` in your `.env.dev` file
2. **Use Old API**: Set `USE_NEW_RAG_API=false` in your `.env.dev` file

The application will automatically use the selected API format and endpoint.

## Testing

You can test the API configuration using the built-in test methods:

```dart
final ragService = RagChatService();

// Test basic connectivity
bool isConnected = await ragService.testConnection();

// Get detailed test results
Map<String, dynamic> testResults = await ragService.testConnectionDetailed();
```

The test results will include:
- Which API version is being used
- Response time
- CORS test results
- Sample response from the API

## Troubleshooting

If you encounter issues:

1. Check that your environment variables are correctly set
2. Verify the API endpoints are accessible
3. Use the detailed connectivity test to diagnose issues
4. Check the logs for specific error messages

The service will automatically handle the different request/response formats based on your configuration. 