# Vercel Deployment Guide for CardSense AI

This guide will walk you through deploying your Flutter CardSense AI app to Vercel.

## Prerequisites

- [Vercel CLI](https://vercel.com/cli) installed globally
- Flutter SDK properly configured
- Git repository pushed to GitHub/GitLab/Bitbucket

## Step 1: Install Vercel CLI

```bash
npm install -g vercel
```

## Step 2: Login to Vercel

```bash
vercel login
```

## Step 3: Configure Environment Variables

You'll need to set up environment variables in Vercel. You can do this through:

### Option A: Vercel Dashboard
1. Go to your project dashboard on vercel.com
2. Navigate to Settings → Environment Variables
3. Add the following variables:

### Option B: Vercel CLI
```bash
# Set environment variables via CLI
vercel env add SUPABASE_URL
vercel env add SUPABASE_ANON_KEY
vercel env add GOOGLE_WEB_CLIENT_ID
vercel env add OPENROUTER_API_KEY
vercel env add OPENROUTER_BASE_URL
vercel env add APP_NAME
vercel env add APP_URL
vercel env add DEFAULT_AI_MODEL
vercel env add ENABLE_SPEECH_TO_TEXT
vercel env add ENABLE_AI_CHAT
vercel env add ENABLE_ANALYTICS
vercel env add NEW_RAG_API_BASE_URL
vercel env add USE_NEW_RAG_API
```

### Environment Variables to Set:

```
ENVIRONMENT=production
LOG_LEVEL=INFO
LOG_TO_CONSOLE=true
LOG_TO_FILE=false
SUPABASE_URL=https://ncbuipsgjuxicrhorqtq.supabase.co
SUPABASE_ANON_KEY=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5jYnVpcHNnanV4aWNyaG9ycXRxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NDg2NzQ2OTksImV4cCI6MjA2NDI1MDY5OX0.CtEp2h-ESSIpJH8r_4kbhsjTCw9veWFSfSTybo7a3eo
GOOGLE_WEB_CLIENT_ID=480921289409-6fspjd7c0rhvgs4h5l38utf1q8ksn4bd.apps.googleusercontent.com
OPENROUTER_API_KEY=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
OPENROUTER_BASE_URL=https://openrouter.ai/api/v1
APP_NAME=CardSense AI
APP_URL=https://your-app-name.vercel.app
DEFAULT_AI_MODEL=openai/gpt-4o-mini
ENABLE_SPEECH_TO_TEXT=true
ENABLE_AI_CHAT=true
ENABLE_ANALYTICS=false
NEW_RAG_API_BASE_URL=https://card-sense-ai-rag.vercel.app/chat
USE_NEW_RAG_API=true
```

## Step 4: Test Local Build

Before deploying, test that your app builds correctly for web:

```bash
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit
```

## Step 5: Deploy to Vercel

### First-time Deployment:
```bash
vercel
```

Follow the prompts:
- Link to existing project? → No
- What's your project's name? → `cardsense-ai` (or your preferred name)
- In which directory is your code located? → `./`

### Subsequent Deployments:
```bash
vercel --prod
```

## Step 6: Configure Custom Domain (Optional)

If you have a custom domain:

1. Add domain in Vercel dashboard
2. Update DNS records as instructed
3. Update `APP_URL` environment variable to your custom domain

## Step 7: Update Google OAuth Configuration

After deployment, you need to update your Google OAuth settings:

1. Go to [Google Cloud Console](https://console.cloud.google.com/)
2. Navigate to APIs & Services → Credentials
3. Edit your OAuth 2.0 Client ID
4. Add your Vercel domain to "Authorized JavaScript origins":
   - `https://your-app-name.vercel.app`
   - `https://your-custom-domain.com` (if using custom domain)
5. Add to "Authorized redirect URIs":
   - `https://your-app-name.vercel.app/auth/callback`

## Step 8: Update Supabase Configuration

1. Go to your Supabase dashboard
2. Navigate to Authentication → Settings
3. Update "Site URL" to your Vercel domain
4. Add your Vercel domain to "Additional Redirect URLs"

## Troubleshooting

### Common Issues:

#### 1. Build Fails
```bash
# Clear Flutter cache and rebuild
flutter clean
flutter pub get
flutter build web --release --web-renderer canvaskit --verbose
```

#### 2. Environment Variables Not Loading
- Ensure all environment variables are set in Vercel dashboard
- Check that variable names match exactly (case-sensitive)
- Redeploy after adding new environment variables

#### 3. Google Authentication Issues
- Verify OAuth redirect URLs are correctly configured
- Check that GOOGLE_WEB_CLIENT_ID matches your Google Cloud Console
- Ensure domains are added to authorized origins

#### 4. Supabase Connection Issues
- Verify SUPABASE_URL and SUPABASE_ANON_KEY are correct
- Check that your Supabase project allows connections from your domain
- Update CORS settings in Supabase if needed

#### 5. Flutter Web Performance Issues
- The app uses CanvasKit renderer for better performance
- Large initial load is normal for Flutter web apps
- Consider implementing lazy loading for better UX

### Debugging Deployment:

```bash
# View deployment logs
vercel logs

# View build logs
vercel logs --follow

# Check environment variables
vercel env ls
```

## Performance Optimization

### 1. Enable Compression
Vercel automatically enables gzip compression for static assets.

### 2. Caching Strategy
The `vercel.json` configuration includes optimal caching headers:
- Static assets: 1 year cache
- Flutter service worker: 1 year cache
- HTML: No cache (for dynamic routing)

### 3. Web Renderer
Using CanvasKit renderer provides:
- Better performance for complex UIs
- Consistent rendering across browsers
- Better support for custom fonts and graphics

## Monitoring and Analytics

### 1. Vercel Analytics
Enable Vercel Analytics in your dashboard for:
- Page views and user sessions
- Performance metrics
- Geographic distribution

### 2. Application Monitoring
Consider integrating:
- Sentry for error tracking
- LogRocket for session replay
- Google Analytics for user behavior

## Security Considerations

### 1. Environment Variables
- Never commit sensitive keys to git
- Use Vercel's environment variable system
- Rotate API keys regularly

### 2. CORS Configuration
- Supabase CORS is configured for your domain
- Google OAuth is restricted to authorized domains
- API keys have appropriate permissions

### 3. Content Security Policy
The deployment includes security headers:
- X-Frame-Options: SAMEORIGIN
- X-Content-Type-Options: nosniff
- Cross-Origin policies for Flutter web

## Continuous Deployment

### Automatic Deployments
Vercel automatically deploys when you push to your main branch.

### Preview Deployments
Every pull request gets a preview deployment URL for testing.

### Branch Deployments
You can configure different branches for staging/production:

```bash
# Deploy specific branch
vercel --prod --target production

# Deploy to staging
vercel --target preview
```

## Cost Considerations

### Vercel Pricing Tiers:
- **Hobby (Free)**: 100GB bandwidth, unlimited personal projects
- **Pro ($20/month)**: 1TB bandwidth, team collaboration, custom domains
- **Enterprise**: Custom pricing, advanced features

### Optimization Tips:
- Use efficient image formats (WebP)
- Minimize bundle size with tree shaking
- Implement lazy loading for large features
- Monitor bandwidth usage in Vercel dashboard

## Support and Resources

- [Vercel Documentation](https://vercel.com/docs)
- [Flutter Web Documentation](https://docs.flutter.dev/platform-integration/web)
- [Supabase Documentation](https://supabase.com/docs)
- [Google OAuth Documentation](https://developers.google.com/identity/protocols/oauth2)

## Next Steps After Deployment

1. **Test all features** on the deployed app
2. **Monitor performance** and error rates
3. **Set up monitoring** and alerting
4. **Configure backup strategies** for your database
5. **Plan for scaling** as user base grows
6. **Implement CI/CD pipelines** for automated testing and deployment

Your CardSense AI app should now be successfully deployed to Vercel! 🚀 