import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/sms_provider.dart';

/// Écran affiché lorsque les permissions SMS sont refusées — style Google.
class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 48),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // ── Icône principale ──────────────────────────────────────
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 600),
                curve: Curves.easeOutBack,
                builder: (_, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F0FE),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.lock_outline_rounded,
                    size: 44,
                    color: Color(0xFF1A73E8),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                'Autorisation requise',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF202124),
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              const Text(
                'TestifySMS a besoin d\'accéder à vos SMS pour envoyer et recevoir des messages.',
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF5F6368),
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 36),

              // ── Permissions listées ───────────────────────────────────
              ...[
                ('Envoyer des SMS', Icons.send_rounded),
                ('Lire la boîte de réception', Icons.inbox_rounded),
                ('Recevoir en temps réel', Icons.notifications_rounded),
              ].map(
                (item) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Row(
                    children: [
                      Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F0FE),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item.$2,
                            size: 18, color: const Color(0xFF1A73E8)),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        item.$1,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF202124),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 48),

              // ── Bouton ───────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () =>
                      context.read<SmsProvider>().checkAndRequestPermissions(),
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFF1A73E8),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(28),
                    ),
                  ),
                  child: const Text(
                    'Accorder les permissions',
                    style: TextStyle(
                      fontSize: 15,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              const Text(
                'Vos données restent sur votre appareil.',
                style: TextStyle(fontSize: 12, color: Color(0xFF9AA0A6)),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
