import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PartnerScannerScreen extends StatefulWidget {
  const PartnerScannerScreen({super.key});

  @override
  State<PartnerScannerScreen> createState() => _PartnerScannerScreenState();
}

class _PartnerScannerScreenState extends State<PartnerScannerScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;
      _isProcessing = true;
      try {
        final code = scanData.code;
        if (code == null) {
          _showMessage('Invalid QR code.');
          _isProcessing = false;
          return;
        }
        // Try to parse as JSON (offer QR)
        try {
          final qrData = jsonDecode(code);
          if (qrData is Map && qrData['offerId'] != null && qrData['userId'] != null) {
            await _handleOfferRedemption(Map<String, dynamic>.from(qrData));
            return;
          } else {
            _showMessage('This QR code is not a valid offer QR.');
          }
        } catch (e) {
          _showMessage('Invalid QR code format.');
        }
      } finally {
        _isProcessing = false;
      }
    });
  }

  Future<void> _handleOfferRedemption(Map<String, dynamic> qrData) async {
    final offerId = qrData['offerId'] as String?;
    final userId = qrData['userId'] as String?;
    if (offerId == null || userId == null) {
      _showMessage('Invalid offer QR code.');
      return;
    }
    debugPrint('Redeeming offer: offerId=$offerId, userId=$userId');
    try {
      final response = await Supabase.instance.client.rpc('redeem_offer_qr', params: {
        'p_offer_id': offerId,
        'p_user_id': userId,
      });
      if (response == null) {
        _showMessage('Redemption failed: No response from server.');
      } else if (response is Map && response['error'] != null) {
        _showMessage('Redemption failed: \\${response['error']}');
      } else {
        _showMessage('Offer redeemed successfully!');
        // Fetch offer points
        final offer = await Supabase.instance.client.from('offers').select('points_required').eq('id', offerId).maybeSingle();
        final offerPoints = offer?['points_required'] ?? 0;
        // Add (offerPoints - 5) to partner's points
        final partnerId = Supabase.instance.client.auth.currentUser?.id;
        if (partnerId != null) {
          final partner = await Supabase.instance.client.from('partners').select('points').eq('id', partnerId).maybeSingle();
          final currentPoints = partner?['points'] ?? 0;
          final pointsToAdd = offerPoints - 5;
          await Supabase.instance.client.from('partners').update({
            'points': currentPoints + pointsToAdd,
          }).eq('id', partnerId);
        }
        // Fetch and print updated user points for verification
        final userData = await Supabase.instance.client.from('users').select('total_points').eq('id', userId).maybeSingle();
        debugPrint('Updated user points: \\${userData?['total_points']}');
        
        // Close the scanner after successful redemption
        if (mounted) {
          Navigator.pop(context, true);
        }
      }
    } catch (e) {
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('not enough points')) {
        _showMessage('The user does not have enough points to redeem this offer.');
        if (mounted) {
          Navigator.pop(context, true);
        }
      } else {
        _showMessage('Redemption error: \\${e.toString()}');
      }
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partner Offer Scanner')),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                flex: 4,
                child: QRView(
                  key: qrKey,
                  onQRViewCreated: _onQRViewCreated,
                ),
              ),
              const SizedBox(height: 16),
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: Text(
                  'Align the QR code within the frame to scan',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
          // Add corner markers and overlay
          Positioned.fill(
            child: CustomPaint(
              painter: QRScannerOverlayPainter(
                borderColor: Colors.green,
                borderWidth: 3,
                cornerLength: 20,
                overlayColor: Colors.black54,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class QRScannerOverlayPainter extends CustomPainter {
  final Color borderColor;
  final double borderWidth;
  final double cornerLength;
  final Color overlayColor;

  QRScannerOverlayPainter({
    required this.borderColor,
    required this.borderWidth,
    required this.cornerLength,
    required this.overlayColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final scanAreaSize = size.width * 0.8;
    final scanAreaLeft = (size.width - scanAreaSize) / 2;
    final scanAreaTop = (size.height - scanAreaSize) / 2;

    // Draw semi-transparent overlay
    final overlayPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    // Draw overlay for top area
    canvas.drawRect(
      Rect.fromLTWH(0, 0, size.width, scanAreaTop),
      overlayPaint,
    );
    // Draw overlay for bottom area
    canvas.drawRect(
      Rect.fromLTWH(0, scanAreaTop + scanAreaSize, size.width, size.height - (scanAreaTop + scanAreaSize)),
      overlayPaint,
    );
    // Draw overlay for left area
    canvas.drawRect(
      Rect.fromLTWH(0, scanAreaTop, scanAreaLeft, scanAreaSize),
      overlayPaint,
    );
    // Draw overlay for right area
    canvas.drawRect(
      Rect.fromLTWH(scanAreaLeft + scanAreaSize, scanAreaTop, size.width - (scanAreaLeft + scanAreaSize), scanAreaSize),
      overlayPaint,
    );

    // Draw corner markers
    // Top left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + cornerLength),
      Offset(scanAreaLeft, scanAreaTop),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop),
      Offset(scanAreaLeft + cornerLength, scanAreaTop),
      paint,
    );

    // Top right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + cornerLength),
      paint,
    );

    // Bottom left corner
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize - cornerLength),
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + cornerLength, scanAreaTop + scanAreaSize),
      paint,
    );

    // Bottom right corner
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize - cornerLength, scanAreaTop + scanAreaSize),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      paint,
    );
    canvas.drawLine(
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize - cornerLength),
      Offset(scanAreaLeft + scanAreaSize, scanAreaTop + scanAreaSize),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
} 