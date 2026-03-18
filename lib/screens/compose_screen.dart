import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/sms_provider.dart';

/// Écran de rédaction et d'envoi de SMS.
class ComposeScreen extends StatefulWidget {
  const ComposeScreen({super.key});

  @override
  State<ComposeScreen> createState() => _ComposeScreenState();
}

class _ComposeScreenState extends State<ComposeScreen> {
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
        content: Text(msg),
        backgroundColor:
            success ? const Color(0xFF1E7E34) : const Color(0xFFD93025),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        title: const Text(
          'Nouveau message',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.w400,
            color: Color(0xFF202124),
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: const Color(0xFFE8EAED)),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              // ── Champ : Destinataire ────────────────────────────────────
              _RecipientField(
                  controller: _phoneController, validator: _validatePhone),

              const Divider(height: 1, color: Color(0xFFE8EAED)),

              // ── Champ : Message (zone centrale) ────────────────────────
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: TextFormField(
                    controller: _messageController,
                    validator: _validateMessage,
                    maxLines: null,
                    expands: true,
                    textAlignVertical: TextAlignVertical.top,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF202124),
                      height: 1.5,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Rédigez un message…',
                      hintStyle:
                          TextStyle(color: Color(0xFF9AA0A6), fontSize: 16),
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      errorBorder: InputBorder.none,
                      focusedErrorBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ),

              // ── Barre du bas : compteur + bouton ───────────────────────
              Container(
                decoration: const BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Color(0xFFE8EAED)),
                  ),
                  color: Colors.white,
                ),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    // Compteur de caractères
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
                      child: Text('$_charCount / $_smsMax'),
                    ),
                    const Spacer(),
                    // Bouton envoyer
                    AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: _isSending
                          ? const SizedBox(
                              key: ValueKey('loading'),
                              width: 44,
                              height: 44,
                              child: Center(
                                child: SizedBox(
                                  width: 22,
                                  height: 22,
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
                                minimumSize: const Size(44, 44),
                                shape: const CircleBorder(),
                              ),
                              icon: const Icon(Icons.send_rounded, size: 20),
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
}

// ─── Champ destinataire ────────────────────────────────────────────────────────

class _RecipientField extends StatelessWidget {
  final TextEditingController controller;
  final String? Function(String?) validator;

  const _RecipientField({required this.controller, required this.validator});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          const Icon(Icons.person_outline_rounded,
              color: Color(0xFF5F6368), size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: TextFormField(
              controller: controller,
              validator: validator,
              keyboardType: TextInputType.phone,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9+\s\-]')),
              ],
              style: const TextStyle(
                fontSize: 16,
                color: Color(0xFF202124),
              ),
              decoration: const InputDecoration(
                hintText: 'À : numéro de téléphone',
                hintStyle: TextStyle(color: Color(0xFF9AA0A6), fontSize: 16),
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                errorBorder: InputBorder.none,
                focusedErrorBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.symmetric(vertical: 12),
              ),
              textInputAction: TextInputAction.next,
            ),
          ),
        ],
      ),
    );
  }
}
