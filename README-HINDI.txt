GRACE IMITATION JEWELLERY — COMPLETE WEBSITE PACKAGE

WHAT IS INCLUDED
- Gold / ivory premium responsive storefront
- Product categories, search, product catalogue
- Cart and checkout form
- UPI intent payment to girdharisharma185@ybl
- Customer sign-up / login / password reset
- Customer order history
- Admin dashboard
- Product and category add/delete
- Order viewing and status update
- Multiple admin roles: super_admin, product_manager, order_manager, support
- Admin role management (Super Admin only)
- JSON backup download and catalogue restore
- Privacy Policy, Terms & Conditions, Return & Refund Policy
- Instagram link: https://instagram.com/grace_creation_bjs
- WhatsApp contact: +91 9079394754

IMPORTANT — SETUP REQUIRED BEFORE LIVE USE
This package contains the website source. Secure login, shared product data, orders and admin permissions require a Supabase backend. It is not possible to safely provide multi-admin accounts, password reset or cross-device orders using GitHub Pages alone.

STEP 1 — CREATE SUPABASE PROJECT
1. Open https://supabase.com and create a free project.
2. In Project Settings → API, copy Project URL and anon/public key.
3. Open app.js and replace:
   YOUR_SUPABASE_PROJECT_URL
   YOUR_SUPABASE_ANON_PUBLIC_KEY
4. Never paste a service_role key into app.js or any public file.

STEP 2 — CREATE DATABASE
1. In Supabase → SQL Editor → New query.
2. Paste all contents of supabase-schema.sql and Run.
3. In Supabase → Authentication → URL Configuration, add your deployed website URL to Site URL and Redirect URLs.
4. Deploy this folder to GitHub Pages / another static host.

STEP 3 — OWNER ADMIN
1. Open your deployed website and create an account using the owner's email.
2. In Supabase → SQL Editor run:
   update public.profiles set role='super_admin' where email='YOUR-OWNER-EMAIL@example.com';
   Replace the email with the exact account email.
3. Log out and log in again. Admin dashboard is available from the top Login / Admin button.

STEP 4 — ADD OTHER ADMINS
1. In Supabase → Authentication → Users, invite/create the staff email accounts.
2. Staff members should sign in once so their profile row is created.
3. Super Admin → Admins tab assigns:
   product_manager = products/categories
   order_manager = orders and status updates
   support = view orders
   super_admin = all permissions

PAYMENT NOTE
The checkout opens the customer's UPI app using UPI ID girdharisharma185@ybl and the order amount. This is a UPI intent, not an integrated payment gateway. The site cannot verify payment automatically. Confirm the payment in your UPI/bank app before marking an order paid. For automatic payment verification, register a merchant account with a supported gateway such as Razorpay/Cashfree and configure server-side webhook verification.

BACKUP NOTE
The Admin → Backup tab downloads a JSON backup including customer order data. Keep it private. Restore currently replaces catalogue products/categories only; orders are exported for safekeeping and are not bulk-restored.

BEFORE SELLING
- Replace sample product photos/prices/descriptions with real catalogue details.
- Review policy wording and delivery/return terms.
- Test signup, password reset, checkout, UPI intent, order visibility and role permissions.
- Do not share admin passwords or service-role keys.
