import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';
import 'package:permission_handler/permission_handler.dart';
import '../services/sms_service.dart';

/// Provider principal de l'application — gère les permissions et la liste des SMS.
/// Notifie l'interface à chaque changement d'état.
class SmsProvider extends ChangeNotifier {
  final SmsService _smsService = SmsService();
  final Telephony _telephony = Telephony.instance;

  // ─── État ─────────────────────────────────────────────────────────────────

  /// Indique si toutes les permissions SMS sont accordées
  bool _hasPermission = false;
  bool get hasPermission => _hasPermission;

  /// Liste globale combinée
  List<SmsMessage> _messages = [];
  List<SmsMessage> get messages => List.unmodifiable(_messages);

  /// Liste des messages reçus (boîte de réception)
  List<SmsMessage> _inboxMessages = [];
  List<SmsMessage> get inboxMessages => List.unmodifiable(_inboxMessages);

  /// Liste des messages envoyés
  List<SmsMessage> _sentMessages = [];
  List<SmsMessage> get sentMessages => List.unmodifiable(_sentMessages);

  /// Indique un chargement en cours (lecture inbox ou envoi)
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // ─── Initialisation ───────────────────────────────────────────────────────

  /// Initialise le provider : vérification des permissions et chargement initial.
  Future<void> initialize() async {
    await checkAndRequestPermissions();
    if (_hasPermission) {
      await refreshMessages();
      _setupIncomingSmsListener();
    }
  }

  // ─── Permissions ──────────────────────────────────────────────────────────

  /// Vérifie et demande les permissions nécessaires au fonctionnement de l'app.
  Future<void> checkAndRequestPermissions() async {
    final bool? granted = await _telephony.requestPhoneAndSmsPermissions;
    _hasPermission = granted ?? false;

    // Vérification supplémentaire via permission_handler pour READ_SMS
    if (_hasPermission) {
      final readStatus = await Permission.sms.status;
      _hasPermission = readStatus.isGranted;
    }

    notifyListeners();
  }

  // ─── Chargement des messages (Boîte + Envoyés) ──────────────────────────

  /// Recharge les messages reçus ET envoyés, puis les trie par date du plus récent au plus ancien.
  Future<void> refreshMessages() async {
    _isLoading = true;
    notifyListeners();

    try {
      final inbox = await _smsService.getInboxMessages();
      final sent = await _smsService.getSentMessages();

      // Fusion et tri par date (descendant)
      final allMessages = [...inbox, ...sent];
      allMessages.sort((a, b) {
        final aDate = a.date ?? 0;
        final bDate = b.date ?? 0;
        return bDate.compareTo(aDate);
      });

      _messages = allMessages;
      _inboxMessages = inbox;
      _sentMessages = sent;
    } catch (e) {
      debugPrint('Erreur lors du rafraîchissement : $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ─── Écoute en temps réel ─────────────────────────────────────────────────

  /// Configure l'écoute des SMS entrants — met à jour la liste en temps réel.
  void _setupIncomingSmsListener() {
    _smsService.listenForIncomingSms(
      onNewMessage: (SmsMessage message) {
        // Ajout du nouveau message en tête de liste
        _messages = [message, ..._messages];
        _inboxMessages = [message, ..._inboxMessages];
        notifyListeners();
      },
    );
  }

  // ─── Envoi de SMS ─────────────────────────────────────────────────────────

  /// Envoie un SMS, l'ajoute temporairement à la liste, puis retourne [true] en cas de succès.
  Future<bool> sendSms({required String to, required String message}) async {
    // Envoi réel
    final success = await _smsService.sendSms(to: to, message: message);

    // Rafraîchissement pour récupérer le statut final (Failed/Sent) depuis le système
    await refreshMessages();

    return success;
  }

  // ─── Ajout manuel (pour tests / réception) ───────────────────────────────

  /// Ajoute un message directement à la liste (utile pour reflèter l'envoi).
  void addMessage(SmsMessage message) {
    _messages = [message, ..._messages];
    _sentMessages = [message, ..._sentMessages];
    notifyListeners();
  }
}
