import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:provider/provider.dart';
import '../providers/sms_provider.dart';
import '../constants/requests.dart';
import '../models/sms_request.dart';
import '../widgets/message_card.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  bool _sending = false;
  SmsRequest? _selected;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SmsProvider>().refreshMessages();
    });
  }

  Future<void> _send() async {
    final request = _selected;
    if (request == null) return;

    final sender = kSenderNumber;
    if (sender.isEmpty) {
      _showSnackBar('SENDER_NUMBER non configuré dans .env', false);
      return;
    }

    setState(() => _sending = true);
    try {
      final message = request.buildMessage(sender);
      final ok = await context.read<SmsProvider>().sendSms(
            to: kGatewayNumber,
            message: message,
          );
      if (!mounted) return;
      _showSnackBar(
        ok ? '${request.label} envoyé ✓' : 'Échec de l\'envoi',
        ok,
      );
      if (ok) setState(() => _selected = null);
    } catch (e) {
      if (mounted) _showSnackBar('Erreur : $e', false);
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _showSnackBar(String msg, bool success) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        backgroundColor:
            success ? const Color(0xFF1E7E34) : const Color(0xFFEF4444),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        content: Row(
          children: [
            Icon(
              success ? LucideIcons.checkCircle : LucideIcons.alertCircle,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(msg,
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w500)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: _buildAppBar(),
      body: Column(
        children: [
          _buildInfoBanner(),
          _buildResponseHeader(),
          Expanded(
            flex: 3,
            child: _buildResponseFeed(),
          ),
          _buildIntentsHeader(),
          Expanded(
            flex: 4,
            child: _buildIntentList(),
          ),
          _buildSendButton(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      surfaceTintColor: Colors.transparent,
      title: const Row(
        children: [
          Icon(LucideIcons.messageSquare, color: Color(0xFFF97316), size: 24),
          SizedBox(width: 10),
          Text(
            'Passerelle SMS CIE',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF111827),
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 1, color: const Color(0xFFE5E7EB)),
      ),
    );
  }

  Widget _buildInfoBanner() {
    final sender = kSenderNumber;
    final gateway = kGatewayNumber;
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: _InfoChip(
              icon: LucideIcons.smartphoneNfc,
              label: 'Expéditeur',
              value: sender.isEmpty ? 'Non configuré' : sender,
              valueColor: sender.isEmpty
                  ? const Color(0xFFEF4444)
                  : const Color(0xFF111827),
            ),
          ),
          const SizedBox(width: 12),
          const Icon(LucideIcons.arrowRight,
              size: 16, color: Color(0xFF9CA3AF)),
          const SizedBox(width: 12),
          Expanded(
            child: _InfoChip(
              icon: LucideIcons.serverCrash,
              label: 'Passerelle',
              value: gateway,
              valueColor: const Color(0xFF111827),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseHeader() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          const Icon(LucideIcons.messagesSquare,
              size: 15, color: Color(0xFF6B7280)),
          const SizedBox(width: 8),
          const Text(
            'Réponses du serveur',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280)),
          ),
          const Spacer(),
          Consumer<SmsProvider>(
            builder: (_, provider, __) => GestureDetector(
              onTap: provider.isLoading ? null : provider.refreshMessages,
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: const Color(0xFFF3F4F6),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: provider.isLoading
                    ? const SizedBox(
                        width: 14,
                        height: 14,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Color(0xFF6B7280)))
                    : const Icon(LucideIcons.refreshCcw,
                        size: 14, color: Color(0xFF6B7280)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildResponseFeed() {
    return Container(
      color: const Color(0xFFF9FAFB),
      child: Consumer<SmsProvider>(
        builder: (context, provider, _) {
          if (provider.messages.isEmpty) {
            return const _EmptyResponseState();
          }
          return ListView.builder(
            reverse: true,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            itemCount: provider.messages.length,
            itemBuilder: (context, index) =>
                MessageCard(appSms: provider.messages[index]),
          );
        },
      ),
    );
  }

  Widget _buildIntentsHeader() {
    return Container(
      width: double.infinity,
      color: const Color(0xFFF9FAFB),
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: const Row(
        children: [
          Icon(LucideIcons.list, size: 15, color: Color(0xFF6B7280)),
          SizedBox(width: 8),
          Text(
            'Sélectionnez une requête',
            style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: Color(0xFF6B7280)),
          ),
        ],
      ),
    );
  }

  Widget _buildIntentList() {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      itemCount: kSmsRequests.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, i) {
        final req = kSmsRequests[i];
        final isSelected = _selected == req;
        return _IntentRow(
          request: req,
          isSelected: isSelected,
          onTap: () => setState(() => _selected = isSelected ? null : req),
        );
      },
    );
  }

  Widget _buildSendButton() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 32),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: FilledButton.icon(
          onPressed: (_selected == null || _sending) ? null : _send,
          style: FilledButton.styleFrom(
            backgroundColor: Colors.black,
            disabledBackgroundColor: const Color(0xFFE5E7EB),
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          ),
          icon: _sending
              ? const SizedBox(
                  width: 18,
                  height: 18,
                  child: CircularProgressIndicator(
                      strokeWidth: 2, color: Colors.white))
              : const Icon(LucideIcons.send, size: 18, color: Colors.white),
          label: Text(
            _selected == null
                ? 'Aucune requête sélectionnée'
                : 'Envoyer — ${_selected!.label}',
            style: TextStyle(
              color: _selected == null ? const Color(0xFF9CA3AF) : Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}

// ── Ligne d'intent (liste) ─────────────────────────────────────────────────

class _IntentRow extends StatelessWidget {
  final SmsRequest request;
  final bool isSelected;
  final VoidCallback onTap;

  const _IntentRow({
    required this.request,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: request.label,
      hint: request.description,
      selected: isSelected,
      button: true,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFFFFF7ED) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color:
                isSelected ? const Color(0xFFF97316) : const Color(0xFFE5E7EB),
            width: isSelected ? 2 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: const Color(0xFFF97316).withOpacity(0.12),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  )
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.03),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
        ),
        child: ListTile(
          contentPadding:
              const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          onTap: onTap,
          leading: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: isSelected
                  ? const Color(0xFFFFEDD5)
                  : const Color(0xFFF3F4F6),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              request.icon,
              size: 22,
              color: isSelected
                  ? const Color(0xFFF97316)
                  : const Color(0xFF6B7280),
            ),
          ),
          title: Text(
            request.label,
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 14,
              color: isSelected
                  ? const Color(0xFF111827)
                  : const Color(0xFF374151),
            ),
          ),
          subtitle: Text(
            request.description,
            style: const TextStyle(
                fontSize: 12, color: Color(0xFF6B7280), height: 1.4),
          ),
          trailing: AnimatedSwitcher(
            duration: const Duration(milliseconds: 200),
            child: isSelected
                ? const Icon(LucideIcons.checkCircle,
                    key: ValueKey('check'), color: Color(0xFFF97316), size: 22)
                : const Icon(LucideIcons.circle,
                    key: ValueKey('empty'), color: Color(0xFFE5E7EB), size: 22),
          ),
        ),
      ),
    );
  }
}

// ── Chip info d'en-tête ────────────────────────────────────────────────────

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color valueColor;

  const _InfoChip({
    required this.icon,
    required this.label,
    required this.value,
    required this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: const Color(0xFFF9FAFB),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: const Color(0xFFE5E7EB)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: const Color(0xFF9CA3AF)),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 10, color: Color(0xFF9CA3AF))),
                Text(
                  value,
                  style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: valueColor),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── État vide ──────────────────────────────────────────────────────────────

class _EmptyResponseState extends StatelessWidget {
  const _EmptyResponseState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: const Color(0xFFF3F4F6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFE5E7EB)),
            ),
            child: const Icon(LucideIcons.serverOff,
                size: 30, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 14),
          const Text('Aucune réponse',
              style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151))),
          const SizedBox(height: 4),
          const Text('Les réponses de la passerelle\napparaîtront ici.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 12, color: Color(0xFF6B7280), height: 1.5)),
        ],
      ),
    );
  }
}
