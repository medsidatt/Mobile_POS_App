# Mobile_POS_App

Multi-store mobile Point-of-Sale platform (PWA) — sell subscriptions to stores, each with its own isolated catalog, inventory, and sales. Built on Supabase (Postgres + Auth) with free HTTPS hosting; installable on any phone, no app store.

**Live:** https://rococo-starlight-741552.netlify.app/

## Features

- Installable PWA (Add to Home Screen) with login per cashier
- Multi-tenant SaaS: every user owns a store; data isolated by Postgres row-level security
- Subscriptions: new stores start disabled; the platform admin activates/disables them from the in-app **Admin** tab
- Category grid, search, barcode scanning, add-product-by-scan (with photo)
- Cart with per-line discounts, cash tender + change, printable receipts
- SALE / PURCHASE modes — inventory is derived: `opening stock + purchases − sales`
- Refund / void, low-stock view
- One-way Excel reporting via Power Query (per-store secret token, read-only)
- Currency: MRU (Mauritania) · no tax

## Structure

```
pos_app/            the deployable app (drag this folder onto Netlify)
  index.html        the whole app
  config.js         Supabase URL + anon key + store settings
  manifest.json     PWA install
  sw.js             service worker (network-first)
  icons/ images/    app icons + category tiles
supabase/           SQL — run 01→07 in order in the Supabase SQL Editor
excel/              PowerQuery_Sales.m — Excel ← Supabase live sales feed
BUILD_GUIDE.md      full deploy guide
```

## Deploy

1. Supabase: run `supabase/01_schema.sql` … `07_multi_store_saas.sql` in the SQL Editor.
2. Fill `pos_app/config.js` with your project URL + anon key.
3. Drag `pos_app/` onto Netlify Drop (or Cloudflare Pages).

The anon key in `config.js` is the public browser key — it is safe to expose and protected by row-level security.
