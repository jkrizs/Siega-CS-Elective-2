-- ==============================================================
-- 1. DROP EXISTING CONFLICTING POLICIES & TABLES (CLEAN SLATE)
-- ==============================================================
drop policy if exists "Products are readable by everyone" on public.products;
drop policy if exists "Products can be inserted" on public.products;
drop policy if exists "Products can be updated" on public.products;
drop policy if exists "Products can be deleted" on public.products;
drop table if exists public.order_items cascade;
drop table if exists public.orders cascade;
drop table if exists public.product_colors cascade;
drop table if exists public.products cascade;
drop table if exists public.categories cascade;
drop table if exists public.profiles cascade;
drop table if exists public.roles cascade;

-- ==============================================================
-- 2. CREATE ROLES TABLE
-- ==============================================================
create table public.roles (
  id bigint generated always as identity primary key,
  role varchar(50) not null unique,
  created_at timestamptz not null default now(),
  encoded_by uuid references auth.users(id) on delete set null
);

-- ==============================================================
-- 3. CREATE PROFILES TABLE (Linked 1:1 to auth.users)
-- ==============================================================
create table public.profiles (
  id uuid primary key references auth.users(id) on delete cascade,
  created_at timestamptz not null default now(),
  email text,
  firstname text,
  role_id bigint not null references public.roles(id),
  lastname text
);

-- ==============================================================
-- 4. CREATE CATEGORIES TABLE
-- ==============================================================
create table public.categories (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  name text not null unique
);

-- ==============================================================
-- 5. CREATE PRODUCTS TABLE (Matching required schema)
-- ==============================================================
create table public.products (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  name text not null,
  description text not null default '',
  stock smallint not null default 0 check (stock >= 0),
  image_url text not null default '',
  category_id bigint references public.categories(id) on delete set null,
  price real not null check (price >= 0),
  colors jsonb not null default '[]'::jsonb
);

-- ==============================================================
-- 6. CREATE ORDERS TABLE
-- ==============================================================
create table public.orders (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  user_id uuid not null references public.profiles(id) on delete cascade,
  status text not null default 'done',
  total numeric(10, 2) not null check (total >= 0)
);

-- ==============================================================
-- 7. CREATE ORDER_ITEMS TABLE
-- ==============================================================
create table public.order_items (
  id bigint generated always as identity primary key,
  created_at timestamptz not null default now(),
  order_id bigint not null references public.orders(id) on delete cascade,
  product_id bigint references public.products(id) on delete set null,
  product_name text not null,
  color_name text,
  unit_price numeric(10, 2) not null check (unit_price >= 0),
  quantity bigint not null check (quantity > 0)
);

-- ==============================================================
-- 8. INDEXES FOR PERFORMANCE
-- ==============================================================
create index if not exists idx_profiles_role_id on public.profiles(role_id);
create index if not exists idx_products_category_id on public.products(category_id);
create index if not exists idx_orders_user_id on public.orders(user_id);
create index if not exists idx_order_items_order_id on public.order_items(order_id);

-- ==============================================================
-- 9. SEED INITIAL ROLES & CATEGORIES
-- ==============================================================
insert into public.roles (role) values ('customer'), ('admin');

insert into public.categories (name) values 
  ('Bottles'), 
  ('Coffee'), 
  ('Tumblers');

-- ==============================================================
-- 10. HELPER FUNCTION: is_admin()
-- ==============================================================
create or replace function public.is_admin()
returns boolean
language sql
security definer
set search_path = public
as $$
  select exists (
    select 1 
    from public.profiles p
    join public.roles r on p.role_id = r.id
    where p.id = auth.uid() and r.role = 'admin'
  );
$$;

-- ==============================================================
-- 11. TRIGGER: AUTO-CREATE PROFILE ON USER SIGN-UP
-- ==============================================================
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  default_role_id bigint;
begin
  select id into default_role_id from public.roles where role = 'customer' limit 1;

  insert into public.profiles (id, email, firstname, lastname, role_id)
  values (
    new.id,
    new.email,
    coalesce(new.raw_user_meta_data->>'firstname', new.raw_user_meta_data->>'full_name', ''),
    coalesce(new.raw_user_meta_data->>'lastname', ''),
    default_role_id
  );
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
  after insert on auth.users
  for each row execute function public.handle_new_user();

-- ==============================================================
-- 12. ATOMIC CHECKOUT FUNCTION (place_order)
-- ==============================================================
create or replace function public.place_order(items jsonb)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid := auth.uid();
  v_order_id bigint;
  v_total numeric(10, 2) := 0;
  v_item jsonb;
  v_product_id bigint;
  v_qty bigint;
  v_prod record;
  v_line record;
begin
  if v_user_id is null then
    raise exception 'You must be logged in to place an order.';
  end if;

  if public.is_admin() then
    raise exception 'Admin accounts cannot place orders.';
  end if;

  if jsonb_array_length(items) = 0 then
    raise exception 'Cart is empty.';
  end if;

  if exists (
    select 1 from jsonb_array_elements(items) e
    where coalesce((e->>'quantity')::bigint, 0) <= 0
  ) then
    raise exception 'Quantity must be greater than zero.';
  end if;

  -- First pass: Check stock per product (all colors combined) & calculate server-verified total
  for v_line in
    select (e->>'product_id')::bigint as product_id,
           sum((e->>'quantity')::bigint) as quantity
    from jsonb_array_elements(items) e
    group by 1
    order by 1
  loop
    select id, name, price, stock into v_prod
    from public.products
    where id = v_line.product_id
    for update;

    if not found then
      raise exception 'Product ID % not found.', v_line.product_id;
    end if;

    if v_prod.stock < v_line.quantity then
      raise exception 'Not enough stock for "%" (available: %, requested: %).',
        v_prod.name, v_prod.stock, v_line.quantity;
    end if;

    v_total := v_total + (v_prod.price * v_line.quantity);
  end loop;

  -- Create order
  insert into public.orders (user_id, status, total)
  values (v_user_id, 'done', v_total)
  returning id into v_order_id;

  -- Second pass: Deduct stock & insert order_items with snapshotted name, color and price
  for v_item in select * from jsonb_array_elements(items) loop
    v_product_id := (v_item->>'product_id')::bigint;
    v_qty := (v_item->>'quantity')::bigint;

    select name, price into v_prod from public.products where id = v_product_id;

    update public.products
    set stock = stock - v_qty
    where id = v_product_id;

    insert into public.order_items (order_id, product_id, product_name, color_name, unit_price, quantity)
    values (v_order_id, v_product_id, v_prod.name, nullif(v_item->>'color', ''), v_prod.price, v_qty);
  end loop;

  return jsonb_build_object(
    'order_id', v_order_id,
    'total', v_total,
    'status', 'done'
  );
end;
$$;

-- ==============================================================
-- 13. ROW LEVEL SECURITY (RLS) POLICIES
-- ==============================================================
alter table public.roles enable row level security;
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;
alter table public.order_items enable row level security;

-- ROLES: Authenticated users can read
create policy "roles_select_auth"
  on public.roles for select to authenticated using (true);

-- PROFILES:
-- Customer: read and update own row only, and never the role
create policy "profiles_select_own"
  on public.profiles for select to authenticated
  using (auth.uid() = id or public.is_admin());

create policy "profiles_update_own"
  on public.profiles for update to authenticated
  using (auth.uid() = id)
  with check (
    auth.uid() = id
    and role_id = (select role_id from public.profiles where id = auth.uid())
    and email is not distinct from (select email from public.profiles where id = auth.uid())
  );

-- CATEGORIES:
-- Customer: Read. Admin: Read, add, edit, delete
create policy "categories_select_auth"
  on public.categories for select to authenticated using (true);

create policy "categories_insert_admin"
  on public.categories for insert to authenticated with check (public.is_admin());

create policy "categories_update_admin"
  on public.categories for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "categories_delete_admin"
  on public.categories for delete to authenticated using (public.is_admin());

-- PRODUCTS:
-- Customer: Read. Admin: Read, add, edit, delete
create policy "products_select_auth"
  on public.products for select to authenticated using (true);

create policy "products_insert_admin"
  on public.products for insert to authenticated with check (public.is_admin());

create policy "products_update_admin"
  on public.products for update to authenticated using (public.is_admin()) with check (public.is_admin());

create policy "products_delete_admin"
  on public.products for delete to authenticated using (public.is_admin());

-- ORDERS:
-- Customer: Read own orders. Admin: Read all, update status.
create policy "orders_select"
  on public.orders for select to authenticated
  using (auth.uid() = user_id or public.is_admin());

create policy "orders_update_admin"
  on public.orders for update to authenticated
  using (public.is_admin()) with check (public.is_admin());

-- ORDER_ITEMS:
-- Customer: Read own order items. Admin: Read all
create policy "order_items_select"
  on public.order_items for select to authenticated
  using (
    exists (
      select 1 from public.orders o
      where o.id = order_items.order_id
        and (o.user_id = auth.uid() or public.is_admin())
    )
  );

-- ==============================================================
-- 14. SEED PRODUCTS
-- ==============================================================
insert into public.products (name, description, stock, image_url, category_id, price)
values
  ('Standard Mouth 21 oz', 'The ideal companion for everyday hydration.', 25, 'assets/products/standard_carnation.png', 1, 34.95),
  ('Wide Mouth 32 oz', 'Our largest everyday hydration bottle.', 40, 'assets/products/wide_indigo.png', 1, 44.95),
  ('Flex Straw Cap 24 oz', 'Sip anywhere with leakproof straw cap design.', 15, 'assets/products/straw_pink.png', 1, 39.95),
  ('Coffee Flex Sip 20 oz', 'Engineered for hot beverages.', 30, 'assets/products/coffee_olive.png', 2, 34.95),
  ('All Around Tumbler 28 oz', 'Keeps temperatures locked in for hours.', 20, 'assets/products/tumbler_pacific.png', 3, 32.95),
  ('Trail Series Lightweight 32 oz', '25% lighter than standard bottles.', 10, 'assets/products/trail_obsidian.jpg', 1, 49.95);

-- ==============================================================
-- 15. STORAGE BUCKET FOR PRODUCT IMAGES (admin uploads only)
-- ==============================================================
insert into storage.buckets (id, name, public)
values ('product-images', 'product-images', true)
on conflict (id) do update set public = true;

drop policy if exists "Admins can upload product images" on storage.objects;
create policy "Admins can upload product images"
  on storage.objects for insert to authenticated
  with check (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "Admins can update product images" on storage.objects;
create policy "Admins can update product images"
  on storage.objects for update to authenticated
  using (bucket_id = 'product-images' and public.is_admin());

drop policy if exists "Admins can delete product images" on storage.objects;
create policy "Admins can delete product images"
  on storage.objects for delete to authenticated
  using (bucket_id = 'product-images' and public.is_admin());
