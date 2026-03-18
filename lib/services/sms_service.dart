import 'package:flutter/material.dart';
import 'package:telephony/telephony.dart';

/// Service SMS — couche business logic isolée de l'interface.
/// Toutes les interactions avec le package [telephony] passent par ici.
class SmsService {
  final Telephony _telephony = Telephony.instance;

  // ─── Envoi de SMS ────────────────────────────────────────────────────────

  /// Envoie un SMS au numéro [to] avec le contenu [message].
  /// Retourne [true] si l'envoi a réussi, [false] sinon.
  Future<bool> sendSms({
    required String to,
    required String message,
  }) async {
    try {
      await _telephony.sendSms(
        to: to,
        message: message,
      );
      return true; // Si aucune exception n'est levée, on considère que l'intention d'envoi est validée
    } catch (e) {
      debugPrint('Erreur lors de l\'envoi : $e');
      return false;
    }
  }

  // ─── Lecture de la boîte de réception ────────────────────────────────────

  /// Retourne la liste des SMS présents dans la boîte de réception,
  /// triés du plus récent au plus ancien.
  Future<List<SmsMessage>> getInboxMessages() async {
    try {
      final List<SmsMessage> messages = await _telephony.getInboxSms(
        columns: [
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
        ],
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        ],
      );
      return messages;
    } catch (e) {
      debugPrint('Erreur lecture boîte de réception : $e');
      return [];
    }
  }

  // ─── Lecture des messages envoyés ────────────────────────────────────────

  /// Retourne la liste des SMS envoyés, triés du plus récent au plus ancien.
  Future<List<SmsMessage>> getSentMessages() async {
    try {
      final List<SmsMessage> messages = await _telephony.getSentSms(
        columns: [
          SmsColumn.ADDRESS,
          SmsColumn.BODY,
          SmsColumn.DATE,
          SmsColumn.STATUS,
        ],
        sortOrder: [
          OrderBy(SmsColumn.DATE, sort: Sort.DESC),
        ],
      );
      return messages;
    } catch (e) {
      debugPrint('Erreur lecture messages envoyés : $e');
      return [];
    }
  }

  // ─── Écoute des SMS entrants (temps réel) ────────────────────────────────

  /// Configure l'écoute des SMS entrants.
  /// [onNewMessage] est appelé à chaque nouveau SMS reçu.
  void listenForIncomingSms({
    required void Function(SmsMessage message) onNewMessage,
  }) {
    _telephony.listenIncomingSms(
      onNewMessage: onNewMessage,
      // Handler exécuté en arrière-plan (isolate séparé)
      onBackgroundMessage: backgroundMessageHandler,
    );
  }
}

/// Handler de réception SMS en arrière-plan.
/// Doit être une fonction top-level (pas une méthode de classe).
@pragma('vm:entry-point')
void backgroundMessageHandler(SmsMessage message) {
  // Ce handler s'exécute dans un isolate séparé.
  // On se contente de logger — la mise à jour de l'UI se fait
  // côté foreground via listenIncomingSms.
  debugPrint('SMS en arrière-plan reçu de : ${message.address}');
}
