# Mobile POS with Inventory — Build & Deploy Guide

Turn your Excel **POS With Inventory** into a live, installable mobile app. Free, no code, no app store. Sales flow one-way back into Excel for reporting.

**The free chain:** Supabase (database + login) → installable PWA (product grid, barcode scan, cart, tax, checkout) → Netlify Drop (live HTTPS) → install on phone → ring up a sale → Power Query pulls it into Excel.

---

## What's in this folder

```
pos_app/
├─ index.html          ← the whole app (login, grid, scan, cart, checkout)
├─ config.js           ← paste your Supabase URL + anon key + tax here
├─ manifest.json       ← makes it installable
├─ sw.js               ← service worker (install + offline shell)
├─ icons/              ← app icons
├─ supabase/
│  ├─ 01_schema.sql            ← run FIRST (tables, inventory view, security)
│  ├─ 02_seed_products_full.sql  ← all 624 real products
│  ├─ 02_seed_products_demo.sql  ← ~42 items, clean set for filming
│  ├─ 03_seed_entities.sql       ← customers + vendors
│  ├─ 04_add_images.sql          ← adds the image_url column
│  ├─ 05_seed_demo_real.sql      ← 22 real products w/ real photos + barcodes
│  └─ 06_products_and_storage.sql← add-product writes + photo storage bucket
├─ images/             ← 6 branded category tiles (fallback visuals)
└─ excel/
   └─ PowerQuery_Sales.m ← the Excel → Supabase live sync query
```

---

## Step 1 — Supabase (database + login) · ~4 min

1. Go to **supabase.com** → **New project**. Pick a name, a strong DB password, a region. Free tier is fine.
2. Left sidebar → **SQL Editor** → **New query**.
3. Paste all of **`supabase/01_schema.sql`** → **Run**. (Creates tables, the live inventory view, the sales report view, and read-only security.)
4. New query → paste **`supabase/02_seed_products_full.sql`** (or the `_demo` one for filming) → **Run**.
5. New query → paste **`supabase/03_seed_entities.sql`** → **Run**.
5b. New query → paste **`supabase/04_add_images.sql`** → **Run** (adds the image column).
5c. New query → paste **`supabase/05_seed_demo_real.sql`** → **Run** (22 real products with real photos + barcodes).
5d. New query → paste **`supabase/06_products_and_storage.sql`** → **Run** (lets cashiers add new products by scanning, and creates the photo bucket).
6. Left sidebar → **Project Settings → API**. Copy two things:
   - **Project URL** (e.g. `https://abcd1234.supabase.co`)
   - **anon / public** key (the long "publishable" one — safe for the browser).

> Auth note: by default Supabase asks new users to confirm their email. For a smooth on-camera signup, go to **Authentication → Providers → Email** and turn **"Confirm email" OFF** while filming, so a new cashier logs in instantly.

## Step 2 — Configure the app · ~1 min

Open **`config.js`**, paste your two values:

```js
SUPABASE_URL: "https://abcd1234.supabase.co",
SUPABASE_ANON_KEY: "eyJhbGciOi...your-anon-key...",
```

Store name, tax rate (already 8.25%), and footer message are here too — tweak if you like. Save.

## Step 3 — Test locally (optional) · 1 min

The app needs to be *served* (not opened as a file) for the camera and service worker. Quickest:
- In the `pos_app` folder run: `python -m http.server 5500` then open `http://localhost:5500`.
- Or just skip straight to Netlify Drop below — that's the real test anyway.

## Step 4 — Go live: **Netlify Drop** · ~30 sec  ⭐ the reveal

1. Go to **app.netlify.com/drop**.
2. **Drag the entire `pos_app` folder** onto the page.
3. Done — you get a live **HTTPS** URL like `https://your-name-1234.netlify.app`. That HTTPS is what makes phone-install and the camera work.

> Make it permanent later: **Cloudflare Pages** → Create project → Upload assets (or connect a Git repo) → drop the same folder. Free, fast global CDN, cleaner custom URL. Netlify = the fast reveal, Cloudflare = the permanent home.

## Step 5 — Install on your phone · ~20 sec  ⭐ the "wow"

1. Open the live URL on your phone.
2. **iPhone (Safari):** Share → **Add to Home Screen**.
   **Android (Chrome):** menu ⋮ → **Install app** (or the install banner).
3. It now opens full-screen from your home screen — looks and feels native. No app store.

## Step 6 — Sign in & ring up a sale · ⭐ real users

1. First time: **Create an account** (name + email + password) → you're the cashier.
2. Tap products (filter by category, search, or **scan** a barcode with the ▣ button) → they land in the cart.
3. Open the cart → tax auto-adds at 8.25% → **Charge** → ✅ receipt with an order number. Inventory drops instantly.

## Step 7 — Sales sync into Excel · ⭐ the power move

1. Open Excel → **Data → Get Data → From Other Sources → Blank Query**.
2. **Home → Advanced Editor** → delete everything → paste **`excel/PowerQuery_Sales.m`**. If Claude built this folder for you, it is **already filled in with YOUR Project URL + anon key** — nothing to edit. (Grabbed the files on their own? Replace the two placeholder lines with **your own** URL + anon key from **Supabase → Settings → API** — the same two values that go in `config.js`. Mine won't work for you; every project's are unique.)
3. **Done → Close & Load**.
4. **First refresh only — the step everyone misses:** Excel asks how to connect to the data source → choose **Anonymous → Connect**. (Auth is the `apikey` header, not an Excel login, so *Anonymous* is correct and safe.)
5. Your live sales land as an Excel table. Build pivots/charts/your existing report sheets on top of it.
6. Ring another sale on the phone → in Excel hit **Data → Refresh All** → the new sale appears. That's the one-way sync.

> Security: the anon key here can only **read** the `posinv_sales_report` view. Row-Level Security grants no insert/update/delete to it, so Excel can never write back. One-way by design.
>
> Shared project: every object this build creates is prefixed **`posinv_`** (e.g. `posinv_products`, `posinv_orders`), so it sits alongside your other tables without collisions. The `drop … if exists` lines at the top of the schema only target `posinv_` objects — your existing tables are never touched.

---

## Product images

Every product shows a picture, three ways (in priority order):

1. **A real photo** — if the product has an `image_url` (the 22 real demo items already do). Add your own: paste a URL into the `image_url` column of any row in `posinv_products`.
2. **A branded category tile** — the 6 SVGs in `images/` (Drinks, Bakery, Meat, Dairy, Frozen, Produce). Every one of the 624 products falls back to its category tile, so nothing ever looks empty.
3. **Live scan lookup** — scan a barcode that isn't in your catalog and the app fetches the product name + photo live from **Open Food Facts** (free, open data), asks your price, and drops it into the sale. Great on camera: scan any real item off a shelf and it just appears.

To add your own photos in bulk, put an `image_url` on any rows you like — the app uses the photo when present and the tile otherwise.

**Add products on the fly:** scan a barcode that isn't in your catalog (or tap the **＋** button) and the app opens an Add-Product form — pre-filled from Open Food Facts when recognized. Set price + snap a photo and it saves to your catalog for good. Requires `06_products_and_storage.sql`.

---

## Troubleshooting

- **"Add your Supabase URL…" on the login screen** → `config.js` still has placeholders. Paste your real values and re-deploy.
- **Login says email not confirmed** → turn off "Confirm email" (Step 1 note), or click the confirmation link.
- **Camera won't open** → the site must be **HTTPS** (Netlify/Cloudflare give this free) and you must **Allow** camera. You can always type the SKU into the search box instead.
- **No "Install app" option** → must be HTTPS + `manifest.json` and icons present (they are). On iPhone use Safari's *Add to Home Screen*.
- **Updates not showing on the installed app** → the service worker is network-first, so a redeploy appears on the next reopen automatically. If ever stuck: **Android** — long-press the app icon → *Site settings* → clear **"stored data"**, then reopen. **iPhone** — remove the home-screen icon and re-add it from Safari. Reinstalling is never required for updates, only as a last-resort reset.
- **Power Query error 401** → the anon key or URL is wrong, or you pasted the `service_role` key by mistake — use the **anon/public** key.
- **First refresh asks you to sign in** → pick **Anonymous** (auth is the `apikey` header, not an Excel login).
- **Refresh loads no rows / permission denied** → the anon role needs read on the view. Supabase → SQL Editor: `grant select on posinv_sales_report to anon;` then Refresh All. (SELECT only — one-way write-protection unchanged.)

---

## On-camera build order (retention map)

Follow the plan: **open on the ending, then rebuild it forward with escalating payoffs.**

**0:00–0:20 — COLD OPEN on the payoff.** Phone in hand: scan a product, tap Charge, ✅. Cut to the laptop: Excel **Refresh All** → that exact sale appears. *"By the end of this video you'll have built exactly this — live, free, no code, installs on your phone, and every sale lands in Excel. Let's build it backwards from your finished POS."*

**Beat 1 — The finished Excel POS (fast).** Show the `POS_With_Inventory.xlsm` you already built. *Don't rebuild it.* "This is the endpoint everyone knows. Today we make it mobile." (30–45 sec.)

**Beat 2 — Database in 4 minutes (Supabase).** New project → paste `01_schema.sql` → paste the products seed → "624 real products, live." Small payoff: data is in the cloud.

**Beat 3 — It works in the browser.** Drop in URL + key in `config.js`, open locally → category grid loads, add to cart, tax, charge. Payoff: *it's a working POS in a browser.*

**Beat 4 — It's on the internet (Netlify Drop).** ⭐ Drag the folder → live HTTPS URL in seconds. Payoff: *"anyone in the world can open this now."* (This is what last time skipped.)

**Beat 5 — Install on the phone.** ⭐ Add to Home Screen → open full-screen. Payoff: *"it's an app — no app store."* Tease ahead: *"but a POS needs real users — watch this."*

**Beat 6 — Login (real users).** Create a cashier account, sign in. Payoff: *multi-user, secure.*

**Beat 7 — Ring a real sale on the phone → Excel.** ⭐⭐ The two anchors together: scan → charge on the phone, then Excel **Refresh All** → sale flows in, inventory drops. Payoff: *the full loop, live.*

**Close — Next week's Members video.** *"I'll show you how to build a sales page and monetize this in next week's Members video. You've got the finished, mobile, free, installable POS — now go sell it.*
