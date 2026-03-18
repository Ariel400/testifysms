import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/sms_provider.dart';

class MessageCard extends StatelessWidget {
  final AppSms appSms;
  final VoidCallback? onTap;

  const MessageCard({super.key, required this.appSms, this.onTap});

  String _formatDate(int? timestamp) {
    if (timestamp == null) return '';
    final date = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final msgDay = DateTime(date.year, date.month, date.day);

    if (msgDay == today) return DateFormat('HH:mm').format(date);
    if (msgDay == today.subtract(const Duration(days: 1))) return 'Hier, ${DateFormat('HH:mm').format(date)}';
    return DateFormat('dd MMM HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    final bool isSent = appSms.isSent;
    final message = appSms.message;

    return InkWell(
      onTap: onTap,
      splashColor: Colors.transparent,
      highlightColor: Colors.transparent,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        child: Align(
          alignment: isSent ? Alignment.centerRight : Alignment.centerLeft,
          child: Container(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.75,
            ),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: isSent ? const Color(0xFFFFEDD5) : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(16),
                topRight: const Radius.circular(16),
                bottomLeft: Radius.circular(isSent ? 16 : 4),
                bottomRight: Radius.circular(isSent ? 4 : 16),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  isSent ? 'To: ${message.address ?? "Inconnu"}' : 'From: ${message.address ?? "Inconnu"}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 13,
                    color: isSent ? const Color(0xFF111827) : const Color(0xFF1F2937),
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  message.body ?? '',
                  style: TextStyle(
                    fontSize: 15,
                    color: isSent ? const Color(0xFF111827) : const Color(0xFF1F2937),
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      isSent ? _formatDate(message.date) : 'Status: 200 OK • ${_formatDate(message.date)}',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                        color: isSent ? const Color(0xFF111827).withOpacity(0.5) : const Color(0xFF6B7280),
                      ),
                    ),
                    if (isSent) ...[
                      const SizedBox(width: 4),
                      const Icon(LucideIcons.checkCheck, size: 14, color: Color(0xFF10B981)),
                    ]
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
