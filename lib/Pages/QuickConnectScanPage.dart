import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

/// QuickConnectScanPage
///
/// Full-screen QR scanner. Pops back with the first raw payload string the
/// camera picks up; the caller (LoginPage) is responsible for parsing the JSON
/// and exchanging the OTP against the backend. The scanner does not validate
/// the payload — that keeps the page reusable if the wire shape evolves.
class QuickConnectScanPage extends StatefulWidget {
  const QuickConnectScanPage({super.key});

  @override
  State<QuickConnectScanPage> createState() => _QuickConnectScanPageState();
}

class _QuickConnectScanPageState extends State<QuickConnectScanPage> {
  final MobileScannerController _controller = MobileScannerController(
    detectionSpeed: DetectionSpeed.normal,
    formats: const [BarcodeFormat.qrCode],
  );

  // Guard against multiple onDetect events firing before pop() lands.
  bool _handled = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_handled) return;
    for (final barcode in capture.barcodes) {
      final raw = barcode.rawValue;
      if (raw != null && raw.isNotEmpty) {
        _handled = true;
        Navigator.of(context).pop(raw);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Quick Connect'),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          const Positioned(
            left: 0,
            right: 0,
            bottom: 32,
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 32.0),
                child: Text(
                  'Point at the QR code in the MWPA web portal.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}