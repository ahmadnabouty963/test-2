# Haven – Produktplanung

## Ziel

Haven ist ein ruhiger, mehrsprachiger Chat-Service für Menschen in schwierigen Lebenssituationen. Gespräche finden mit echten Moderatoren statt. Haven ersetzt keine Therapie, medizinische Versorgung oder Notfallhilfe.

## Zielgruppen

1. **Gast:** Sofortiger, anonymer Chat über ein temporäres Konto.
2. **Registriertes Mitglied:** Login, Chatverlauf und Terminplanung.
3. **Moderator:** Warteschlange, aktive Chats, Termine und eigener Online-Status.
4. **Admin:** Alle Moderator-Funktionen sowie Team- und Rollenverwaltung.

## Umgesetzte Funktionen

- Deutsch, Englisch und Arabisch mit RTL-Unterstützung
- Registrierung, Login und anonymer Gastzugang
- Realtime-Chat mit Warteschlange
- Großer Chat-Arbeitsbereich für Desktop und Mobilgeräte
- Moderator-Dashboard mit Warteschlange, aktiven Chats und Terminen
- Admin-Dashboard mit Benutzer- und Rollenverwaltung
- Terminplanung nur für registrierte Mitglieder
- Öffentliche Anzeige: Moderatoren insgesamt und aktuell online
- Dreisprachige Hoffnungsgeschichten als klar gekennzeichnete Platzhalter
- Krisenhinweis und klare Abgrenzung zu Therapie/Notfallhilfe
- Supabase RLS, rollenbasierte Funktionen und private Hilfsfunktionen
- Live-Browser-Benachrichtigung für eingeloggte Moderatoren
- Datenschutzfreundlicher Push-Dienst ohne Themen oder Chat-Inhalte
- Gemeinsame iPhone-/Android-App für Gäste, Mitglieder, Moderatoren und Admins
- Mobile Push-Registrierung nur für freigeschaltete Teamrollen

## Rollen und Rechte

| Funktion | Gast | Mitglied | Moderator | Admin |
|---|---:|---:|---:|---:|
| Sofort-Chat | Ja | Ja | Ja | Ja |
| Eigene Chats sehen | Temporär | Ja | Ja | Ja |
| Termin anfragen | Nein | Ja | Ja | Ja |
| Warteschlange sehen | Nein | Nein | Ja | Ja |
| Termine verwalten | Nein | Eigene stornieren | Ja | Ja |
| Verfügbarkeit setzen | Nein | Nein | Ja | Ja |
| Rollen ändern | Nein | Nein | Nein | Ja |

## Externe Freigaben vor dem Store-Start

- Vom Betreiber geliefertes Hero-Foto einsetzen
- Expo-Projekt-ID in mobile/app.json einsetzen und Push-Zertifikate über EAS hinterlegen
- Apple-Developer- und Google-Play-Konto für die Store-Veröffentlichung verbinden
- Für Moderator-E-Mails eine Absender-Domain bei Resend freigeben und zwei Supabase-Secrets setzen
- Freigegebene echte Erfahrungsberichte statt Platzhalter einpflegen
- Datenschutz, Impressum und Moderationsrichtlinien rechtlich prüfen
- Optional: feste Moderator-Zeitfenster statt frei wählbarer Terminanfragen

## Designrichtung

- Dunkles Waldgrün als Vertrauensfarbe
- Warme, gedämpfte Flächen statt klinischem Weiß
- Serifenschrift nur für emotionale Überschriften
- Klare Abstände, wenig visuelle Ablenkung
- Keine KI-Symbole, Roboter-Optik oder künstlich wirkende Texte
