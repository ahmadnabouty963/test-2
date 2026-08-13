# Haven – Checkliste für die öffentliche Freigabe

Stand: 13. August 2026

## Technischer Prüfstand

| Prüfung | Ergebnis |
|---|---|
| Produktions-Build und Hosting-Artefakt | Bestanden |
| ESLint | Bestanden |
| Web-Abhängigkeiten (`npm audit`) | 0 bekannte Schwachstellen |
| Deutsch, Englisch, Arabisch | Je 191 vollständige Textschlüssel |
| Datenbanktabellen | RLS auf allen öffentlichen Tabellen aktiv |
| Fremdzugriff auf Chats | Blockiert |
| Fremdes Schreiben in Chats | Blockiert |
| Gast darf Termine buchen | Blockiert |
| Normales Konto darf Moderator-Aktionen ausführen | Blockiert |
| Moderator übernimmt Warteschlangen-Chat | Bestanden |
| Realtime-Nachrichten in beide Richtungen | Bestanden |
| Schreiben nach Gesprächsende | Blockiert |
| Moderator-Benachrichtigungsfunktion | HTTP 200, Bestanden |
| Temporäre Testkonten und Testdaten | Vollständig gelöscht |
| Expo-Projektprüfung | 20/20 bestanden |

## Vor dem öffentlichen Start vom Betreiber zu erledigen

### 1. Eigene Adresse ohne `chatgpt`

Eine eigene Domain kaufen, zum Beispiel `haven-support.de` oder eine andere freie Adresse. Danach nur den exakten Domainnamen mitteilen. Die Domain wird mit der vorhandenen Website verbunden; anschließend zeigt der Hosting-Dienst die DNS-Einträge, die beim Domainanbieter einzutragen sind. Die aktuelle Adresse bleibt bis zur erfolgreichen SSL-Aktivierung erreichbar.

### 2. Supabase-URLs nach der Domain-Verbindung

In Supabase **Authentication → URL Configuration**:

- **Site URL:** die neue HTTPS-Adresse
- **Redirect URLs:** die neue Adresse mit `/**` ergänzen
- die bisherige Adresse vorerst zusätzlich behalten, bis Login, E-Mail-Bestätigung und Passwort-Reset auf der neuen Domain getestet wurden

### 3. Auth-Schutz einschalten

In Supabase:

- **Authentication → Providers → Email:** E-Mail-Bestätigung eingeschaltet lassen
- **Authentication → Attack Protection:** Schutz gegen kompromittierte Passwörter aktivieren
- CAPTCHA/Cloudflare Turnstile für Registrierung und anonyme Gastkonten einrichten
- sinnvolle Auth-Rate-Limits prüfen
- im eigenen Supabase-Konto MFA aktivieren

### 4. Eigener E-Mail-Versand

Vor echtem Besucherbetrieb einen eigenen SMTP-Anbieter und eine bestätigte Absender-Domain einrichten. Für Moderator-E-Mails zusätzlich in Supabase die Function-Secrets `RESEND_API_KEY` und `HAVEN_EMAIL_FROM` setzen. Keine Schlüssel per Chat senden oder in GitHub speichern.

### 5. Recht und Verantwortung

Vor Veröffentlichung müssen echte Betreiberangaben vorliegen und rechtlich geprüft werden:

- Impressum bzw. Anbieterkennzeichnung
- Datenschutzerklärung einschließlich Supabase, Hosting, E-Mail und Push
- Mindestalter und Einwilligungsregeln
- Lösch- und Aufbewahrungsfrist für Konten, Chats und Termine
- Moderations-, Eskalations- und Krisenrichtlinie
- zuständige Notfallkontakte für alle Zielregionen

Ohne diese Angaben sollen keine erfundenen Namen, Adressen oder rechtlichen Texte veröffentlicht werden.

### 6. Betrieb am ersten Tag

- Mindestens zwei freigeschaltete Moderatoren anlegen
- Moderator meldet sich an, öffnet das Team-Dashboard und setzt den Status auf **Online**
- Browser-Benachrichtigungen erlauben und das Dashboard geöffnet lassen
- Einen letzten Gast-Chat von einem zweiten Gerät durchführen
- Verantwortliche Person für technische Ausfälle und dringende Moderationsfälle bestimmen
- Täglich offene Chats, Termine und Benachrichtigungsfehler kontrollieren

## Mobile App

Der gemeinsame iPhone-/Android-Quellcode und die Expo-Konfiguration sind vorbereitet; die Expo-Projektprüfung besteht. Ein Store-Release ist noch nicht freigegeben, weil folgende externe Voraussetzungen fehlen:

- echte Expo/EAS-Projekt-ID statt `REPLACE_WITH_EAS_PROJECT_ID`
- Apple-Developer-Konto und Google-Play-Developer-Konto
- Push-Zertifikate/FCM-Konfiguration
- App-Symbole, Splashscreen, Store-Texte, Datenschutz-URL und Screenshots
- echte Geräteprüfung für iOS und Android
- aktuell gemeldete Schwachstelle in einem Metro-Buildwerkzeug (`image-size`) mit kompatiblem Expo-Update beheben; das Werkzeug läuft nicht in der veröffentlichten Website

Die Website kann unabhängig von den App Stores gestartet werden. Die App sollte erst nach echten Geräte- und Push-Tests eingereicht werden.

## Supabase-Tarif

Für einen öffentlichen Hilfsdienst ist der kostenlose Tarif nur zum Testen sinnvoll. Vor dem Start Backup-Verfügbarkeit, Projekt-Pausierung, Auth-/E-Mail-Limits und Supportumfang prüfen und bei Bedarf auf einen bezahlten Tarif wechseln.
