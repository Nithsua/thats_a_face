import 'dart:io';
import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:image_picker/image_picker.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      home: HomeView(),
    );
  }
}

class HomeView extends StatefulWidget {
  const HomeView({Key? key}) : super(key: key);

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView> {
  bool _imageSelected = false;
  ui.Image? _image;
  List<Face>? faces;

  Future<void> _pickImage() async {
    await ImagePicker()
        .pickImage(source: ImageSource.camera)
        .then((xFile) async {
      if (xFile != null) {
        faces = await computeMl(File(xFile.path));
        final temp = await decodeImageFromList(await xFile.readAsBytes());
        setState(() {
          _imageSelected = true;
          _image = temp;
        });
      }
    });
  }

  Future<List<Face>> computeMl(File image) async {
    final detector = GoogleMlKit.vision.faceDetector(FaceDetectorOptions());
    final faces = await detector.processImage(InputImage.fromFile(image));
    return faces;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: _imageSelected
          ? Column(
              children: [
                Flexible(
                  flex: 2,
                  child: Container(
                    constraints: const BoxConstraints.expand(),
                    child: FittedBox(
                      child: SizedBox(
                        width: _image?.width.toDouble(),
                        height: _image?.height.toDouble(),
                        child: CustomPaint(
                          foregroundPainter: SmileyPainter(
                              image: _image!,
                              faces: faces!.map((e) => e.boundingBox).toList()),
                        ),
                      ),
                    ),
                  ),
                ),
                Flexible(
                  flex: 1,
                  child: faces != null
                      ? Text(
                          faces!.map((e) => e.boundingBox).toList().toString())
                      : const SizedBox(),
                ),
              ],
            )
          : Center(
              child: ElevatedButton(
                onPressed: _pickImage,
                child: const Text("Computer Vision"),
              ),
            ),
    );
  }
}

class SmileyPainter extends CustomPainter {
  final List<Rect> faces;
  final ui.Image image;
  SmileyPainter({required this.image, required this.faces});

  @override
  void paint(Canvas canvas, Size size) async {
    final backgroundPaint = Paint()..color = Colors.yellow;
    final center = Offset(size.width / 2, size.height / 2);
    canvas.drawImage(image, Offset.zero, Paint());

    for (var rect in faces) {
      print(rect.toString());
      final radius = rect.shortestSide / 2;

      canvas.drawCircle(
        ui.Offset(rect.left + rect.width / 2, rect.top + rect.height / 2),
        radius,
        backgroundPaint,
      );
      canvas.drawCircle(
        ui.Offset(rect.left + rect.width * 0.3, rect.top + rect.height / 2.5),
        radius * 0.1,
        ui.Paint(),
      );
      canvas.drawCircle(
        ui.Offset(rect.left + rect.width * 0.7, rect.top + rect.height / 2.5),
        radius * 0.1,
        ui.Paint(),
      );
      canvas.drawArc(
        Rect.fromCircle(
            center: Offset(
                rect.left + rect.width / 2, rect.top + rect.height / 1.8),
            radius: radius / 2),
        0,
        pi,
        false,
        Paint()
          ..style = ui.PaintingStyle.stroke
          ..strokeWidth = 20.0,
      );
    }
  }

  @override
  bool shouldRepaint(covariant SmileyPainter oldDelegate) =>
      oldDelegate.faces != faces;
}
