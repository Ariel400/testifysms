import 'package:flutter/material.dart';

/// Modèle d'une requête SMS pré-configurée vers la passerelle CIE.
class SmsRequest {
  final String label;
  final String description;
  final IconData icon;
  final String idApp;
  final String intent;
  final String payload;

  const SmsRequest({
    required this.label,
    required this.description,
    required this.icon,
    required this.idApp,
    required this.intent,
    required this.payload,
  });

  /// Génère un id_request unique basé sur le timestamp.
  String get _idRequest => 'req-${DateTime.now().millisecondsSinceEpoch}';

  /// Construit le message SMS formaté selon le protocole.
  /// [senderNumber] : le numéro du téléphone qui envoie (+225XXXXXXXXX).
  String buildMessage(String senderNumber) {
    return 'id_app:$idApp;id_request:$_idRequest;number:$senderNumber;intent:$intent;payload:$payload';
  }
}
