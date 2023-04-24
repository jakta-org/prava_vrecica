import 'dart:math';
import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:tflite_flutter_helper/tflite_flutter_helper.dart';

class AiModelProvider extends ChangeNotifier {
  Interpreter interpreter;
  List<String> labels;
  double threshold = 0.5;

  Classifier get classifier {
    return Classifier(interpreter, labels, threshold);
  }

  AiModelProvider(this.interpreter, this.labels, this.threshold);

  Future<void> setThreshold(double threshold) async {
    SharedPreferences sharedPreferences = await SharedPreferences.getInstance();

    this.threshold = threshold;
    sharedPreferences.setDouble('threshold', threshold);

    notifyListeners();
  }
}

class Classifier {
  final Interpreter _interpreter;

  final List<String> _labels;

  static const int inputSize = 448;

  late double threshold = 0;

  late List<List<int>> _outputShapes;

  late List<TfLiteType> _outputTypes;

  static const int numResults = 10;

  Classifier(this._interpreter, this._labels, this.threshold) {
    _outputShapes = [];
    _outputTypes = [];


    var outputTensors = _interpreter.getOutputTensors();
    _outputShapes = [];
    _outputTypes = [];
    for (var tensor in outputTensors) {
      _outputShapes.add(tensor.shape);
      _outputTypes.add(tensor.type);
    }

  }

  TensorImage getProcessedImage(TensorImage inputImage) {
    var padSize = max(inputImage.height, inputImage.width);
    var imageProcessor = ImageProcessorBuilder()
        .add(ResizeWithCropOrPadOp(padSize, padSize))
        .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
        .build();
    inputImage = imageProcessor.process(inputImage);
    return inputImage;
  }

  List<Recognition> predict(img.Image image) {
    TensorImage inputImage = TensorImage.fromImage(image);
    var padSize = max(inputImage.height, inputImage.width);

    inputImage = getProcessedImage(inputImage);

    TensorBuffer outputScores = TensorBufferFloat(_outputShapes[0]);
    TensorBuffer outputLocations = TensorBufferFloat(_outputShapes[1]);
    TensorBuffer numLocations = TensorBufferFloat(_outputShapes[2]);
    TensorBuffer outputClasses = TensorBufferFloat(_outputShapes[3]);

    List<Object> inputs = [inputImage.buffer];

    Map<int, Object> outputs = {
      0: outputScores.buffer,
      1: outputLocations.buffer,
      2: numLocations.buffer,
      3: outputClasses.buffer,
    };

    _interpreter.runForMultipleInputs(inputs, outputs);

    int resultsCount = min(numResults, numLocations.getIntValue(0));

    List<Rect> locations = BoundingBoxUtils.convert(
      tensor: outputLocations,
      valueIndex: [1, 0, 3, 2],
      boundingBoxAxis: 2,
      boundingBoxType: BoundingBoxType.BOUNDARIES,
      coordinateType: CoordinateType.RATIO,
      height: inputSize,
      width: inputSize,
    );

    List<Recognition> recognitions = [];

    for (int i = 0; i < resultsCount; i++) {
      var score = outputScores.getDoubleValue(i);

      var labelIndex = outputClasses.getIntValue(i);
      var label = _labels.elementAt(labelIndex);

      var imageProcessor = ImageProcessorBuilder()
          .add(ResizeWithCropOrPadOp(padSize, padSize))
          .add(ResizeOp(inputSize, inputSize, ResizeMethod.BILINEAR))
          .build();

      if (score > threshold) {
        Rect transformedRect = imageProcessor.inverseTransformRect(
            locations[i], image.height, image.width);

        recognitions.add(
          Recognition(i, label, score, transformedRect),
        );
      }
    }

    return recognitions;
  }
}

class Recognition {
  int id;

  String label;

  late String recognizedLabel;

  double score;

  Rect location;

  bool valid = false;

  Recognition(this.id, this.label, this.score, this.location) {
    recognizedLabel = label;
  }

  Rect get renderLocation {
    // ratioX = screenWidth / imageInputWidth
    // ratioY = ratioX if image fits screenWidth with aspectRatio = constant

    double ratioX = 1;
    double ratioY = ratioX;

    double transLeft = max(0.1, location.left * ratioX);
    double transTop = max(0.1, location.top * ratioY);
    double transWidth = min(
        location.width * ratioX, 10000);
    double transHeight = min(
        location.height * ratioY, 10000);

    Rect transformedRect =
    Rect.fromLTWH(transLeft, transTop, transWidth, transHeight);
    return transformedRect;
  }

  @override
  String toString() {
    return 'Recognition(id: $id, label: $label, score: $score, location: $location)';
  }
}