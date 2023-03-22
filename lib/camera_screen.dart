import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:flutter/services.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key}) : super();

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  List<CameraDescription> cameras = [];
  Future<CameraController>? futureController;

  @override
  void initState() {
    futureController = startCamera();
    super.initState();
  }

  Future<CameraController> startCamera() async {
    cameras = await availableCameras();
    final controller = CameraController(
      cameras[0],
      ResolutionPreset.veryHigh,
      enableAudio: false,
    );
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
    return controller;
  }

  @override
  void dispose() {
    futureController?.then((controller) {
      controller.dispose();
    });
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CameraController>(
      future: futureController,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(
              child: CircularProgressIndicator(),
            ),
          );
        }
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(
              child: Text('Error initializing camera'),
            ),
          );
        }

        final controller = snapshot.requireData;
        final size = MediaQuery.of(context).size;

        SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
          systemNavigationBarColor: Theme.of(context).primaryColor,
          systemNavigationBarIconBrightness: Theme.of(context).brightness,
          systemNavigationBarDividerColor: Colors.transparent,
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ));

        var scale = size.aspectRatio * controller.value.aspectRatio;

        if (scale < 1) {
          scale = 1 / scale;
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
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(
                              onPressed: () {},
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
                        margin: const EdgeInsetsDirectional.symmetric(
                            horizontal: 20),
                        decoration: const BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(12)),
                          color: Colors.white,
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
                                borderRadius:
                                    BorderRadius.all(Radius.circular(12)),
                                color: Colors.black12,
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
                          color: Theme.of(context).primaryColor,
                        ),
                        height: 60,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.bar_chart,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.home,
                                color: Colors.black,
                              ),
                            ),
                            IconButton(
                              onPressed: () {},
                              icon: const Icon(
                                Icons.map,
                                color: Colors.black,
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
      },
    );
  }
}
