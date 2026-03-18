import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/sms_request.dart';

/// Numéro de la passerelle SMS (destinataire fixe), lu depuis le fichier .env.
String get kGatewayNumber {
  try {
    return dotenv.env['GATEWAY_NUMBER'] ?? '0574386145';
  } catch (_) {
    return '0574386145';
  }
}

/// Numéro expéditeur (le téléphone de l'utilisateur), lu depuis le fichier .env.
String get kSenderNumber {
  try {
    return dotenv.env['SENDER_NUMBER'] ?? '+2250102030405';
  } catch (_) {
    return '+2250102030405';
  }
}

/// Liste de toutes les requêtes SMS disponibles.
/// Ajoutez un SmsRequest dans cette liste pour créer un nouveau bouton.
const List<SmsRequest> kSmsRequests = [
  // ───  (id_app: 100001) ───────────────────────────────────────────────

  SmsRequest(
    label: 'Info Compteur',
    description: 'Consulter les informations d\'un compteur client',
    icon: LucideIcons.gauge,
    idApp: '100001',
    intent: 'get_info_compteur',
    payload: 'client=42057051031',
  ),

  SmsRequest(
    label: 'Solde Client',
    description: 'Consulter le solde d\'un compte client',
    icon: LucideIcons.wallet,
    idApp: '100001',
    intent: 'get_solde_client',
    payload: 'client=42057051031',
  ),

  SmsRequest(
    label: 'Historique Conso',
    description: 'Historique de consommation du client',
    icon: LucideIcons.barChart2,
    idApp: '100001',
    intent: 'get_historique_conso',
    payload: 'client=42057051031',
  ),

  SmsRequest(
    label: 'Facture en cours',
    description: 'Consulter la facture courante du client',
    icon: LucideIcons.fileText,
    idApp: '100001',
    intent: 'get_facture_courante',
    payload: 'client=42057051031',
  ),
];
