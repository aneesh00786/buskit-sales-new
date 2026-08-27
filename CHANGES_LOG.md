# Implementation & Synchronization Changes Log

This document lists all the features, bug fixes, and calculation logic updates implemented in the **Sales App (`buskit-sales-new`)** and synchronized across to the **Admin App (`buskit_admin`)**.

---

## Summary of Changes

### 1. Bulk Discount & Tax Offline Hive Hydration & Percentage Fix (34.5% vs 10% / 0.0%)
- **Problem & Root Causes Identified**:
  - The discount percentage in the Discount Details dialog and cart calculations was displaying 10% (Customer Discount) or 0.0% (with double-discounted $759.50 / $1160.35) when loaded from drafts/Hive.
  - **Root Causes**:
    1. In `cart_table_rowcontent.dart`, the fallback `effectiveBulkDiscountPercent` fell back to `CustomerDiscount` (10%) or 0.0%.
    2. When `effectiveBulkDiscountPercent` evaluated to 0.0%, `bulkDiscountAmount` was treated as a separate flat discount, which could cause double discount addition and display "You Saved 0.0%".
    3. Old or partially populated Hive draft entries did not store `bulk_discount` percentage explicitly.
- **Fixes Applied**:
  - **Identical Add-To-Cart Math**:
    - `totalDiscountPercent` uses strictly `bulkDiscount` (34.5%).
    - Discount Amount is strictly:
      $$\text{percentageDiscountAmount} = \text{Base Sell Amount} \times 34.5\% = \mathbf{\$379.50}$$
    - `effectiveBulkDiscountAmount` (flat) is set to `0` whenever `bulkDiscount` is active, preventing any double-counting.
    - Inclusive Tax (15%) is strictly calculated from the discounted net price ($\$720.50 \times 15\% = \mathbf{\$108.08}$).
    - Final Amount is strictly $\mathbf{\$720.50}$.
  - **Stored Bulk List Auto-Fallback**:
    - In `getCartItems()` and `fetchDrafts()`, if a previously cached draft is missing `bulk_discount` percentage, it automatically looks up the item by `bulk_id` from `storedBulkList` to restore the exact 34.5% rate and 15% bulk tax.
  - **Draft Serialization**:
    - In `saveDraftOffline()`: Serialized `bulk_discount`, `discount_percentage`, `bulk_discount_amount`, and `bulk_tax`.

### 2. Promo Discount Exclusivity (Strictly Promo-Added Items, Excluded from Bulk)
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

### 3. Bulk Discount Display in Discount Details ("i" Info Button) Popup
- **Fixes Applied**:
  - **Item Classification**: Checked if the item is a Bulk item (`isBulkItem`) via `bulkId`, `packtype == 'Bulk'`, or `bulkDiscount > 0`.
  - **Bulk Discount Row**: Rendered as `"Bulk Discount"` with a package icon (`Icons.inventory_2_outlined`), showing the exact bulk discount percentage (34.5%) and calculated bulk discount dollar amount.
  - **Customer Discount Row**: Only rendered as `"Customer Discount"` when the item is a non-bulk regular item.
  - **Comprehensive Breakdown**: Added explicit support for Flat Discounts (`Icons.money_off_rounded`) and BOGO discounts in the popup.

### 4. Custom Calculation, Pricing Logic & Backend Payload (`add_to_cart` / `add_to_draft`)
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

### 5. Cart Item Deletion Bug Fix (Items Reappearing After Deletion)
- **Fixes Applied**:
  - **`deleteCartItem()`**: Updated to delete the item from `cartBox`, `draftBox`, **and** `offlineDraftsBox` for the matching customer and variant/product.
  - **`clearCart()`**: Updated to purge `offlineDraftsBox` entries for that customer.
  - **Cart Dialog Deletion Flow**: Removed redundant `_loadCartItems()` calls upon confirmation, made deletion asynchronously awaited, and updated local controller state directly without triggering a re-fetch of stale records.

### 6. Adding Products to Saved Draft Orders Fix
- **Fixes Applied**:
  - **Seamless Merge in `getCartItems()`**: Updated `getCartItems(customerId)` to always combine all customer items across `cartBox`, `draftBox`, and `offlineDraftsBox`.
  - **Unified Loading**: Removed restrictive `draftsOnly: isDraftView` parameter from `CartDialogue._loadCartItems()`, ensuring all existing draft items plus newly added products are preserved, displayed, and saved together.

### 7. Catalog Search Bar (Category, Subcategory & Product In-Grid Search)
- **UI Placement**: Placed the `CatalogSearchBar` on a dedicated 2nd row under the Customer Search bar inside `order_taking.dart` without unbounded flex/height constraints.
- **Search Capabilities**:
  - **Category Search**: Filters and selects catalog categories.
  - **Subcategory Search**: Filters and selects subcategories within parent categories.
  - **Product Search (In-Grid)**: Dynamically filters the live product grid using `searchProductsInCatalog(query)` and `clearCatalogProductSearch()`.

### 8. Apply Customer Credit Dialog Redesign & Non-Breaking Formatting
- **Redesigned Dialog**:
  - Clean card-based visual design with balance/total rows and green confirmation pill container.
  - Redesigned 3-action buttons (Cancel, Pay without Credit, Pay with Credit).
- **Single-Line Currency Formatting**:
  - Updated `formatAmount()` in `string_extention.dart` to use a non-breaking space (`\u00A0`), preventing currency symbols and numbers from wrapping.

### 9. Order-Taking Top Cart Total Amount (Final Payable Calculation)
- **Fixes Applied**:
  - Updated `calculateCartNetTotal(items)` in `utils.dart` to compute the exact **Final Amount**:
    $$\text{Final Amount} = \text{Base Amount} - \text{Total Discounts (Customer + Tiered + Bulk + Edit Price)} + \text{Exclusive Taxes}$$
  - Matches the cart dialogue total to the exact cent across the entire application.

---

## File Mapping Table

| Component / Feature | Sales App File Path (`buskit-sales-new`) | Admin App File Path (`buskit_admin`) |
| :--- | :--- | :--- |
| **Bulk Screen** | `lib/ui/components/category_filter/order_taking/view/bulk/view/bulk_screen.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/view/bulk/view/bulk_scree.dart` |
| **Cart Database & Hive Hydration** | `lib/ui/components/category_filter/order_taking/local_database/cart_database.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/local_database/cart_database.dart` |
| **Cart Dialogue & Discount Calculations** | `lib/ui/components/category_filter/order_taking/widgets/cart_dialogue/cart_dialogue.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/widgets/cart_dialogue/cart_dialogue.dart` |
| **Discount Table Rows & Details Popup** | `lib/ui/components/category_filter/order_taking/widgets/cart_dialogue/widgets/cart_table_rowcontent.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/widgets/cart_dialogue/widgets/cart_table_rowcontent.dart` |
| **Calculation Utilities** | `lib/ui/components/category_filter/order_taking/utils/utils.dart` | `lib/ui/view/ui/customer_and_orders/order_taking_new/utils/utils.dart` |
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
