# Haven

Professionelle, dreisprachige Plattform für vertrauliche Gespräche mit echten Moderatoren.

## Enthalten

- Vite 8 und Supabase Auth/Realtime
- Gastzugang über anonyme Supabase-Konten
- Registrierung und Login per E-Mail
- Deutsch, Englisch und Arabisch mit RTL-Layout
- Private Warteschlange und Moderator-Dashboard
- Echtzeit-Nachrichten und Row Level Security
- Responsives Design und sichtbare Krisenhinweise

## Lokal starten

```bash
npm install
cp .env.example .env
npm run dev
```

## Supabase einmalig einrichten

1. Ein Supabase-Projekt erstellen.
2. `supabase/schema.sql` vollständig im **SQL Editor** ausführen.
3. Unter **Authentication → Sign In / Providers → Anonymous** anonyme Logins aktivieren.
4. Project URL und öffentlichen Publishable-/Anon-Key in `.env` eintragen:

```env
VITE_SUPABASE_URL=https://DEIN-PROJEKT.supabase.co
VITE_SUPABASE_ANON_KEY=DEIN_OEFFENTLICHER_KEY
```

5. Einen Account über die Website registrieren und dessen UUID unter **Authentication → Users** kopieren.
6. Diesen Account im SQL Editor zum Moderator machen:

```sql
update public.profiles set role = 'moderator' where id = 'USER_UUID';
```

Danach kann sich der Moderator anmelden, wartende Gespräche übernehmen und live antworten.

## Produktionsbuild

```bash
npm run build
```

## Vor öffentlichem Betrieb

Zusätzlich notwendig sind geschulte Moderatoren, feste Dienstzeiten, ein Krisen- und Eskalationsablauf, Datenschutzinformation, Nutzungsbedingungen, Löschfristen, Missbrauchsschutz, länderspezifische Krisenkontakte sowie eine rechtliche und technische Sicherheitsprüfung.

Haven ist keine Therapie, medizinische Behandlung oder Notfallhilfe.


## Haven v2

The current version adds:

- full-screen member, moderator and admin workspaces
- appointment requests for registered members
- live moderator availability counts
- admin role management
- a darker, calmer multilingual design
- English, German and Arabic including RTL
- documented Supabase security and RLS rules

Documentation:

- `docs/PLANNING.md` – product plan, roles and roadmap
- `docs/CODE_GUIDE.md` – file map and practical change guide
- `supabase/upgrade-v2.sql` – database upgrade for an existing v1 project

The production frontend uses the public Supabase publishable key only. Never add a secret or service-role key to frontend files.
