# PapaBear Shop CRM

Flutter PWA for the V1 shop: two logins, bookings, bills, cash, attendance, leave, stock, salary and reports. This build is the interface only. Data lives in memory and resets on refresh.

## Run

```bash
flutter run -d chrome
```

Installable PWA:

```bash
flutter build web
```

Serve the `build/web` folder over HTTPS. The app uses `standalone` display in `web/manifest.json`.

## Preview logins

| Login | Password |
| --- | --- |
| Reception | `desk1234` |
| Owner / Manager | `owner1234` |

The shop clock is pinned to 11:00 so the online-booking clash (Rahul booked at 11:15) stays visible.

## Layout

- `lib/features/receptionist/` — every desk screen, including waiting list, day close, bill, customer, stock item and today’s reports.
- `lib/features/owner/` — dashboard, sales, expenses, profit, staff, salary, all reports, each settings page and the activity log.
- `lib/core/` — theme, shell and the ledger modal.
- `lib/data/mock/` — Riverpod shop state.

Reception routes start at `/reception`. Owner routes start at `/owner`. The menu lists every page for that login.
