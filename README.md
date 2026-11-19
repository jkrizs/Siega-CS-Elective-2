# Hydro Flask Store – Flutter E-Commerce (Final Exam)

CS Elective 2 · Final Exam Project (branch `final-exam`)

A Hydro Flask bottle shop with two roles. **Admins** manage products, categories and
orders. **Customers** browse, filter, pick a color, build a cart, check out and see
their order history. Every new account starts as a customer.

| Area | Used |
| --- | --- |
| State management | Riverpod (`Provider`, `ChangeNotifierProvider`) |
| Navigation | go_router with login and role guards |
| Backend | Supabase Auth, Postgres, Row Level Security |
| Sign-in | Email and password, and Google |
| Images | Supabase Storage bucket `product-images` |

## Architecture

Screens read providers, providers call services, and only services talk to Supabase.

```
lib/
  models/      Product (with color options), Category, UserProfile, OrderModel, CartItem
  services/    auth_service, product_service, order_service  ← the only Supabase code
  state/       SessionState, ProductProvider, CartState, OrdersProvider
  providers/   app_providers.dart – the Riverpod providers that connect state to services
  router/      app_router.dart – login redirect, admin-only and customer-only routes
  screens/     login, home, product detail, cart, checkout confirmation, order history
  screens/admin/  product form, categories, store orders
  utils/       error_messages.dart – turns database errors into readable messages
  widgets/     product card, filters, pagination, drawer and home page sections
  theme/       app colors and the shared light and dark theme
supabase/
  products_schema.sql   tables, functions, trigger, RLS, storage policies and seed data
```

## Features

**Customer**
- Search, category filter, price range slider and pagination (6 per page), all done in
  the Supabase query (`.ilike`, `.eq`, `.gte` / `.lte`, `.range` with an exact count).
- Product page with color choices. Stock is shown, and the cart never goes above it,
  even when the same product is added in different colors.
- Cart with quantity controls, checkout through `place_order`, a confirmation page
  with the order number and total, and an order history.
- The cart is emptied on log out.

**Admin**
- Add and edit products: name, description, price, stock, category, colors and an
  image file uploaded to Supabase Storage. Every field is validated.
- Delete products, with a confirmation that names the product.
- Manage categories: add, rename and delete.
- See every customer's orders and change the status (pending, done, cancelled).
- Admins have no cart and cannot place orders.

**Every screen** has loading, empty and error states. Permission errors from the
database are shown as "You don't have permission to do that." instead of raw SQL text.

## Security

Hiding admin buttons from customers is only the interface. The real rules are in the
database:

- **RLS is enabled on every table**, and every policy is for signed-in users only, so
  signed-out requests get nothing.
- `is_admin()` is `security definer`, so policies can call it without recursion.
- Customers can read and update only their own profile, and cannot change their
  `role_id` or `email`. Nobody can promote themselves to admin.
- Only admins can insert, update or delete products and categories, and only admins
  can upload, replace or delete product images.
- Customers can read only their own orders and order items. Admins can read all orders
  and update their status.
- There is no insert policy on `orders` or `order_items`. The only way to create an
  order is `place_order(items)`, which:
  - reads each product's **price, name and stock from the database** (the app sends
    only product ids, quantities and the chosen color),
  - locks those rows (`for update`) and checks stock per product across all colors,
  - saves the order and all its items, reduces stock, and sets the status to `done`
    in **one transaction**. If any item fails, nothing is saved,
  - stores the product name, color and unit price on each order item, so old orders
    stay correct after a product changes or is deleted,
  - refuses admin accounts.

## Setup

1. Create a Supabase project.
2. In **SQL Editor**, run `supabase/products_schema.sql`. It drops and recreates the
   tables, so only run the whole file on a fresh project.
3. Put the project URL and publishable key in `lib/main.dart`. Never put the secret /
   `service_role` key or the Google client secret in the app.
4. **Google sign-in**
   - In Google Cloud Console, create an OAuth client ID of type *Web application*.
   - Authorized JavaScript origin: `http://localhost:3000`
   - Authorized redirect URI: `https://<project-ref>.supabase.co/auth/v1/callback`
   - In Supabase, open **Authentication → Sign In / Providers → Google**, enable it and
     paste the client ID and secret.
5. In **Authentication → URL Configuration**, set the Site URL to
   `http://localhost:3000` and add `http://localhost:3000/**` to the Redirect URLs.
6. Run the app:

   ```bash
   flutter pub get
   flutter run -d web-server --web-port 3000
   ```

   Then open `http://localhost:3000` in Chrome.
7. Sign up, then make that account an admin in the SQL Editor:

   ```sql
   update public.profiles
      set role_id = (select id from public.roles where role = 'admin')
    where email = 'you@example.com';
   ```

   Log out and back in to see the admin screens.
