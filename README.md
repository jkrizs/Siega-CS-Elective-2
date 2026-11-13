# Hydro Flask Store – Flutter + Supabase

CS Elective 2 · Supabase-Auth Activity (branch `backend-auth`)

Products are stored in Supabase (PostgreSQL) in two related tables: `products`, and
`product_colors`, which links to it with a foreign key. The app loads each product
together with its colors in one query (`select('*, product_colors(*)')`) and keeps the
store's page and filter state in a `ProductProvider` (Provider / ChangeNotifier).

## Features in this branch

- **Price filter** – a price range slider. Releasing it runs
  `.gte('price', min).lte('price', max)`.
- **Pagination** – 6 products per page with `.range(from, to)` and
  `.count(CountOption.exact)` for the total, plus previous / page number / next buttons.
- **Category filter** – `.eq('category', ...)` (Bottles, Coffee, Tumblers), combined
  with the price filter.
- **Update / delete** – the ⋮ menu on a product page edits the title and price
  (`.update(...).eq('id', id)`) or deletes the product (`.delete().eq('id', id)`). Its
  colors are removed with it through `on delete cascade`.

Every query follows the order filter → `.order()` → `.range()`.

## Setup

1. Create a project at [supabase.com](https://supabase.com).
2. Open **SQL Editor → New query**, paste `supabase/products_schema.sql` and run it.
   It creates both tables, turns on Row Level Security with SELECT, INSERT, UPDATE and
   DELETE policies, and adds 14 products with their colors.
3. Copy the **Project URL** and **publishable (anon) key** from
   **Project Settings → API Keys** into `supabaseUrl` and `supabasePublishableKey` in
   `lib/main.dart`. Never use the secret / `service_role` key in the app.
4. Run:

   ```bash
   flutter pub get
   flutter run
   ```

## Authentication (branch `backend-auth`)

Customers must log in before they can shop. Sign-in is handled by Supabase Auth:

- **Email and password** – `supabase.auth.signUp(...)` to register and
  `supabase.auth.signInWithPassword(...)` to log in.
- **GitHub (third-party provider)** – `supabase.auth.signInWithOAuth(OAuthProvider.github)`.
- **Log out** – the account menu in the app bar calls `supabase.auth.signOut()`.

`SessionState` (`lib/state/session_state.dart`) listens to
`supabase.auth.onAuthStateChange`, and go_router's `redirect` sends anyone without a
session to `/login`.

### Auth setup

1. On GitHub: **Settings → Developer settings → OAuth Apps → New OAuth App**.
   - Homepage URL: `http://localhost:3000`
   - Redirect / callback URL: `https://<project-ref>.supabase.co/auth/v1/callback`
2. In Supabase: **Authentication → Sign In / Providers → GitHub**, enable it and paste
   the Client ID and Client Secret.
3. In **Authentication → URL Configuration**, set the Site URL to
   `http://localhost:3000` and add `http://localhost:3000/**` to the Redirect URLs.
4. Run the app on that port:

   ```bash
   flutter run -d chrome --web-port 3000
   ```
