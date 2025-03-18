# AgriConnect

AgriConnect is a Flutter application that connects farmers directly with consumers, enabling efficient agricultural product trading and management.

## Features

- User Authentication (Farmers and Consumers)
- Product Management
- Profile Management
- Real-time Product Updates
- Secure Data Storage with Supabase
- Image Upload Functionality
- QR Code Generation for Products

## Getting Started

### Prerequisites

- Flutter SDK (latest version)
- Dart SDK
- Android Studio / VS Code
- Git
- Supabase Account

### Installation

1. Clone the repository
```bash
git clone [your-repository-url]
```

2. Install dependencies
```bash
flutter pub get
```

3. Configure Supabase
- Create a `.env` file in the root directory
- Add your Supabase credentials:
```
SUPABASE_URL=your_supabase_url
SUPABASE_ANON_KEY=your_supabase_anon_key
```

4. Run the app
```bash
flutter run
```

## Project Structure

```
lib/
├── models/         # Data models
├── providers/      # State management
├── screens/        # UI screens
├── services/       # API services
├── utils/          # Utilities and constants
└── widgets/        # Reusable widgets
```

## Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Acknowledgments

- Flutter Team
- Supabase
- All contributors
