import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:prava_vrecica/settings_screen.dart';

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
    controller = CameraController(
        cameras[0],
        ResolutionPreset.veryHigh,
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
                        IconButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const SettingsScreen()),
                            );
                          },
                          padding: EdgeInsets.zero,
                          iconSize: 35,
                          icon: const Icon(
                            Icons.settings,
                            color: Colors.white,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          padding: EdgeInsets.zero,
                          iconSize: 35,
                          icon: const Icon(
                            Icons.account_circle,
                            color: Colors.white,
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
                      color: Theme.of(context).colorScheme.background,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                              horizontal: 2),
                          child: const Center(
                            child: Icon(
                              Icons.recycling,
                              color: Colors.green,
                            ),
                          ),
                        ),
                        Container(
                          width: 90,
                          height: 30,
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(12)),
                            color: Colors.grey,
                          ),
                          child: const Center(
                            child: Text(
                              "25001",
                              style: TextStyle(
                                color: Colors.green,
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
                            icon: const Icon(
                              Icons.add_circle,
                              color: Colors.white,
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
                            icon: const Icon(
                              Icons.circle_outlined,
                              color: Colors.white,
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
                            icon: const Icon(
                              Icons.flashlight_off,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(25),
                          topRight: Radius.circular(25)),
                      color: Theme.of(context).colorScheme.background,
                    ),
                    height: 60,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.bar_chart,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.home,
                            color: Theme.of(context).colorScheme.onBackground,
                          ),
                        ),
                        IconButton(
                          onPressed: () {},
                          icon: Icon(
                            Icons.map,
                            color: Theme.of(context).colorScheme.onBackground,
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
