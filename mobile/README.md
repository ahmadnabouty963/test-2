# Haven Mobile – iPhone und Android

Die App verwendet dieselben Supabase-Konten, Rollen, Chats und Termine wie die Website. Der Quellcode ist für Expo/EAS vorbereitet, damit ein gemeinsames Projekt native Builds für Android und iOS erzeugt.

## Bereits umgesetzt

- Englisch, Deutsch und Arabisch
- Gastzugang, Registrierung und Login
- Live-Warteschlange und Echtzeit-Chat
- Mitglieder- und Moderator-Ansicht
- Termin-Anfrage für registrierte Mitglieder
- Moderator-Verfügbarkeit
- Push-Registrierung nur für Moderator/Admin
- Datenschutzfreundliche Push-Texte ohne Namen, Thema, Sprache oder Nachrichten

## Lokal testen

```bash
cd mobile
npm install
npx expo start
```

Für Push-Benachrichtigungen ist ein echter iPhone-/Android-Testbuild nötig; Expo Go reicht je nach SDK und Plattform nicht für den vollständigen Push-Test.

## Einmalige Expo-Einrichtung

1. Bei expo.dev ein Projekt erstellen.
2. Im Ordner mobile `npx eas-cli init` ausführen.
3. Die erzeugte projectId in app.json unter expo.extra.eas.projectId einsetzen.
4. Mit `npx eas-cli build --profile development --platform all` interne Test-Apps bauen.
5. Als Moderator anmelden und „Handy-Benachrichtigungen aktivieren“ drücken.

## Store-Builds

```bash
npx eas-cli build --profile production --platform android
npx eas-cli build --profile production --platform ios
npx eas-cli submit --platform android
npx eas-cli submit --platform ios
```

Die letzten Schritte benötigen das Google-Play-Entwicklerkonto und das Apple-Developer-Konto des Betreibers. Zugangsdaten und Store-Schlüssel dürfen nie in Git gespeichert werden.

## Optionaler Moderator-E-Mail-Versand

Der Supabase-Dienst `notify-moderators` sendet E-Mails nur, wenn diese Secrets gesetzt sind:

- `RESEND_API_KEY`: API-Schlüssel des Resend-Kontos
- `HAVEN_EMAIL_FROM`: bestätigter Absender, zum Beispiel `Haven <alerts@example.org>`

Auch E-Mails enthalten absichtlich keine Gesprächsdetails. Moderatoren öffnen dafür immer das geschützte Dashboard.
