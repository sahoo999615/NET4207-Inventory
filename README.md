# NET4207 Stock Inventory Manager

**Cross Platform Mobile App Development — Practical Lab Test**  
**Technologies:** Flutter, Cloud Firestore, GitHub  
**GitHub Repository:** [https://github.com/sahoo999615/NET4207-Inventory](https://github.com/sahoo999615/NET4207-Inventory)

---

## 1. Setup & Run Instructions

### Prerequisites
- Flutter SDK (version 3.13 or newer) & Dart SDK
- Google Chrome browser (or Android Emulator / Windows Desktop)
- Internet connection for Cloud Firestore communication

### Required Packages
The project dependencies in `pubspec.yaml`:
- `firebase_core: ^5.1.0` (Firebase initialization & platform channels)
- `cloud_firestore: ^7.1.0` (Cloud Firestore database real-time stream & writes)
- `cupertino_icons: ^1.0.8` (iOS style icons)

### Project ID & Configuration
- **Lecturer-Provided Firebase Project ID:** `net4207-stock-inventory`
- Firebase initialization options are defined in `lib/firebase_options.dart`. Update `projectId`, `apiKey`, and `appId` with your class Firebase credentials as provided by the lecturer.

### How to Run
```bash
# 1. Fetch dependencies
flutter pub get

# 2. Run unit and widget validation tests
flutter test

# 3. Launch application on Chrome (Web)
flutter run -d chrome

# Alternatively, run on Windows desktop or connected emulator
flutter run -d windows
```

---

## 2. Firestore Data Schema & Validation Rules

### Collection: `stockItems`
Every stock record is stored under the root `stockItems` collection with an auto-generated Firestore document ID.

| Field Name | Firestore Type | Constraints & Requirement |
| :--- | :--- | :--- |
| `sku` | `String` | Format `STK-` followed by exactly three digits (e.g. `STK-101`) |
| `itemName` | `String` | Trimmed; compulsory; minimum length 3 characters |
| `category` | `String` | Permitted: `Electronics`, `Stationery`, `Hardware`, `Grocery` |
| `quantity` | `Integer` | Compulsory; whole number, 0 or above (`int >= 0`) |
| `unitPrice` | `Number` | Compulsory; RM currency amount strictly greater than 0 (`> 0`) |
| `reorderLevel` | `Integer` | Compulsory; whole number, 0 or above (`int >= 0`) |
| `createdAt` | `Timestamp` | Cloud Firestore server timestamp (`FieldValue.serverTimestamp()`) |

### Main Form Validation Rules (Task 1 & Task 2)
1. **Validation Gate:** Managed via `GlobalKey<FormState>`. When the user clicks **Save Item**, `_formKey.currentState!.validate()` is evaluated. Any invalid input immediately aborts execution and prevents any Firestore network write.
2. **Field-Level Inline Errors:**
   - Empty/malformed SKU shows `"SKU must be in format STK- followed by 3 digits (e.g. STK-101)"`.
   - Name under 3 characters shows `"Item name must be at least 3 characters"`.
   - Unselected category shows `"Please select a category"`.
   - Non-integer or negative quantity/reorder level shows `"Quantity/Reorder level must be a whole number, 0 or above"`.
   - Non-positive price shows `"Unit price must be an amount greater than RM 0"`.
3. **Confirmed Write & Error Resilience:** Progress is indicated with a spinner during save. A confirmation SnackBar displays upon acknowledged write. If an error occurs, the form values remain intact without clearing so user input is never lost.

---

## 3. Advanced Search & Filtering (Task 3)

The search controls above the inventory list allow dynamic querying with client-side reactivity:
1. **Keyword Search:** Partial, case-insensitive substring match against `itemName` OR `sku` (`item.itemName.toLowerCase().contains(q) || item.sku.toLowerCase().contains(q)`).
2. **Category Filter:** Dropdown with `All` plus the 4 permitted categories (`Electronics`, `Stationery`, `Hardware`, `Grocery`).
3. **Low-Stock Filter:** When toggled on, only records where `quantity <= reorderLevel` are included.
4. **Combined Filtering:** Active search parameters are joined using logical `AND` (`matchesKeyword && matchesCategory && matchesLowStock`).
5. **Quantity Sorting:** Allows ascending order (lowest stock first) or descending order (highest stock first).
6. **Clear Filters & Empty State:** A dedicated button resets all filters, and a clear no-results message guides the user when no records match.

---

## 4. Test Log & Evidence

| Case # | Scenario & Test Input | Expected Result | Actual Result | Screenshot Evidence |
| :---: | :--- | :--- | :--- | :--- |
| **Test 1** | **Invalid Form Submission**<br>SKU: `STK-1`, Name: `ab`, Category: none, Qty: `-2`, Price: `0`, Reorder: `-1` | All fields display specific inline error messages. Firestore write is blocked. | Inline errors shown for all 6 fields; no network document written. | `screenshots/test1_invalid_form.png` |
| **Test 2** | **Valid Firestore Save & Retrieval**<br>Enter acceptance items:<br>1. `STK-101` / `USB C Cable` / `Electronics` / `4` / `RM 19.90` / `5`<br>2. `STK-102` / `Notebook` / `Stationery` / `25` / `RM 4.50` / `10`<br>3. `STK-103` / `Wireless Mouse` / `Electronics` / `1` / `RM 35.00` / `3` | Loading indicator during save. Success confirmation displayed. 3 retrievable Firestore items appear on inventory list with correct values. | Successfully saved to `stockItems` collection. All 3 records retrieved and displayed in real-time. | `screenshots/test2_valid_save_retrieve.png` |
| **Test 3** | **Combined Search & Low-Stock Filter**<br>Keyword: `"mouse"`, Category: `Electronics`, Low Stock: `ON` | Only `STK-103` (`Wireless Mouse`, Qty 1 <= Reorder 3) matches and appears. | Only `STK-103` appears in the list. STK-101 and STK-102 are filtered out. | `screenshots/test3_combined_search.png` |
| **Test 4** | **Quantity Sort & Reset Filters**<br>Sort: `Ascending`, then click `Clear Filters` | Ascending sort lists `STK-103` (1), `STK-101` (4), `STK-102` (25). `Clear Filters` restores full 3 items. | Correctly sorted by quantity; full inventory list restored on clear. | `screenshots/test4_sort_and_clear.png` |
