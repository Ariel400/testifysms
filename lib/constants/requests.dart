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


/// Liste de toutes les requêtes SMS disponibles.
/// Ajoutez un SmsRequest dans cette liste pour créer un nouveau bouton.
const List<SmsRequest> kSmsRequests = [
  SmsRequest(
    label: 'Info Compteur',
    description: 'Consulter les informations d\'un compteur client',
    icon: LucideIcons.gauge,
    idApp: '100001',
    intent: 'get_info_compteur',
    payload: 'client=42057051031', // Ce numéro sera écrasé par la saisie utilisateur
  ),
];
