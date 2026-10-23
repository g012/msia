# Verification performed

23 October 2026. Rails 8.1.4, Ruby 3.4.12. Application is implemented and verified locally; no public deployment or real SMTP delivery has been performed.

## Automated checks

- `bin/rails test`: **24 tests, 211 assertions, zero failures/errors/skips**.
- `bin/rubocop`: **65 Ruby files, no offences**.
- `bin/brakeman --no-pager`: **zero security warnings and zero scanner errors**.
- `bin/rails zeitwerk:check`: passes.
- `SECRET_KEY_BASE_DUMMY=1 RAILS_ENV=production bin/rails assets:precompile`: passes without database or runtime credentials.
- `bin/verify`: runs the above sequence successfully.
- Seeds run successfully and are idempotent: **15 real official-catalogue references, nine categories, no invented waitlist/votes**. Re-running preserves admin edits.
- Kamal 2.12.0 `config` validates the template using dummy environment values and an explicit verification version, without connecting to a host.
- `docker build -t msia:prelaunch-local .`: succeeds, including Ruby 3.4.12 runtime and asset compilation.

## Production container checks

An isolated PostgreSQL 17 container and production application were launched on a private Docker network. They use disposable verification credentials and no external email provider. The application successfully prepared a fresh database from `db/schema.rb`, seeded the real catalogue, served the homepage with HTTP 200 and reported a healthy `/up` with PostgreSQL available.

A separate GoodJob worker started, subscribed to PostgreSQL notifications, started its cron scheduler and executed a persisted `RetentionJob` successfully. The job was removed after success as configured. The verification database contained 15 catalogue products and zero subscribers. These verification containers are removed after QA; the image remains available locally.

## Mobile Lighthouse — production container

Lighthouse CLI 13.5.0, clean headless Chromium, default simulated mobile throttling, local production container through Thruster:

| Category / metric | Measured result |
|---|---:|
| Performance | **99** |
| Accessibility | **100** |
| Best practices | **100** |
| SEO | **100** |
| Largest contentful paint | **2.0 seconds** |
| Cumulative layout shift | **0** |
| Total blocking time | **0 ms** |

Scores are local lab measurements, not guarantees for a deployed host, mobile network or future uploaded images. Real traffic and deployment monitoring are still needed. Development-server scores were lower and are not used to represent production performance.

The audit identified and led to fixes for muted text contrast and an empty CSP nonce on first visit. A regression test verifies that a fresh request gets a nonempty nonce matching the importmap scripts. The final clean-browser audit reported no console/CSP audit failures. The CSP was retained, not weakened to accommodate browser extensions.

## Interactive browser QA

- Desktop homepage inspected visually at 1440px: hero, navigation, image/caption, editorial spacing and catalogue.
- Mobile homepage, product detail, catalogue/filtering and waitlist/thank-you inspected at **390 × 844**.
- `document.documentElement.scrollWidth` equalled the 390px viewport on each inspected mobile page: no horizontal overflow.
- Mobile navigation opens and updates `aria-expanded`.
- The English catalogue shows all 15 references. Submitting Pan Mee + manufacturer-labelled vegetarian filters through Turbo updates the catalogue frame to **three** references.
- A product interest click saved intent and redirected to signup with the reference selected.
- A browser signup using a reserved `.test` email saved consent and the favourite, displayed the optional preference form and wrote a bilingual local welcome/confirmation email to `tmp/mails/`. No real email was sent. The QA record was erased afterward.
- Automated integration tests additionally verify confirmation, unsubscribe, preference authorisation, duplicates, UTM tampering protection, admin CRUD/auth/CSV, visibility, category deduplication and retention.

## Still requiring real deployment / operator input

- Actual domain, DNS, production server, registry, secrets, SMTP delivery, verified email sender and backup destination are not configured. No external messages were sent and no production account was provisioned.
- Complete the legal identity/contact/processor disclosures and obtain appropriate review before public data collection.
- Obtain manufacturer image reuse permission and product-specific technical/regulatory documents; none of the initial products is approved or available for sale.
