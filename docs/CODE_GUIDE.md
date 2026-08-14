# Haven – Entwicklerhandbuch

Dieses Dokument erklärt, welche Technik Haven verwendet, wo eine Funktion zu finden ist und wie die Teile zusammenarbeiten. Für die genaue Erklärung der einzelnen Codezeilen siehe [`LINE_BY_LINE.md`](./LINE_BY_LINE.md).

## 1. Technik und Aufgabe

| Technik | Wofür Haven sie benutzt |
|---|---|
| HTML (`index.html`) | Startpunkt der Website und Container `#app`. |
| CSS (`src/style.css`) | Farben, Kontrast, Layout, Dialoge, Chat, Dashboard und Mobilansicht. |
| JavaScript (`src/main.js`) | Oberfläche, Login, Rollen, Chat, Termine, Realtime und Bedienung. |
| Vite | Lokaler Entwicklungsserver und optimierter Produktions-Build. |
| npm | Installiert und sperrt die benötigten JavaScript-Pakete. |
| Supabase Auth | Registrierung, Anmeldung, anonyme Gäste, E-Mail-Bestätigung und Passwort-Reset. |
| Supabase PostgreSQL | Speichert Profile, Gespräche, Nachrichten, Termine und Benachrichtigungsdaten. |
| Row Level Security (RLS) | Erzwingt in der Datenbank, wer welche Zeile lesen oder schreiben darf. |
| Supabase Realtime | Überträgt neue Nachrichten und neue Warteschlangen-Einträge ohne Neuladen. |
| Supabase Edge Function | Versendet allgemeine Push-/E-Mail-Hinweise an das Team, ohne Gesprächsinhalte. |
| Expo / React Native | Gemeinsamer App-Code für Android und iPhone. |
| Vercel | Baut und veröffentlicht die Website aus GitHub. |
| GitHub | Versionsverwaltung, Sicherung und automatische Quelle für Vercel. |

## 2. Wichtige Dateien

| Datei | Aufgabe |
|---|---|
| `index.html` | Lädt die Web-App und setzt grundlegende Metadaten. |
| `src/main.js` | Gesamte Web-Anwendungslogik. |
| `src/translations.js` | Alle sichtbaren Texte für Englisch, Deutsch und Arabisch. |
| `src/style.css` | Gesamtes visuelles Design und responsive Regeln. |
| `supabase/schema.sql` | Grundtabellen, RLS-Regeln, Trigger und Chat-Funktionen. |
| `supabase/upgrade-v2.sql` | Admin-Rolle, Termine, Verfügbarkeit und öffentliche Statistiken. |
| `supabase/upgrade-v3-notifications.sql` | Push-Geräte und Versandprotokoll. |
| `supabase/upgrade-v4-admin-chat.sql` | Erlaubt Admins ausdrücklich, Chats wie Moderatoren anzunehmen. |
| `supabase/functions/notify-moderators/index.ts` | Geschützter Push- und E-Mail-Versand. |
| `mobile/App.js` | Android-/iPhone-App mit Auth, Chat, Termin und Team-Warteschlange. |
| `vercel.json` | Vercel-Build und SPA-Weiterleitung. |
| `.env.example` | Beispiel für öffentliche Konfiguration, niemals echte geheime Schlüssel. |

## 3. Rollen

| Rolle | Anmeldung | Rechte |
|---|---|---|
| Gast | Anonymes Supabase-Konto | Einen Chat beginnen und am eigenen Chat teilnehmen; keine Termine. |
| Mitglied | E-Mail und Passwort | Eigene Chats, Nachrichten und Termine. |
| Moderator | Normales Konto, danach vom Admin hochgestuft | Warteschlange sehen, Chat annehmen, Nachrichten senden, Termine verwalten, Verfügbarkeit setzen. |
| Admin | Normales Konto mit Admin-Rolle | Alle Moderator-Rechte plus Teamrollen verwalten. |

Eine Rolle wird niemals vom Browser selbst vergeben. `admin_set_role` prüft die Admin-Rolle serverseitig.

## 4. Datenbanktabellen

| Tabelle | Inhalt | Schutz |
|---|---|---|
| `profiles` | Anzeigename, Rolle, Verfügbarkeit | Eigenes Profil; Teamzugriff nur nach RLS/Rolle. |
| `conversations` | Besitzer, Moderator, Thema, Sprache und Status | Nur Teilnehmer oder freigeschaltetes Team. |
| `messages` | Gespräch, Absender, Text und Zeit | Nur Personen mit Zugriff auf das Gespräch. |
| `appointments` | Termin, Dauer, Notiz, Moderator und Status | Mitglied sieht eigene; Team verwaltet nach RLS. |
| `device_push_tokens` | Expo-Push-Token eines Team-Geräts | Nur das zugehörige freigeschaltete Teamkonto. |
| `notification_events` | Wann Push/E-Mail versucht oder versendet wurde | Serverinterne Versandkontrolle. |

## 5. Web-Funktionen in `src/main.js`

### Grundlagen und Darstellung

| Funktion | Zweck |
|---|---|
| `t(key)` | Holt einen Text in der aktiven Sprache und fällt auf Englisch zurück. |
| `escapeHtml(value)` | Macht Benutzereingaben sicher für HTML-Ausgabe. |
| `formatDate(value)` | Formatiert Datum und Uhrzeit passend zur Sprache. |
| `roleLabel(role)` | Übersetzt die technische Rolle in eine sichtbare Bezeichnung. |
| `statusLabel(status)` | Übersetzt den Gesprächsstatus. |
| `translate()` | Setzt Sprache, RTL für Arabisch und alle `data-i18n`-Texte. |
| `renderHeader()` | Zeigt je nach Sitzung und Rolle die richtigen Kopfzeilen-Schaltflächen. |
| `showToast(message, error)` | Zeigt eine kurze Erfolgs- oder Fehlermeldung. |
| `showModal(html, mode)` | Öffnet einen Dialog und setzt dessen Inhalt/Layout. |
| `closeModal()` | Schließt den Dialog und beendet die aktuelle Chat-Realtime-Verbindung. |
| `loadProfile()` | Lädt das Profil der angemeldeten Person und aktiviert Teamfunktionen. |
| `loadStats()` | Lädt die öffentliche Zahl aller und aktuell verfügbarer Moderatoren. |

### Anmeldung und rechtliche Dialoge

| Funktion | Zweck |
|---|---|
| `authModal(mode)` | Baut Login oder Registrierung. |
| `resetPasswordModal()` | Fragt die E-Mail für einen Passwort-Reset ab. |
| `newPasswordModal()` | Zeigt nach gültigem Recovery-Link das Formular für ein neues Passwort. |
| `recoveryErrorModal()` | Erklärt einen ungültigen/abgelaufenen Recovery-Link. |
| `guestModal()` | Fragt Gast-Spitzname und Zustimmung ab. |
| `crisisModal()` | Zeigt klar den Notfallhinweis und Krisenwege. |
| `privacyModal()` | Zeigt Datenschutzhinweise. |
| `imprintModal()` | Zeigt das Impressum und warnt, solange Pflichtangaben fehlen. |
| `submitAuth(form)` | Führt Registrierung oder Login aus und verarbeitet Fehler. |
| `submitPasswordReset(form)` | Sendet die Supabase-Recovery-E-Mail zur aktuellen Domain. |
| `submitNewPassword(form)` | Prüft beide Passwörter, speichert das neue Passwort und meldet sicher ab. |
| `startGuest(nickname)` | Erstellt eine anonyme Sitzung und öffnet den Chatbereich. |

### Chats

| Funktion | Zweck |
|---|---|
| `memberSpace()` | Lädt Chats und Termine eines Mitglieds. |
| `chatRow(c)` | Rendert einen normalen Gesprächseintrag. |
| `staffChatRow(c)` | Rendert einen Team-Eintrag mit deutlicher Annehmen-Schaltfläche. |
| `conversationHome()` | Öffnet einen laufenden Chat oder das Formular für einen neuen. |
| `createConversation(form)` | Speichert einen wartenden Chat und löst Teamhinweise aus. |
| `openConversation(id)` | Lädt Gespräch und Nachrichten parallel. |
| `renderConversation()` | Baut den großen Chat-Arbeitsbereich. |
| `messageHtml()` | Rendert alle Chatblasen und markiert eigene Nachrichten. |
| `scrollMessages()` | Scrollt nach unten zur neuesten Nachricht. |
| `sendMessage(form)` | Prüft Text und speichert eine Nachricht. |
| `subscribe(id)` | Abonniert neue Nachrichten des geöffneten Gesprächs. |
| `unsubscribe()` | Entfernt das Chat-Abonnement. |
| `endConversation()` | Ruft die geschützte Datenbankfunktion zum Beenden auf. |
| `acceptChat(id, status)` | Nimmt wartende Gespräche atomar an und öffnet sie danach. |

### Team und Benachrichtigungen

| Funktion | Zweck |
|---|---|
| `notificationPermission()` | Liest, ob Browser-Benachrichtigungen unterstützt/erlaubt sind. |
| `notificationButton()` | Rendert den passenden Zustand der Benachrichtigungs-Schaltfläche. |
| `notifyStaff()` | Setzt Browser-Titel, Toast und optionale Systembenachrichtigung. |
| `subscribeStaffAlerts()` | Abonniert neue wartende Gespräche für Moderator/Admin. |
| `unsubscribeStaffAlerts()` | Beendet dieses Team-Abonnement. |
| `enableStaffNotifications()` | Fragt einmalig Browser-Erlaubnis an. |
| `staffDashboard(view)` | Lädt Warteschlange, Termine, Statistiken oder Teamverwaltung. |
| `profileRow(p)` | Rendert eine Person für die Admin-Rollenverwaltung. |

### Termine und Start

| Funktion | Zweck |
|---|---|
| `appointmentModal()` | Prüft Mitgliedschaft und öffnet die Terminplanung. |
| `createAppointment(form)` | Wandelt Datum in UTC um und speichert den Termin. |
| `appointmentRow(a, staff)` | Rendert Termin und passende Mitglied-/Teamaktionen. |
| globaler `click`-Handler | Verteilt alle `data-action`-Klicks auf Funktionen. |
| globaler `submit`-Handler | Verteilt Formulare auf die richtige Submit-Funktion. |
| globaler `change`-Handler | Verarbeitet Sprache, Team-Verfügbarkeit und Rollenänderungen. |
| `init()` | Startet Übersetzung, Statistik, Auth-Listener und bestehende Sitzung. |

## 6. Mobile Funktionen in `mobile/App.js`

| Funktion/Komponente | Zweck |
|---|---|
| `Button` | Einheitliche berührbare App-Schaltfläche. |
| `Field` | Einheitliches beschriftetes Eingabefeld. |
| `Brand` | Haven-Logozeile. |
| `App` | Zentraler Zustand, Navigation, Sitzung, Profil, Nachrichten und Push. |
| `signOut` | Setzt Team offline, meldet ab und leert Chatdaten. |
| `openConversation` | Lädt Nachrichten, öffnet Chat und startet Realtime. |
| `registerPush` | Fordert Push-Rechte an und speichert Expo-Gerätetoken sicher. |
| `GuestLanding` | Öffentliche App-Startseite. |
| `Auth` / `submit` | Registrierung und Anmeldung. |
| `GuestStart` / `submit` | Anonymes Konto und neuer wartender Chat. |
| `Dashboard` / `load` | Lädt je nach Rolle eigene Chats oder Team-Warteschlange. |
| `Chat` / `send` | Zeigt Realtime-Nachrichten und sendet neue. |
| `Appointment` / `submit` | Erstellt Mitgliedstermine. |

## 7. SQL-Funktionen

| Funktion | Zweck |
|---|---|
| `handle_new_user` | Erstellt automatisch ein Profil nach einem neuen Auth-Konto. |
| `private.is_moderator` | Erlaubt Moderator **und Admin** Team-Chatrechte. |
| `private.can_access_conversation` | Prüft Besitzer, zugewiesenen Moderator oder Teamrolle. |
| `accept_conversation` | Weist genau einem Teammitglied einen wartenden Chat zu. |
| `close_conversation` | Beendet einen Chat nur für Teilnehmer. |
| `private.is_staff` | Gemeinsame Prüfung auf Moderator/Admin. |
| `private.is_admin` | Prüft ausschließlich Admin. |
| `private.is_permanent_user` | Schließt anonyme Konten bei Terminregeln aus. |
| `get_public_stats` | Gibt nur aggregierte Teamzahlen zurück. |
| `set_staff_availability` | Setzt Teamstatus online/beschäftigt/offline. |
| `manage_appointment` | Team nimmt Termin an, schließt ihn oder ändert Status. |
| `cancel_own_appointment` | Mitglied storniert den eigenen Termin. |
| `admin_set_role` | Admin ändert eine Rolle kontrolliert. |

## 8. Chat-Ablauf

1. Gast oder Mitglied meldet sich an.
2. `createConversation` fügt `status = waiting` ein.
3. RLS kontrolliert Besitzer und Startstatus.
4. Realtime informiert geöffnete Team-Dashboards.
5. Die Edge Function verschickt auf Wunsch allgemeine Push-/E-Mail-Hinweise.
6. Moderator/Admin klickt „Annehmen“.
7. `accept_conversation` setzt atomar `moderator_id` und `active`.
8. Beide Seiten abonnieren neue Nachrichten.
9. `close_conversation` beendet das Gespräch.

## 9. Sicherheit und Datenschutz – technisch korrekt formuliert

- Die Verbindung zu Supabase/Vercel läuft über HTTPS.
- Passwörter werden von Supabase Auth verarbeitet und sind nicht im Haven-Code gespeichert.
- RLS beschränkt Datenbankzugriffe auf Teilnehmer und Rollen.
- Gesprächsinhalte stehen nicht in Push-Nachrichten oder Team-E-Mails.
- Gäste sind gegenüber Moderatoren mit Spitznamen sichtbar, aber technisch existiert ein anonymes Auth-Konto.
- Betreiber mit hoch privilegiertem Supabase-Zugang können technisch Datenbankdaten sehen. Deshalb darf die Website **keine absolute Unsichtbarkeits- oder Anonymitätsgarantie** behaupten.
- Für echten Betrieb braucht es vollständiges Impressum, Datenschutzerklärung, Löschfristen, Auftragsverarbeitungsprüfung und ein Notfallkonzept.
- Haven ist kein Notfall- oder medizinischer Dienst; dieser Hinweis muss sichtbar bleiben.

## 10. Änderungen

- Texte: denselben Schlüssel in `src/translations.js` unter `en`, `de` und `ar` ändern.
- Farben/Kontrast: CSS-Variablen und betroffene Komponenten in `src/style.css` ändern.
- Web-Verhalten: passende Funktion in `src/main.js` ändern.
- Datenrechte: niemals nur Frontend ändern; SQL/RLS und RPC prüfen.
- Neue Datenbankänderungen als neue `supabase/upgrade-vN-*.sql` anlegen, nicht alte Produktion blind neu ausführen.

## 11. Test vor Veröffentlichung

```bash
npm ci
npm run check
```

Danach Registrierung, Bestätigungslink, Login, Gastchat, Chat-Annahme, Nachrichten in beiden Richtungen, Termin und drei Sprachen manuell testen. Die vollständige Liste steht in [`LAUNCH_CHECKLIST.md`](./LAUNCH_CHECKLIST.md).
