# Coin Charger

A modern cryptocurrency trading app with live charts and market data, built with Flutter.

## Features

### 🏠 Home Screen
- **Market Overview**: Global cryptocurrency market statistics
- **Quick Actions**: Buy, sell, and convert cryptocurrencies
- **Top Movers**: Top gaining and losing cryptocurrencies
- **Trending Coins**: Trending cryptocurrencies with sparkline charts

### 📊 Markets Screen
- **Cryptocurrency List**: Complete list of top cryptocurrencies by market cap
- **Search Functionality**: Search for specific cryptocurrencies
- **Live Data**: Real-time price updates and market data
- **Sparkline Charts**: 7-day price trend visualization

### 💼 Portfolio Screen
- **Coming Soon**: Portfolio tracking and management features
- **Planned Features**:
  - Portfolio tracking with real-time updates
  - Transaction history and analytics
  - Performance charts and insights
  - Portfolio rebalancing tools
  - Tax reporting and calculations

### 👤 Profile Screen
- **User Settings**: Notifications, security, language, and theme preferences
- **Support & Info**: Help, about, privacy policy, and terms of service

## Technical Stack

- **Framework**: Flutter 3.0+
- **State Management**: Provider pattern
- **API Integration**: CoinGecko API for cryptocurrency data
- **Charts**: fl_chart for sparkline charts
- **UI**: Material Design 3 with custom dark theme
- **Fonts**: Google Fonts (Inter)
- **HTTP Client**: http and dio packages

## Dependencies

```yaml
dependencies:
  flutter:
    sdk: flutter
  provider: ^6.1.1
  http: ^1.1.0
  dio: ^5.3.2
  fl_chart: ^0.65.0
  syncfusion_flutter_charts: ^24.1.41
  google_fonts: ^6.1.0
  flutter_svg: ^2.0.9
  cached_network_image: ^3.3.0
  intl: ^0.18.1
  shared_preferences: ^2.2.2
  web_socket_channel: ^2.4.0
```

## Project Structure

```
lib/
├── models/
│   └── crypto_coin.dart          # Cryptocurrency data model
├── services/
│   └── crypto_api_service.dart   # API service for CoinGecko
├── providers/
│   └── crypto_provider.dart      # State management provider
├── screens/
│   ├── main_screen.dart          # Main navigation screen
│   ├── home_screen.dart          # Home screen with overview
│   ├── markets_screen.dart       # Markets and search
│   ├── portfolio_screen.dart     # Portfolio (coming soon)
│   └── profile_screen.dart       # User profile and settings
├── widgets/
│   ├── market_overview_card.dart # Market statistics card
│   ├── quick_actions_card.dart   # Buy/sell/convert actions
│   ├── top_movers_card.dart      # Top gainers/losers
│   ├── trending_coins_card.dart  # Trending cryptocurrencies
│   └── crypto_list_item.dart     # Individual crypto item
└── main.dart                     # App entry point
```

## Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd coin
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## API Integration

The app integrates with the **CoinGecko API** to fetch:
- Top cryptocurrencies by market cap
- Real-time price data and market statistics
- Trending cryptocurrencies
- Search results
- Global market overview

## Features in Development

- [ ] Portfolio tracking and management
- [ ] Real-time price alerts
- [ ] Advanced charting with multiple timeframes
- [ ] Trading functionality
- [ ] News and market analysis
- [ ] Social features and community
- [ ] Push notifications
- [ ] Offline mode
- [ ] Multiple language support
- [ ] Advanced filtering and sorting

## Future Enhancements

- **Real-time Updates**: WebSocket integration for live price updates
- **Advanced Charts**: Multiple timeframes and technical indicators
- **Portfolio Management**: Complete portfolio tracking and analytics
- **Trading Features**: Buy/sell orders and trading history
- **News Integration**: Cryptocurrency news and market analysis
- **Social Features**: User communities and sharing
- **Performance Optimization**: Caching and offline support
- **Testing**: Unit tests and widget tests
- **Accessibility**: Screen reader support and accessibility features

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Add tests if applicable
5. Submit a pull request

## License

This project is licensed under the MIT License.

## Disclaimer

This app is for educational and demonstration purposes. Cryptocurrency trading involves risk, and users should conduct their own research before making investment decisions.
