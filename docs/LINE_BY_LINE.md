# Haven – Code Zeile für Zeile erklärt

Stand: Branch `main`. Zeilennummern beziehen sich auf die aktuelle Version. Nach Änderungen können sie sich verschieben.

**Wie diese Dokumentation gelesen wird:** Jede ausführbare Zeile und jeder logische Block wird erklärt. Sehr lange, kompakte Zeilen enthalten teilweise eine ganze Funktion; deshalb wird innerhalb der Zeile zusätzlich jeder Schritt beschrieben. Wiederholte Übersetzungswerte und CSS-Eigenschaften werden nach Schlüssel-/Selektorgruppen erklärt, weil 1:1-Wiederholungen die Erklärung unlesbar machen würden.

## `index.html`

- `<!doctype html>`: Aktiviert modernen HTML5-Modus.
- `<html lang="en">`: Setzt Englisch als Startsprache; `translate()` ersetzt Sprache und Schreibrichtung später.
- `<meta charset="UTF-8">`: Unterstützt deutsche Umlaute und arabische Schrift.
- Viewport-Meta: Passt die Breite an Mobilgeräte an.
- Description/Theme-Color: Suchmaschinenbeschreibung und Browserfarbe.
- `<div id="app">`: Leerer Container, in den `src/main.js` die komplette Oberfläche einsetzt.
- `<script type="module" src="/src/main.js">`: Startet die Vite-JavaScript-App als ES-Modul.

## `src/main.js` – Zeilen 1–16: Startwerte

| Zeile | Erklärung |
|---:|---|
| 1 | Importiert `createClient`, damit der Browser Supabase Auth, Datenbank, RPC und Realtime verwenden kann. |
| 2 | Importiert die drei Sprachobjekte. |
| 3 | Lässt Vite das globale CSS bündeln. |
| 5 | Liest die beim ersten Laden vorhandene URL. |
| 6 | Wandelt den URL-Hash in suchbare Parameter um. |
| 7 | Merkt sich sofort, ob der Aufruf ein Passwort-Recovery ist. Das ist wichtig, bevor Supabase URL-Token entfernt. |
| 8 | Liest mögliche Fehlercodes aus Hash oder Query. |
| 9 | Erstellt den Supabase-Client mit Projekt-URL und öffentlichem Publishable Key. Dieser Key ist kein Server-Geheimnis; RLS bleibt zwingend. |
| 10–12 | Kommentar und `location.origin`: Bestätigungs-/Resetlinks kehren zur tatsächlich geöffneten Domain zurück. |
| 13 | Zentraler Zustand: Sprache, Sitzung, Profil, aktueller Chat, Nachrichten, Realtime-Kanäle, Auth-Modus, Dashboard-Ansicht und Recovery-Status. |
| 14 | `t`: Sprachschlüssel → gewählte Sprache → englischer Fallback → Schlüsselname. |
| 15 | Holt den App-Container aus `index.html`. |

## `src/main.js` – Zeilen 17–56: Seitenstruktur

| Zeile(n) | Element und Zweck |
|---:|---|
| 17 | Startet ein Template Literal für die gesamte Grundoberfläche. |
| 18 | Oberer Notfallhinweis plus Schaltfläche für Krisenhilfe. |
| 19–30 | Kopfzeile: Marke, Navigation, Sprachauswahl, Nutzerstatus, Mitglieds-/Teamzugang, Login/Logout. |
| 31–46 | Hero: Hauptbotschaft, klare Dienstgrenze, Aktionen, Vertrauenspunkte und ruhige visuelle Karte. |
| 47 | Live-Zahlen für Moderatoren und aktuell verfügbare Personen. |
| 48 | Drei Schritte „so funktioniert es“. |
| 49 | Drei Hoffnungsgeschichten/Zitate. Diese Texte sind keine echten Testimonials, solange keine Einwilligung vorliegt. |
| 50 | Datenschutzsektion mit verständlichen Kernpunkten. |
| 51 | Sicherheits- und Dienstgrenzen. |
| 52 | Abschließender Handlungsaufruf. |
| 54 | Footer mit Datenschutz, Impressum und Notfallgrenze. |
| 55 | Wiederverwendbarer Dialog-Overlay und Schließen-Schaltfläche. |
| 56 | Toast-Meldung für kurze Rückmeldungen. |

## `src/main.js` – Zeilen 58–68: Hilfsfunktionen

- **58 `escapeHtml(value="")`:** Erstellt ein temporäres `div`; setzt Benutzereingabe über `textContent`; liest die sicher kodierte HTML-Ausgabe. Dadurch wird z. B. `<script>` nur als Text angezeigt.
- **59 `formatDate(value)`:** Erstellt `Intl.DateTimeFormat` mit aktueller Sprache, mittlerem Datum und kurzer Zeit; formatiert ein `Date`.
- **60 `roleLabel(role)`:** Wählt `roleAdmin`, `roleModerator` oder `roleUser` und übersetzt den Schlüssel.
- **61 `statusLabel(status)`:** Verwendet für `closed` den sichtbaren Schlüssel `ended`; andere Status werden direkt übersetzt.
- **62 `translate()`:** Setzt HTML-Sprache; setzt für Arabisch `dir=rtl`; synchronisiert das Select; läuft über jedes `data-i18n`; ersetzt dessen Text; aktualisiert bereits geöffneten Kopfbereich.
- **63 `renderHeader()`:** Prüft Sitzung; prüft Rolle Moderator/Admin; zeigt/versteckt Login, Logout, Mitglieds- und Teambereich; zeigt Name/Rolle im Nutzer-Pill.
- **64 `showToast(message,error)`:** Setzt Text und Klasse; macht Toast sichtbar; löscht alten Timer; blendet nach einigen Sekunden aus.
- **65 `showModal(html,mode)`:** Setzt Dialoginhalt und Modusklasse; zeigt Overlay; sperrt Hintergrundscrollen.
- **66 `closeModal()`:** Versteckt Dialog; gibt Scrollen frei; beendet Chat-Realtime.
- **67 `loadProfile()`:** Bricht ohne Sitzung ab; liest eigenes Profil; wirft Datenbankfehler; speichert Profil; aktualisiert Header; startet bei Teamrollen das Warteschlangen-Abo.
- **68 `loadStats()`:** Ruft `get_public_stats`; verwendet bei fehlenden Werten `0`; trägt Summen in die zwei Kennzahlen ein.

## `src/main.js` – Zeilen 70–81: Auth und Dialoge

- **70 `authModal(mode)`:** Speichert Login/Signup-Modus, bestimmt Registrierung, baut Überschrift/Formular, zeigt Namensfeld nur bei Registrierung, bietet Moduswechsel und Passwort-Reset.
- **71 `resetPasswordModal()`:** Baut E-Mail-Formular für den Reset.
- **72 `newPasswordModal()`:** Markiert Recovery als angezeigt und baut zwei Passwortfelder.
- **73 `recoveryErrorModal()`:** Entfernt alte Recovery-Parameter aus der URL und bietet einen neuen Link an.
- **74 `guestModal()`:** Baut Spitznamenformular und erklärt den Gastmodus.
- **75 `crisisModal()`:** Zeigt, dass Haven kein Notfalldienst ist, plus externe Hilfswege.
- **76 `privacyModal()`:** Baut die Datenschutztexte aus Übersetzungsschlüsseln.
- **77 `imprintModal()`:** Baut Impressum; zeigt Warnung, solange Betreiberangaben nicht vollständig sind.
- **78 `submitAuth(form)`:** Deaktiviert Submit; liest Felder. Bei Registrierung ruft es `signUp` mit Anzeigename und Rückleitungs-URL auf. Bei Login ruft es `signInWithPassword` auf. Fehler werden verständlich geworfen; Erfolg aktualisiert Zustand/Profil; `finally` aktiviert den Button wieder.
- **79 `submitPasswordReset(form)`:** Liest E-Mail; ruft `resetPasswordForEmail` mit `productionUrl/?recovery=1`; zeigt Bestätigung oder Fehler; aktiviert Button wieder.
- **80 `submitNewPassword(form)`:** Vergleicht Passwort und Wiederholung; aktualisiert Supabase-Passwort; bereinigt URL; meldet ab; öffnet Login; Fehler bleiben sichtbar.
- **81 `startGuest(nickname)`:** Verwendet `signInAnonymously`; speichert Spitzname in Auth-Metadaten; setzt Sitzung; lädt Profil; öffnet Chat-Start.

## `src/main.js` – Zeilen 83–101: Chat

- **83 `memberSpace()`:** Öffnet Login ohne Sitzung; anonyme Gäste landen direkt im Chat; dauerhafte Nutzer laden Gespräche und Termine parallel; Fehler stoppen die Ausgabe; Dialog zeigt beide Listen.
- **84 `chatRow(c)`:** Gibt einen sicheren Button mit Gespräch-ID, Status, escaped Thema, Sprache, Datum und Status-Badge zurück.
- **85 `staffChatRow(c)`:** Rendert Teamzeile. Wartende Chats bekommen eine deutliche Annehmen-Schaltfläche; aktive Chats eine Öffnen-Schaltfläche.
- **86 `conversationHome()`:** Liest eigene erreichbare Gespräche; öffnet den ersten nicht geschlossenen Chat; andernfalls zeigt es das Formular für einen neuen.
- **87 `createConversation(form)`:** Liest Thema/Sprache; fügt Gespräch für die angemeldete User-ID ein; verlangt den neu gespeicherten Datensatz; ruft Team-Benachrichtigung auf; öffnet Chat.
- **88 `openConversation(id)`:** Lädt Gespräch und sortierte Nachrichten gleichzeitig; prüft beide Fehler; speichert Auswahl/Nachrichten; rendert; startet Realtime.
- **89 `renderConversation()`:** Bestimmt Wartestatus; baut linken Kontext, Kopf, Statushinweis, Nachrichtenbereich und Sendefeld; Team kann beenden; Wartende sehen noch keinen aktiven Dialogpartner.
- **90 `messageHtml()`:** Zeigt bei leerer Liste Wartehinweis; sonst mappt jede Nachricht zu einer Bubble; eigene Absender-ID erhält `mine`; Text wird escaped; Datum formatiert.
- **91 `scrollMessages()`:** Falls der Nachrichtencontainer existiert, setzt Scrollposition auf das Ende.
- **92 `sendMessage(form)`:** Trimnt Text; ignoriert leer; fügt Gespräch-ID, eigene Absender-ID und Text ein; leert Eingabe; Fehler wird weitergereicht.
- **93 `subscribe(id)`:** Entfernt altes Abo; erstellt Supabase-Kanal; hört nur auf Inserts für diese Gespräch-ID; verhindert doppelte Nachricht anhand ID; ergänzt, rendert und scrollt; bei Statusänderung lädt es Gespräch neu.
- **94 `unsubscribe()`:** Entfernt Kanal bei Supabase und setzt Referenz auf `null`.
- **95 `notificationPermission()`:** Gibt Browserstatus oder `unsupported` zurück.
- **96 `notificationButton()`:** Gibt je nach Berechtigung einen deaktivierten Aktiv-Zustand, eine Aktivieren-Schaltfläche oder einen Hinweis zurück.
- **97 `notifyStaff()`:** Markiert den Tabtitel; stellt Titel bei Fokus wieder her; zeigt Toast; erzeugt nur bei Erlaubnis eine Systembenachrichtigung ohne Gesprächsinhalt.
- **98 `subscribeStaffAlerts()`:** Nur Team, nur einmal. Hört auf neue `conversations`; reagiert nur auf `waiting`; benachrichtigt und aktualisiert geöffnetes Dashboard.
- **99 `unsubscribeStaffAlerts()`:** Entfernt Teamkanal.
- **100 `enableStaffNotifications()`:** Prüft Browserunterstützung; fordert Erlaubnis; zeigt Ergebnis; rendert Teamansicht neu.
- **101 `endConversation()`:** Ruft `close_conversation`; setzt lokalen Status; rendert neu.

## `src/main.js` – Zeilen 103–109: Termine und Team

- **103 `appointmentModal()`:** Ohne Sitzung → Signup; anonymer Gast → Fehlermeldung/Signup; setzt frühesten Zeitpunkt; baut Terminformular.
- **104 `createAppointment(form)`:** Liest Formular; verbindet Datum/Uhrzeit und wandelt in ISO/UTC; fügt Termin mit Dauer, Sprache und Notiz ein; zeigt Erfolg.
- **105 `appointmentRow(a,staff)`:** Rendert Datum, Zeit, Dauer, Status und – abhängig von Rolle/Status – Annehmen/Erledigen/Absagen.
- **107 `staffDashboard(view)`:** Prüft Sitzung und Profil/Rolle; speichert Ansicht; lädt je nach Reiter Statistiken, Warteschlange/aktive Chats, Termine oder Profile; baut Team-Navigation, Verfügbarkeit und passende Karten.
- **108 `profileRow(p)`:** Rendert Initial, sicheren Namen, Datum, Rolle und Admin-Auswahl.
- **109 `acceptChat(id,status)`:** Ruft bei `waiting` zuerst atomar `accept_conversation`; bei Erfolg öffnet es den Chat. So können nicht zwei Moderatoren denselben Chat übernehmen.

## `src/main.js` – Zeilen 111–128: Ereignisse und Start

- **111–122 Klick-Handler:** Ermittelt `data-action`; öffnet Gast/Auth/Krise/Datenschutz/Impressum; verwaltet Räume, Benachrichtigungen, Logout, Chatende, Chatauswahl, Team-Reiter, Terminaktionen und Terminabsage. Jeder Fehler endet im roten Toast.
- **123 Submit-Handler:** Verhindert Browser-Neuladen und leitet anhand der Formular-ID an Gast, Auth, Reset, neues Passwort, Gespräch, Nachricht oder Termin weiter.
- **124 Change-Handler:** Speichert Sprache; aktualisiert Übersetzung; setzt Team-Verfügbarkeit per RPC; ändert Rollen über `admin_set_role`; Fehler werden als Toast gezeigt.
- **125:** Klick auf den dunklen Overlay-Hintergrund sowie Escape schließen den Dialog.
- **127 `init()`:** Übersetzt; lädt Statistiken; registriert Auth-State-Listener; reagiert sofort auf `PASSWORD_RECOVERY`; leert Zustand beim Logout; lädt Profil bei Sitzung; prüft anfängliche Recovery-Fehler/-Absicht; liest bestehende Sitzung.
- **128:** Startet `init`; nicht abgefangene Startfehler erscheinen als Toast.

## `src/translations.js`

- Exportiert `translations` mit `en`, `de`, `ar`.
- Jeder identische Schlüssel beschreibt dasselbe UI-Element in drei Sprachen.
- Navigations-/Hero-Schlüssel steuern Startseite und Dienstgrenze.
- Auth-/Recovery-Schlüssel steuern Registrierung, Login und Passwort-Reset.
- Chat-Schlüssel steuern Warteschlange, Nachrichteneingabe, Status und Annehmen.
- Termin-Schlüssel steuern Planung und Verwaltung.
- Team-/Rollen-Schlüssel steuern Moderator-/Admin-Dashboard.
- Datenschutz-/Impressum-/Krisenschlüssel steuern rechtliche und sicherheitsrelevante Dialoge.
- Beim Ergänzen eines Schlüssels müssen alle drei Sprachobjekte erweitert werden; `t()` fällt sonst auf Englisch zurück.

## `src/style.css`

- `:root`: globale Farb-, Schrift- und Abstandsvariablen.
- Reset (`*`, `html`, `body`, Buttons/Inputs): einheitliches Boxmodell und Grunddarstellung.
- `.emergency`, `.header`, `.nav`, `.header-actions`: obere Dienstgrenze und Navigation.
- `.hero*`, `.support-card`, Bewegungs-Keyframes: Hero-Komposition und ruhige Animation.
- `.metrics`, `.section`, `.cards`, `.story-grid`: Startseitenbereiche und Karten.
- `.privacy-*`, `.safety`, `.closing`, `.footer`: Vertrauen, Grenzen und Rechtliches.
- `.overlay`, `.modal`, `.dialog-*`, `.form`, `.toast`: Dialog- und Feedbacksystem.
- `.chat-*`, `.messages`, `.bubble`, `.composer`: großer Chat-Arbeitsplatz.
- `.staff-*`, `.stat-*`, `.list-row`, `.appointment-*`, `.team-*`: Moderator-/Admin-Dashboard.
- `@media`: Tablet-/Mobilumbau; Spalten werden gestapelt, Navigation vereinfacht, Chat nutzt Bildschirmbreite.
- `[dir="rtl"]`: korrigiert Ausrichtung für Arabisch.
- `prefers-reduced-motion`: reduziert Bewegung für Menschen, die Animationen deaktivieren.

## `mobile/App.js`

| Zeilen | Erklärung |
|---:|---|
| 1–11 | Polyfill, React Hooks, native UI-Bausteine, lokale Session-Speicherung, Supabase, Gerätedaten und Expo Notifications. |
| 13–17 | Öffentliche Supabase-Konfiguration; Sessions werden sicher im App-Speicher erhalten und erneuert. |
| 19–21 | Legt fest, wie eingehende Push-Nachrichten sichtbar sind. |
| 23–27 | Dreisprachige App-Texte. |
| 29–31 | Wiederverwendbare `Button`, `Field` und `Brand`-Komponenten. |
| 33–58 | `App`: hält Sprache, Sitzung, Profil, Screen, Gespräch, Nachrichten und Realtime; Auth/Profile/Push-Listener; rendert richtigen Screen. |
| 43 | `signOut`: Team offline, Supabase-Abmeldung, lokalen Chat leeren. |
| 44 | `openConversation`: Nachrichten laden, alten Kanal entfernen, neuen Kanal abonnieren, Chat öffnen. |
| 45 | `registerPush`: nur echtes Gerät; Berechtigung; Expo-Projekt-ID/Token; Upsert in `device_push_tokens`. |
| 60 | `GuestLanding`: App-Hero und drei Startaktionen. |
| 62 | `Auth`: lokale Felder; `submit` wählt Signup/Login; Anzeigename wird beim Signup mitgesendet. |
| 63 | `navButton`: einheitlicher Zurück-Link. |
| 65 | `GuestStart`: erstellt falls nötig anonyme Sitzung und anschließend wartendes Gespräch. |
| 67 | `Dashboard`: `load` liest als Team Warteschlange, sonst eigene Gespräche; Team kann annehmen und Push aktivieren. |
| 69 | `Chat`: `send` trimmt und speichert Nachricht; `FlatList` zeigt Nachrichten. |
| 71 | `Appointment`: prüft Datum/Zeit und fügt Termin ein. |
| 73–74 | Zentrale React-Native-Stile. |

## `supabase/schema.sql` – Zeilen 1–75

| Zeilen | Erklärung |
|---:|---|
| 1–3 | Installationshinweis und UUID-Erweiterung. |
| 4–5 | Definiert Rollen- und Gesprächsstatus-Typen. Spätere Migration erweitert Rollen um `admin`. |
| 7–22 | Tabellen `profiles`, `conversations`, `messages` samt Fremdschlüsseln, Längenprüfungen und Zeitstempeln. |
| 23–27 | Indizes beschleunigen Benutzerlisten, Warteschlange und Nachrichtensortierung. |
| 29–31 | Privates Schema; anonyme Nutzer erhalten keinen direkten Zugriff. |
| 33–35 | Trigger erstellt nach Auth-Registrierung automatisch Profil. |
| 36–37 | `is_moderator`: prüft angemeldete ID und Rolle Moderator/Admin. |
| 38–39 | `can_access_conversation`: Besitzer, zugewiesener Moderator oder Team. |
| 40–43 | `accept_conversation`: Rollenprüfung; atomisches Update nur von `waiting`; Fehler, wenn bereits vergeben. |
| 44–48 | `close_conversation`: nur Besitzer/zugewiesener Moderator; setzt `closed` und Zeit. |
| 50–56 | Aktiviert RLS und definiert Lesen/Ändern/Erstellen/Senden. |
| 58–71 | Entzieht breite Funktionsrechte und vergibt nur benötigte Rechte an `authenticated`. |
| 72 | Aktiviert Realtime für Gespräche und Nachrichten. |
| 73 | Beispiel zur manuellen Erstbeförderung eines vertrauenswürdigen Moderators. |

## Upgrades

- **`upgrade-v2.sql`:** ergänzt Adminrolle, Verfügbarkeit, `appointments`; erstellt Rollenprüfungen und geschützte RPCs; erneuert Policies.
- **`upgrade-v3-notifications.sql`:** erstellt `device_push_tokens` und `notification_events`, Indizes und RLS; Push-Tokens gehören ausschließlich zum eingeloggten Teamkonto.
- **`upgrade-v4-admin-chat.sql`:** ersetzt `private.is_moderator`, sodass sowohl `moderator` als auch `admin` Chatannahme und Teamzugriff besitzen.

## `notify-moderators/index.ts` – Zeilen 1–148

| Zeilen | Erklärung |
|---:|---|
| 1 | Importiert Supabase serverseitig über Deno/NPM. |
| 3–8 | CORS- und JSON-Header. |
| 10–11 | `json`: erzeugt einheitliche JSON-Responses. |
| 13–20 | `secretKey`: liest Server-Schlüssel aus Supabase-Umgebung; dieser Schlüssel darf nie ins Frontend. |
| 22–24 | Startet HTTP-Funktion; beantwortet Preflight; erlaubt nur POST. |
| 26–35 | Liest Bearer-Token und validiert die anfragende Sitzung. |
| 37–40 | Validiert `conversation_id`. |
| 42–49 | Lädt Gespräch; erlaubt nur dessen Besitzer; versendet nur bei `waiting`. |
| 51–61 | Liest/erstellt Versandereignis und verhindert doppelte vollständige Zustellung. |
| 63–68 | Ermittelt ausschließlich Moderator-/Admin-IDs. |
| 70–102 | Liest aktivierte eindeutige Gerätetokens; baut inhaltsneutrale Expo-Pushs; sendet; speichert Zeitpunkt und Anzahl. |
| 104–130 | Wenn Resend-Secrets vorhanden sind: ermittelt Team-E-Mails über Auth-Admin; sendet eine allgemeine E-Mail ohne Thema/Nachricht; speichert Ergebnis. |
| 132–138 | Aktualisiert Versandprotokoll. |
| 140–143 | Antwortet mit Anzahl der Zustellungen und E-Mail-Konfigurationsstatus. |
| 144–147 | Loggt Serverfehler und gibt HTTP 500 zurück. |

## Wichtige Regel beim Ändern

Frontend-Prüfungen machen die Oberfläche verständlich, aber **Sicherheit entsteht in RLS und serverseitigen RPC-Funktionen**. Wenn eine neue Rolle oder Aktion hinzukommt, müssen Web/App **und** SQL-Regeln gemeinsam geprüft werden.
