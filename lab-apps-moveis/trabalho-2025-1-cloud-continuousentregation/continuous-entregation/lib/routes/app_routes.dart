import 'package:continuous_entregation/screens/client/home_client_screen.dart';
import 'package:continuous_entregation/screens/client/package_history_screen.dart';
import 'package:continuous_entregation/screens/client/register_package_screen.dart';
import 'package:continuous_entregation/screens/client/track_delivery.dart';
import 'package:continuous_entregation/screens/common/register_screen.dart';
import 'package:continuous_entregation/screens/common/settings_screen.dart';
import 'package:continuous_entregation/screens/driver/available_deliveries_screen.dart';
import 'package:continuous_entregation/screens/driver/completed_deliveries_screen.dart';
import 'package:continuous_entregation/screens/driver/delivery_route_screen.dart';
import 'package:continuous_entregation/screens/driver/home_driver_screen.dart';
import 'package:continuous_entregation/screens/driver/take_photo_screen.dart'; // Import TakePhotoScreen
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../screens/common/login_screen.dart';

class AppRoutes {
  static const login = '/';
  static const homeDriver = '/home-driver';
  static const homeClient = '/home-client';
  static const register = '/register';
  static const settings = '/settings';
  static const registerPackage = '/register-package';
  static const acceptDelivery = '/accept-delivery';
  static const trackDelivery = '/track-delivery';
  static const deliveryRoute = '/delivery-route';
  static const historyClient = '/history-client';
  static const historyCompleted = '/history-completed';
  static const takePhoto = '/take-photo';

  static Map<String, WidgetBuilder> get routes => {
    login: (_) => const LoginClientScreen(),
    homeDriver: (_) => const HomeDriverScreen(),
    homeClient: (_) => const HomeClientScreen(),
    register: (_) => const RegisterScreen(),
    settings: (_) => const SettingsScreen(),
    registerPackage: (_) => const RegisterPackageScreen(),
    acceptDelivery: (_) => const AvailableDeliveriesScreen(),
    trackDelivery: (_) => const RastrearPedidoScreen(),
    deliveryRoute: (_) => const RotaEntregaScreen(),
    historyClient: (_) => const HistoricoPedidosScreen(),
    historyCompleted: (_) => const HistoricoPedidosConcluidosScreen(),
    takePhoto: (_) => TakePhotoScreen(deliveryId: ''),
  };
}
