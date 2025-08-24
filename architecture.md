# CryptoTax Helper - Architecture Document

## Overview
CryptoTax Helper is a modern Flutter mobile app designed for cryptocurrency portfolio management and tax calculation with a dark-themed crypto dashboard aesthetic.

## Core Features (MVP)
1. **Authentication**: Login/Signup with email/password + Google sign-in UI
2. **Dashboard**: Portfolio overview with key metrics and recent transactions
3. **Transaction Management**: Add, view, filter, and manage crypto transactions
4. **Analytics**: Visual charts for portfolio performance and distribution
5. **Settings**: Currency preferences, tax rates, and theme switching

## Technical Stack
- **Framework**: Flutter 3.6+
- **State Management**: StatefulWidget (for MVP simplicity)
- **Local Storage**: SharedPreferences
- **Charts**: fl_chart package
- **Fonts**: Google Fonts (Inter)
- **Navigation**: Bottom navigation with floating action button

## App Structure

### Core Files
- `lib/main.dart` - App entry point and routing
- `lib/theme.dart` - Dark/light theme with crypto colors (Neon Green #39FF14, Purple #8A2BE2)

### Feature-Based Architecture
```
lib/
├── models/
│   ├── transaction.dart
│   ├── portfolio.dart
│   └── user_settings.dart
├── screens/
│   ├── splash_screen.dart
│   ├── auth/
│   │   ├── login_screen.dart
│   │   └── signup_screen.dart
│   ├── dashboard/
│   │   └── dashboard_screen.dart
│   ├── transactions/
│   │   ├── transactions_screen.dart
│   │   └── add_transaction_screen.dart
│   ├── analytics/
│   │   └── analytics_screen.dart
│   └── settings/
│       └── settings_screen.dart
├── widgets/
│   ├── summary_card.dart
│   ├── transaction_item.dart
│   ├── crypto_chart.dart
│   └── custom_bottom_nav.dart
├── services/
│   ├── storage_service.dart
│   └── mock_data_service.dart
└── utils/
    ├── constants.dart
    └── helpers.dart
```

## Implementation Plan

### Phase 1: Core Structure
1. Update main.dart with navigation setup
2. Create data models for transactions and portfolio
3. Implement storage service for local data persistence
4. Create mock data service for placeholder content

### Phase 2: Authentication Flow
1. Create splash screen with logo animation
2. Build login/signup screens with modern crypto design
3. Implement basic form validation
4. Add Google sign-in button (UI only for MVP)

### Phase 3: Main App Navigation
1. Implement bottom navigation with 4 tabs
2. Add floating action button for quick transaction entry
3. Create custom navigation widgets

### Phase 4: Dashboard Screen
1. Build summary cards (Total Value, Profit/Loss, Estimated Tax)
2. Create recent transactions section
3. Implement responsive layout for mobile/tablet
4. Add smooth animations and transitions

### Phase 5: Transaction Management
1. Create transaction list screen with filtering
2. Build add transaction form with validation
3. Implement coin dropdown, buy/sell toggle, date picker
4. Add pagination for transaction history

### Phase 6: Analytics Screen
1. Implement profit/loss line chart using fl_chart
2. Create portfolio distribution pie chart
3. Add interactive chart features
4. Use placeholder data for MVP

### Phase 7: Settings Screen
1. Build currency preference dropdown
2. Add tax rate input field
3. Implement theme switching (dark/light mode)
4. Store preferences in local storage

### Phase 8: Polish & Testing
1. Add loading states and animations
2. Implement error handling
3. Test responsive layouts
4. Optimize performance

## Design Guidelines
- **Colors**: Dark mode default with Neon Green (#39FF14) and Purple (#8A2BE2) accents
- **Typography**: Inter font family with clear hierarchy
- **Components**: Rounded cards, minimal shadows, smooth transitions
- **Layout**: Generous whitespace, left-aligned text, responsive design
- **Icons**: Material Design icons only
- **Navigation**: Bottom tabs + FAB for primary actions

## Mock Data Requirements
- Sample cryptocurrency transactions (Bitcoin, Ethereum, etc.)
- Portfolio performance data for charts
- User settings with default values
- Realistic profit/loss calculations

## Future API Integration Points
- User authentication endpoints
- Transaction CRUD operations
- Real-time cryptocurrency prices
- Tax calculation services
- Portfolio analytics APIs

## Testing Strategy
1. Unit tests for data models and services
2. Widget tests for key UI components
3. Integration tests for user flows
4. Performance testing on various devices