import 'dart:io';
import 'dart:ui';
import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prava_vrecica/screens/settings_screen.dart';
import 'package:prava_vrecica/screens/user_info_screen.dart';
import 'package:provider/provider.dart';
import '../providers/ai_model_provider.dart';
import '../providers/camera_provider.dart';
import 'preview_screen.dart';
import 'package:image/image.dart' as img;
import '../providers/theme_provider.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class CameraScreen extends StatefulWidget {
  const CameraScreen({super.key}) : super();

  @override
  State<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends State<CameraScreen> {
  late CameraController cameraController;
  late Widget preview;
  late CameraProvider cameraProvider;
  late ThemeProvider themeProvider;
  late Size size;
  late double scale;
  bool previewOn = false;
  IconData flashIcon = Icons.flashlight_off;
  bool flashOn = false;

  @override
  void initState() {
    super.initState();
    preview = Container();
  }

  Widget buildImagePreview(Future<XFile> future) {
    return FutureBuilder(
      future: future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.transparent,
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

        return imagePreview(snapshot.data!.path);
      },
    );
  }

  void startRecognition(String path) {
    final aiModelProvider = Provider.of<AiModelProvider>(
        context,
        listen: false);
    final classifier = aiModelProvider.classifier;
    List<int> imageBytes = File(path).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    List<Recognition> recognitions =
    classifier.predict(image!);
    recognitions.sort((a, b) =>
        a.location.left.compareTo(b.location.left));
    final factor =
        MediaQuery.of(context).size.width / image.width;

    if (recognitions.isNotEmpty) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PreviewScreen(
              imagePath: path,
              recognitions: recognitions,
              factor: factor,
              dateTime: DateTime.now(),
          ),
        ),
      );
    }

    setState(() => preview = Container());
  }

  Widget imagePreview(String path) {
    File file = File(path);
    Image image = Image.file(file);

    return Center(
      child: Stack(
        children: [
          FractionallySizedBox(
            widthFactor: 1,
            heightFactor: 1,
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 8, sigmaY: 8),
              child: Container(
                color: Colors.black54,
              ),
            ),
          ),
          Center(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              child: FractionallySizedBox(
                widthFactor: 0.8,
                child: Stack(
                  children: [
                    image,
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        padding:
                        const EdgeInsetsDirectional.only(start: 10),
                        color: Theme.of(context).colorScheme.surfaceTint,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              AppLocalizations.of(context)!.photo_prompt,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                IconButton(
                                  padding: EdgeInsetsDirectional.zero,
                                  onPressed: () {
                                    setState(() => preview = Container());
                                  },
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.red, width: 3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(
                                      Icons.close,
                                      size: 30,
                                      color: Colors.red,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  padding: EdgeInsetsDirectional.zero,
                                  onPressed: () => startRecognition(path),
                                  icon: Container(
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Theme.of(context).primaryColor, width: 3),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Icon(
                                      Icons.check,
                                      size: 30,
                                      color: Theme.of(context).primaryColor,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    themeProvider = Provider.of<ThemeProvider>(context, listen: false);
    cameraProvider = Provider.of<CameraProvider>(context, listen: false);
    cameraController = cameraProvider.cameraController;

    size = MediaQuery.of(context).size;
    var scale = size.aspectRatio * cameraController.value.aspectRatio;
    if (scale < 1) {
      scale = 1 / scale;
    }

    //int userScore = 0;

    return Scaffold(
      body: Stack(
        children: [
          Transform.scale(
            scale: scale,
            child: Center(
              child: CameraPreview(cameraController),
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
                            onPressed: () async {
                              XFile? picked = await cameraProvider.picker.pickImage(source: ImageSource.gallery);
                              if (picked != null) {
                                setState(() {
                                  preview = imagePreview(picked.path);
                                });
                              }
                            },
                            padding: EdgeInsets.zero,
                            iconSize: 30,
                            icon: Icon(
                              Icons.add_circle,
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                              horizontal: 20),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                preview = buildImagePreview(cameraController.takePicture());
                              });
                            },
                            padding: EdgeInsets.zero,
                            iconSize: 80,
                            icon: Icon(
                              Icons.circle_outlined,
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
                            ),
                          ),
                        ),
                        Container(
                          margin: const EdgeInsetsDirectional.symmetric(
                              horizontal: 20),
                          child: IconButton(
                            onPressed: () {
                              setState(() {
                                flashOn = flashOn == true ? false : true;
                                flashIcon = flashOn == true ? Icons.flashlight_on : Icons.flashlight_off;
                                cameraController.setFlashMode(flashOn == true ? FlashMode.torch : FlashMode.off);
                              });
                            },
                            padding: EdgeInsets.zero,
                            iconSize: 30,
                            icon: Icon(
                              flashIcon,
                              color:
                                  Theme.of(context).colorScheme.surfaceVariant,
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
          preview,
        ],
      ),
    );
  }
}