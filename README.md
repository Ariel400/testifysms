Application Flutter pour l'envoi et la réception de SMS de test, dotée d'une interface de chat moderne et unifiée inspirée de la charte graphique CIE.

## 🚀 Fonctionnalités

- **Interface Chat unifiée** : Un seul flux temporel pour les messages envoyés (User) et reçus (Serveur).
- **Envoi de SMS** : Formulaire ergonomique ancré en bas de l'écran avec validation.
- **Visualisation des statuts** : Bulles de chat différenciées avec indicateurs de succès (checkmarks).
- **Splash Screen Premium** : Écran d'accueil animé et brandé "SMS Gateway Tester".
- **Date/Heure précise** : Formatage local des timestamps de réception et d'envoi.

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

L'application nécessite les permissions SMS standard. Sur Android >= 10, il est recommandé de définir l'app comme **application SMS par défaut** pour une réception optimale en temps réel.

```xml
<uses-permission android:name="android.permission.SEND_SMS" />
<uses-permission android:name="android.permission.RECEIVE_SMS" />
<uses-permission android:name="android.permission.READ_SMS" />
<uses-permission android:name="android.permission.READ_PHONE_STATE" />
```

## 🎨 Design System (CIE)

L'application respecte les codes visuels de la **CIE** tout en gardant une esthétique minimaliste :

- **Couleurs** :
  - Background App : `#F9FAFB` (Gris perle)
  - Bulle Envoyée : `#FFEDD5` (Orange très pâle)
  - Bulle Reçue : `#F3F4F6` (Gris doux)
  - Bouton d'action : `#000000` (Noir pur)
  - Statuts : Vert `#10B981` / Rouge `#EF4444`

- **Composants** :
  - `MessageCard` : Bulle de chat dynamique avec alignement gauche/droite.
  - `LucideIcons` : Bibliothèque d'icônes premium pour une interface haut de gamme.
  - `BottomCard` : Zone de saisie flottante avec coins arrondis `3xl`.

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

**Développé avec ❤️ BadRequest**
