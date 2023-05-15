import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'ai_model_provider.dart';
import 'camera_provider.dart';
import 'preview_screen.dart';
import 'package:image/image.dart' as img;
import '../user/theme_provider.dart';
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

  Widget loading(Future<XFile> future) {
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

        return Container();
      },
    );
  }

  void startRecognition(String path) {
    print("da");
    final aiModelProvider =
        Provider.of<AiModelProvider>(context, listen: false);
    final classifier = aiModelProvider.classifier;
    List<int> imageBytes = File(path).readAsBytesSync();
    final image = img.decodeImage(imageBytes);
    List<Recognition> recognitions = classifier.predict(image!);
    recognitions.sort((a, b) => a.location.left.compareTo(b.location.left));
    final factor = MediaQuery.of(context).size.width / image.width;

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

  Widget imagePreview(String path, Image image) {
    return AlertDialog(
        titlePadding: EdgeInsets.zero,
        contentPadding: EdgeInsets.zero,
        buttonPadding: EdgeInsets.zero,
        iconPadding: EdgeInsets.zero,
        backgroundColor: Colors.transparent,
        content: Stack(
          children: [
            image,
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                color: Colors.black54,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.photo_prompt,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        IconButton(
                          padding: EdgeInsetsDirectional.zero,
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: Container(
                            decoration: BoxDecoration(
                              border: Border.all(color: Colors.red, width: 3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.close,
                              size: 25,
                              color: Colors.red,
                            ),
                          ),
                        ),
                        IconButton(
                          padding: EdgeInsetsDirectional.zero,
                          onPressed: () {
                            Navigator.of(context).pop();
                            startRecognition(path);
                          },
                          icon: Container(
                            decoration: BoxDecoration(
                              border: Border.all(
                                  color: Theme.of(context).primaryColor,
                                  width: 3),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              Icons.check,
                              size: 25,
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
        ));
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
                              XFile? picked = await cameraProvider.picker
                                  .pickImage(source: ImageSource.gallery);
                              if (picked != null && context.mounted) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return imagePreview(picked.path,
                                          Image.file(File(picked.path)));
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
                            onPressed: () async {
                              Future<XFile> pick =
                                  cameraController.takePicture();
                              setState(() {
                                preview = loading(pick);
                              });
                              XFile picked = await pick;
                              if (context.mounted) {
                                showDialog(
                                    context: context,
                                    builder: (BuildContext context) {
                                      return imagePreview(picked.path,
                                          Image.file(File(picked.path)));
                                    });
                              }
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
                                flashIcon = flashOn == true
                                    ? Icons.flashlight_on
                                    : Icons.flashlight_off;
                                cameraController.setFlashMode(flashOn == true
                                    ? FlashMode.torch
                                    : FlashMode.off);
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
