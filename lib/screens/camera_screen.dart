import 'package:animations/animations.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:prava_vrecica/screens/settings_screen.dart';
import 'package:prava_vrecica/screens/user_info_screen.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key}) : super();

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  late CameraController controller;

  @override
  void initState() {
    startCamera();
    super.initState();
  }

  void startCamera() async {
    cameras = await availableCameras();
    controller = CameraController(cameras[0], ResolutionPreset.veryHigh,
        enableAudio: false);
    await controller.initialize().then((value) {
      if (!mounted) {
        return;
      }
      setState(() {});
    }).catchError((error) {
      if (kDebugMode) {
        print(error);
      }
    });
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * controller.value.aspectRatio;

    if (scale < 1) {
      scale = 1 / scale;
    }

    if (!controller.value.isInitialized) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    final themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    themeProvider.toggleNavigationBar(true);

    int userScore = 53001;

    return Scaffold(
      body: Stack(
        children: [
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(controller),
            ),
          ),
          Positioned(
            top: 50,
            child: SizedBox(
              width: size.width,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    margin:
                        const EdgeInsetsDirectional.symmetric(horizontal: 10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        OpenContainer(
                          closedElevation: 0,
                          openElevation: 0,
                          transitionType: ContainerTransitionType.fadeThrough,
                          closedColor: Colors.transparent,
                          transitionDuration: const Duration(seconds: 1),
                          routeSettings: const RouteSettings(name: 'Settings'),
                          openBuilder: (context, action) => const SettingsScreen(),
                          closedBuilder: (context, VoidCallback openContainer) => IconButton(
                            onPressed: openContainer,
                            padding: EdgeInsets.zero,
                            iconSize: 35,
                            icon: Icon(
                              Icons.settings,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                        OpenContainer(
                          closedElevation: 0,
                          openElevation: 0,
                          transitionType: ContainerTransitionType.fadeThrough,
                          closedColor: Colors.transparent,
                          transitionDuration: const Duration(seconds: 1),
                          routeSettings: const RouteSettings(name: 'User'),
                          openBuilder: (context, action) => const UserInfoScreen(),
                          closedBuilder: (context, VoidCallback openContainer) => IconButton(
                            onPressed: openContainer,
                            padding: EdgeInsets.zero,
                            iconSize: 35,
                            icon: Icon(
                              Icons.account_circle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    margin:
                        const EdgeInsetsDirectional.symmetric(horizontal: 20),
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.all(Radius.circular(12)),
                      color: Theme.of(context).colorScheme.surface,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                              horizontal: 2),
                          child: Center(
                            child: Icon(
                              Icons.recycling,
                              color: Theme.of(context).colorScheme.primary,
                            ),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.all(Radius.circular(12)),
                            border: Border.all(width: 2, color: Theme.of(context).colorScheme.surface),
                            color: Theme.of(context).colorScheme.surfaceTint,
                          ),
                          child: Center(
                            child: Text(
                              userScore.toString(),
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.onSurface,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 0,
            child: SizedBox(
              width: size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Container(
                    margin: const EdgeInsetsDirectional.only(bottom: 80),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                              horizontal: 20),
                          child: IconButton(
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            iconSize: 30,
                            icon: Icon(
                              Icons.add_circle,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                              horizontal: 20),
                          child: IconButton(
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            iconSize: 80,
                            icon: Icon(
                              Icons.circle_outlined,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                              horizontal: 20),
                          child: IconButton(
                            onPressed: () {},
                            padding: EdgeInsets.zero,
                            iconSize: 30,
                            icon: Icon(
                              Icons.flashlight_off,
                              color: Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
