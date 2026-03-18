# TestifySMS — Application de test SMS

Application Flutter pour envoyer et recevoir des SMS de test, avec une interface inspirée de Google Messages.

## 🚀 Fonctionnalités

- **Envoi de SMS** : Formulaire avec validation et compteur de caractères
- **Boîte de réception** : Liste des SMS reçus avec détails
- **Historique** : Onglet pour les SMS envoyés
- **Notifications** : Alertes visuelles pour l'envoi et la réception
- **Actualisation** : Bouton pour rafraîchir la liste des messages

## 🛠️ Installation

### Prérequis

- Flutter SDK installé
- Android Studio ou VS Code avec extensions Flutter
- Accès root ou émulateur Android pour les permissions SMS

### Étapes

1. Cloner le dépôt :
   ```bash
   git clone <url-du-dépôt>
   cd testifysms
   ```

2. Installer les dépendances :
   ```bash
   flutter pub get
   ```

3. Lancer l'application :
   ```bash
   flutter run
   ```

## 📱 Permissions Android

Pour que l'application fonctionne correctement, vous devez accorder les permissions SMS :

```xml
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

Sur les appareils Android récents, vous devrez également définir l'application comme application SMS par défaut pour recevoir les messages.

## 🎨 Design

L'application utilise les couleurs et composants suivants :

- **Couleurs principales** :
  - Bleu Google : `#1A73E8`
  - Vert Google : `#34A853`
  - Rouge Google : `#EA4335`
  - Jaune Google : `#FBBC05`
  - Blanc : `#FFFFFF`
  - Gris : `#202124`, `#5F6368`, `#E8EAED`

- **Composants** :
  - `MessageCard` : Carte de message avec avatar coloré et date formatée
  - `TabBar` : Onglets pour les messages reçus et envoyés
  - `SnackBar` : Notifications avec icônes et couleurs adaptées
  - `EmptyState` : Message d'état vide avec icône et bouton de rafraîchissement

## 📂 Structure du projet

```
testifysms/
├── lib/
│   ├── main.dart              # Point d'entrée de l'application
│   ├── providers/
│   │   └── sms_provider.dart  # Logique de gestion des SMS
│   ├── screens/
│   │   └── inbox_screen.dart  # Écran principal avec formulaire et liste
│   └── widgets/
│       └── message_card.dart  # Composant de carte de message
├── pubspec.yaml               # Dépendances et configuration
└── README.md                  # Documentation du projet
```

## 🤝 Contribuer

Les contributions sont les bienvenues ! N'hésitez pas à :

1. Créer une branche (`git checkout -b feature/AmazingFeature`)
2. Commiter vos changements (`git commit -m 'Add some AmazingFeature'`)
3. Pousser vers la branche (`git push origin feature/AmazingFeature`)
4. Ouvrir une Pull Request

## 📝 Licence

Ce projet est sous licence MIT. Voir le fichier `LICENSE` pour plus de détails.

## 📞 Support

Pour toute question ou problème, veuillez ouvrir une issue sur le dépôt.

---

**Développé avec ❤️ avec Flutter**
