import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../../core/l10n/l10n.dart';
import '../../../core/theme/app_palette.dart';
import '../model/friend_code_scan.dart';

/// Mon code ami en QR code (US15.6), à faire scanner par un ami.
Future<void> showFriendCodeQr(BuildContext context, String code) =>
    showModalBottomSheet<void>(
      context: context,
      backgroundColor: context.colors.card,
      showDragHandle: true,
      builder: (context) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  // Fond blanc : les lecteurs de QR lisent mal un code clair
                  // sur fond sombre (dans les deux thèmes).
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: QrImageView(data: code, size: 220),
              ),
              const SizedBox(height: 16),
              Text(
                code,
                style: TextStyle(
                  color: context.colors.green,
                  fontWeight: FontWeight.bold,
                  fontSize: 22,
                  letterSpacing: 2,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                context.l10n.friendQrHint,
                textAlign: TextAlign.center,
                style: TextStyle(color: context.colors.textMuted, fontSize: 13),
              ),
            ],
          ),
        ),
      ),
    );

/// Ouvre la caméra et renvoie le code ami (`P4-XXXXXX`) du premier QR qui
/// en contient un, ou `null` si on revient sans.
Future<String?> scanFriendCode(BuildContext context) =>
    Navigator.of(context).push<String>(
      MaterialPageRoute(builder: (_) => const _FriendCodeScanner()),
    );

class _FriendCodeScanner extends StatefulWidget {
  const _FriendCodeScanner();

  @override
  State<_FriendCodeScanner> createState() => _FriendCodeScannerState();
}

class _FriendCodeScannerState extends State<_FriendCodeScanner> {
  var _done = false;

  void _onDetect(BarcodeCapture capture) {
    if (_done) return;
    for (final barcode in capture.barcodes) {
      final code = friendCodeFromScan(barcode.rawValue ?? '');
      if (code != null) {
        _done = true;
        Navigator.of(context).pop(code);
        return;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(context.l10n.friendScanQr),
      ),
      body: Stack(
        fit: StackFit.expand,
        children: [
          MobileScanner(
            onDetect: _onDetect,
            errorBuilder: (context, error) => Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  context.l10n.cameraUnavailable,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
              ),
            ),
          ),
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: context.colors.green, width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          Positioned(
            left: 24,
            right: 24,
            bottom: 48,
            child: Text(
              context.l10n.friendScanHint,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.white, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }
}
