# Implementation & Synchronization Changes Log

This document lists all the features, bug fixes, and calculation logic updates implemented in the **Sales App (`buskit-sales-new`)** and synchronized across to the **Admin App (`buskit_admin`)**.

---

## Summary of Changes

### 1. Promo Discount Exclusivity (Strictly Promo-Added Items, Excluded from Bulk)
- **Requirement**:
  - Promo discounts (tiered discount, flat promo discount, BOGO) must **only** be applied when the product is added directly from the Promotion flow (`isPromo == true`).
  - Items added from the Bulk catalog/screen must never receive promo discounts, even if the same product exists in both bulk and promotion campaigns. Bulk items must only use Bulk pricing and Bulk discounts.
- **Logic & Fixes Applied**:
  - Defined explicit item eligibility:
    ```dart
    final bool isBulk = (item.detail.bulkId != null && item.detail.bulkId!.isNotEmpty) ||
        (item.detail.packtype == 'Bulk') ||
        (item.isPack == true && item.detail.bulkDiscount != null && item.detail.bulkDiscount! > 0) ||
        (item.detail.bulkDiscountAmount != null && item.detail.bulkDiscountAmount! > 0);

    final bool isPromoItem = (item.isPromo == true) && !isBulk;
    ```
  - **Cart Dialogue & Totals** (`cart_dialogue.dart` & `utils.dart`):
    - `tieredDiscount`, `bogoDiscount`, and `flatDiscount` are now evaluated only when `isPromoItem == true`.
    - Customer discounts are bypassed on bulk items so only bulk discount tiers apply.
  - **Cart Table & Info Popup** (`cart_table_rowcontent.dart`):
    - Discount table rows and Discount Details dialog only render promo rows if `isPromoItem == true`.
  - **Payload Generation** (`products_controller.dart` & `connectivity_check.dart`):
    - `combinedPromoDiscount` is set to `0` for bulk and non-promo items in `add_to_cart` and `add_to_draft` payloads.
  - **Local Database & Offline Hydration** (`cart_database.dart`):
    - Prevented customer category discounts from being attached to bulk items in `calculateEffectivePrice()`.
    - In `fetchDrafts()`, set `tieredDiscount: 0` and `flatDiscount: 0` unless `isPromoDraft` is strictly true and not bulk.

### 2. Bulk Discount Display in Discount Details ("i" Info Button) Popup
- **Root Cause**:
  - In `cart_table_rowcontent.dart`, the discount information popup (opened by clicking the `Icons.info_outline` "i" button next to discount in the cart table) unconditionally displayed `CustomerDiscount` as `"Customer Discount"`, even when the item was added from the Bulk product screen.
- **Fixes Applied**:
  - **Item Classification**: Checked if the item is a Bulk item (`isBulkItem`) via `bulkId`, `packtype == 'Bulk'`, or `bulkDiscount > 0`.
  - **Bulk Discount Row**: Rendered as `"Bulk Discount"` with a package icon (`Icons.inventory_2_outlined`), showing the exact bulk discount percentage and calculated bulk discount dollar amount.
  - **Customer Discount Row**: Only rendered as `"Customer Discount"` when the item is a non-bulk regular item.
  - **Comprehensive Breakdown**: Added explicit support for Flat Discounts (`Icons.money_off_rounded`) and BOGO discounts in the popup.

### 3. Custom Calculation, Pricing Logic & Backend Payload (`add_to_cart` / `add_to_draft`)
- **Original vs. Effective Prices**:
  - `originalUnitPrice` and `originalPackPrice` are tracked to preserve catalog base prices prior to manual salesman overrides.
  - `effectiveUnitPrice` uses `displayPrice` (if overridden) or base `sellPrice`.
- **Edit-Price Discount Tracking**:
  - Calculated `editedAmount` / `editPriceDiscountAmt` when a price is edited manually:
    $$\text{priceDiff} = \text{origPrice} - \text{newPrice}$$
    $$\text{editPriceDiscountAmt} = \text{priceDiff} \times \text{packFactor} \times \text{quantity}$$
  - Included `editedAmount`, `customerDiscountPercentage`, `originalUnitPrice`, and `originalPackPrice` in `SendCartData` (`cart_data_model.dart`).
- **Tax Breakdown in Backend Payload**:
  - Included `catTax`, `taxAmount`, and unit tax portions in both UI display and backend payload (`SendCartData.toJson()`).
- **Endpoints Supported**:
  - `addToCart` (Payload generated in `CartDialogueState` & `ConnectivityService`).
  - `addToDraft` (Payload generated in `ProductsController.processCartBeforeNavigation`).

### 4. Cart Item Deletion Bug Fix (Items Reappearing After Deletion)
- **Root Causes**:
  - `_deleteVariant` and `showVariantDeleteDialog` called `_loadCartItems()` immediately after deleting an item in `CartDialogueState`, which re-queried `getCartItems()` and loaded un-purged offline drafts from `offlineDraftsBox`.
  - `deleteCartItem()` and `clearCart()` only deleted records from `cartBox` and `draftBox`, leaving the items intact inside `offlineDraftsBox.get('drafts')`.
- **Fixes Applied**:
  - **`deleteCartItem()`**: Updated to delete the item from `cartBox`, `draftBox`, **and** `offlineDraftsBox` for the matching customer and variant/product.
  - **`clearCart()`**: Updated to purge `offlineDraftsBox` entries for that customer.
  - **Cart Dialog Deletion Flow**: Removed redundant `_loadCartItems()` calls upon confirmation, made deletion asynchronously awaited, and updated local controller state directly without triggering a re-fetch of stale records.

### 5. Adding Products to Saved Draft Orders Fix
- **Root Causes**:
  - When opening a draft from the Customer Dashboard (`isFromCustomerDach: true`), `isDraftView` was set to `true`, causing `getCartItems(customerId, draftsOnly: true)` to be called with `draftsOnly: true`.
  - `getCartItems` with `draftsOnly: true` exclusively read from `draftBox` and completely excluded `cartBox` and `offlineDraftsBox`.
  - When a user continued shopping on a saved draft and added a new product, `addToCart()` placed the newly selected variant into `cartBox`. Opening the draft dialogue or navigating reloaded the items with `draftsOnly: true`, dropping all newly added items from `cartBox`.
- **Fixes Applied**:
  - **Seamless Merge in `getCartItems()`**: Updated `getCartItems(customerId)` to always combine all customer items across `cartBox`, `draftBox`, and `offlineDraftsBox`.
  - **Unified Loading**: Removed restrictive `draftsOnly: isDraftView` parameter from `CartDialogue._loadCartItems()`, ensuring all existing draft items plus newly added products are preserved, displayed, and saved together.

### 6. Catalog Search Bar (Category, Subcategory & Product In-Grid Search)
- **UI Placement**: Placed the `CatalogSearchBar` on a dedicated 2nd row under the Customer Search bar inside `order_taking.dart` without unbounded flex/height constraints.
- **Search Capabilities**:
  - **Category Search**: Filters and selects catalog categories.
  - **Subcategory Search**: Filters and selects subcategories within parent categories.
  - **Product Search (In-Grid)**: Dynamically filters the live product grid using `searchProductsInCatalog(query)` and `clearCatalogProductSearch()`.
- **Search Scope**: Queries active products, `scidProductGroups` Hive box, and `products` Hive box by product name, product code, brand name, variant name, and barcode.

### 7. Apply Customer Credit Dialog Redesign & Non-Breaking Formatting
- **Redesigned Dialog**:
  - Clean card-based visual design with balance/total rows and green confirmation pill container.
  - Redesigned 3-action buttons:
    1. **Cancel** (Outlined grey button)
    2. **Pay without Credit** (Blue outlined button with arrow icon)
    3. **Pay with Credit / Apply Credit** (Solid green button with checkmark icon)
- **Single-Line Currency Formatting**:
  - Updated `formatAmount()` in `string_extention.dart` to use a non-breaking space (`\u00A0`), preventing currency symbols (`$`) and numbers from breaking into separate lines.
  - Wrapped the dynamic payable amount inside a `WidgetSpan` in `cart_dialogue.dart` to guarantee single-line atomic rendering.

### 8. Hive / Offline Tax Calculation & Hydration Fix
- **Root Cause**:
  - When loading draft items from Hive storage (`offlineDrafts` / `draftBox`), `catTax` (the category tax percentage) was omitted, causing tax calculations in the cart dialog to evaluate to `0.0` or fall back incorrectly to unit taxes.
- **Fixes Applied**:
  - **Tax Hydration**: Updated `fetchDrafts()` and `getDraftCartItems()` in `cart_database.dart` to load `catTax`, `taxAmount`, `totaltax`, and `unitTax`.
  - **Local Cache Fallback**: Added `getStoredTaxFromCache()` lookup so if `catTax` is missing from an offline record, it is immediately restored from local product cache.
  - **Cart Dialog Fallback**: Added real-time fallback in `cart_dialogue.dart`'s discount & tax processing loop.
  - **Local Persistence**: Updated `saveDraftOrderLocally()` to serialize `cat_tax`, `tax_amount`, `total_tax`, `unit_tax`, and `cat_id`.

### 9. Order-Taking Top Cart Total Amount (Final Payable Calculation)
- **Root Cause**:
  - The amount shown next to the cart icon in the top header was previously calculated by `calculateCartNetTotal()` using only raw item subtotal minus discounts, without factoring in exclusive taxes or price overrides.
- **Fixes Applied**:
  - Updated `calculateCartNetTotal(items)` in `utils.dart` to compute the exact **Final Amount**:
    $$\text{Final Amount} = \text{Base Amount} - \text{Total Discounts (Customer + Tiered + Bulk + Edit Price)} + \text{Exclusive Taxes}$$
  - Prioritizes pre-computed `item.finalPrice` from the cart dialogue when available.
  - Matches the cart dialogue total to the exact cent across the entire application.

---

## File Mapping Table

| Component / Feature | Sales App File Path (`buskit-sales-new`) | Admin App File Path (`buskit_admin`) |
| :--- | :--- | :--- |
| **Cart Dialogue & Discount Calculations** | `lib/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/widgets/cart_dialogue/cart_dialogue.dart` |
| **Discount Table Rows & Details Popup** | `lib/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_rowcontent.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/widgets/cart_dialogue/widgets/cart_table_rowcontent.dart` |
| **Calculation Utilities** | `lib/ui/components/category_filter/order_taking/utils/utils.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/utils/utils.dart` |
| **Cart Database & Local Calculations** | `lib/ui/components/category_filter/order_taking/local_database/cart_database.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/local_database/cart_database.dart` |
| **Connectivity & Payload Service** | `lib/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/connectivity_check.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/widgets/cart_dialogue/widgets/connectivity_check.dart` |
| **Products Controller & Draft Sync** | `lib/ui/view/ui/products/products_controller.dart` | `lib/ui/view/ui/products/products_controller.dart` |
| **SendCartData & Payload Model** | `lib/ui/components/diloags/cart_diloag/cart_data_model.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/local_database/cart_data_model.dart` |
| **Catalog Search Bar Widget** | `lib/ui/components/category_filter/order_taking/widgets/catalog_search_bar.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/widgets/catalog_search_bar.dart` |
| **Order Taking Screen Layout** | `lib/ui/components/category_filter/order_taking/view/order_taking.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/view/order_taking.dart` |
| **Currency Extension** | `lib/ui/utills/extentions/string_extention.dart` | `lib/ui/utills/extentions/string_extention.dart` |

---

## Verification Status
- **Sales App (`buskit-sales-new`)**: Verified with `flutter analyze` — **0 errors**.
- **Admin App (`buskit_admin`)**: Verified with `flutter analyze` — **0 errors**.
