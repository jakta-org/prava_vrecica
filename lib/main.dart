import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prava_vrecica/documents/document_provider.dart';
import 'package:prava_vrecica/feedback/detection_entry_queue_provider.dart';
import 'package:prava_vrecica/intro/intro_screen.dart';
import 'package:prava_vrecica/boot_handler/mode_status.dart';
import 'package:prava_vrecica/ai/ai_model_provider.dart';
import 'package:prava_vrecica/ai/categorization_provider.dart';
import 'package:prava_vrecica/database/database_provider.dart';
import 'package:prava_vrecica/statistics/statistics_provider.dart';
import 'package:prava_vrecica/languages/localization_provider.dart';
import 'package:prava_vrecica/user/user_provider.dart';
import 'package:prava_vrecica/user/theme_provider.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';
import 'ai/camera_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pdf/widgets.dart' as pw;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

  final isDark = sharedPreferences.getBool('is_dark') ??
      (ThemeMode.system == ThemeMode.dark);
  final userId = sharedPreferences.getInt('user_id') ?? -2;
  final wasIntroScreenShown = sharedPreferences.getBool('was_intro_screen_shown') ?? false;
  //const wasIntroScreenShown = false;

  final cameras = await availableCameras();
  final cameraController = CameraController(
    cameras[0],
    ResolutionPreset.veryHigh,
    enableAudio: false,
  );
  await cameraController.initialize();

  final interpreter = await Interpreter.fromAsset("model_v2.tflite",
      options: InterpreterOptions()..threads = 4);
  final labels = await FileUtil.loadLabels("assets/labels_v2.txt");
  final threshold = sharedPreferences.getDouble('threshold') ?? 0.5;

  final List<String> objectsListsSrc = [];
  for (String cLocale in Language.languageList().map((lang) => lang.languageCode)) {
    objectsListsSrc.add(await rootBundle.loadString("assets/locale_objects/objects_$cLocale.json"));
  }

  final rulesSrc =
      await rootBundle.loadString("assets/categorization_zagreb.json");

  final locale = sharedPreferences.getString('locale') ?? "hr";

  final token = sharedPreferences.getString('token') ?? "void";

  final appDirectory = await getApplicationDocumentsDirectory();

  pw.MemoryImage logo = await rootBundle.load("assets/images/V_logo_ns.png").then((value) => pw.MemoryImage(value.buffer.asUint8List()));

  runApp(App(
    isDark: isDark,
    userId: userId,
    cameras: cameras,
    cameraController: cameraController,
    interpreter: interpreter,
    labels: labels,
    threshold: threshold,
    objectsListsSrc: objectsListsSrc,
    ruleSrc: rulesSrc,
    locale: locale,
    token: token,
    appDirectory: appDirectory,
    logo: logo,
    wasIntroScreenShown: wasIntroScreenShown,
  ));
}

class App extends StatelessWidget {
  final int userId;
  final bool isDark;
  final List<CameraDescription> cameras;
  final CameraController cameraController;
  final Interpreter interpreter;
  final List<String> labels;
  final double threshold;
  final List<String> objectsListsSrc;
  final String ruleSrc;
  final String locale;
  final String token;
  final Directory appDirectory;
  final pw.MemoryImage logo;
  final bool wasIntroScreenShown;

  const App(
      {super.key,
      required this.isDark,
      required this.userId,
      required this.cameras,
      required this.cameraController,
      required this.interpreter,
      required this.labels,
      required this.threshold,
      required this.objectsListsSrc,
      required this.ruleSrc,
      required this.locale,
      required this.token,
      required this.appDirectory,
        required this.logo,
        required this.wasIntroScreenShown});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (context) => CategorizationProvider(objectsListsSrc, ruleSrc, locale)),
        ChangeNotifierProvider(create: (context) => DatabaseProvider(token)),
        ChangeNotifierProvider(create: (context) => StatisticsProvider(userId, Provider.of<CategorizationProvider>(context, listen: false), Provider.of<DatabaseProvider>(context, listen: false), appDirectory)),
        ChangeNotifierProvider(create: (context) => DetectionEntryQueueProvider(userId, Provider.of<StatisticsProvider>(context, listen: false), Provider.of<DatabaseProvider>(context, listen: false), appDirectory)),
        ChangeNotifierProvider(
            create: (context) =>
                UserProvider(
                    userId,
                    Provider.of<StatisticsProvider>(context, listen: false),
                    Provider.of<DatabaseProvider>(context, listen: false),
                    Provider.of<DetectionEntryQueueProvider>(context, listen: false),
                  wasIntroScreenShown,
                )),
        ChangeNotifierProvider(create: (context) => ThemeProvider(isDark)),
        ChangeNotifierProvider(
            create: (context) =>
                AiModelProvider(interpreter, labels, threshold)),
        ChangeNotifierProvider(
            create: (context) => CameraProvider(cameras, cameraController)),
        ChangeNotifierProvider(
            create: (context) => LocalizationProvider(locale)),
        ChangeNotifierProvider(create: (context) => DocumentProvider(logo))
      ],
      builder: (context, _) {
        final themeProvider = Provider.of<ThemeProvider>(context);
        themeProvider.updateSystemUI(false);

        final localizationProvider = Provider.of<LocalizationProvider>(context);
        final detectionEntryQueueProvider = Provider.of<DetectionEntryQueueProvider>(context, listen: false);
        detectionEntryQueueProvider.processEntries();

        return MaterialApp(
          title: 'Prava Vrećica',
          themeMode: themeProvider.themeMode,
          theme: Themes.lightTheme,
          darkTheme: Themes.darkTheme,
          home: wasIntroScreenShown ? const ModeStatus() : const IntroScreen(),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          locale: Locale(localizationProvider.locale),
        );
      },
    );
  }
}
