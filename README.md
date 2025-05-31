# CardSense AI

A Flutter mobile app with Supabase integration and AI card recognition capabilities.

## Features

- 🔐 **Authentication**: Secure user authentication with Supabase
- 🎨 **Modern UI**: Clean and intuitive Material Design 3 interface
- 🌍 **Environment Management**: Separate development and production configurations
- 🧭 **Navigation**: Declarative routing with GoRouter
- 🔄 **State Management**: Reactive state management with Riverpod
- 📱 **Cross-Platform**: Runs on iOS, Android, Web, and Desktop

## Project Structure

```
lib/
├── features/           # Feature-based modules
│   ├── auth/          # Authentication screens and providers
│   ├── home/          # Home screen and dashboard
│   └── splash/        # Splash screen
├── models/            # Data models
├── services/          # Business logic and API services
├── utils/             # Utilities and helpers
└── main.dart          # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK (3.22.3 or later)
- Dart SDK (3.4.4 or later)
- A Supabase project

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd cardsense_ai
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   
   Update the environment files with your Supabase credentials:
   
   **`.env.dev`** (Development):
   ```env
   SUPABASE_URL=https://your-dev-project.supabase.co
   SUPABASE_ANON_KEY=your-dev-anon-key-here
   ENVIRONMENT=dev
   ```
   
   **`.env.prod`** (Production):
   ```env
   SUPABASE_URL=https://your-prod-project.supabase.co
   SUPABASE_ANON_KEY=your-prod-anon-key-here
   ENVIRONMENT=prod
   ```

4. **Run the app**
   ```bash
   flutter run
   ```

## Environment Configuration

The app supports separate development and production environments:

- **Development**: Uses `.env.dev` file
- **Production**: Uses `.env.prod` file

The environment is automatically loaded based on the build configuration.

## Dependencies

### Core Dependencies
- `flutter`: Flutter SDK
- `supabase_flutter`: Supabase integration
- `flutter_riverpod`: State management
- `go_router`: Declarative routing
- `flutter_dotenv`: Environment configuration

### UI Dependencies
- `flutter_svg`: SVG support
- `cupertino_icons`: iOS-style icons

## Architecture

The app follows a feature-based architecture with clear separation of concerns:

- **Features**: Self-contained modules with screens, providers, and logic
- **Services**: Shared business logic and API integrations
- **Models**: Data structures and entities
- **Utils**: Helper functions and utilities

## State Management

The app uses Riverpod for state management, providing:
- Reactive state updates
- Dependency injection
- Provider composition
- Testing support

## Authentication Flow

1. **Splash Screen**: App initialization and environment loading
2. **Auth Check**: Determines user authentication status
3. **Login/Signup**: User authentication forms
4. **Home**: Main app dashboard for authenticated users

## Development

### Running in Development Mode

```bash
flutter run --debug
```

### Building for Production

```bash
flutter build apk --release
flutter build ios --release
```

### Code Generation

If you add new models or providers that require code generation:

```bash
flutter packages pub run build_runner build
```

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please open an issue in the repository.
