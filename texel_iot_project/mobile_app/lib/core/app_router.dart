import 'package:go_router/go_router.dart';
import 'package:mobile_app/main.dart'; // Import HomeScreen (Login)
import 'package:mobile_app/screens/screen_home.dart'; // Import ScreenHome (Dashboard)
import 'package:mobile_app/screens/screen_option_device.dart';
import 'package:mobile_app/screens/provision_screen.dart';
import 'package:mobile_app/screens/device_registration_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (context, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/home',
      builder: (context, state) => const ScreenHome(),
    ),
    GoRoute(
      path: '/provision',
      builder: (context, state) => const ScreenOptionDevice(),
      routes: [
        GoRoute(
          path: 'ble',
          builder: (context, state) => const ProvisionScreen(),
        ),
        GoRoute(
          path: 'qr',
          builder: (context, state) => const DeviceRegistrationScreen(),
        ),
      ],
    ),
  ],
);
