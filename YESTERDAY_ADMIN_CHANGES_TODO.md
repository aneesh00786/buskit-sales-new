# Admin app changes (2026-08-28) not ported to sales app

Checked all commits made in `buskit_admin` yesterday (2026-08-28) and compared against `buskit-sales-new`. Sync was already up to date through admin commit `319bd03b` (17:04). Everything after that was reviewed individually.

## Applied to sales app (design-only, safe to keep)

These were already partially applied (uncommitted, likely from the earlier antigravity attempt) — I verified/completed/fixed them:

- **Pending payment popup redesign** (source: admin `77b11dcd`) — `lib/ui/components/bar_and_chart/pending_payment_collection.dart`
  Widened payment-method column/dropdown (fixes RenderFlex overflow), wider table columns for Balance/Received/Remarks.
  Fixed a bug in the partially-applied diff: a `columns: const [...]` list was left `const` while containing a `.tr` (GetX) call, which doesn't compile as a constant expression — removed the invalid `const`.
- **Safe date parsing** (source: admin `2ca30ff1`) — `lib/ui/view/ui/dashboard1/provider/dash_models.dart` — already matches admin's `DateTime.tryParse` null-safety fix (this repo's model didn't need the `orderGeneratedDate` getter admin added, since the field already exists directly here).
- `lib/ui/theme/custom_fonts.dart` — `commonFont` constant already present; it's unused in admin too (leftover from an unrelated "chatbot" commit), harmless, left as-is.

## Skipped — feature doesn't exist in sales app's main dashboard

- **`502775ac`** "modernize frequently bought products table design to match customer dashboard" and **`8f1b671f`** "fix ParentDataWidget error in dashboardFrequentlyBoughtChart" — both touch `dashboard_middle_widget.dart`'s `DashboardFrequentlyBoughtTableWidget` / `dashboardFrequentlyBoughtChart()`. The sales app's main dashboard (`lib/ui/view/ui/dashboard1/dashboard_ui/widget/dashboard_middle_widget.dart`) has no such widget at all — only the per-customer dashboard has a "Frequently Bought" section, and that was already synced earlier (commit `4487264a` / sales `8e9d39fe`). Nothing to port.

## Skipped per your instruction — product menu/edit/search redesign

- `2c3d47e4` modernize product menu design, `d7b407af` product search update, `a4daee69` product add design, `d6b2fca7`/`7acb7208` product edit popup — all under `products_new/`. You said not to apply these to the sales app.

## Needs your manual review — these are functional changes, not just design

Per your instruction, I did not auto-apply these since they add real behavior, not just visual changes:

1. **Full interactive Communication dialog** (admin commit `13d9ce8c`, file `lib/ui/view/ui/dashboard/dashboard_ui/widget/dashboard_middle_widget.dart`)
   Replaces a placeholder "Chat Interface" popup with a real 2-pane dialog: a conversation list on the left and a working `ChatScreen` (new `StatefulWidget`, ~line 1406 in admin's file) on the right, with actual message sending/receiving logic.
   Sales app currently has a completely different, simpler `CommunicationsDisplayWidget` (`lib/ui/view/ui/dashboard1/dashboard_ui/widget/communication_display_widget.dart`) with no enlarge/chat dialog at all — this isn't a drop-in design tweak, it's new functionality that needs to be wired to sales app's own communication/messaging backend calls.

2. **Broadcast / send-to-multiple-salesmen option** (admin commit `9b63e0be`, same file)
   Adds the ability to send one message to multiple salesmen at once from the Communication dialog. Depends on the dialog from #1 existing first.

If you want these ported, they'll need real implementation work (checking what messaging API/provider the sales app uses), not just a design copy-paste.

## Follow-up check (morning commits: `d0b232d4`, `17c278db`, `39806b2c`, `e24573a5`, `3c7c18de`, `80ee95ad`)

Re-verified these six by diffing the actual current files (not just commit messages), since a couple had no message-matching sales commit:

- **`e24573a5`, `3c7c18de`, `80ee95ad`** (all `customer_option_widget.dart` design polish) — confirmed already fully applied. Direct diff between admin's and sales' `customer_option_widget.dart` today shows only import-path differences (different package name) and one pre-existing null-safety difference (`AppDimensions.instance` nullable in admin, non-nullable in sales) — no design content missing.
- **`39806b2c`** "Updated customer dashboard design matching sales app" — this commit was admin copying its customer dashboard structure *from* the sales app (sales was the source), so sales already had everything in it. Confirmed all the files it added (`customer_dashbord_screen.dart`, `payment_collection_dialog.dart`, `orders_payments.dart`, etc.) already exist in sales. Nothing to port.
- **`17c278db`** "updated sync" — the design part (`on_sync_widget.dart` — animated sync button, tooltip, status states) is already identical in sales (only import paths differ). The rest of this commit (`login_controller.dart`, `sync_controller.dart`) is backend sync/session logic, not design — left as-is per your "design only" instruction. `sync_controller.dart` does differ meaningfully between the two apps, but that looks like pre-existing app-specific sync logic, not a missed port.
- **`d0b232d4`** "updated sync" — purely backend: API response caching (`api_worker.dart`), Dio timeout values (15s → 60s in `dio_client.dart`), Hive box key handling. No UI/design content. Not applied — functional only, flagging here for your manual review if the sales app should also get the longer network timeouts or the same caching fix.

## Applied — main dashboard card headers (2026-08-29 follow-up)

You confirmed the missing "uniform card style" was on the category/target/projection, revenue, communication, frequently ordered product, collection, and order status cards. All six route through one shared function, `dashboardContainerHeader()` in `lib/ui/theme/custom_fonts.dart` — and so do 3 customer-dashboard cards (Category Sales, Frequently Bought Products, Orders & Payments), matching admin commit `89144089`'s intent ("...consistently across customer and main dashboards").

Sales' `dashboardContainerHeader` was still on an old, larger scale (28px icon box, 16px icon, 18px text, 12px padding) that never matched any of admin's history. Updated it to admin's current subtle values (24px icon box, 14px icon, 15px text w/ letter-spacing -0.2, 4-8px padding) — this single change now applies uniformly to all 9 cards across both dashboards, same as in admin.

## Applied — "enlarged popup" modernization (2026-08-29 follow-up)

Confirmed by direct file diff (not commit-message matching) that admin's popup redesign (source: commit `e4e2a288` "modernize all enlarged dashboard popup designs", plus the pending-payment width/overflow fix `77b11dcd`) had NOT reached sales for the popups opened from the six main-dashboard cards. Each got the same header treatment: solid `primaryColor` bar + plain `dialogCloseButton1` → gradient header (`primaryColor` → `0xFF2D3748`) with an icon chip, `.tr`-wrapped title, custom circular close button, `insetPadding`, and responsive `isPhonePortrait`/`fullScreenWidth` sizing.

- `show_revenue_chart_dialog.dart` (Revenue card popup) — `Icons.bar_chart_rounded`
- `show_category_chart_dialog.dart` → `showCategoryChartDialog` (Category/Target/Projection card popup) — `Icons.show_chart_rounded`. (This file also has an unused, dead `showValueDialogCusDash` function left on the old style — every real caller imports the already-modern one from `show_rev_value_dialog.dart` instead, so it was left alone.)
- `show_collection_chart_dialog.dart` (Collection card popup) — `Icons.pie_chart_rounded`
- `show_order_status_chart_dialog.dart` (Order Status card popup) — `Icons.donut_large_rounded`
- `communication_display_widget.dart` (Communication card's enlarge dialog) — `Icons.chat_bubble_outline_rounded`. Header only; the `ChatScreen()` body sales already has was left untouched.
- `collection_dialog_table.dart` (the completed-orders table opened from inside the Collection popup) — `Icons.receipt_long_rounded`, plus admin's added "Sl.No." row-numbering column.
- `pending_payment_collection.dart` — same gradient-header treatment applied to its outer dialog (`Icons.pie_chart_rounded`); kept sales' own proportional dialog-width approach rather than admin's fixed 950px, since it was already wide enough.

Already confirmed in sync, no changes needed: `bar_chart_table_dialog.dart`, `salesman_target_by_caregory_dialog.dart` (= admin's `salesman_target_categ_dialog.dart`), `show_rev_value_dialog.dart`.

Not applicable: the "Frequently Ordered Products" card (`topselling_product.dart`) has no enlarge popup at all in sales (its only dialog is the subscription upsell screen) — nothing to modernize there.

## Follow-up fixes (2026-08-29, second pass — your feedback)

- **Pending payment popup — submit button rendering outside the card**: this was a regression from my own header edit above. The inner content used `SizedBox(width: MediaQuery.of(context).size.width * 1.3)` — wider than the screen itself. Before I added the visible white/shadow card boundary, the overflow was invisible; once the card had a real edge to compare against, the oversized content broke past it. Fixed by giving the outer `Container` a proper `constraints: BoxConstraints(maxWidth: ... 950, maxHeight: ...)` (matching admin's actual approach) and changing the inner width to `double.infinity` so it fills the constrained card instead of oversizing it. The horizontal `SingleChildScrollView` already in place (from `c9f367a2`) now does the job of scrolling wide content instead of the whole dialog stretching past the screen.

- **Top widget "Orders" popup still old design**: found the real cause — `lib/ui/components/option/widgets/orderstatus_dialog/show_orderstatus_dialog.dart` is a sales-only file (admin keeps this dialog inline, no equivalent to diff against), and it had never been touched by any modernization pass. It used a `Stack` + floating `dialogCloseButton1` with no header bar at all. Rebuilt it to match the same gradient-header pattern as everywhere else (`Icons.shopping_cart_outlined`, title, close button), moved the search field to its own row below the header, and removed the now-redundant `Stack`/`Positioned` close button.

- **Draft / Cancelled status styling**: in that same file, every order status (Delivered, Draft, Cancelled, Estimate, etc.) was rendered with one hardcoded orange badge color. Found the already-modern per-status color scheme used in `customer_option_widget.dart`'s `_buildStatusBadge` (green/delivered, amber/estimate, blue/booking, slate/draft, red/cancelled) and applied the same color mapping here via two small helpers (`_orderStatusBadgeColor`, `_orderStatusTextColor`), so Draft and Cancelled (and every other status) now get correct, distinct colors instead of all sharing one.

- **"Frequently Ordered Products" scrollbars and content style**: `dash_frequently_table.dart` had plain `SingleChildScrollView`s with no visible scrollbar at all (unlike the persistent `Scrollbar`/`ScrollbarTheme` pattern used everywhere else, e.g. `orders_payments.dart`). Added matching horizontal + vertical `Scrollbar`s with `thumbVisibility`/`trackVisibility`. Also updated the header row to the same modern style used in `orders_payment_heading.dart` (rounded `Color(0xFFF1F5F9)` background instead of plain grey, bumped to `w700`/11.5px), added subtle row-separator borders, and darkened/bolded the product-name cell to match the "primary cell" text treatment used elsewhere (`0xFF0F172A`, `w600`).
