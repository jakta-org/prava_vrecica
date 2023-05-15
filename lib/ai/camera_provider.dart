import 'package:camera/camera.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';

class CameraProvider extends ChangeNotifier {
  CameraController cameraController;
  List<CameraDescription> cameras;
  late ImagePicker picker;

  CameraProvider(this.cameras, this.cameraController) {
    picker = ImagePicker();
  }
}