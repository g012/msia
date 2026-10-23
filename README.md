# MSIA

A warm, bilingual pre-launch catalogue for Malaysian specialities in France, with an EU expansion in mind. **This release validates demand. It has no checkout, payment, stock or shipping system.**

Rails **8.1.4**, Ruby **3.4.12**, PostgreSQL, Turbo/Stimulus, Tailwind 4, Propshaft, Active Storage, GoodJob and Kamal 2. Versions were checked against the official release listings on 23 October 2026; `Gemfile.lock` pins the resolved bundle.

## Run locally

Install Ruby from `.ruby-version`, PostgreSQL 17+ and libvips. No Node build is needed for the application.

```sh
bundle install
bin/rails db:prepare
bin/rails db:seed
bin/dev
```

Visit `http://localhost:3000/fr` or `/en`. `/` uses the supported language from `Accept-Language`, defaulting to French. If another application occupies port 3000, use `APP_URL=http://localhost:3100 bin/rails server -p 3100` after `bin/rails tailwindcss:build`; run the Tailwind watcher separately while editing.

Development and test default to PostgreSQL peer authentication and databases `msia_development` / `msia_test`. Set `DATABASE_URL` when your local PostgreSQL needs a username/password or a different socket. The URL overrides the environment's database entry; **never run tests with a production DATABASE_URL**. `bin/rails db:create db:migrate db:seed` is also supported for explicit setup.

Development writes emails to `tmp/mails/` and uses GoodJob inline execution, so nothing is sent to real inboxes. Test delivery is isolated. Production uses configurable SMTP and an external, PostgreSQL-backed GoodJob worker. Confirmation links expire in 7 days; preference links in 90 days. Unsubscribe links have no arbitrary expiry and remain valid while the signup exists.

To access `/fr/admin` or `/en/admin`, export `ADMIN_USERNAME` and `ADMIN_PASSWORD` before starting Rails. There is no default admin credential or public account creation. The small private interface uses HTTP Basic authentication over enforced HTTPS in production. Use a password manager and a random password of at least 24 characters. Restart after changing credentials. Browser Basic auth caches credentials until the session is closed; use a dedicated admin browser profile, and restrict access at the proxy/VPN if the team grows.

`.env.example` documents environment variables; Rails does **not** load `.env` files automatically. Keep values in your shell or secret manager. Do not commit credentials, database dumps, exports, `.env`, `config/master.key`, logs or uploaded assets. This app uses `SECRET_KEY_BASE` in production and does not require a committed encrypted credentials file.

## What is implemented

- French and English home, catalogue, product details, project story, FAQ, privacy, legal placeholder and editorial landing pages for Malaysian grocery, Malaysian noodles, Pan Mee, Kolo Mee and kopitiam.
- Category, brand, explicitly manufacturer-labelled vegetarian, confirmed animal-content and confirmed spice filters. Null dietary values remain unknown and do not match false/negative filters.
- Fifteen real Hock Kee references seeded from its public official catalogue. Nine category preferences include research ideas without inventing products. No fabricated subscriber counts, prices, stock or certifications.
- Email + country + explicit launch/availability consent first. Optional preferences follow on the thank-you page: first name, postcode, favourites, categories, connection to Malaysia and one import question.
- Welcome/confirmation email containing selected favourites and management/unsubscribe links. Explicit confirmation POST prevents email link scanners from confirming. Unsubscribe GET is a safe confirmation page, followed by POST. Unsubscribing removes preference votes and prevents a pending welcome job from sending.
- Duplicate emails are normalised, unique in PostgreSQL, and receive the same generic thank-you. A duplicate submission does not resend mail, change preferences, renew consent or reactivate an unsubscribed address. This prevents public forms from altering another person's record. Existing users manage preferences through their email link. An expired link/rejoin request can be handled through the privacy contact and authenticated admin erasure, or a separately designed verified-link resend flow later.
- Product intent is stored on POST, deduplicated within the preference session and consolidated with signup preferences. Public popularity uses confirmed subscribers only. Category demand combines explicit category choices and favourite-product categories, counting each person once per category. The private dashboard separates all signals from confirmed interest.
- Authenticated product CRUD, translations, photo uploads, provenance, research/regulatory states, first-import selection, consent-aware waitlist CSV, UTM reporting, erasure and demand metrics.
- Minimal first-party aggregate page counts. No IP, user agent, fingerprint or visitor identifier in `PageMetric`. No Google Analytics, Meta Pixel, advertising scripts or external font requests.
- Canonical URLs, language alternates, OpenGraph, sitemap, robots rules, semantic headings, keyboard navigation, accessible forms, responsive images and reduced-motion support. Product/Offer structured data is deliberately omitted while these are research candidates: no price, offer, `InStock`, merchant availability or purchasable-product claim is emitted.

## Catalogue data & translations

Read [`data/research_notes.md`](data/research_notes.md) for every source, confirmed facts, unknowns, animal-origin considerations and supplier questions. [`data/hock_kee_products.json`](data/hock_kee_products.json) records per-product official page, public API record, image URL and rewritten descriptions. Seeds create missing records only; rerunning **preserves admin edits**.

Hock Kee's terms require permission for commercial image reproduction. The catalogue therefore uses labelled original SVG placeholders, with official image URLs and source names saved in `ProductSource`. Upload authorised local images through admin to use Active Storage. Never assume public accessibility grants a reuse licence. Record image rights and keep the written permission separately.

The hero is a labelled AI-created generic serving suggestion, not an actual Hock Kee product photograph. Its project asset paths, tool and complete generation prompt are documented in [`data/visual_assets.md`](data/visual_assets.md).

`ProductTranslation` stores independently editable content for each language. Site UI strings are in `config/locales`. To add German, Dutch, Spanish or Italian: add UI translations, extend `available_locales` and route constraints, country/category display translations and signup locale validation, then create reviewed product translations. There is no automatic fallback into another language for regulated fields. Translated ingredients/allergens/nutrition/preparation are visibly marked unverified until explicitly reviewed. Editing those fields resets approval; save new content, then review in a separate save. Manufacturer preparation text that is currently provided is shown in English, clearly labelled as manufacturer information in its original language. Missing fields remain unknown.

Launch state and import review state are independent. Setting `available` changes the product label but does not enable a sale. `selected_for_first_import` is an internal planning choice, not a public compliance assertion. `manufacturer` and `country_of_origin` remain blank until the actual product manufacturing facts are established. A Malaysian brand does not prove a particular production country.

## Privacy & attribution

The initial form requires explicit, unchecked consent for launch and product availability messages only; consent timestamp and wording version `launch-v1` are stored. The optional questions do not delay signup. Legal/operator/provider details must be filled before collecting real people's data.

A technical encrypted, HttpOnly, SameSite=Lax session cookie keeps favourites and secures forms. Production forces HTTPS/Secure cookies. It is not a marketing audience ID. UTM strings (`source`, `medium`, `campaign`, `content`) and the landing path travel through a signed context in internal links/forms, valid for two hours. No UTM marketing cookie is used. Canonical and alternate URLs exclude this query context. Do not put personal data in UTM values. Language switches preserve the attribution context for the active journey.

`AnalyticsAdapter.page_view` is the single replacement point for a future reviewed analytics provider. Views are request counts, not unique visitors; dashboard conversion is **confirmed signups / aggregate landing-page views**, a directional ratio affected by bots, repeat views and confirmation delay. It is not advertised as a precise unique-user conversion metric. Anonymous interest can be inflated by clearing a session and is deliberately labelled weaker than confirmed demand.

Public forms have honeypot/rate limits. Rate counters use Rails' memory cache (per process), suitable as a basic first release defence with the single worker configuration provided; add a shared limiter or proxy rate controls before scaling or significant paid traffic. Logs are distinct from analytics: configure proxy/application log rotation and access, and avoid logging request URLs/tokens at the proxy. Sensitive controller parameters are filtered, including bearer links passed as query parameters. Thruster request logging is disabled by default to avoid duplicating IPs, user agents and raw tokens in access logs; configure the outer proxy with a similarly restrained log policy. Emails and CSV exports remain personal data.

`RetentionJob` runs daily at 03:00 Paris time via GoodJob cron when `GOOD_JOB_ENABLE_CRON=true` and an external worker is running. It deletes unconfirmed records after 30 days, unsubscribed records after 30 days, consent older than 24 months, and anonymous interest older than 90 days. These are chosen project defaults, not claims of statutory maximum durations. Run manually with:

```sh
bin/rails runner 'RetentionJob.perform_now'
```

Review the privacy text, legal operator information, processors, hosting locations and transfer safeguards for the actual deployment. No cookie consent banner is needed for the current implementation's technical cookie; reassess before adding any new tracker.

## Test & quality checks

```sh
bin/verify
```

This runs database preparation, integration/model/job/mail tests, RuboCop, Brakeman, Zeitwerk and a production asset build without runtime secrets. Tests exercise consent, normalised duplicates, locale routing, anonymous/confirmed interest, rejected product visibility, unknown dietary filters, signed UTM attribution, authenticated admin/CSV, preference links, confirmation, unsubscribe and retention. Use the test database only. In a restricted environment, set writable `BUNDLE_USER_HOME`, `GEM_SPEC_CACHE` and `npm_config_cache` directories if needed; these are tooling caches, not application settings.

See [`docs/verification.md`](docs/verification.md) for checks actually performed, mobile QA and measured Lighthouse results. Lighthouse CLI is optional QA tooling, not an application dependency:

```sh
CHROME_PATH=/usr/bin/chromium npx lighthouse@13.5.0 http://localhost:3000/fr \
  --chrome-flags='--headless --no-sandbox' --output=json --output-path=tmp/lighthouse-mobile.json
```

## Deploy with Kamal 2

[`config/deploy.yml`](config/deploy.yml) is a template for one host with web, separate GoodJob worker, private PostgreSQL 17 accessory and persistent Active Storage volume. Replace the documentation IP, host, image and registry name. No deployment is performed automatically. Use your real HTTPS domain in `APP_URL`; it controls canonical URLs and email links and must match the Kamal proxy host. `.kamal/secrets` only references exported secrets; it contains no values.

1. Supply a Linux Docker host and DNS, configure SSH, replace the template identifiers and set registry access.
2. Export all secrets listed in `.env.example` / `config/deploy.yml`. Generate `SECRET_KEY_BASE` with `bin/rails secret`; URL-encode the database password in `DATABASE_URL`, using accessory hostname `msia-db` on Kamal's private Docker network. Do not expose PostgreSQL port 5432 publicly.
3. Configure an authenticated SMTP provider and verified sending domain with SPF, DKIM and DMARC. Complete all legal/privacy/operator/provider disclosures. Use an EU hosting/data-processing configuration suitable for your project.
4. Run local checks and `docker build -t msia:prelaunch .`. `bundle exec kamal config` validates your completed configuration; do not paste its secret-containing output in tickets or chat.
5. `bundle exec kamal setup` for the first deployment, then `bundle exec kamal deploy`. The web entrypoint runs `db:prepare`; seeds on a fresh database are idempotent. Explicitly initialise/update missing seed records with `bundle exec kamal app exec --reuse 'bin/rails db:seed'` after verifying the environment.
6. Confirm `/up`, both languages, admin authentication, image persistence, a real email/confirmation/unsubscribe cycle and GoodJob worker/cron operation. The worker must stay running; SMTP retries use persisted jobs and no email should be treated as delivered merely because it was queued.
7. Set up encrypted offsite backups and perform a restore drill; see [`docs/backups.md`](docs/backups.md).

Production refuses to boot without the core database/SMTP/admin/secret settings and HTTPS APP_URL. Asset precompilation uses `SECRET_KEY_BASE_DUMMY=1` and needs neither credentials nor a database. `/up` checks Rails and PostgreSQL readiness. Uploaded files live on the named `msia_storage` volume; databases live on the accessory data volume. Back up both. Do not run destructive database resets in production.

## Highest-value demand experiments

1. Obtain image permission, samples and product-specific technical sheets; clear initial regulatory feasibility before promising an import.
2. Run small, separately tagged campaigns to the Pan Mee, Kolo Mee and kopitiam pages; compare cost per **confirmed** signup and confirmed product preferences.
3. Compare France postcode clusters and category demand before choosing the smallest practical first assortment and landed-cost targets.
4. Ask willing confirmed subscribers a short follow-up about missing products and acceptable price ranges once realistic landed costs are known. Keep communication within the consented purpose.
