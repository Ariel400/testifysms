import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:intl/intl.dart';

/// Card SMS style Google Messages — fond blanc, avatar coloré, layout épuré.
class MessageCard extends StatelessWidget {
  final SmsMessage message;
  final VoidCallback? onTap;

  const MessageCard({super.key, required this.message, this.onTap});

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return DateFormat('HH:mm').format(date);
    if (msgDay == today.subtract(const Duration(days: 1))) {
      return 'Hier';
    }
    return DateFormat('dd/MM').format(date);
  }

  /// Palette Google — couleur déterministe selon l'expéditeur
  Color _avatarColor(String? address) {
    const colors = [
      Color(0xFF1A73E8), // Google Blue
      Color(0xFF34A853), // Google Green
      Color(0xFFEA4335), // Google Red
      Color(0xFFFBBC05), // Google Yellow
      Color(0xFF9334E6), // Purple
      Color(0xFF00BCD4), // Cyan
    ];
    if (address == null) return colors[0];
    final hash = address.codeUnits.fold(0, (p, e) => p + e);
    return colors[hash % colors.length];
  }

  String _initials(String? address) {
    if (address == null || address.isEmpty) return '?';
    final cleaned = address.replaceAll(RegExp(r'\D'), '');
    if (cleaned.length >= 2) return cleaned.substring(cleaned.length - 2);
    return address[0].toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _avatarColor(message.address);

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // ── Avatar rond coloré ──────────────────────────────────────
            CircleAvatar(
              radius: 24,
              backgroundColor: color,
              child: Text(
                _initials(message.address),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // ── Contenu ─────────────────────────────────────────────────
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          message.address ?? 'Inconnu',
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                            color: Color(0xFF202124),
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatDate(message.date),
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFF5F6368),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Text(
                    message.body ?? '',
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF5F6368),
                      height: 1.4,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
