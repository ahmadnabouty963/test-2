# Haven – Code- und Änderungsleitfaden

## Projektstruktur

| Datei | Aufgabe |
|---|---|
| index.html | Erstellt den App-Container und lädt Haven im Browser. |
| src/main.js | Seitenaufbau, Login, Chat, Termine und Dashboards. |
| src/translations.js | Alle Texte für Englisch, Deutsch und Arabisch. |
| src/style.css | Farben, Layout, Chat, Dashboards und Mobilansicht. |
| supabase/upgrade-v2.sql | Datenbank-Erweiterung für Admins, Termine und Verfügbarkeit. |
| supabase/upgrade-v3-notifications.sql | Sichere Gerätetokens und Versandprotokoll für Moderator-Benachrichtigungen. |
| supabase/functions/notify-moderators/index.ts | Geschützter Push-/E-Mail-Versand ohne Gesprächsinhalte. |
| mobile/App.js | Gemeinsame iPhone-/Android-App mit Login, Gastzugang, Chat, Terminen und Moderator-Warteschlange. |
| mobile/app.json | App-Name, Paketnamen und Expo-Konfiguration. |
| mobile/eas.json | Entwicklungs- und Store-Builds für iOS und Android. |
| mobile/README.md | Schritte zum Testen und Veröffentlichen der App. |
| docs/PLANNING.md | Produktziel, Rollen und nächste Schritte. |

## Wichtige Bereiche in src/main.js

- Öffentliche Startseite: Der große app.innerHTML-Block baut Header, Hero, Live-Zahlen, Ablauf, Geschichten, Sicherheit und Footer.
- Sprache: state.lang speichert die Sprache, t() holt Texte und translate() aktualisiert data-i18n. Arabisch setzt automatisch RTL.
- Login: authModal(), submitAuth(), guestModal() und startGuest().
- Passwort zurücksetzen: resetPasswordModal(), submitPasswordReset(), newPasswordModal() und submitNewPassword().
- Chat: conversationHome(), createConversation(), openConversation(), renderConversation(), sendMessage() und subscribe().
- Termine: appointmentModal(), createAppointment() und appointmentRow().
- Team: staffDashboard() enthält Moderator- und Admin-Ansichten.
- Benachrichtigungen: subscribeStaffAlerts(), enableStaffNotifications() und notifyStaff().

## Häufige Änderungen

### Farben

Ganz oben in src/style.css stehen die Variablen --night, --forest, --sage und --paper. Eine Änderung dort wirkt auf die gesamte Seite.

### Texte

In src/translations.js denselben Schlüssel in en, de und ar ändern, zum Beispiel heroTitle.

### Hero-Foto

Das Foto als public/hero-support.webp speichern. Danach bei .hero-photo in app/globals.css eine URL zum Bild, background-size: cover und background-position: center ergänzen. Anschließend photo-note aus app/haven-client.js entfernen.

### Dashboard

Neue Kennzahlen werden in staffDashboard() im Bereich stat-grid ergänzt. Benötigte Daten müssen vorher aus Supabase geladen werden.

## Supabase-Sicherheit

- Im Browser steht nur der öffentliche Publishable Key.
- Secret- oder Service-Role-Keys dürfen nie in Frontend-Dateien stehen.
- Alle öffentlichen Tabellen verwenden Row Level Security.
- Admin- und Moderator-Aktionen laufen über kontrollierte RPC-Funktionen.
- Öffentliche Statistiken geben ausschließlich Summen zurück.
- Gastkonten dürfen keine Termine buchen.
- Push- und E-Mail-Nachrichten enthalten niemals Thema, Sprache, Namen oder Nachrichtentext.
- Gerätetokens können nur vom zugehörigen freigeschalteten Moderator/Admin verwaltet werden.

## Benachrichtigungsablauf

1. Ein Gast oder Mitglied erstellt eine Warteschlangen-Unterhaltung.
2. Das Moderator-Dashboard erhält das Ereignis sofort über Supabase Realtime.
3. Ein geöffnetes Browser-Dashboard zeigt Toast und – nach Zustimmung – eine System-Benachrichtigung.
4. Die App registriert freigeschaltete Moderator-Geräte in device_push_tokens.
5. Die geschützte Edge Function notify-moderators sendet eine allgemeine Push-Nachricht an diese Geräte.
6. Der erste freie Moderator öffnet die Warteschlange und übernimmt die Unterhaltung atomar über accept_conversation.

E-Mail-Versand ist im selben Dienst vorbereitet. Er wird aktiv, sobald in Supabase die Secrets RESEND_API_KEY und HAVEN_EMAIL_FROM gesetzt sind. Ohne diese Secrets bleibt E-Mail bewusst aus; Browser, Realtime und App-Push funktionieren unabhängig davon.

## Lokal starten

1. npm install
2. npm run dev
3. npm run build

Vor jeder Veröffentlichung muss npm run build ohne Fehler laufen.

## Moderator- und Admin-Anmeldung

Moderatoren brauchen keine getrennte Login-Seite:

1. Die Person registriert ein normales Haven-Konto und bestätigt ihre E-Mail.
2. Ein Admin öffnet im Team-Dashboard die Ansicht Team und setzt die Rolle auf Moderator.
3. Der Moderator verwendet anschließend oben rechts Anmelden mit derselben E-Mail und demselben Passwort.
4. Haven liest die sichere Rolle aus der profiles-Tabelle und öffnet automatisch das Team-Dashboard.

Die Rolle darf nicht über Browser-Metadaten oder Frontend-Code vergeben werden. Nur ein bestehender Admin kann sie über die geschützte Funktion admin_set_role ändern.

## Registrierungsablauf

Die Registrierung sendet eine Bestätigungs-E-Mail. Der Bestätigungslink verweist auf die öffentliche Haven-Adresse. Danach kehrt die Person zu Haven zurück und meldet sich mit dem gewählten Passwort an.

## Passwort-Wiederherstellung

Unter dem Passwortfeld der Anmeldung befindet sich „Passwort vergessen?“. Haven sendet über Supabase eine sichere Wiederherstellungs-E-Mail. Der Link führt zurück zur öffentlichen Haven-Seite, wo ein neues Passwort zweimal eingegeben wird. Nach der Änderung wird die Sitzung beendet und die Person meldet sich mit dem neuen Passwort an.

Haven speichert beim ersten Laden sofort, ob die URL zu einer Passwort-Wiederherstellung gehört. Dadurch bleibt der Ablauf zuverlässig, auch wenn Supabase die Token-Parameter kurz danach aus der Adresszeile entfernt. Abgelaufene oder bereits verwendete Links zeigen eine verständliche Meldung und führen direkt zur Anforderung eines neuen Links. Immer nur den neuesten Wiederherstellungslink verwenden; ein neuer Link macht ältere Links ungültig.

In Supabase muss unter **Authentication → URL Configuration** die öffentliche Haven-Adresse als Site URL und erlaubte Redirect URL eingetragen sein. Passwörter, Codes und geheime Schlüssel gehören niemals in den Quellcode oder in Support-Nachrichten.
