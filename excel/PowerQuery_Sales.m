// ============================================================
//  Excel  <-  Supabase   (one-way, read-only sales feed)
//  MULTI-STORE version: each store has its own secret report
//  token. Open the app as admin -> Admin tab -> copy the
//  "Excel token" of the store you want, paste it below.
//  Wrong or missing token = zero rows, by design.
//
//  1. Excel: Data > Get Data > From Other Sources > Blank Query
//  2. Home > Advanced Editor > delete all > paste this > Done
//  3. Close & Load
//  4. First refresh: choose ANONYMOUS when asked how to connect
//     (auth is the apikey header, not an Excel login)
//  5. Refresh anytime with Data > Refresh All
// ============================================================
let
    ProjectUrl  = "https://odimxwlmzxdmomtwzozq.supabase.co",
    AnonKey     = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im9kaW14d2xtenhkbW9tdHd6b3pxIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODU2MDY3MTgsImV4cCI6MjEwMTE4MjcxOH0.5uSkEPGuVRAgJv7FzhNH8vWKN6Lrg2Eq_rS7ppL3zYA",
    ReportToken = "PASTE-YOUR-STORE-REPORT-TOKEN-HERE",

    Response = Web.Contents(ProjectUrl & "/rest/v1/rpc/posinv_sales_report_x", [
        Query   = [ token = ReportToken ],
        Headers = [ apikey = AnonKey, Authorization = "Bearer " & AnonKey ]
    ]),

    Json  = Json.Document(Response),
    Table = Table.FromRecords(Json),

    // Type the columns so pivots/reports behave.
    Typed = Table.TransformColumnTypes(Table, {
        {"order_id",     Int64.Type},
        {"order_on",     type datetimezone},
        {"status",       type text},
        {"customer",     type text},
        {"cashier",      type text},
        {"sku",          type text},
        {"product_name", type text},
        {"qty",          type number},
        {"unit_price",   type number},
        {"disc_pct",     type number},
        {"line_total",   type number},
        {"order_total",  type number}
    })
in
    Typed
