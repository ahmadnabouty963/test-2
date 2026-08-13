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

## Nächste sinnvolle Schritte

- Vom Betreiber geliefertes Hero-Foto einsetzen
- Erstes Betreiberkonto als Admin freischalten
- Anonyme Anmeldung in Supabase aktivieren
- E-Mail-Vorlagen und Absender-Domain konfigurieren
- Freigegebene echte Erfahrungsberichte statt Platzhalter einpflegen
- Datenschutz, Impressum und Moderationsrichtlinien rechtlich prüfen
- Optional: feste Moderator-Zeitfenster statt frei wählbarer Terminanfragen

## Designrichtung

- Dunkles Waldgrün als Vertrauensfarbe
- Warme, gedämpfte Flächen statt klinischem Weiß
- Serifenschrift nur für emotionale Überschriften
- Klare Abstände, wenig visuelle Ablenkung
- Keine KI-Symbole, Roboter-Optik oder künstlich wirkende Texte

