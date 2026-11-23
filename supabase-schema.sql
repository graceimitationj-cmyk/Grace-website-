-- Grace Imitation Jewellery: Supabase database schema
-- Run this whole file in Supabase SQL Editor. Then create your first user via website signup.
create extension if not exists pgcrypto;

create table if not exists public.profiles (
 id uuid primary key references auth.users(id) on delete cascade,
 email text,
 full_name text,
 role text not null default 'customer' check (role in ('customer','super_admin','product_manager','order_manager','support')),
 created_at timestamptz not null default now()
);
create table if not exists public.categories (
 id uuid primary key default gen_random_uuid(),
 name text unique not null,
 created_at timestamptz not null default now()
);
create table if not exists public.products (
 id uuid primary key default gen_random_uuid(),
 name text not null,
 category text not null,
 price numeric(12,2) not null check(price>=0),
 image_url text not null,
 description text default '',
 active boolean not null default true,
 created_at timestamptz not null default now()
);
create table if not exists public.orders (
 id uuid primary key default gen_random_uuid(),
 user_id uuid not null references auth.users(id),
 customer_name text not null,
 phone text not null,
 address text not null,
 items jsonb not null,
 total numeric(12,2) not null check(total>=0),
 payment_method text not null default 'upi' check(payment_method in ('upi','cash_on_delivery')),
 payment_status text not null default 'pending' check(payment_status in ('pending','paid','failed','refunded')),
 status text not null default 'new' check(status in ('new','confirmed','shipped','delivered','cancelled')),
 created_at timestamptz not null default now()
);

create or replace function public.current_role()
returns text language sql stable security definer set search_path=public
as $$ select role from public.profiles where id=auth.uid() $$;

create or replace function public.handle_new_user()
returns trigger language plpgsql security definer set search_path=public
as $$
begin
 insert into public.profiles(id,email,full_name,role)
 values(new.id,new.email,coalesce(new.raw_user_meta_data->>'full_name',''),'customer')
 on conflict(id) do nothing;
 return new;
end;
$$;
drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created after insert on auth.users
for each row execute procedure public.handle_new_user();

create or replace function public.set_user_role(target_user_id uuid,new_role text)
returns void language plpgsql security definer set search_path=public
as $$
begin
 if public.current_role() <> 'super_admin' then
   raise exception 'Only Super Admin can change roles';
 end if;
 if new_role not in ('customer','super_admin','product_manager','order_manager','support') then
   raise exception 'Invalid role';
 end if;
 update public.profiles set role=new_role where id=target_user_id;
end;
$$;
revoke all on function public.set_user_role(uuid,text) from public;
grant execute on function public.set_user_role(uuid,text) to authenticated;

alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.products enable row level security;
alter table public.orders enable row level security;

drop policy if exists "profiles read self or admins" on public.profiles;
create policy "profiles read self or admins" on public.profiles for select to authenticated
using (id=auth.uid() or public.current_role() in ('super_admin','order_manager','support'));
drop policy if exists "profiles update self" on public.profiles;
create policy "profiles update self" on public.profiles for update to authenticated
using(id=auth.uid()) with check(id=auth.uid());

drop policy if exists "categories public read" on public.categories;
create policy "categories public read" on public.categories for select to anon,authenticated using(true);
drop policy if exists "categories manager write" on public.categories;
create policy "categories manager write" on public.categories for all to authenticated
using(public.current_role() in ('super_admin','product_manager'))
with check(public.current_role() in ('super_admin','product_manager'));

drop policy if exists "products public read active" on public.products;
create policy "products public read active" on public.products for select to anon,authenticated using(active=true or public.current_role() in ('super_admin','product_manager'));
drop policy if exists "products manager write" on public.products;
create policy "products manager write" on public.products for all to authenticated
using(public.current_role() in ('super_admin','product_manager'))
with check(public.current_role() in ('super_admin','product_manager'));

drop policy if exists "customer read own orders or order staff" on public.orders;
create policy "customer read own orders or order staff" on public.orders for select to authenticated
using(user_id=auth.uid() or public.current_role() in ('super_admin','order_manager','support'));
drop policy if exists "customer create own order" on public.orders;
create policy "customer create own order" on public.orders for insert to authenticated
with check(user_id=auth.uid());
drop policy if exists "order staff update" on public.orders;
create policy "order staff update" on public.orders for update to authenticated
using(public.current_role() in ('super_admin','order_manager'))
with check(public.current_role() in ('super_admin','order_manager'));

insert into public.categories(name) values
('Earrings'),('Necklace Sets'),('Bangles'),('Ladies Purses')
on conflict(name) do nothing;

-- After you sign up using your own email on the website, run this once
-- (replace the email with the same email used for the first owner account):
-- update public.profiles set role='super_admin' where email='YOUR-OWNER-EMAIL@example.com';
