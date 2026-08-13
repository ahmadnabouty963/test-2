# Haven Human Support

Haven is a calm, multilingual human-support service with guest and member chat, moderator/admin dashboards, appointments, realtime messages and privacy-safe moderator notifications.

## Website

```bash
npm install
npm run dev
npm run check
```

The website is a Vite application ready for Vercel. Supabase confirmation and password-recovery links use `location.origin`, so they follow the currently opened Vercel or custom-domain address.

## Before publishing on a new Vercel URL

Add the exact Vercel production address in Supabase under **Authentication → URL Configuration** as the Site URL and as an allowed redirect URL. Keep the previous URL temporarily until confirmation and password-reset have been retested.

## Structure

- `src/main.js` — website, authentication, chat, appointments and dashboards
- `src/style.css` — responsive design and colors
- `src/translations.js` — English, German and Arabic text
- `supabase/` — database schema, upgrades and moderator notification function
- `mobile/` — shared Expo source for Android and iPhone
- `docs/` — planning, code guide and launch checklist

## Secrets

The Supabase publishable browser key is intentionally public. Never commit a service-role key, Resend key, Vercel token, Apple key or Google service-account key.

See `docs/LAUNCH_CHECKLIST.md` before public use.
