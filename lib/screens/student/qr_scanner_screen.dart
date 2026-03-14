import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

import '../../models/attendance_model.dart';
import '../../providers/app_providers.dart';
import '../../providers/auth_provider.dart';
import '../../providers/library_provider.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  MobileScannerController? _controller;
  bool _processing = false;
  bool _done = false;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    _controller = MobileScannerController(
      facing: CameraFacing.back,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _done) return;
    final barcodes = capture.barcodes;
    if (barcodes.isEmpty) return;

    final code = barcodes.first.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _processing = true);
    await _controller?.stop();

    try {
      final userId = context.read<AuthProvider>().currentUser?.id;
      final currentLibraryId = context.read<LibraryProvider>().currentLibrary?.id;

      if (userId == null) {
        _showResult(false, 'Not logged in. Please re-login.');
        return;
      }

      // Check if scanned QR matches the student's library
      if (currentLibraryId != null && code != currentLibraryId) {
        _showResult(false, 'This QR code is not for your library.');
        return;
      }

      final libraryId = code;

      // Check if already marked today
      final allAttendance = await AppProviders.dbService.getAttendance(libraryId);
      final studentAttendance = allAttendance.where((a) => a.studentId == userId).toList();
      final today = DateTime.now();
      final alreadyMarked = studentAttendance.any((a) =>
          a.timestamp.year == today.year &&
          a.timestamp.month == today.month &&
          a.timestamp.day == today.day);

      if (alreadyMarked) {
        _showResult(true, 'Attendance already marked for today! ✓');
        return;
      }

      // Mark attendance
      final record = AttendanceModel(
        id: const Uuid().v4(),
        libraryId: libraryId,
        studentId: userId,
        timestamp: DateTime.now(),
        status: 'Present',
      );
      await AppProviders.dbService.addAttendance(record);
      _showResult(true, 'Attendance marked successfully! 🎉');
    } catch (e) {
      _showResult(false, 'Error: $e');
    }
  }

  void _showResult(bool success, String message) {
    if (!mounted) return;
    setState(() {
      _processing = false;
      _done = true;
      _statusMessage = message;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircleAvatar(
              radius: 36,
              backgroundColor: success ? Colors.green.shade100 : Colors.red.shade100,
              child: Icon(
                success ? Icons.check_circle : Icons.error,
                size: 40,
                color: success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              success ? 'Success!' : 'Failed',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: success ? Colors.green : Colors.red,
              ),
            ),
            const SizedBox(height: 8),
            Text(message, textAlign: TextAlign.center),
          ],
        ),
        actions: [
          Center(
            child: FilledButton(
              onPressed: () {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop(success);
              },
              style: FilledButton.styleFrom(
                backgroundColor: success ? Colors.green : const Color(0xFFE64A19),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Done'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan Library QR Code'),
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _controller!.torchState,
              builder: (ctx, state, _) => Icon(
                state == TorchState.on ? Icons.flash_on : Icons.flash_off,
              ),
            ),
            onPressed: () => _controller?.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera view
          MobileScanner(
            controller: _controller!,
            onDetect: _onDetect,
          ),

          // Overlay
          CustomPaint(
            painter: _ScannerOverlayPainter(),
            child: const SizedBox.expand(),
          ),

          // Instructions
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.6),
                    borderRadius: BorderRadius.circular(24),
                  ),
                  child: const Text(
                    'Point the camera at the library QR code\nto mark your attendance',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                if (_processing)
                  const Padding(
                    padding: EdgeInsets.only(top: 16),
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
              ],
            ),
          ),

          // Scan frame
          Center(
            child: Container(
              width: 220,
              height: 220,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFFE64A19), width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ScannerOverlayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    const scanAreaSize = 220.0;
    final rect = Rect.fromCenter(
      center: Offset(size.width / 2, size.height / 2),
      width: scanAreaSize,
      height: scanAreaSize,
    );
    final path = Path()
      ..addRect(Rect.fromLTWH(0, 0, size.width, size.height))
      ..addRRect(RRect.fromRectAndRadius(rect, const Radius.circular(16)));
    canvas.drawPath(
      path,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.5)
        ..fillType = PathFillType.evenOdd,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
