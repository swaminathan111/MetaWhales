# Vercel Environment Configuration

## Required Environment Variables

### Core Application
```
SUPABASE_URL=https://your-project-id.supabase.co
SUPABASE_ANON_KEY=your-anon-key
GOOGLE_WEB_CLIENT_ID=your-web-client-id.apps.googleusercontent.com
```

### AI Services
```
OPENROUTER_API_KEY=your-openrouter-api-key
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
DEFAULT_AI_MODEL=openai/gpt-4o-mini
```

### RAG API Configuration
```
OLD_RAG_API_BASE_URL=https://cardsense-ai.vercel.app/api/query
NEW_RAG_API_BASE_URL=https://card-sense-ai-rag.vercel.app/chat
USE_NEW_RAG_API=true
```

### Application Settings
```
APP_NAME=CardSense AI
APP_URL=https://your-app-name.vercel.app
ENVIRONMENT=production
```

### Feature Flags
```
ENABLE_SPEECH_TO_TEXT=true
ENABLE_AI_CHAT=true
ENABLE_ANALYTICS=true
```

## Setting Variables in Vercel

### Via CLI
```bash
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GOOGLE_WEB_CLIENT_ID
vercel env add OPENROUTER_API_KEY
vercel env add NEW_RAG_API_BASE_URL
vercel env add USE_NEW_RAG_API
```

### Via Dashboard
1. Go to your project on vercel.com
2. Navigate to Settings → Environment Variables
3. Add each variable with appropriate values

## Environment-Specific URLs

### Production
- App URL: `https://cardsense-ai.vercel.app`
- RAG API: `https://card-sense-ai-rag.vercel.app/chat`

### Development
- App URL: `https://dev-cardsense-ai.vercel.app`
- RAG API: `https://dev-card-sense-ai-rag.vercel.app/chat`

### Staging
- App URL: `https://staging-cardsense-ai.vercel.app`
- RAG API: `https://staging-card-sense-ai-rag.vercel.app/chat` 