# 🚀 CryptoTax Helper

**Your Ultimate Cryptocurrency Tax Tracking & Portfolio Management Solution**

CryptoTax Helper is a comprehensive Flutter mobile application designed to simplify cryptocurrency tax tracking and portfolio management with an elegant, intuitive dark-themed interface.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/dart-%230175C2.svg?style=for-the-badge&logo=dart&logoColor=white)

## ✨ Features

### 🔐 Authentication & Security
- **Email & Password Authentication** with Firebase Auth
- **Password Reset** functionality
- **User Profile Management** with display names
- **Secure Data Storage** with Firebase Firestore

### 📊 Portfolio Management
- **Real-time Portfolio Tracking** with live value updates
- **Multi-coin Support** for various cryptocurrencies
- **Portfolio Performance Analytics** with visual charts
- **Profit/Loss Calculations** with detailed breakdowns

### 💰 Transaction Management
- **Buy/Sell Transaction Recording** with detailed metadata
- **Transaction History** with filtering and sorting
- **Import/Export Capabilities** for external data
- **Transaction Categories** for better organization

### 📈 Tax Calculations
- **Automated Tax Calculations** based on local regulations
- **Tax Rate Customization** for different jurisdictions
- **Annual Tax Reports** with detailed summaries
- **Capital Gains/Loss Tracking** with FIFO/LIFO methods

### 🎨 User Experience
- **Modern Dark Theme** with Material Design 3
- **Smooth Animations** with custom transitions
- **Responsive Design** for all screen sizes
- **Intuitive Navigation** with bottom navigation bar

## 🛠 Tech Stack

### Frontend
- **Flutter** - Cross-platform mobile development framework
- **Dart** - Programming language
- **Material Design 3** - UI design system
- **Google Fonts** - Typography

### Backend & Services
- **Firebase Core** - Backend infrastructure
- **Firebase Authentication** - User authentication
- **Cloud Firestore** - NoSQL database
- **Firebase Storage** - File storage (future implementation)

### Data Visualization
- **FL Chart** - Beautiful charts and graphs
- **Custom Widgets** - Tailored UI components

### State Management & Utilities
- **Shared Preferences** - Local data persistence
- **Intl** - Internationalization support
- **Repository Pattern** - Clean architecture

## 📱 Screenshots

*Coming Soon - Screenshots will be added after UI implementation*

## 🚀 Getting Started

### Prerequisites

Before you begin, ensure you have the following installed:
- [Flutter SDK](https://flutter.dev/docs/get-started/install) (>=3.6.0)
- [Dart SDK](https://dart.dev/get-dart)
- [Android Studio](https://developer.android.com/studio) or [VS Code](https://code.visualstudio.com/)
- [Git](https://git-scm.com/)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/DKSingh1604/cryptotax_helper.git
   cd cryptotax_helper
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Firebase Setup**
   - Create a new Firebase project at [Firebase Console](https://console.firebase.google.com/)
   - Enable Authentication (Email/Password)
   - Create a Firestore database
   - Download `google-services.json` for Android and place it in `android/app/`
   - Download `GoogleService-Info.plist` for iOS and place it in `ios/Runner/`
   - Run FlutterFire CLI to configure:
     ```bash
     flutterfire configure
     ```

4. **Run the app**
   ```bash
   flutter run
   ```

### Android Build Requirements

- **Minimum SDK**: 23 (Android 6.0)
- **Target SDK**: 34 (Android 14)
- **Compile SDK**: 34
- **Java Version**: 11
- **Kotlin Version**: 2.0.0
- **Gradle Version**: 8.3.0

## 🏗 Project Structure

```
lib/
├── main.dart                    # App entry point
├── theme.dart                   # App theme configuration
├── firebase_options.dart        # Firebase configuration
├── firestore/
│   └── firestore_data_schema.dart   # Database schema
├── models/
│   ├── portfolio.dart           # Portfolio data model
│   ├── transaction.dart         # Transaction data model
│   └── user_settings.dart       # User settings model
├── screens/
│   ├── splash_screen.dart       # Loading screen
│   ├── analytics/               # Analytics screens
│   ├── auth/                    # Authentication screens
│   │   ├── auth_wrapper.dart    # Auth state management
│   │   ├── login_screen.dart    # Login interface
│   │   └── signup_screen.dart   # Registration interface
│   ├── dashboard/               # Main dashboard
│   ├── settings/                # App settings
│   └── transactions/            # Transaction management
├── services/
│   ├── crypto_repository.dart   # Main business logic
│   ├── firebase_auth_service.dart   # Authentication service
│   ├── firestore_service.dart   # Database service
│   ├── mock_data_service.dart   # Development data
│   └── storage_service.dart     # File storage service
├── utils/
│   ├── constants.dart           # App constants
│   └── helpers.dart             # Utility functions
└── widgets/
    ├── crypto_chart.dart        # Chart components
    ├── custom_bottom_nav.dart   # Navigation bar
    ├── summary_card.dart        # Summary widgets
    └── transaction_item.dart    # Transaction list items
```

## 🔧 Configuration

### Firebase Security Rules

Update your Firestore security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can only access their own documents
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }
    
    // Transactions are user-specific
    match /transactions/{document} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // Portfolios are user-specific
    match /portfolios/{document} {
      allow read, write: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
  }
}
```

### Environment Variables

Create a `.env` file for sensitive configuration:

```env
# API Keys (if needed for external services)
CRYPTO_API_KEY=your_crypto_api_key_here
TAX_API_KEY=your_tax_api_key_here
```

## 📖 Usage

### Creating an Account
1. Open the app
2. Tap "Sign Up" 
3. Enter your email, password, and optional display name
4. Verify your email (if enabled)
5. Start tracking your crypto transactions!

### Adding Transactions
1. Navigate to the Dashboard
2. Tap the "+" button
3. Select transaction type (Buy/Sell)
4. Enter transaction details
5. Save to update your portfolio

### Viewing Analytics
1. Go to the Analytics tab
2. View portfolio performance charts
3. Check profit/loss calculations
4. Export tax reports

## 🧪 Testing

Run tests with:

```bash
# Unit tests
flutter test

# Integration tests
flutter test integration_test/

# Widget tests
flutter test test/widget_test.dart
```

## 🏗 Building for Production

### Android APK
```bash
flutter build apk --release
```

### Android App Bundle
```bash
flutter build appbundle --release
```

### iOS
```bash
flutter build ios --release
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

### Code Style

- Follow [Dart style guide](https://dart.dev/guides/language/effective-dart/style)
- Use meaningful variable and function names
- Add comments for complex logic
- Write tests for new features

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- [Flutter Team](https://flutter.dev/) for the amazing framework
- [Firebase](https://firebase.google.com/) for backend services
- [FL Chart](https://github.com/imaNNeo/fl_chart) for beautiful charts
- [Google Fonts](https://fonts.google.com/) for typography

## 📞 Support & Contact

- **Issues**: [GitHub Issues](https://github.com/DKSingh1604/cryptotax_helper/issues)
- **Discussions**: [GitHub Discussions](https://github.com/DKSingh1604/cryptotax_helper/discussions)
- **Email**: [your-email@example.com](mailto:your-email@example.com)

## 🗺 Roadmap

### Upcoming Features
- [ ] Google Sign-In integration
- [ ] Biometric authentication
- [ ] CSV/Excel import/export
- [ ] Multiple currency support
- [ ] Advanced tax calculations
- [ ] Price alerts and notifications
- [ ] Dark/Light theme toggle
- [ ] Backup and restore functionality

### Future Enhancements
- [ ] Web application
- [ ] Desktop applications (Windows, macOS, Linux)
- [ ] API for third-party integrations
- [ ] Advanced analytics and insights
- [ ] Tax advisor integration
- [ ] Multi-language support

---

**Made with ❤️ using Flutter**

*CryptoTax Helper - Simplifying crypto tax tracking, one transaction at a time.*