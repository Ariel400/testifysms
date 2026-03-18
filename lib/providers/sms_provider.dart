import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sms_service.dart';

/// Structure enveloppant un SMS pour savoir s'il a été envoyé ou reçu.
class AppSms {
  final SmsMessage message;
  final bool isSent;

  AppSms({required this.message, required this.isSent});
}

/// Provider principal de l'application — gère les permissions et la liste unifiée des SMS.
class SmsProvider extends ChangeNotifier {
  final SmsService _smsService = SmsService();
  final Telephony _telephony = Telephony.instance;

  // ─── État ─────────────────────────────────────────────────────────────────

  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  /// Liste globale combinée et triée des SMS (Chat View)
  List<AppSms> _messages = [];
  List<AppSms> get messages => List.unmodifiable(_messages);

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Initialisation ───────────────────────────────────────────────────────

  Future<void> initialize() async {
    await checkAndRequestPermissions();
    if (_hasPermission) {
      await refreshMessages();
      _setupIncomingSmsListener();
    }
  }

  // ─── Permissions ──────────────────────────────────────────────────────────

  Future<void> checkAndRequestPermissions() async {
    final bool? granted = await _telephony.requestPhoneAndSmsPermissions;
    _hasPermission = granted ?? false;

    if (_hasPermission) {
      final readStatus = await Permission.sms.status;
      _hasPermission = readStatus.isGranted;
    }

    notifyListeners();
  }

  // ─── Chargement des messages (Boîte + Envoyés) ──────────────────────────

  Future<void> refreshMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final inbox = await _smsService.getInboxMessages();
      final sent = await _smsService.getSentMessages();

      // Mapping vers le wrapper AppSms
      final inboxAppSms = inbox.map((m) => AppSms(message: m, isSent: false)).toList();
      final sentAppSms = sent.map((m) => AppSms(message: m, isSent: true)).toList();

      // Fusion et tri par date (descendant, le plus récent en premier)
      final allMessages = [...inboxAppSms, ...sentAppSms];
      allMessages.sort((a, b) {
        final aDate = a.message.date ?? 0;
        final bDate = b.message.date ?? 0;
        return bDate.compareTo(aDate);
      });

      _messages = allMessages;
    } catch (e) {
      debugPrint('Erreur lors du rafraîchissement : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Écoute en temps réel ─────────────────────────────────────────────────

  void _setupIncomingSmsListener() {
    _smsService.listenForIncomingSms(
      onNewMessage: (SmsMessage message) {
        // Ajout du nouveau message en tête de liste (reçu)
        _messages = [AppSms(message: message, isSent: false), ..._messages];
        notifyListeners();
      },
    );
  }

  // ─── Envoi de SMS ─────────────────────────────────────────────────────────

  Future<bool> sendSms({required String to, required String message}) async {
    final success = await _smsService.sendSms(to: to, message: message);

    // Rafraîchissement pour insérer le nouveau message envoyé dans le flux
    await refreshMessages();

    return success;
  }
}
