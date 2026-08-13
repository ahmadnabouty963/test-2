# Haven – Code- und Änderungsleitfaden

## Projektstruktur

| Datei | Aufgabe |
|---|---|
| app/page.tsx | Erstellt den App-Container und lädt Haven im Browser. |
| app/haven-client.js | Seitenaufbau, Login, Chat, Termine und Dashboards. |
| app/translations.js | Alle Texte für Englisch, Deutsch und Arabisch. |
| app/globals.css | Farben, Layout, Chat, Dashboards und Mobilansicht. |
| app/layout.tsx | Browser-Titel und allgemeines HTML-Layout. |
| supabase/upgrade-v2.sql | Datenbank-Erweiterung für Admins, Termine und Verfügbarkeit. |
| docs/PLANNING.md | Produktziel, Rollen und nächste Schritte. |

## Wichtige Bereiche in app/haven-client.js

- Öffentliche Startseite: Der große app.innerHTML-Block baut Header, Hero, Live-Zahlen, Ablauf, Geschichten, Sicherheit und Footer.
- Sprache: state.lang speichert die Sprache, t() holt Texte und translate() aktualisiert data-i18n. Arabisch setzt automatisch RTL.
- Login: authModal(), submitAuth(), guestModal() und startGuest().
- Chat: conversationHome(), createConversation(), openConversation(), renderConversation(), sendMessage() und subscribe().
- Termine: appointmentModal(), createAppointment() und appointmentRow().
- Team: staffDashboard() enthält Moderator- und Admin-Ansichten.

## Häufige Änderungen

### Farben

Ganz oben in app/globals.css stehen die Variablen --night, --forest, --sage und --paper. Eine Änderung dort wirkt auf die gesamte Seite.

### Texte

In app/translations.js denselben Schlüssel in en, de und ar ändern, zum Beispiel heroTitle.

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

## Lokal starten

1. npm install
2. npm run dev
3. npm run build

Vor jeder Veröffentlichung muss npm run build ohne Fehler laufen.
