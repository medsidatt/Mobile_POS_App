# Mobile_POS_App

Multi-store mobile Point-of-Sale platform (PWA) — sell subscriptions to stores, each with its own isolated catalog, inventory, and sales. Built on Supabase (Postgres + Auth), hosted free on Netlify; installable on any phone, no app store.

## Features

- Installable PWA (Add to Home Screen) with login per user
- Multi-tenant SaaS: every signup owns a store; data isolated by Postgres row-level security
- Subscriptions: new stores start **disabled**; the platform admin (`mohamedaloueimin@gmail.com`) activates or disables them from the in-app **Admin** tab
- Signup asks the store name and what it sells (any business type — vehicle keys, grocery, phones…)
- Category grid, search, barcode scanning, add-product-by-scan with photo
- Cart with per-line discounts, cash tender + change, printable receipts
- SALE / PURCHASE modes — inventory is derived: `opening stock + purchases − sales`
- Refund / void, low-stock view
- One-way Excel reporting via Power Query (per-store secret token, read-only)
- Currency: MRU (Mauritania) · no tax

## Structure

```
pos_app/                  the app (Netlify publishes this folder — see netlify.toml)
  index.html              the whole app
  config.js               Supabase URL + anon key + store settings  ← fill this
  manifest.json  sw.js    PWA install + service worker
  icons/ images/          app icons + category tiles
supabase/setup.sql        the ONLY database script — run once in a fresh project
excel/PowerQuery_Sales.m  Excel ← Supabase live sales feed (per-store token)
netlify.toml              tells Netlify to publish pos_app/
```

## Setup from zero

1. **Supabase** — create a free project → SQL Editor → run all of `supabase/setup.sql` once.
   Then Authentication → Sign In / Providers → Email → turn **off** "Confirm email".
2. **Config** — put your Project URL + anon key (Project Settings → API Keys) into `pos_app/config.js`.
3. **Netlify** — Add new project → Import from GitHub → this repo. Settings come from
   `netlify.toml` automatically. Every push to `main` redeploys.
4. **Admin** — sign up in the app with the admin email; the 🏪 Admin tab appears.
   Other signups create their stores and wait until you tap **Activate subscription**.

The anon key in `config.js` is the public browser key — safe to commit, protected by row-level security.
