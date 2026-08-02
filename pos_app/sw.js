// Service worker — installable POS.
// Network-first for the app HTML so redeploys appear on the next open
// (no cache-clearing). Cache-first for static assets. Supabase always live.
const CACHE = "pos-shell-v4";
const SHELL = [
  "./",
  "./index.html",
  "./config.js",
  "./manifest.json",
  "./icons/icon-192.png",
  "./icons/icon-512.png"
];

self.addEventListener("install", (e) => {
  e.waitUntil(caches.open(CACHE).then((c) => c.addAll(SHELL)).then(() => self.skipWaiting()));
});

self.addEventListener("activate", (e) => {
  e.waitUntil(
    caches.keys().then((keys) =>
      Promise.all(keys.filter((k) => k !== CACHE).map((k) => caches.delete(k)))
    ).then(() => self.clients.claim())
  );
});

self.addEventListener("fetch", (e) => {
  const req = e.request;
  const url = new URL(req.url);

  // Never cache Supabase / API / auth / storage calls — always fresh.
  if (url.hostname.includes("supabase") || url.pathname.includes("/rest/") ||
      url.pathname.includes("/auth/") || url.pathname.includes("/storage/")) {
    return; // default network
  }

    const isHTML = req.mode === "navigate" ||
      (req.headers.get("accept") || "").includes("text/html");

  if (isHTML) {
    // Network-first: fresh app on every open; fall back to cache when offline.
    e.respondWith(
      fetch(req).then((res) => {
        const copy = res.clone();
        caches.open(CACHE).then((c) => c.put("./index.html", copy));
        return res;
      }).catch(() => caches.match("./index.html"))
    );
    return;
  }

  // Cache-first for static assets; fetch and cache on first miss.
  e.respondWith(
    caches.match(req).then((hit) => hit || fetch(req).then((res) => {
      const copy = res.clone();
      caches.open(CACHE).then((c) => c.put(req, copy));
      return res;
    }))
  );
});
