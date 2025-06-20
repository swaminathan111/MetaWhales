# Environment-Driven Configuration

## Overview

The CardSense AI application now uses a fully environment-driven configuration approach for all API endpoints, eliminating hardcoded URLs and improving deployment flexibility.

## Key Changes

### RAG API Configuration

**Before:**
```dart
// Hardcoded fallback URLs in env_service.dart
static String get oldRagApiBaseUrl =>
    dotenv.env['OLD_RAG_API_BASE_URL'] ??
    'https://cardsense-ai.vercel.app/api/query';  // ❌ Hardcoded fallback
```

**After:**
```dart
// Environment-only configuration
static String get oldRagApiBaseUrl {
  final url = dotenv.env['OLD_RAG_API_BASE_URL'];
  if (url == null || url.isEmpty) {
    throw Exception('OLD_RAG_API_BASE_URL environment variable is required but not set');
  }
  return url;
}
```

## Benefits

### 1. **Environment Flexibility**
- Different URLs for development, staging, and production
- Easy switching between API versions
- No code changes required for different environments

### 2. **Configuration Validation**
- Early detection of missing environment variables
- Clear error messages for misconfiguration
- Prevents runtime failures due to wrong URLs

### 3. **Security**
- No sensitive URLs hardcoded in source code
- Environment-specific secrets management
- Better separation of configuration and code

### 4. **Deployment Safety**
- Explicit configuration requirements
- Prevents accidental use of wrong endpoints
- Better visibility into required environment variables

## Required Environment Variables

### RAG API Configuration
```bash
# Legacy RAG API endpoint
OLD_RAG_API_BASE_URL=https://cardsense-ai.vercel.app/api/query

# New RAG API endpoint
NEW_RAG_API_BASE_URL=https://card-sense-ai-rag.vercel.app/chat

# API version selection (true = new API, false = old API)
USE_NEW_RAG_API=true
```

### Environment-Specific Examples

#### Development (.env.dev)
```bash
OLD_RAG_API_BASE_URL=https://dev-cardsense-ai.vercel.app/api/query
NEW_RAG_API_BASE_URL=https://dev-card-sense-ai-rag.vercel.app/chat
USE_NEW_RAG_API=true
```

#### Production (.env.prod)
```bash
OLD_RAG_API_BASE_URL=https://cardsense-ai.vercel.app/api/query
NEW_RAG_API_BASE_URL=https://card-sense-ai-rag.vercel.app/chat
USE_NEW_RAG_API=true
```

## Error Handling

### Missing Environment Variables
When a required environment variable is missing, the application will throw a descriptive exception:

```
Exception: OLD_RAG_API_BASE_URL environment variable is required but not set
```

### Empty Environment Variables
Empty strings are treated as missing variables and will trigger the same exception.

## Testing

The configuration is thoroughly tested in `test/services/env_service_test.dart`:

- ✅ Valid environment variable handling
- ✅ API version switching logic
- ✅ Missing variable exception handling
- ✅ Empty string validation
- ✅ Default behavior verification

## Migration Guide

### For Developers
1. Ensure all environment files (`.env.dev`, `.env.prod`) contain the required RAG API variables
2. Remove any hardcoded URLs from your code
3. Test the application with different environment configurations

### For Deployment
1. Update Vercel environment variables to include RAG API configuration
2. Verify all required variables are set in production
3. Test the deployment with the new configuration

## Best Practices

### 1. **Environment File Organization**
```
.env.dev          # Development configuration
.env.prod         # Production configuration
.env.staging      # Staging configuration (if needed)
```

### 2. **Variable Naming Convention**
- Use descriptive, uppercase names
- Group related variables with prefixes
- Include API version in variable names when applicable

### 3. **Documentation**
- Document all required environment variables
- Include example values in documentation
- Explain the purpose of each variable

### 4. **Validation**
- Validate environment variables at application startup
- Provide clear error messages for missing configuration
- Use automated tests to verify configuration handling

## Troubleshooting

### Common Issues

#### Missing Environment Variables
**Problem:** Application throws exception about missing RAG API URLs
**Solution:** Ensure all required variables are set in your environment file

#### Wrong API Endpoint
**Problem:** API calls fail with 404 or connection errors
**Solution:** Verify the URLs in your environment variables are correct and accessible

#### Environment File Not Loaded
**Problem:** Environment variables appear to be ignored
**Solution:** Check that `EnvService.loadEnv()` is called during app initialization

## Future Considerations

### Extensibility
This pattern can be extended to other configuration areas:
- Database connection strings
- Third-party service endpoints
- Feature flags and toggles
- API keys and secrets

### Monitoring
Consider adding:
- Configuration validation at startup
- Environment variable logging (without sensitive values)
- Health checks for configured endpoints
- Configuration change notifications 