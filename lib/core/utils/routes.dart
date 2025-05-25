import 'package:flutter/material.dart';
import 'package:flutter_application_3/features/account/screens/withdraw_screen.dart';
import 'package:flutter_application_3/features/auth/login_screen.dart';
// ignore: unused_import
import 'package:flutter_application_3/features/auth/register_screen.dart'; // Updated to import the RegisterScreen
import 'package:flutter_application_3/features/auth/signin_screen.dart';
import 'package:flutter_application_3/features/home/screens/home_screen.dart';
import 'package:flutter_application_3/features/home/screens/scan_qr_screen.dart';
import 'package:flutter_application_3/features/home/screens/redeem_screen.dart';
import 'package:flutter_application_3/features/home/screens/pickup_screen.dart';
import 'package:flutter_application_3/features/home/screens/partner_scanner_screen.dart';
// import 'package:flutter_application_3/features/home/screens/rewards_screen.dart';
import 'package:flutter_application_3/features/account/screens/about_me_screen.dart';
import 'package:flutter_application_3/features/account/screens/address_screen.dart';
import 'package:flutter_application_3/features/account/screens/notifications_screen.dart';

class AppRoutes {
  // Auth Routes
  static const String login = '/login';
  static const String signup = '/signup';
  static const String forgotPassword = '/forgot-password';
  static const String continueAsGuest = '/continue-as-guest';
  
  // Home Routes
  static const String home = '/home';
  static const String scanQr = '/scan-qr';
  static const String redeem = '/redeem';
  static const String pickup = '/pickup';
  static const String withdraw = '/withdraw';
  static const String rewards = '/rewards';
  static const String partnerScanner = '/partner-scanner';

  // Account Routes
  static const String account = '/account';
  static const String aboutMe = '/about-me';
  static const String address = '/address';
  static const String history = '/history';
  static const String notifications = '/notifications';
  static const String profile = '/profile';

  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      // Auth Screens
      case login:
        return _buildRoute(const LoginScreen()); // Changed from LoginPage to LoginScreen
      case signup:
        return _buildRoute(const RegisterScreen()); // Changed from AuthPage to RegisterScreen
      
      // Home Screens
      case home:
        return _buildRoute(const HomeScreen());
      case scanQr:
        return _buildRoute(const ScanQrScreen());
      case redeem:
        return _buildRoute(const RedeemScreen(userPoints: 0));
      case pickup:
        return _buildRoute(const PickupScreen());
      case withdraw:
        return _buildRoute(const WithdrawScreen());
      case rewards:
        // ActiveOffersScreen now requires arguments and cannot be used here directly.
        // Use MaterialPageRoute with required arguments from the calling context instead.
        throw UnimplementedError('ActiveOffersScreen requires arguments and cannot be used with named routes.');
      case partnerScanner:
        return _buildRoute(const PartnerScannerScreen());
      
      // Account Screens
      case account:
        // AccountScreen now requires offers and cannot be used here directly.
        throw UnimplementedError('AccountScreen requires offers and cannot be used with named routes.');
      case aboutMe:
        return _buildRoute(const AboutMeScreen());
      case address:
        return _buildRoute(const AddressScreen());
      case history:
        // HistoryScreen now requires offers and cannot be used here directly.
        throw UnimplementedError('HistoryScreen requires offers and cannot be used with named routes.');
      case notifications:
        return _buildRoute(const NotificationsScreen());
      case profile:
        // AccountScreen now requires offers and cannot be used here directly.
        throw UnimplementedError('AccountScreen requires offers and cannot be used with named routes.');

      default:
        return _buildRoute(
          Scaffold(
            appBar: AppBar(title: const Text('Error')),
            body: Center(child: Text('Not found: ${settings.name}')),
          ),
        );
    }
  }

  static MaterialPageRoute<T> _buildRoute<T>(Widget widget) {
    return MaterialPageRoute<T>(builder: (_) => widget);
  }
}