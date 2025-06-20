# Deployment Configuration

This directory contains all deployment-related configurations and scripts for the CardSense AI project.

## Directory Structure

```
deployment/
├── README.md                     # This file
└── vercel/                       # Vercel-specific deployment files
    ├── vercel.json              # Vercel configuration
    ├── vercel-build.sh          # Build script
    ├── deploy.sh                # Deployment script
    ├── environment.md           # Environment variables guide
    └── VERCEL_DEPLOYMENT_GUIDE.md # Complete deployment guide
```

## Quick Deployment

### Prerequisites
1. Install Vercel CLI: `npm install -g vercel`
2. Login to Vercel: `vercel login`

### Deploy to Vercel
```bash
# From project root
cd deployment/vercel
./deploy.sh
```

## Platform-Specific Guides

### Vercel
- **Configuration**: `vercel/vercel.json`
- **Environment Setup**: `vercel/environment.md`
- **Complete Guide**: `vercel/VERCEL_DEPLOYMENT_GUIDE.md`

## Environment Variables

All environment variables are documented in:
- `vercel/environment.md` - Vercel-specific variables

### Critical Configuration Changes
- **RAG API URLs**: Now fully environment-driven (no hardcoded fallbacks)
- **Required Variables**: `OLD_RAG_API_BASE_URL`, `NEW_RAG_API_BASE_URL`, `USE_NEW_RAG_API`
- **Error Handling**: App will throw exceptions if RAG API URLs are not configured
- **Environment-specific**: Use different URLs for development, staging, and production

## Build Scripts

- `vercel/vercel-build.sh` - Flutter web build for Vercel
- `vercel/deploy.sh` - Complete deployment automation

## Notes

- Vercel configuration moved from root to `deployment/vercel/`
- Update `package.json` build script path if needed
- All Vercel URLs centralized in environment configuration 