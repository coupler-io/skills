# Platform rules registry

Every platform rule a skill states as fact, where it comes from, when it was last checked, and which
skills carry it. How to read, refresh and extend this file: [SKILL.md](SKILL.md).

`Used in` names the skill and the text to search for, not a line number, because lines move. "#41"
marks a use in an open PR that isn't on main yet.

## Ad platforms

| ID | Rule | Value | Source | Checked | Status | Used in |
|---|---|---|---|---|---|---|
| google-ads-daily-budget | How far a Google Ads campaign may go past its average daily budget | Up to 2× the average daily budget on one day; no more than 30.4× it in a calendar month. Quote: "might spend up to twice your average daily budget"; "you will have spent no more than 30.4 times your average daily budget" | https://support.google.com/google-ads/answer/2375423 | 2026-10-28 | Verified | `google-ads-budget-pacing` ("30.4"); #41 `black-friday-ads-readiness-check` ("2×"), `black-friday-daily-ad-spend-decisions` ("average, not a cap") |
| google-ads-scheduled-pacing | Budget pacing for campaigns with an ad schedule | Third-party reports of a 2026 change that concentrates monthly spend on scheduled days; reported dates conflict (March or 1 June 2026). Not on Google's daily-budget page | Primary source not found. Reported by https://tillison.co.uk/blog/google-ads-just-quietly-raised-your-budget-by-50-here-is-what-to-do/ | 2026-10-28 | Secondhand | None yet. Don't state a value until Google's page confirms it |
| google-ads-seasonality-adjustments | When Google recommends seasonality adjustments | Smart Bidding already manages seasonal events; adjustments only for major expected conversion-rate changes, ideal for 1–7 day events, may not work as well past 14 days. Quote: "Seasonality adjustments are ideal for short events of 1–7 days" | https://support.google.com/google-ads/answer/10369906 | 2026-10-28 | Verified | #41 `black-friday-ads-readiness-check` ("Seasonality adjustments") |
| google-ads-target-changes | Whether changing a tCPA / tROAS target restarts learning | Smart Bidding reacts to target changes in real time; judge after 1–2 conversion cycles. Quote: "Smart Bidding reacts to target changes in real time". Google's learning-status article still lists a bid strategy setting change as a possible trigger | https://support.google.com/google-ads/answer/17125145 | 2026-10-28 | Verified | #41 `black-friday-ads-readiness-check` ("A target change is an edit too"), `black-friday-daily-ad-spend-decisions` ("target change counts as an edit"). Both currently contradict this row |
| tiktok-ads-budget-steps | How much and how often to raise a TikTok budget | In learning: no more than 40% per adjustment. After learning: no more than 30%. No more often than every two days. Quote: "Avoid making adjustments more frequently than every two days" | https://ads.tiktok.com/help/article/budget | 2026-10-28 | Verified | #41 `black-friday-ads-readiness-check`, `black-friday-daily-ad-spend-decisions` ("20% per step", to be replaced) |
| meta-ads-budget-steps | How much a Meta budget can rise without restarting learning | No published percentage found. Meta's wording, as quoted by Jon Loomer, contrasts $100 → $101 (unlikely) with $100 → $1,000 (may restart learning). "About 20%" is a practitioner rule of thumb | https://www.facebook.com/business/help/112167992830700 (did not load in a fetch tool); https://www.jonloomer.com/updates-to-meta-ads-budgeting/ | 2026-10-28 | Unverifiable | #41 `black-friday-ads-readiness-check`, `black-friday-daily-ad-spend-decisions` ("20% per step"). Skills must label it a working rule |

## Email and support

| ID | Rule | Value | Source | Checked | Status | Used in |
|---|---|---|---|---|---|---|
| klaviyo-deliverability-bands | Klaviyo's healthy / room for improvement / needs attention bands | Spam complaints: under 0.01% / 0.01–0.05% / over 0.05%. Bounces: under 1% / 1–2% / over 2%. Unsubscribes: under 0.3% / 0.3–1% / over 1% | https://help.klaviyo.com/hc/en-us/articles/115000201131 | 2026-10-27 | Verified | `klaviyo-email-deliverability-check` ("0.05%", "0.3%") |
| gmail-spam-complaints-to-esps | Whether Gmail reports spam complaints to ESPs | It doesn't. Quote: "Since Gmail does not report spam complaints to ESPs like Klaviyo"; use Google Postmaster Tools | https://help.klaviyo.com/hc/en-us/articles/115000201131 | 2026-10-27 | Verified | `klaviyo-email-deliverability-check` ("Postmaster") |
| gmail-spam-rate-limits | Gmail's spam-rate guideline for senders | Keep the Postmaster Tools spam rate below 0.10%; never reach 0.30%. The skill also says senders of more than 5,000 messages a day to Gmail must stay under 0.30%, which wasn't checked | Seen via Klaviyo citing Gmail (https://help.klaviyo.com/hc/en-us/articles/115000201131). Primary: Google's email sender guidelines, https://support.google.com/a/answer/81126 | 2026-10-27 | Secondhand | `klaviyo-email-deliverability-check` ("0.10%") |
| klaviyo-attribution-defaults | Klaviyo's default attribution windows | For accounts created on or after 9 Oct 2024: email open 5 days, email click 5 days, SMS click 5 days, SMS delivery 12 hours, push open 24 hours. Older accounts had a 24-hour SMS click window | https://help.klaviyo.com/hc/en-us/articles/1260804504250 (read through a search summary, not fetched) | 2026-10-27 | Secondhand | `klaviyo-revenue-share-of-shopify-sales` ("12 hours"), `klaviyo-flow-performance-vs-benchmarks` ("5 days") |
| klaviyo-flow-benchmarks | Klaviyo's revenue per recipient by flow, average (top 10%) | Published 2 Oct 2026, 110,000+ customers. Email: abandoned cart $6.77 ($13.70), welcome $5.75 ($13.27), browse abandonment $2.08 ($4.32), post-purchase $1.80 ($2.77), winback $0.82 ($1.60). SMS: abandoned cart $4.48 ($8.69), welcome $3.33 ($7.07), browse abandonment $1.04 ($2.10) | https://www.klaviyo.com/blog/abandoned-cart-benchmarks | 2026-10-27 | Verified | `klaviyo-flow-performance-vs-benchmarks` ("$6.77") |
| klaviyo-flow-share | Flows' share of email sends and revenue | Flows: 5.3% of email sends, nearly 41% of email revenue. Measurement period not stated on the page | https://www.klaviyo.com/products/email-marketing/benchmarks (read through a search summary) | 2026-10-27 | Secondhand | `klaviyo-revenue-share-of-shopify-sales` ("41%") |
| gorgias-tickets-per-order | Gorgias tickets per order by vertical | About 460 per 1,000 orders in electronics, about 200 in food and beverage. The skill's "data as of March 2026, modeled for brands around $10M GMV" has no source | Gorgias research as cited by https://eightx.co/blog/average-ecommerce-customer-tickets-per-1000-orders-by-vertical-2026; original Gorgias post not found | 2026-10-27 | Secondhand | `gorgias-support-tickets-per-order` ("46 tickets") |

## Coupler.io product

| ID | Rule | Value | Source | Checked | Status | Used in |
|---|---|---|---|---|---|---|
| coupler-refresh-intervals | Fastest scheduled refresh by plan | Free: manual only. Starter, Active: daily. Pro: hourly. Agency and Enterprise: every 15 minutes. The MCP rejects an interval the plan doesn't include and lists the allowed ones | `coupler-io-knowledge-base/help-center/functionality/coupler.io-features-and-limits.md`; `coupler-io-web/config/billing_plans.yml`; `coupler-io-web/spec/requests/mcp_api/v1/dataflows/update_spec.rb` | 2026-10-28 | Verified | #41 `black-friday-daily-ad-spend-decisions`, `black-friday-ad-spend-on-low-stock-products` ("15 minutes") |
| coupler-schedule-defaults | Days and hours a new schedule runs when none are given | Daily, hourly, every 30 and every 15 minutes default to Monday–Friday. Sub-daily schedules default to 09:00–18:00; daily to 09:00. Same in the web form and the MCP | `coupler-io-web/app/request_handlers/mcp_api/v1/dataflows/update_handler.rb` (`DEFAULT_WEEK_DAYS`, `DEFAULT_ACTIVE_HOURS`); `coupler-io-web/app/frontend/src/constants/scheduling.js` | 2026-10-28 | Verified | #41 `black-friday-daily-ad-spend-decisions`, `black-friday-ad-spend-on-low-stock-products` ("weekdays within business hours") |
| coupler-default-start-date | Default start date of a new Google Ads, Meta or Search Console source | 60 days ago | `coupler-io-web/config/integrations/sources/google-ads/google-ads.yml` (`{{60daysago}}`), `facebook-ads/facebook-ads.yml`, `google-search-console/google-search-console.yml` | 2026-10-28 | Verified | `new-page-indexing-tracker` ("60 days ago"), `content-decay-analysis` and `organic-traffic-drop-diagnosis` ("default start date"); #41 `black-friday-last-year-report` ("default to the last 60 days") |

## Calendar

| ID | Rule | Value | Source | Checked | Status | Used in |
|---|---|---|---|---|---|---|
| black-friday-dates | Black Friday and Cyber Monday | 2025: Black Friday 28 Nov, Cyber Monday 1 Dec. 2026: 27 Nov and 30 Nov. Black Friday is the day after the fourth Thursday of November (US Thanksgiving). **Update every year** | Calendar | 2026-10-28 | Verified | #41 `black-friday-last-year-report`, `black-friday-ads-readiness-check`, `black-friday-ad-spend-on-low-stock-products`, `black-friday-ads-and-sales-report` ("27 Nov", "28 Nov") |

## Unchecked

Found in skills on main. Never checked against a source, or checked without the source recorded.
Work these in the next refresh.

| ID | Rule | Value as stated | Where it says it came from | Used in |
|---|---|---|---|---|
| meta-ads-daily-budget | How far Meta may go past a daily budget | Up to 75% over on a single day, balanced across the week. `skill-review` item 6 says a past review confirmed 75% over the legacy 25%, but recorded no source or date | Nothing in the skill | `facebook-ads-budget-pacing` ("75%") |
| amazon-ads-daily-budget | How far Amazon Ads may go past a daily budget | Sponsored Products, Brands and Display: up to 2× the daily budget on one day (1.25× if the account opted in); monthly ceiling = daily budget × days in the month | "Amazon Ads daily budgeting policy, checked 2026-09-30" (no URL) | `amazon-ads-budget-pacing` ("1.25×") |
| linkedin-ads-daily-budget | How far LinkedIn may go past a daily budget | Up to 2× the daily budget on a single day; a Monday–Sunday week capped at 7× it | Nothing in the skill | `linkedin-ads-budget-pacing` ("seven times") |
| microsoft-ads-daily-budget | How far Microsoft Ads may go past a daily budget | A single day usually stays under 2× the daily budget; monthly ceiling = daily budget × days in the month | "Microsoft budget guide" (no URL) | `bing-ads-budget-pacing` ("2× the daily budget") |
| gsc-timezone | The timezone Search Console reports in | Pacific Time | Nothing in the skills | `organic-traffic-drop-diagnosis`, `seo-client-report`, `seo-landing-page-performance` ("Pacific Time") |
