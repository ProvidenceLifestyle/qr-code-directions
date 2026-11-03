-- Local development seed. Runs after the migrations on `supabase start`
-- and on every `supabase db reset`. Never applied to the cloud project.
--
-- Two things a fresh local database is missing before the app is usable:
-- someone who can sign in to /admin, and a resort with enough of a road
-- network that routing has something to route through.

-- ---------------------------------------------------------------------
-- Dev admin: admin@example.test / devpassword
--
-- Inserted straight into auth.users because there is no other way to
-- seed a user. The empty-string tokens are not optional: GoTrue fails
-- sign-in with a scan error if any of them is NULL.
-- ---------------------------------------------------------------------

insert into auth.users (
  instance_id, id, aud, role, email, encrypted_password, email_confirmed_at,
  raw_app_meta_data, raw_user_meta_data, created_at, updated_at,
  confirmation_token, recovery_token, email_change_token_new, email_change
) values (
  '00000000-0000-0000-0000-000000000000',
  '11111111-1111-1111-1111-111111111111',
  'authenticated', 'authenticated',
  'admin@example.test',
  extensions.crypt('devpassword', extensions.gen_salt('bf')),
  now(),
  '{"provider": "email", "providers": ["email"]}', '{}',
  now(), now(),
  '', '', '', ''
);

insert into auth.identities (
  id, user_id, provider_id, identity_data, provider, last_sign_in_at, created_at, updated_at
) values (
  gen_random_uuid(),
  '11111111-1111-1111-1111-111111111111',
  '11111111-1111-1111-1111-111111111111',
  jsonb_build_object(
    'sub', '11111111-1111-1111-1111-111111111111',
    'email', 'admin@example.test',
    'email_verified', true
  ),
  'email', now(), now(), now()
);

insert into public.staff_profiles (id, email, display_name, is_admin)
values ('11111111-1111-1111-1111-111111111111', 'admin@example.test', 'Dev Admin', true);

-- ---------------------------------------------------------------------
-- Demo resort: a T-shaped road with three homes, published and routable.
-- Made-up coordinates, not a real Providence site.
--
--              E  (entrance)
--              |
--              C  -- home 003
--              |
--   home 002 - B ---- J ---- A - home 001
-- ---------------------------------------------------------------------

insert into public.resorts (id, name, slug, is_published, center, total_homes, created_by)
values (
  '22222222-2222-2222-2222-222222222222',
  'Demo Resort', 'demo-resort', true,
  'SRID=4326;POINT(115.90000 -32.00000)',
  3,
  '11111111-1111-1111-1111-111111111111'
);

insert into public.graph_nodes (id, resort_id, geom, node_type) values
  ('33333333-0000-0000-0000-00000000000e', '22222222-2222-2222-2222-222222222222', 'SRID=4326;POINT(115.90000 -32.00000)', 'entrance'),
  ('33333333-0000-0000-0000-00000000000c', '22222222-2222-2222-2222-222222222222', 'SRID=4326;POINT(115.90000 -32.00025)', 'site'),
  ('33333333-0000-0000-0000-00000000000f', '22222222-2222-2222-2222-222222222222', 'SRID=4326;POINT(115.90000 -32.00050)', 'intersection'),
  ('33333333-0000-0000-0000-00000000000a', '22222222-2222-2222-2222-222222222222', 'SRID=4326;POINT(115.90060 -32.00050)', 'site'),
  ('33333333-0000-0000-0000-00000000000b', '22222222-2222-2222-2222-222222222222', 'SRID=4326;POINT(115.89940 -32.00050)', 'site');

update public.resorts
set entrance_node_id = '33333333-0000-0000-0000-00000000000e'
where id = '22222222-2222-2222-2222-222222222222';

insert into public.graph_edges (resort_id, from_node_id, to_node_id, geom) values
  ('22222222-2222-2222-2222-222222222222', '33333333-0000-0000-0000-00000000000e', '33333333-0000-0000-0000-00000000000c',
   'SRID=4326;LINESTRING(115.90000 -32.00000, 115.90000 -32.00025)'),
  ('22222222-2222-2222-2222-222222222222', '33333333-0000-0000-0000-00000000000c', '33333333-0000-0000-0000-00000000000f',
   'SRID=4326;LINESTRING(115.90000 -32.00025, 115.90000 -32.00050)'),
  ('22222222-2222-2222-2222-222222222222', '33333333-0000-0000-0000-00000000000f', '33333333-0000-0000-0000-00000000000a',
   'SRID=4326;LINESTRING(115.90000 -32.00050, 115.90060 -32.00050)'),
  ('22222222-2222-2222-2222-222222222222', '33333333-0000-0000-0000-00000000000f', '33333333-0000-0000-0000-00000000000b',
   'SRID=4326;LINESTRING(115.90000 -32.00050, 115.89940 -32.00050)');

insert into public.sites (resort_id, site_number, location, graph_node_id, status) values
  ('22222222-2222-2222-2222-222222222222', '001', 'SRID=4326;POINT(115.90060 -32.00060)', '33333333-0000-0000-0000-00000000000a', 'active'),
  ('22222222-2222-2222-2222-222222222222', '002', 'SRID=4326;POINT(115.89940 -32.00060)', '33333333-0000-0000-0000-00000000000b', 'active'),
  ('22222222-2222-2222-2222-222222222222', '003', 'SRID=4326;POINT(115.90010 -32.00025)', '33333333-0000-0000-0000-00000000000c', 'active');
