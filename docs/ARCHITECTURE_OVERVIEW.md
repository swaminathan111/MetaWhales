# CardSense AI - Architecture Overview

## Introduction

CardSense AI is a comprehensive Flutter-based personal finance application that helps users manage their credit cards, track spending, and get personalized AI-powered financial advice. This document provides a complete architectural overview of the system.

## System Architecture

### High-Level Architecture

The CardSense AI application follows a layered architecture pattern with clear separation of concerns:

1. **Presentation Layer**: Flutter UI components with Riverpod state management
2. **Business Logic Layer**: Domain-specific services and providers
3. **Data Layer**: Supabase backend with PostgreSQL database
4. **External Services**: OpenRouter AI API, Google OAuth, and other integrations

### Technology Stack

- **Frontend**: Flutter (Dart) - Cross-platform mobile, web, and desktop
- **State Management**: Riverpod for reactive state management
- **Navigation**: GoRouter for declarative routing
- **Backend**: Supabase (PostgreSQL + Auth + Storage + Real-time)
- **AI Integration**: OpenRouter API for LLM access
- **Authentication**: Supabase Auth + Google OAuth
- **Deployment**: Multiple platforms (Android, iOS, Web via Vercel, Desktop)

## Feature Architecture

### Domain-Driven Design

The application follows domain-driven design principles with features organized by business domains:

#### 1. Authentication Feature
- **Screens**: Login, Signup
- **Services**: Google Auth Service, Profile Service
- **Providers**: Auth Provider for state management
- **Widgets**: User Avatar, custom auth components

#### 2. Onboarding Feature
- **Screens**: Preferences, Spending Categories, Add Card, Optimization
- **Models**: User Preferences
- **Providers**: Onboarding Provider
- **Services**: Integration with user profile creation

#### 3. Cards Management Feature
- **Screens**: Add Card, Card Details
- **Models**: Card Info
- **Providers**: Card Provider, Cards Provider
- **Services**: Card Service, Card Data Service

#### 4. AI Chat Feature
- **Screens**: Chat History, RAG Test Screen
- **Services**: 
  - Chat Service (main chat logic)
  - OpenRouter Service (AI API integration)
  - RAG Chat Service (retrieval-augmented generation)
  - Speech Service (voice interaction)
  - Chat Persistence Service (conversation storage)
- **Widgets**: Service Status Indicator

#### 5. Home/Dashboard Feature
- **Screens**: Main dashboard
- **Integration**: Aggregates data from all other features

### Service Layer Architecture

#### Core Services

1. **Supabase Service**: Central backend communication
2. **Environment Service**: Configuration management
3. **User Context Service**: Personalization data aggregation
4. **Card Service**: Credit card management logic
5. **Onboarding Service**: User setup flow management
6. **Prompt Service**: AI prompt management

#### AI and Chat Services

1. **OpenRouter Service**: AI API communication
2. **RAG Chat Service**: Context-aware AI responses
3. **Chat Persistence Service**: Conversation storage and retrieval
4. **Speech Service**: Voice-to-text and text-to-voice

## Database Architecture

### Core Tables

#### User Management
- `user_profiles`: Extended user information beyond Supabase auth
- Contains onboarding data, preferences, and settings

#### Financial Data
- `card_issuers`: Bank and financial institution information
- `card_categories`: Credit card type classifications
- `user_cards`: User's credit/debit card information
- `transactions`: Financial transaction records
- `spending_categories`: Transaction categorization system
- `spending_summaries`: Monthly analytics data

#### AI and Chat
- `chat_conversations`: Chat session management
- `chat_messages`: Individual chat messages with metadata
- `notifications`: User notification system
- `alert_rules`: Automated alert configuration

#### Analytics and Tracking
- `user_engagement`: User behavior tracking
- Additional analytics tables for insights

### Data Relationships

- One-to-many relationships between users and their cards, transactions, chats
- Many-to-many relationships for spending categories and user preferences
- Foreign key constraints ensure data integrity
- Row Level Security (RLS) policies for data protection

## Authentication Flow

### Multi-Provider Authentication
1. **Email/Password**: Traditional authentication via Supabase
2. **Google OAuth**: Social login integration
3. **Session Management**: Automatic token refresh and state persistence

### Authentication States
- **Unauthenticated**: Landing and login screens
- **Authenticated**: Access to protected routes
- **Profile Creation**: Automatic profile setup after authentication
- **Onboarding Check**: Route users through setup if incomplete

## AI Integration Architecture

### Personalized AI Responses

The system implements a sophisticated AI pipeline:

1. **Context Building**: User Context Service aggregates:
   - User profile and preferences
   - Card portfolio information
   - Spending patterns and history
   - Recent transactions

2. **RAG (Retrieval-Augmented Generation)**:
   - Context-aware prompt generation
   - Integration with user's financial data
   - Personalized recommendations

3. **AI API Integration**:
   - OpenRouter service for LLM access
   - Multiple AI model support
   - Error handling and fallback mechanisms

4. **Chat Persistence**:
   - Conversation history storage
   - Context maintenance across sessions
   - Performance optimization for chat loading

## Navigation and Routing

### Declarative Routing with GoRouter

- **Route Protection**: Authentication-based access control
- **Dynamic Redirects**: Based on user state (authenticated, onboarded)
- **Error Handling**: Custom error pages and fallbacks
- **Deep Linking**: Support for web and mobile deep links

### Navigation Flow
1. **Splash Screen**: App initialization
2. **Landing**: Unauthenticated entry point
3. **Auth Screens**: Login/Signup flows
4. **Onboarding**: First-time user setup
5. **Home**: Main application dashboard

## State Management

### Riverpod Architecture

- **Providers**: Reactive state containers
- **Consumer Widgets**: UI components that react to state changes
- **State Persistence**: Automatic state management
- **Dependency Injection**: Service locator pattern

### Key Providers
- `authProvider`: Authentication state
- `cardProvider`: Individual card management
- `cardsProvider`: Card portfolio management
- `onboardingProvider`: Setup flow state

## Infrastructure and DevOps

### Multi-Platform Deployment

#### Mobile Platforms
- **Android**: APK and Google Play Store deployment
- **iOS**: App Store deployment with iOS-specific configurations

#### Web Platform
- **Progressive Web App (PWA)** capabilities
- **Vercel Deployment**: Optimized for web performance
- **CORS Configuration**: API access management

#### Desktop Platforms
- **Windows**: MSIX packaging
- **macOS**: DMG distribution
- **Linux**: AppImage distribution

### Environment Management

#### Development Environment
- `.env.dev` configuration
- Development database branch
- Hot reload and debugging tools
- Local development setup scripts

#### Production Environment
- `.env.prod` configuration
- Production database
- Performance monitoring
- Error tracking and analytics

### Database Management

#### Migration System
- **Schema Migrations**: Version-controlled database changes
- **Setup Scripts**: Environment-specific database initialization
- **Seed Data**: Test and development data management
- **Cleanup Scripts**: Database maintenance utilities

## Logging and Monitoring

### Centralized Logging System

Located in `lib/core/logging/`:

#### Components
1. **App Logger**: General application logging
2. **API Logger**: API request/response logging
3. **Performance Monitor**: Performance metrics tracking

#### Log Levels
- **ERROR**: System errors and exceptions
- **WARNING**: Potential issues and recoverable errors
- **INFO**: Important business events
- **DEBUG**: Detailed diagnostic information

#### Structured Logging
- JSON-based log format
- Context-aware logging with user IDs and session information
- Performance metrics and timing data
- Error tracking with stack traces

## Security Considerations

### Data Protection
- **Row Level Security (RLS)**: Database-level access control
- **Authentication Tokens**: Secure session management
- **Environment Variables**: Sensitive configuration protection
- **Input Validation**: SQL injection and XSS prevention

### Privacy Compliance
- **Data Minimization**: Only collect necessary user data
- **Consent Management**: User control over data usage
- **Audit Trails**: Track data access and modifications
- **Secure Communication**: HTTPS/TLS for all communications

## Performance Optimization

### Frontend Optimization
- **Widget Rebuilding**: Efficient state management with Riverpod
- **Image Optimization**: Compressed assets and lazy loading
- **Bundle Size**: Code splitting and tree shaking
- **Caching**: Local data persistence and offline support

### Backend Optimization
- **Database Indexing**: Optimized query performance
- **Connection Pooling**: Efficient database connections
- **Caching Strategies**: Redis-like caching for frequent queries
- **Query Optimization**: Efficient SQL patterns

## Testing Strategy

### Test Organization
Located in `test/` directory:

#### Test Types
1. **Unit Tests**: Individual service and utility testing
2. **Integration Tests**: Feature-level testing
3. **Widget Tests**: UI component testing
4. **Service Tests**: Business logic validation

#### Test Structure
- **Mocking**: Isolated testing with mock dependencies
- **Test Data**: Controlled test scenarios
- **Coverage**: Comprehensive test coverage metrics

## Development Guidelines

### Code Organization
- **Feature-First**: Domain-driven feature organization
- **Service Layer**: Centralized business logic
- **Repository Pattern**: Data access abstraction
- **Dependency Injection**: Loose coupling between components

### Best Practices
- **Error Handling**: Comprehensive error management
- **Logging**: Structured logging throughout the application
- **Documentation**: Inline documentation and README files
- **Code Quality**: Linting, formatting, and analysis tools

## Future Enhancements

### Planned Features
1. **Advanced Analytics**: Machine learning-based insights
2. **Investment Tracking**: Portfolio management features
3. **Bill Reminders**: Automated payment notifications
4. **Social Features**: Sharing and collaboration tools
5. **Multi-Currency**: International transaction support

### Technical Improvements
1. **Offline Support**: Enhanced offline capabilities
2. **Real-time Updates**: WebSocket-based live updates
3. **AI Models**: Custom fine-tuned models for financial advice
4. **API Gateway**: Microservices architecture migration
5. **Advanced Security**: Biometric authentication and fraud detection

## Conclusion

CardSense AI represents a modern, scalable approach to personal finance management with AI integration. The architecture emphasizes:

- **Maintainability**: Clear separation of concerns and modular design
- **Scalability**: Cloud-native backend with horizontal scaling capabilities
- **Security**: Multiple layers of protection for sensitive financial data
- **User Experience**: Fast, responsive interface across all platforms
- **AI Integration**: Sophisticated personalization and intelligent recommendations

This architecture provides a solid foundation for current features while remaining flexible for future enhancements and scaling requirements. 