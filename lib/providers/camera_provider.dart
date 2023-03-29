import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';

class CameraProvider extends ChangeNotifier {
  CameraController cameraController;
  List<CameraDescription> cameras;

  CameraProvider(this.cameras, this.cameraController);
}