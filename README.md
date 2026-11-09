# Hydro Flask Store – Flutter + Supabase

CS Elective 2 · Supabase-Flutter Activity (branch `backend-filter-pagination`)

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
