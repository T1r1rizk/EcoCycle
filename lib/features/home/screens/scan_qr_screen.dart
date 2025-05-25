import 'package:flutter/material.dart';
import 'package:qr_code_scanner_plus/qr_code_scanner_plus.dart';
import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_application_3/services/supabase_service.dart';

class ScanQrScreen extends StatefulWidget {
  const ScanQrScreen({super.key});

  @override
  State<ScanQrScreen> createState() => _ScanQrScreenState();
}

class _ScanQrScreenState extends State<ScanQrScreen> {
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QR');
  QRViewController? controller;
  bool _isProcessing = false;
  final _supabase = Supabase.instance.client;
  bool _hasPermission = false;

  @override
  void initState() {
    super.initState();
    _checkPermission();
  }

  Future<void> _checkPermission() async {
    final status = await Permission.camera.request();
    setState(() {
      _hasPermission = status.isGranted;
    });
  }

  Future<void> _handleSuccessfulScan() async {
    if (!mounted) return;
    
    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('+100 points added!')),
    );
    
    // Add a small delay before navigation
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (!mounted) return;
    Navigator.pop(context, true);
  }

  Future<void> _handleOfferScan(Map<String, dynamic> qrData) async {
    try {
      final result = await _supabase.rpc('redeem_offer_qr', params: {
        'p_offer_id': qrData['offerId'],
        'p_user_id': qrData['userId'],
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(result['message'] ?? 'Offer redeemed!')),
      );

      await Future.delayed(const Duration(milliseconds: 500));
      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().toLowerCase();
      if (errorMsg.contains('already been used') || errorMsg.contains('already used') || errorMsg.contains('duplicate') || errorMsg.contains('has been used')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This QR code has already been used. Please scan a new one!')),
        );
      } else if (errorMsg.contains('qr code not found')) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('This QR code is invalid or not found. Please try another one!')),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $errorMsg')),
        );
      }
    }
  }

  void _onQRViewCreated(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.listen((scanData) async {
      if (_isProcessing) return;
      _isProcessing = true;

      try {
        final userId = Supabase.instance.client.auth.currentUser?.id;
        if (userId == null) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('You must be logged in to scan QR codes.')),
          );
          _isProcessing = false;
          return;
        }
        final partner = await Supabase.instance.client.from('partners').select().eq('id', userId).maybeSingle();

        // Try to parse as JSON first (offer QR)
        try {
          final qrData = jsonDecode(scanData.code ?? '{}');
          if (qrData is Map && qrData['offerId'] != null) {
            debugPrint('Detected offer QR, handling as offer redemption.');
            await _handleOfferScan(Map<String, dynamic>.from(qrData));
            return;
          }
        } catch (e) {
          debugPrint('JSON parse error: $e');
          // Not a JSON QR code, treat as regular QR
        }

        if (partner != null) {
          // This is a partner: do NOT allow adding points, even for regular QR
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Partners can only redeem offers, not earn points.')),
          );
          _isProcessing = false;
          return;
        } else {
          // This is a user: allow regular QR code scanning for points
          debugPrint('Detected user scanning regular QR, adding points.');
          await _supabase.rpc('use_qr_code', params: {
            'p_code': scanData.code,
            'p_user_id': userId,
            'p_points': 100,
          });
          // Also update environmental impact and points
          await SupabaseService.addPoints(0); // 0 points, just increment items recycled
          await Future.delayed(const Duration(milliseconds: 100));
          await _handleSuccessfulScan();
        }
      } catch (e) {
        if (!mounted) return;
        final errorMsg = e.toString().toLowerCase();
        if (errorMsg.contains('already been used') || errorMsg.contains('already used') || errorMsg.contains('duplicate') || errorMsg.contains('has been used')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This QR code has already been used. Please scan a new one!')),
          );
        } else if (errorMsg.contains('qr code not found')) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('This QR code is invalid or not found. Please try another one!')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error: $errorMsg')),
          );
        }
      } finally {
        _isProcessing = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (!_hasPermission) {
      return Scaffold(
        appBar: AppBar(title: const Text('Scan QR Code')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Camera permission is required to scan QR codes'),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _checkPermission,
                child: const Text('Grant Permission'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            if (mounted) {
              Navigator.pop(context);
            }
          },
        ),
      ),
      body: Column(
        children: [
          Expanded(
            flex: 4,
            child: QRView(
              key: qrKey,
              onQRViewCreated: _onQRViewCreated,
              overlay: QrScannerOverlayShape(
                borderColor: Colors.green,
                borderRadius: 10,
                borderLength: 30,
                borderWidth: 10,
                cutOutSize: 250,
              ),
            ),
          ),
          const Expanded(
            flex: 1,
            child: Center(
              child: Text('Scan any QR code to add points or redeem offers'),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    super.dispose();
  }
}