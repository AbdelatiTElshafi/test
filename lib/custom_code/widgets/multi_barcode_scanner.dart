// Automatic FlutterFlow imports
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'index.dart'; // Imports other custom widgets
import 'package:flutter/material.dart';
// Begin custom widget code
// DO NOT REMOVE OR MODIFY THE CODE ABOVE!

// External packages
import 'package:camera/camera.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'dart:typed_data';

class MultiBarcodeScanner extends StatefulWidget {
  const MultiBarcodeScanner({
    super.key,
    this.width,
    this.height,
  });

  final double? width;
  final double? height;

  @override
  State<MultiBarcodeScanner> createState() => _MultiBarcodeScannerState();
}

class _MultiBarcodeScannerState extends State<MultiBarcodeScanner> {
  late CameraController _cameraController;
  bool _isDetecting = false;
  List<String> detectedCodes = [];

  @override
  void initState() {
    super.initState();
    _startCamera();
  }

  Future<void> _startCamera() async {
    final cameras = await availableCameras();
    final backCamera = cameras.firstWhere(
      (c) => c.lensDirection == CameraLensDirection.back,
    );

    _cameraController = CameraController(
      backCamera,
      ResolutionPreset.medium,
      enableAudio: false,
    );
    await _cameraController.initialize();

    _cameraController.startImageStream((CameraImage image) async {
      if (_isDetecting) return;
      _isDetecting = true;

      try {
        final allBytes = <int>[];
        for (final plane in image.planes) {
          allBytes.addAll(plane.bytes);
        }
        final bytes = Uint8List.fromList(allBytes);

        final inputImage = InputImage.fromBytes(
          bytes: bytes,
          metadata: InputImageMetadata(
            size: Size(image.width.toDouble(), image.height.toDouble()),
            rotation:
                InputImageRotation.rotation90deg, // أو rotation270deg حسب الوضع
            format: InputImageFormat.nv21,
            bytesPerRow: image.planes.first.bytesPerRow,
          ),
        );
        final barcodeScanner = BarcodeScanner();
        final barcodes = await barcodeScanner.processImage(inputImage);
        final newCodes = barcodes
            .map((b) => b.rawValue ?? '')
            .where((v) => v.isNotEmpty)
            .toList();

        if (newCodes.isNotEmpty) {
          setState(() {
            for (final code in newCodes) {
              if (!detectedCodes.contains(code)) {
                detectedCodes.add(code);
              }
            }
          });

          // حفظ في FFAppState (FlutterFlow)
          FFAppState().scannedCodes = detectedCodes;
        }
      } catch (e) {
        debugPrint('❌ Barcode scan error: $e');
      }

      _isDetecting = false;
    });

    setState(() {});
  }

  @override
  void dispose() {
    if (_cameraController.value.isInitialized) {
      _cameraController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (_cameraController.value.isInitialized)
          SizedBox(
            width: widget.width ?? 300,
            height: widget.height ?? 300,
            child: CameraPreview(_cameraController),
          )
        else
          const Center(child: CircularProgressIndicator()),
        const SizedBox(height: 12),
        Text(
          'عدد الأكواد: ${detectedCodes.length}',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView.builder(
            itemCount: detectedCodes.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  detectedCodes[index],
                  style: const TextStyle(fontSize: 14),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
