import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/sms_provider.dart';
import '../widgets/message_card.dart';

class InboxScreen extends StatefulWidget {
  const InboxScreen({super.key});

  @override
  State<InboxScreen> createState() => _InboxScreenState();
}

class _InboxScreenState extends State<InboxScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _messageController = TextEditingController();
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<SmsProvider>().refreshMessages();
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String? _validatePhone(String? v) {
    if (v == null || v.trim().isEmpty) return 'Requis';
    if (!RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(v.trim())) return 'Invalide';
    return null;
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    if (_messageController.text.trim().isEmpty) return;

    setState(() => _isSending = true);

    try {
      final ok = await context.read<SmsProvider>().sendSms(
            to: _phoneController.text.trim(),
            message: _messageController.text.trim(),
          );
      if (!mounted) return;
      if (ok) {
        _messageController.clear();
      } else {
        _showSnackBar('Échec de l\'envoi', false);
      }
    } catch (e) {
      if (mounted) _showSnackBar('Erreur : $e', false);
    } finally {
      if (mounted) setState(() => _isSending = false);
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
            Icon(success ? LucideIcons.checkCircle : LucideIcons.alertCircle,
                color: Colors.white, size: 20),
            const SizedBox(width: 12),
            Expanded(
                child: Text(msg,
                    style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.w500))),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: Row(
          children: [
            // IconButton(
            //   icon: const Icon(LucideIcons.arrowLeft, size: 24, color: Color(0xFF111827)),
            //   onPressed: () {},
            // ),
            const SizedBox(width: 4),
            const Text('Testify SMS',
                style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF111827))),
            const SizedBox(width: 12),
            // Container(
            //   padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            //   decoration: BoxDecoration(
            //       color: const Color(0xFF10B981).withOpacity(0.15),
            //       borderRadius: BorderRadius.circular(20)),
            //   child: const Row(
            //     children: [
            //       Icon(Icons.circle, color: Color(0xFF10B981), size: 8),
            //       // Text('API En ligne',
            //       //     style: TextStyle(
            //       //         color: Color(0xFF10B981),
            //       //         fontSize: 12,
            //       //         fontWeight: FontWeight.w600)),
            //     ],
            //   ),
            // ),
          ],
        ),
        // actions: [
        //   IconButton(
        //       icon: const Icon(LucideIcons.settings, color: Color(0xFF111827)),
        //       onPressed: () {}),
        //   const SizedBox(width: 8),
        // ],
        bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE5E7EB))),
      ),
      body: Column(
        children: [
          Expanded(
            child: Consumer<SmsProvider>(
              builder: (context, provider, _) {
                if (provider.isLoading && provider.messages.isEmpty) {
                  return const Center(
                      child: CircularProgressIndicator(color: Colors.black));
                }
                if (provider.messages.isEmpty) return const _EmptyState();

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(vertical: 24),
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final appSms = provider.messages[index];
                    return MessageCard(appSms: appSms);
                  },
                );
              },
            ),
          ),
          _buildBottomInput(),
        ],
      ),
    );
  }

  Widget _buildBottomInput() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Phone Number Input
                Container(
                  height: 44,
                  decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(16)),
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.phone,
                          size: 18, color: Color(0xFF6B7280)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextFormField(
                          controller: _phoneController,
                          validator: _validatePhone,
                          keyboardType: TextInputType.phone,
                          style: const TextStyle(
                              fontSize: 15, color: Color(0xFF111827)),
                          decoration: const InputDecoration(
                            hintText: 'Numéro de téléphone cible',
                            hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 15),
                            border: InputBorder.none,
                            errorStyle: TextStyle(height: 0, fontSize: 0),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                // Message Input + Send Button
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 16, vertical: 8),
                        child: TextFormField(
                          controller: _messageController,
                          minLines: 1,
                          maxLines: 4,
                          style: const TextStyle(
                              fontSize: 15,
                              color: Color(0xFF111827),
                              height: 1.4),
                          decoration: const InputDecoration(
                            hintText: 'Saisissez votre SMS de test...',
                            hintStyle: TextStyle(
                                color: Color(0xFF9CA3AF), fontSize: 15),
                            border: InputBorder.none,
                            isDense: true,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      height: 48,
                      width: 48,
                      decoration: BoxDecoration(
                          color: Colors.black,
                          borderRadius: BorderRadius.circular(12)),
                      child: IconButton(
                        onPressed: _isSending ? null : _send,
                        icon: _isSending
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2.5, color: Colors.white))
                            : const Icon(LucideIcons.send,
                                color: Colors.white, size: 18),
                      ),
                    ),
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

class _EmptyState extends StatelessWidget {
  const _EmptyState();
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                      color: Colors.black.withOpacity(0.04),
                      blurRadius: 10,
                      offset: const Offset(0, 4))
                ]),
            child: const Icon(LucideIcons.messageSquareDashed,
                size: 48, color: Color(0xFF9CA3AF)),
          ),
          const SizedBox(height: 24),
          const Text('Aucun message',
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF374151))),
          const SizedBox(height: 8),
          const Text(
              'Les tests envoyés et reçus\napparaîtront dans ce fil de discussion.',
              textAlign: TextAlign.center,
              style: TextStyle(
                  fontSize: 14, color: Color(0xFF6B7280), height: 1.5)),
        ],
      ),
    );
  }
}
