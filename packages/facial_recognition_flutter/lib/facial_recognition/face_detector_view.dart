import 'dart:io';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

import 'camera_view.dart';
import 'facial_recognition_provider.dart';
import 'painters/face_detector_painter.dart';

class FaceDetectorView extends StatefulWidget {
  @override
  State<FaceDetectorView> createState() => _FaceDetectorViewState();
}

class _FaceDetectorViewState extends State<FaceDetectorView> {
  final provider = FacialRecognitionProvider();
  static List<CameraDescription> _cameras = [];

  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      enableContours: true,
      enableLandmarks: true,
    ),
  );

  CameraController? _controller;

  final List<XFile> _picturesTaken = [];

  CustomPaint? _customPaint;
  int _intFaces = 1;
  String _facingDirection = '';
  bool _canProcess = true;
  bool _isBusy = false;
  bool _frontImageOk = false;
  bool _leftImageOk = false;
  bool _rightImageOk = false;
  bool _takingPhoto = false;
  bool _loading = true;

  var _cameraLensDirection = CameraLensDirection.front;

  Future<void> _detectFaceDirection(Face face) async {
    if (_takingPhoto) {
      return;
    }
    try {
      final double yRotation = face.headEulerAngleY ?? 0.0;
      final double zRotation = face.headEulerAngleZ ?? 0.0;

      // Definir limiares para decidir se o usuário está olhando para frente, esquerda ou direita
      // Esses valores podem precisar de ajustes
      const double yThreshold = 10.0;
      const double zThreshold = 6.0;

      // Detecta a direção baseada nos ângulos de rotação
      if (yRotation.abs() < yThreshold && zRotation.abs() < zThreshold) {
        // Frente
        if (!_frontImageOk) {
          await getPhoto(FacePositiion.front).then((value) {
            setState(() {
              _frontImageOk = true;
            });
          });
        }
        return;
      } else if (yRotation < yThreshold) {
        // Direita
        if (_frontImageOk && !_rightImageOk) {
          await getPhoto(FacePositiion.right).then((value) {
            setState(() {
              _rightImageOk = true;
            });
          });
        }
        return;
      } else if (yRotation > -yThreshold) {
        // Esquerda
        if (_frontImageOk && _rightImageOk && !_leftImageOk) {
          await getPhoto(FacePositiion.left).then((value) {
            setState(() {
              _leftImageOk = true;
            });
          });
        }
        return;
      } else {
        return;
      }
    } catch (e) {
      // Tratar erros aqui
      debugPrint(e.toString());
      throw e.toString();
    }
  }

  String _lookAt() {
    if (!_frontImageOk) {
      return 'Olhe diretamente para a câmera';
    } else if (_frontImageOk && !_rightImageOk) {
      return 'Olhe para a direta';
    } else if (_frontImageOk && _rightImageOk && !_leftImageOk) {
      return 'Olhe para a esquerda';
    } else {
      return 'Concluído!';
    }
  }

  Future<void> getPhoto(FacePositiion position) async {
    final size = MediaQuery.of(context).size;

    setState(() => _takingPhoto = true);

    final image = await _controller!.takePicture();

    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return Center(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.all(Radius.circular(15)),
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 8,
              vertical: 16,
            ),
            margin: EdgeInsets.symmetric(horizontal: size.width / 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.tag_faces_outlined,
                  color: Colors.grey,
                  size: 56,
                ),
                const Divider(color: Colors.transparent),
                Text(
                  'Aguarde enquanto validamos seu rosto',
                  style: Theme.of(context).textTheme.titleLarge,
                  textAlign: TextAlign.center,
                ),
                const Divider(color: Colors.transparent),
                CircularProgressIndicator(color: Colors.grey),
              ],
            ),
          ),
        );
      },
    );
    Future.delayed(Duration(seconds: 3)).then((value) {
      _picturesTaken.add(image);
      Navigator.pop(context);
      setState(() => _takingPhoto = false);
    });
  }

  Future<void> _processImage(InputImage inputImage) async {
    if (!_canProcess) return;
    if (_isBusy) return;
    _isBusy = true;
    final faces = await _faceDetector.processImage(inputImage);
    if (inputImage.metadata?.size != null &&
        inputImage.metadata?.rotation != null) {
      final painter = FaceDetectorPainter(
        faces,
        inputImage.metadata!.size,
        inputImage.metadata!.rotation,
        _cameraLensDirection,
      );
      _intFaces = faces.length;
      _customPaint = CustomPaint(painter: painter);
      if (faces.isNotEmpty) {
        await _detectFaceDirection(faces.first);
      } else {
        _facingDirection = '';
      }
    }
    _isBusy = false;
    if (mounted) {
      setState(() {});
    }
  }

  void _initCamera() async {
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras[1],
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );

    setState(() => _loading = false);
  }

  @override
  void initState() {
    _initCamera();
    super.initState();
  }

  @override
  void dispose() {
    _canProcess = false;
    _faceDetector.close();
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    if (_loading) {
      return Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(automaticallyImplyLeading: true),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ClipOval(
                    clipper: CustomClipperOval(
                      clipHeight: size.height / 4.5,
                      clipWidth: size.width / 1.5,
                    ),
                    child: SizedBox(
                      height: size.height / 2,
                      width: size.width / 1.5,
                      child: Center(
                        child: Center(
                          child: SizedBox(
                            width: size.width / 1,
                            height: double.infinity,
                            child: CameraView(
                              initialZoomLevel: 1.7,
                              cameraController: _controller,
                              customPaint: _customPaint,
                              onImage: _processImage,
                              initialCameraLensDirection: _cameraLensDirection,
                              onCameraLensDirectionChanged: (value) =>
                                  _cameraLensDirection = value,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Text(
              _lookAt(),
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.red,
              ),
            ),
            Visibility(
              visible: _facingDirection.isNotEmpty,
              child: Column(
                children: [
                  const Divider(color: Colors.transparent),
                  Text(
                    'Olhando para: $_facingDirection',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
            const Divider(color: Colors.transparent),
            Visibility(
              visible: _intFaces != 1,
              child: Text(
                'Seu rosto não está visível\nPor favor olhe diretamente para a câmera',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            ),
            const Divider(color: Colors.transparent),
            Visibility(
              visible: provider.getShowPhotos,
              child: SizedBox(
                height: 200,
                width: double.infinity,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: _picturesTaken.length,
                  separatorBuilder: (context, index) => const VerticalDivider(
                    color: Colors.transparent,
                  ),
                  itemBuilder: (context, index) {
                    final item = _picturesTaken[index];
                    return SizedBox(
                      width: 100,
                      height: 200,
                      child: Image.file(File(item.path)),
                    );
                  },
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomClipperOval extends CustomClipper<Rect> {
  CustomClipperOval({
    required this.clipWidth,
    required this.clipHeight,
  });

  final double clipWidth;
  final double clipHeight;

  @override
  Rect getClip(Size size) {
    return Rect.fromLTWH(0, 0, clipWidth, clipHeight * 2);
  }

  @override
  bool shouldReclip(CustomClipperOval oldClipper) {
    return clipWidth != oldClipper.clipWidth ||
        clipHeight != oldClipper.clipHeight;
  }
}

enum FacePositiion { front, left, right }
