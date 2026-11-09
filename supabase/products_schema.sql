create table if not exists public.products (
  id          text primary key,
  title       text          not null,
  category    text          not null,
  size        text          not null,
  price       numeric(10,2) not null check (price >= 0),
  rating      numeric(2,1)  not null default 0 check (rating between 0 and 5),
  badge       text          not null default '',
  image_url   text          not null,
  description text          not null default '',
  created_at  timestamptz   not null default now()
);

create table if not exists public.product_colors (
  id         bigint generated always as identity primary key,
  product_id text not null references public.products (id) on delete cascade,
  name       text not null,
  hex        text not null check (hex ~ '^[0-9A-Fa-f]{6}$'),
  image_url  text not null,
  position   int  not null default 0,
  unique (product_id, name)
);

create index if not exists products_price_idx          on public.products (price);
create index if not exists products_category_idx       on public.products (category);
create index if not exists product_colors_product_idx  on public.product_colors (product_id);

alter table public.products       enable row level security;
alter table public.product_colors enable row level security;

drop policy if exists "Products are readable by everyone" on public.products;
create policy "Products are readable by everyone"
  on public.products for select to anon, authenticated using (true);

drop policy if exists "Products can be inserted" on public.products;
create policy "Products can be inserted"
  on public.products for insert to anon, authenticated with check (true);

drop policy if exists "Products can be updated" on public.products;
create policy "Products can be updated"
  on public.products for update to anon, authenticated using (true) with check (true);

drop policy if exists "Products can be deleted" on public.products;
create policy "Products can be deleted"
  on public.products for delete to anon, authenticated using (true);

drop policy if exists "Product colors are readable by everyone" on public.product_colors;
create policy "Product colors are readable by everyone"
  on public.product_colors for select to anon, authenticated using (true);

drop policy if exists "Product colors can be inserted" on public.product_colors;
create policy "Product colors can be inserted"
  on public.product_colors for insert to anon, authenticated with check (true);

drop policy if exists "Product colors can be updated" on public.product_colors;
create policy "Product colors can be updated"
  on public.product_colors for update to anon, authenticated using (true) with check (true);

drop policy if exists "Product colors can be deleted" on public.product_colors;
create policy "Product colors can be deleted"
  on public.product_colors for delete to anon, authenticated using (true);

insert into public.products
  (id, title, category, size, price, rating, badge, image_url, description)
values
  ('1', 'Standard Mouth', 'Bottles', '21 oz', 34.95, 4.8, 'NEW', 'assets/products/standard_carnation.png', 'The ideal companion for everyday hydration. Standard mouth opening fits most backcountry water filters and fits easily in standard car cup holders.'),
  ('2', 'Wide Mouth', 'Bottles', '32 oz', 44.95, 4.9, 'BEST SELLER', 'assets/products/wide_indigo.png', 'Our largest everyday hydration bottle. Wide mouth opening allows quick filling, ice insertion, and easy cleaning.'),
  ('3', 'Flex Straw Cap', 'Bottles', '24 oz', 39.95, 4.7, 'LEAKPROOF', 'assets/products/straw_pink.png', 'Sip anywhere with leakproof straw cap design. Keeps drinks icy cold with double-wall insulation while offering effortless hydration on the go.'),
  ('4', 'Coffee Flex Sip', 'Coffee', '20 oz', 34.95, 4.6, 'HOT + COLD', 'assets/products/coffee_olive.png', 'Engineered for hot beverages. Fits under most coffee brewing systems and ensures leakproof travel so you can sip your favorite brew with confidence.'),
  ('5', 'All Around Tumbler', 'Tumblers', '28 oz', 32.95, 4.8, 'POPULAR', 'assets/products/tumbler_pacific.png', 'From morning smoothie to evening mocktail, this tumbler keeps temperatures locked in for hours with splash-resistant press-in lid.'),
  ('6', 'Trail Series Lightweight', 'Bottles', '32 oz', 49.95, 4.9, 'LIGHTWEIGHT', 'assets/products/trail_obsidian.jpg', '25% lighter than standard 32 oz bottles. Engineered for backcountry hikers and backpackers seeking ultralight hydration without sacrificing durability.'),
  ('7', 'Standard Mouth', 'Bottles', '24 oz', 37.95, 4.7, 'CLASSIC', 'assets/products/standard_white.png', 'A taller take on the everyday standard mouth bottle with the same leakproof cap and TempShield insulation.'),
  ('8', 'Wide Mouth', 'Bottles', '20 oz', 34.95, 4.7, 'COMPACT', 'assets/products/wide_clementine.png', 'A compact wide mouth bottle that fits bike cages and bag pockets while still taking ice cubes with ease.'),
  ('9', 'Wide Mouth', 'Bottles', '40 oz', 49.95, 4.8, 'BIG CAPACITY', 'assets/products/wide_black.png', 'Enough water for a full day out. The wide opening makes filling, adding ice and cleaning quick.'),
  ('10', 'Flex Straw Cap', 'Bottles', '32 oz', 44.95, 4.8, 'NEW', 'assets/products/straw_spearmint.png', 'The leakproof straw cap bottle in a bigger size for long workdays and gym sessions.'),
  ('11', 'Coffee Flex Sip', 'Coffee', '12 oz', 29.95, 4.6, 'TRAVEL', 'assets/products/coffee_snapper.png', 'A small travel mug sized for a single cup of coffee, with a leakproof flex sip lid.'),
  ('12', 'All Around Tumbler', 'Tumblers', '20 oz', 29.95, 4.7, 'POPULAR', 'assets/products/tumbler_lupine.png', 'A smaller tumbler for coffee, smoothies or iced tea, with a splash-resistant press-in lid.'),
  ('13', 'Trail Series Lightweight', 'Bottles', '24 oz', 44.95, 4.8, 'LIGHTWEIGHT', 'assets/products/trail_cobalt.jpg', 'A lighter, smaller Trail Series bottle for day hikes and trail runs.'),
  ('14', 'All Around Tumbler', 'Tumblers', '40 oz', 39.95, 4.7, 'NEW', 'assets/products/tumbler_olive.png', 'Our biggest tumbler keeps drinks cold through long drives and long days.')
on conflict (id) do nothing;

insert into public.product_colors
  (product_id, name, hex, image_url, position)
values
  ('1', 'Carnation', 'DFACB4', 'assets/products/standard_carnation.png', 0),
  ('1', 'Indigo', '1E365D', 'assets/products/standard_indigo.png', 1),
  ('1', 'White', 'F0F0F0', 'assets/products/standard_white.png', 2),
  ('2', 'Indigo', '1E365D', 'assets/products/wide_indigo.png', 0),
  ('2', 'Black', '222222', 'assets/products/wide_black.png', 1),
  ('2', 'Clementine', 'F0753F', 'assets/products/wide_clementine.png', 2),
  ('3', 'Carnation', 'DFACB4', 'assets/products/straw_pink.png', 0),
  ('3', 'Spearmint', '74C2A8', 'assets/products/straw_spearmint.png', 1),
  ('3', 'Snapper', '8B2B43', 'assets/products/straw_snapper.png', 2),
  ('4', 'Olive', '76834F', 'assets/products/coffee_olive.png', 0),
  ('4', 'Snapper', '813647', 'assets/products/coffee_snapper.png', 1),
  ('5', 'Pacific Blue', '4C6988', 'assets/products/tumbler_pacific.png', 0),
  ('5', 'Lupine', '745DB0', 'assets/products/tumbler_lupine.png', 1),
  ('5', 'Olive', '748147', 'assets/products/tumbler_olive.png', 2),
  ('6', 'Obsidian', '5A4C40', 'assets/products/trail_obsidian.jpg', 0),
  ('6', 'Cobalt', '334CB8', 'assets/products/trail_cobalt.jpg', 1),
  ('7', 'White', 'F0F0F0', 'assets/products/standard_white.png', 0),
  ('7', 'Indigo', '1E365D', 'assets/products/standard_indigo.png', 1),
  ('8', 'Clementine', 'F0753F', 'assets/products/wide_clementine.png', 0),
  ('8', 'Black', '222222', 'assets/products/wide_black.png', 1),
  ('9', 'Black', '222222', 'assets/products/wide_black.png', 0),
  ('9', 'Indigo', '1E365D', 'assets/products/wide_indigo.png', 1),
  ('10', 'Spearmint', '74C2A8', 'assets/products/straw_spearmint.png', 0),
  ('10', 'Snapper', '8B2B43', 'assets/products/straw_snapper.png', 1),
  ('11', 'Snapper', '813647', 'assets/products/coffee_snapper.png', 0),
  ('11', 'Olive', '76834F', 'assets/products/coffee_olive.png', 1),
  ('12', 'Lupine', '745DB0', 'assets/products/tumbler_lupine.png', 0),
  ('12', 'Pacific Blue', '4C6988', 'assets/products/tumbler_pacific.png', 1),
  ('13', 'Cobalt', '334CB8', 'assets/products/trail_cobalt.jpg', 0),
  ('13', 'Obsidian', '5A4C40', 'assets/products/trail_obsidian.jpg', 1),
  ('14', 'Olive', '748147', 'assets/products/tumbler_olive.png', 0),
  ('14', 'Pacific Blue', '4C6988', 'assets/products/tumbler_pacific.png', 1)
on conflict (product_id, name) do nothing;
