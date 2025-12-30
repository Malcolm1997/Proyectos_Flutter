import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:texel_domotica/core/app_colors.dart';
import 'package:texel_domotica/screens/txl_home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  // Oculta las barras del sistema para toda la app (immersiveSticky)
  SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(
          title: const Text("Texel Control"),
          backgroundColor: AppColors.background,
        ),
        body: const TxlHomeScreen(),
      ),
    );
  }
}
