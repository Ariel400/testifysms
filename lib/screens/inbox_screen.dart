import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/sms_provider.dart';
import '../widgets/message_card.dart';

/// Écran contenant la composition et la boîte de réception
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
  int _charCount = 0;
  static const int _smsMax = 160;

  @override
  void initState() {
    super.initState();
    _messageController.addListener(
      () => setState(() => _charCount = _messageController.text.length),
    );
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
    if (v == null || v.trim().isEmpty) return 'Numéro requis';
    if (!RegExp(r'^\+?[0-9\s\-]{7,15}$').hasMatch(v.trim())) {
      return 'Format invalide (ex: +33612345678)';
    }
    return null;
  }

  String? _validateMessage(String? v) {
    if (v == null || v.trim().isEmpty) return 'Message requis';
    return null;
  }

  Future<void> _send() async {
    FocusScope.of(context).unfocus();
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSending = true);

    try {
      final ok = await context.read<SmsProvider>().sendSms(
            to: _phoneController.text.trim(),
            message: _messageController.text.trim(),
          );
      if (!mounted) return;
      _showSnackBar(
        ok ? 'SMS envoyé ✓' : 'Échec de l\'envoi',
        ok,
      );
      if (ok) {
        _formKey.currentState!.reset();
        _phoneController.clear();
        _messageController.clear();
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
        backgroundColor: success ? const Color(0xFF1E7E34) : const Color(0xFFD93025),
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
              child: Text(msg, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w500)),
            ),
          ],
        ),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
          title: const Row(
            children: [
              Icon(LucideIcons.messageSquare, color: Color(0xFF1A73E8), size: 26),
              SizedBox(width: 10),
              Text(
                'TestifySMS',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF202124),
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Consumer<SmsProvider>(
                builder: (_, provider, __) => GestureDetector(
                  onTap: provider.isLoading ? null : provider.refreshMessages,
                  child: CircleAvatar(
                    radius: 18,
                    backgroundColor: const Color(0xFF1A73E8),
                    child: provider.isLoading
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            LucideIcons.refreshCcw,
                            color: Colors.white,
                            size: 16,
                          ),
                  ),
                ),
              ),
            ),
          ],
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(1),
            child: Container(height: 1, color: const Color(0xFFE8EAED)),
          ),
        ),
        body: Column(
          children: [
            // 1. Zone de rédaction et envoi
            _buildComposeForm(),

            // 2. Les Tabs (Reçus / Envoyés)
            const TabBar(
              indicatorColor: Color(0xFF1A73E8),
              labelColor: Color(0xFF1A73E8),
              unselectedLabelColor: Color(0xFF5F6368),
              labelStyle: TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
              unselectedLabelStyle:
                  TextStyle(fontSize: 15, fontWeight: FontWeight.w400),
              indicatorWeight: 3,
              tabs: [
                Tab(text: 'Reçus'),
                Tab(text: 'Envoyés'),
              ],
            ),

            // 3. Les Vues par Tab
            Expanded(
              child: Consumer<SmsProvider>(
                builder: (context, provider, _) {
                  if (provider.isLoading && provider.messages.isEmpty) {
                    return const Center(
                      child: CircularProgressIndicator(
                        color: Color(0xFF1A73E8),
                        strokeWidth: 2.5,
                      ),
                    );
                  }

                  return TabBarView(
                    children: [
                      _buildMessageList(provider, provider.inboxMessages,
                          isInbox: true),
                      _buildMessageList(provider, provider.sentMessages,
                          isInbox: false),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildComposeForm() {
    return Container(
      margin: const EdgeInsets.only(left: 16, right: 16, top: 16, bottom: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: const Color(0xFFE8EAED), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // Champ Destinataire
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: Row(
                  children: [
                    const Icon(LucideIcons.user,
                        color: Color(0xFF5F6368), size: 18),
                    const SizedBox(width: 12),
                    Expanded(
                      child: TextFormField(
                        controller: _phoneController,
                        validator: _validatePhone,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(
                              RegExp(r'[0-9+\s\-]')),
                        ],
                        style: const TextStyle(
                          fontSize: 15,
                          color: Color(0xFF202124),
                        ),
                        decoration: const InputDecoration(
                          hintText: 'À : numéro de téléphone',
                          hintStyle:
                              TextStyle(color: Color(0xFF9AA0A6), fontSize: 15),
                          border: InputBorder.none,
                          enabledBorder: InputBorder.none,
                          focusedBorder: InputBorder.none,
                          errorBorder: InputBorder.none,
                          focusedErrorBorder: InputBorder.none,
                          filled: false,
                          isDense: true,
                          contentPadding: EdgeInsets.symmetric(vertical: 12),
                        ),
                        textInputAction: TextInputAction.next,
                      ),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1, color: Color(0xFFE8EAED)),

              // Champ Message
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: TextFormField(
                  controller: _messageController,
                  validator: _validateMessage,
                  minLines: 1,
                  maxLines: 4,
                  textAlignVertical: TextAlignVertical.top,
                  style: const TextStyle(
                    fontSize: 15,
                    color: Color(0xFF202124),
                    height: 1.4,
                  ),
                  decoration: const InputDecoration(
                    hintText: 'Rédigez un message…',
                    hintStyle:
                        TextStyle(color: Color(0xFF9AA0A6), fontSize: 15),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    focusedErrorBorder: InputBorder.none,
                    filled: false,
                    isDense: true,
                    contentPadding: EdgeInsets.zero,
                  ),
                ),
              ),

              // Barre du bas compteur + bouton
              Container(
                decoration: const BoxDecoration(
                  color: Color(0xFFF8F9FA),
                  border: Border(
                    top: BorderSide(color: Color(0xFFE8EAED)),
                  ),
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Row(
                  children: [
                    AnimatedDefaultTextStyle(
                      duration: const Duration(milliseconds: 150),
                      style: TextStyle(
                        fontSize: 12,
                        color: _charCount > _smsMax
                            ? const Color(0xFFD93025)
                            : const Color(0xFF5F6368),
                        fontWeight: _charCount > _smsMax
                            ? FontWeight.w600
                            : FontWeight.normal,
                      ),
                      child: Text('$_charCount / $_smsMax chars'),
                    ),
                    const Spacer(),
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isSending
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 36,
                              height: 36,
                              child: Center(
                                child: SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.5,
                                    color: Color(0xFF1A73E8),
                                  ),
                                ),
                              ),
                            )
                          : IconButton.filled(
                              key: const ValueKey('send'),
                              onPressed: _send,
                              style: IconButton.styleFrom(
                                backgroundColor: const Color(0xFF1A73E8),
                                foregroundColor: Colors.white,
                                minimumSize: const Size(36, 36),
                                padding: EdgeInsets.zero,
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(LucideIcons.send, size: 18),
                              tooltip: 'Envoyer',
                            ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMessageList(SmsProvider provider, List<dynamic> messagesList,
      {required bool isInbox}) {
    if (messagesList.isEmpty) {
      return _EmptyState(isInbox: isInbox);
    }

    return RefreshIndicator(
      onRefresh: provider.refreshMessages,
      color: const Color(0xFF1A73E8),
      child: ListView.separated(
        padding: const EdgeInsets.only(top: 4, bottom: 80),
        itemCount: messagesList.length,
        separatorBuilder: (_, __) => const Divider(
          height: 1,
          indent: 72,
          endIndent: 0,
          color: Color(0xFFE8EAED),
        ),
        itemBuilder: (context, index) {
          return MessageCard(
            message: messagesList[index],
            onTap: () => _showDetail(context, messagesList[index]),
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext context, dynamic message) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.5,
        minChildSize: 0.35,
        maxChildSize: 0.9,
        builder: (_, ctrl) => Column(
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 12),
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDADCE0),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 22,
                    backgroundColor: const Color(0xFF1A73E8),
                    child: Text(
                      (message.address ?? '?').length >= 2
                          ? message.address!
                              .replaceAll(RegExp(r'\D'), '')
                              .padLeft(2, '0')
                              .substring((message.address!
                                          .replaceAll(RegExp(r'\D'), '')
                                          .length -
                                      2)
                                  .clamp(0, 999))
                          : '?',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          fontSize: 13),
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          message.address ?? 'Inconnu',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF202124),
                          ),
                        ),
                        Text(
                          message.date != null ? DateFormat('dd MMM yyyy à HH:mm').format(DateTime.fromMillisecondsSinceEpoch(message.date!)) : '',
                          style: const TextStyle(
                            fontSize: 12,
                            color: Color(0xFF5F6368),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const Divider(height: 1, color: Color(0xFFE8EAED)),
            Expanded(
              child: SingleChildScrollView(
                controller: ctrl,
                padding: const EdgeInsets.all(24),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F0FE),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                      bottomRight: Radius.circular(20),
                      bottomLeft: Radius.circular(4),
                    ),
                  ),
                  child: Text(
                    message.body ?? '',
                    style: const TextStyle(
                      fontSize: 15,
                      color: Color(0xFF202124),
                      height: 1.6,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  final bool isInbox;

  const _EmptyState({required this.isInbox});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              color: const Color(0xFFE8F0FE).withOpacity(0.6),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFFD2E3FC), width: 1.5),
            ),
            child: const Icon(
              LucideIcons.messageCircle,
              size: 40,
              color: Color(0xFF1A73E8),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Aucun message',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Color(0xFF202124),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            isInbox ? 'Les SMS reçus apparaîtront ici.' : 'Les SMS envoyés apparaîtront ici.',
            style: const TextStyle(fontSize: 14, color: Color(0xFF5F6368)),
          ),
          const SizedBox(height: 28),
          TextButton.icon(
            onPressed: context.read<SmsProvider>().refreshMessages,
            icon: const Icon(LucideIcons.refreshCw, color: Color(0xFF1A73E8), size: 18),
            label: const Text(
              'Actualiser',
              style: TextStyle(color: Color(0xFF1A73E8), fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
