import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prava_vrecica/mode_status.dart';
import 'package:prava_vrecica/providers/ai_model_provider.dart';
import 'package:prava_vrecica/providers/database_provider.dart';
import 'package:prava_vrecica/providers/user_provider.dart';
import 'package:prava_vrecica/screens/account_mode_screen.dart';
import 'package:prava_vrecica/screens/login_screen.dart';
import 'package:prava_vrecica/screens/settings_screen.dart';
import 'package:prava_vrecica/screens/statistics_screen.dart';
import 'package:prava_vrecica/providers/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'providers/camera_provider.dart';
import 'screens/camera_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  final isDark = sharedPreferences.getBool('is_dark') ?? (ThemeMode.system == ThemeMode.dark);
  final userId = sharedPreferences.getInt('user_id') ?? -2;

  final cameras = await availableCameras();
  final cameraController = CameraController(
    cameras[0],
    ResolutionPreset.veryHigh,
    enableAudio: false,
  );
  await cameraController.initialize();

  final interpreter = await Interpreter.fromAsset("model.tflite", options: InterpreterOptions()..threads = 4);
  final labels = await FileUtil.loadLabels("assets/labels.txt");
  final threshold = sharedPreferences.getDouble('threshold') ?? 0.5;

  runApp(App(isDark: isDark, userId: userId, cameras: cameras, cameraController: cameraController, interpreter: interpreter, labels: labels, threshold: threshold));
}

class App extends StatelessWidget {
  final int userId;
  final bool isDark;
  final List<CameraDescription> cameras;
  final CameraController cameraController;
  final Interpreter interpreter;
  final List<String> labels;
  final double threshold;

  const App({super.key, required this.isDark, required this.userId, required this.cameras, required this.cameraController, required this.interpreter, required this.labels, required this.threshold});

  @override
  Widget build(BuildContext context) {
    if (kDebugMode) {
      String userPrint = userId.toString();
      print("User is: $userPrint");
    }
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => UserProvider(userId)),
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDark)),
        ChangeNotifierProvider(create: (context) => DatabaseProvider()),
        ChangeNotifierProvider(create: (context) => AiModelProvider(interpreter, labels, threshold)),
        ChangeNotifierProvider(create: (context) => CameraProvider(cameras, cameraController)),
      ],
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        themeProvider.updateSystemUI();

        return MaterialApp(
          title: 'Prava Vrećica',
          themeMode: themeProvider.themeMode,
          theme: Themes.lightTheme,
          darkTheme: Themes.darkTheme,
          home: const ModeStatus(),
          routes: {
            'Camera': (BuildContext context) => const CameraScreen(),
            'Settings': (BuildContext context) => const SettingsScreen(),
            'Statistics': (BuildContext context) => const StatisticsScreen(),
            'Account': (BuildContext context) => const AccountModeScreen(),
            'Login': (BuildContext context) => const LoginScreen(),
          },
        );
      },
    );
  }
}
