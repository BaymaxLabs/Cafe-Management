# Cafe Management — Implementation & Architecture Plan

## Design Summary

**App name:** Brew / Cafe Management  
**Theme:** Dark (#1A1A1A background, #F5A623 amber accent, white text, red for breached SLA, amber for urgent/low stock, green for healthy)  
**Typography:** Heavy weight display font for hero text, clean sans-serif for UI  
**Layout:** Split-panel on tablet/web (left nav sidebar + right content); mobile assumes full-screen navigation  
**Audience:** Cafe staff (Admin, Manager, Cashier, Inventory Manager, Staff roles)

---

## Screen Inventory

| # | Screen | Route | Status |
|---|--------|-------|--------|
| 1 | Landing (Login / Register entry) | `/` | ✅ done |
| 2 | Sign In | `/login` | ✅ done |
| 3 | Create Account (4-step wizard) | `/register` | ✅ done |
| 4 | Orders (live board) | `/orders` | ⬜ pending |
| 5 | Operations hub | `/operations` | ⬜ pending |
| 6 | Operations → Inventory | `/operations/inventory` | ⬜ pending |
| 7 | Operations → Menu Stock | `/operations/menu-stock` | ⬜ pending |
| 8 | Operations → Members | `/operations/members` | ⬜ pending |
| 9 | Operations → Roles & Access | `/operations/roles` | ⬜ pending |
| 10 | Operations → Table QR Codes | `/operations/qr-codes` | ⬜ pending |
| 11 | Operations → Completed Orders | `/operations/completed-orders` | ⬜ pending |
| 12 | Menu catalogue | `/menu` | ⬜ pending |
| 13 | Menu → Add/Edit item (bottom sheet) | overlay on `/menu` | ⬜ pending |
| 14 | Notifications panel | overlay on any screen | ⬜ pending |
| — | Analytics | `/analytics` | ⬜ WIP stub |
| — | Settings | `/settings` | ⬜ WIP stub |

---

## Architecture

### Approach: Feature-First

Each feature is a self-contained folder with its own screens, widgets, models, services, and state. Only code that is genuinely shared across multiple features lives outside a feature folder. This matches the existing codebase structure introduced by the peer PR.

### Folder Structure

```
lib/
  main.dart                        # app entry, MaterialApp, theme, provider setup

  core/
    router/
      app_router.dart              # onGenerateRoute — maps route names to screens
      app_routes.dart              # route name constants
    theme/
      app_colors.dart              # all color tokens (single source of truth)
      app_theme.dart               # ThemeData built from AppColors

  features/
    auth/
      models/
        app_user.dart              # User data class (uid, phone, cafeName, role)
      services/
        auth_service.dart          # all Firebase Auth + Firestore calls; no Flutter deps
      state/
        auth_state.dart            # ChangeNotifier: currentUser, login, logout
      screens/
        landing_screen.dart        # Image #1 — Login / Register entry
        login_screen.dart          # Image #2
        register_screen.dart       # Image #3 — 4-step wizard
      widgets/
        brew_logo.dart
        feature_item.dart

    orders/
      models/
        order.dart                 # Order, OrderItem data classes
      services/
        order_service.dart         # Firestore reads/writes for orders
      state/
        order_state.dart           # ChangeNotifier: live list, SLA timer ticks
      screens/
        orders_screen.dart         # Image #4
      widgets/
        order_card.dart            # SLA progress bar + status badge
        order_filter_bar.dart

    operations/
      screens/
        operations_screen.dart     # Image #5 — hub with 6 nav tiles
      # sub-features below share the operations route prefix
      inventory/
        models/
          inventory_item.dart
        services/
          inventory_service.dart
        state/
          inventory_state.dart
        screens/
          inventory_screen.dart    # Image #6
        widgets/
          inventory_item_card.dart
      menu_stock/
        models/
          menu_stock_item.dart
        services/
          menu_stock_service.dart
        state/
          menu_stock_state.dart
        screens/
          menu_stock_screen.dart   # Image #7
        widgets/
          menu_stock_item_row.dart
      members/
        models/
          member.dart
        services/
          member_service.dart
        state/
          member_state.dart
        screens/
          members_screen.dart      # Image #8
        widgets/
          member_list_tile.dart
          add_member_wizard.dart   # 5-step wizard
      roles/
        models/
          role.dart
        services/
          role_service.dart
        state/
          role_state.dart
        screens/
          roles_screen.dart        # Image #9
        widgets/
          role_list_tile.dart
      qr_codes/
        screens/
          qr_codes_screen.dart     # Image #10
      completed_orders/
        screens/
          completed_orders_screen.dart  # Image #11

    menu/
      models/
        menu_item.dart
      services/
        menu_service.dart
      state/
        menu_state.dart
      screens/
        menu_screen.dart           # Image #12
      widgets/
        menu_item_card.dart
        menu_category_chip.dart
        add_menu_item_sheet.dart   # Image #13 — bottom sheet

    notifications/
      models/
        notification_item.dart
      services/
        notification_service.dart
      state/
        notification_state.dart
      widgets/
        notifications_panel.dart   # Image #14 — slide-in overlay

    analytics/
      screens/
        analytics_screen.dart      # WIP stub

    settings/
      screens/
        settings_screen.dart       # WIP stub

  widgets/                         # shared cross-feature components only
    app_scaffold.dart              # sidebar nav + top bar + notification bell
    brew_search_bar.dart
    filter_chip_bar.dart
    status_badge.dart              # Breached / Urgent / On Track / Low Stock chips
    avatar_initials.dart           # circular initials avatar (AK, PS, etc.)
    section_nav_tile.dart          # Operations hub row tile with icon + chevron
    primary_button.dart            # moved here from features/auth/widgets
    empty_state.dart
```

### Rules

- **Features own their code.** A screen, widget, model, service, or state class lives inside the feature that owns it.
- **No cross-feature imports.** Feature A must not import from Feature B's folder. If both need something, it belongs in `widgets/` or a shared model at `core/`.
- **`widgets/` is for shared UI only.** If a widget is used in only one feature, it stays inside that feature's `widgets/` subfolder.
- **Services have no Flutter deps.** They take plain Dart inputs and return models or throw exceptions. No `BuildContext`, no `Navigator`.
- **State (ChangeNotifiers) owns business logic.** Screens call state methods; state calls services. Screens never call services directly.

### State Management

Use `ChangeNotifier` + `provider`. One `ChangeNotifier` per feature domain, provided at the root via `MultiProvider` in `main.dart`.

- No Riverpod, Bloc, or Redux — overkill for this scope.
- `provider` package to be added to `pubspec.yaml` as part of the auth service layer task.

### Navigation

Use Flutter's named routes. `core/router/app_router.dart` owns `onGenerateRoute`. The sidebar in `AppScaffold` pushes named routes from `app_routes.dart`.

---

## Design Tokens (`core/theme/app_colors.dart`)

All color constants live in `AppColors`. `AppTheme` consumes them to build `ThemeData`. Never use raw hex values in feature code — always reference `AppColors`.

| Token | `AppColors` field | Value |
|-------|-------------------|-------|
| Background | `background` | `#141414` |
| Surface / card | `surface` | `#1E1E1E` |
| Card (elevated) | `cardElevated` | `#222222` |
| Accent / Amber | `gold` | `#C9A84C` |
| Login button bg | `loginButton` | `#F0EFED` |
| Login button text | `loginButtonText` | `#141414` |
| Register button bg | `registerButton` | `#2A2A2A` |
| Text primary | `white` | `#FFFFFF` |
| Text secondary | `textMuted` | `#9A9A9A` |
| SLA breached / red | `slaBreached` | `#E53935` |
| SLA urgent / orange | `slaUrgent` | `#FF6F00` |
| Success / green | `success` | `#43A047` |
| Low stock / amber | `lowStock` | `#FF6F00` |
| Nav selected bg | — | `gold` at 15% opacity |
| Card border | `cardBorder` | `#2C2C2C` |
| Divider | `divider` | `#2A2A2A` |
| Border radius (cards) | — | `12px` |
| Border radius (chips) | — | `8px` |
| Border radius (buttons) | — | `14px` |

> **Note:** The tokens marked with `†` (`cardElevated`, `slaBreached`, `slaUrgent`, `success`, `cardBorder`, `divider`) are not yet in `AppColors` and must be added before building Orders, Inventory, or Menu screens.

---

## Feature-by-Feature Plan

### 1. Splash Screen
- Full black screen, centered "Brew" logo + "Cafe Management" wordmark
- 2s delay → navigate to Sign In (or Orders if already authenticated)

### 2. Auth — Sign In
- Left panel: "Welcome back." hero text (decorative, wider screens only)
- Right panel: phone `+91` input, Password / OTP tab toggle, Shop Code field, Login button
- On success → store `AuthState` (user, shopCode, role) → navigate to `/orders`

### 3. Auth — Create Account (4-step wizard)
- Step indicators: Phone → Verify → Password → Cafe
- Step 1: Phone number input + Send OTP
- Step 2: 6-digit OTP verification
- Step 3: Set password
- Step 4: Cafe name / shop setup
- Each step validates before Next is enabled

### 4. Orders Screen
- `AppScaffold` with sidebar (Orders highlighted)
- Header: "Orders" title + subtitle + notification bell with red badge
- `SearchBar` (order ID or table)
- `FilterChipBar`: All / Breached / Urgent / On Track / Unassigned (with counts)
- `ListView` of `OrderCard` widgets, sorted by urgency (Breached → Urgent → On Track)
- **OrderCard** contains:
  - Order ID (small, muted), Table label (large bold), order type (Dine-in / Takeaway)
  - Item names (right-aligned, truncated)
  - SLA `LinearProgressIndicator` — color driven by status (red=Breached, amber=Urgent, green=On Track)
  - Elapsed time (left) and SLA delta/remaining text (right, color-coded)
  - Assigned staff avatar + name, or "Unassigned" + "Assign" button
- Swipe-right or long-press to mark complete → moves to Completed Orders
- SLA timer ticks via a `Timer.periodic` in `OrderState`

### 5. Operations Hub
- List of 6 `SectionNavTile` rows: Inventory, Menu Stock, Members, Roles & Access, Table QR Codes, Completed Orders
- Each row has a rounded-square icon (amber tint), title, subtitle, right chevron

### 6. Inventory
- Back button + title + "N need attention" subtitle
- `SearchBar`
- `FilterChipBar`: All / Low Stock / Out of Stock
- `InventoryItemCard`: code, name, last-updated-by + time, stock level `LinearProgressIndicator` (green/amber based on alert threshold), quantity + unit (top-right), alert threshold text, "Low stock" badge
- FAB (`+`) → add inventory item sheet

### 7. Menu Stock
- Same pattern as Inventory but items have a `Toggle` switch (in/out of stock) + quantity badge
- Category filter chips: All / Coffee / Food / Drinks / Desserts / + New
- Second filter row: All / Low Stock / Out of Stock
- Items grouped under category headings
- Low stock items show amber "Low — alert limit N" subtitle

### 8. Members
- "N total · N active" subtitle
- `FilterChipBar`: All / Active / On Leave / Inactive
- `MemberListTile`: initials avatar, name + active indicator dot, employee ID + phone, role badge, chevron
- FAB → 5-step Add Member wizard:
  1. Basic details (name, phone, employee ID, join date, emergency contact, notes)
  2. Phone OTP verification
  3. Optional ID photo (Aadhaar etc.)
  4. Assign role
  5. Confirmation summary

### 9. Roles & Access
- "N roles · N staff" subtitle
- Grouped under DEFAULT ROLES header
- `RoleListTile`: colored dot, role name, DEFAULT badge, description, assigned member avatars (small), chevron
- FAB → create custom role

### 10. Table QR Codes
- 3-column grid of table tiles (T1–T6+)
- Each tile: dark card, QR icon placeholder + table label
- Tap → generate/show QR code for that table (modal or detail screen)

### 11. Completed Orders
- `FilterChipBar`: All / On Time / Urgent / Breached SLA
- Empty state: icon + "No completed orders yet" + hint text
- Populated: order cards showing completion metadata

### 12. Menu Catalogue
- Grid/list toggle (top-right icons)
- `FilterChipBar` for categories (Hot Coffee, Cold Coffee, Tea, Food, Desserts, Snacks)
- Featured section with colored gradient cards (icon + name + price)
- Regular items in 2-column grid or list with tags (Bestseller, New, Vegan, etc.)
- FAB → `AddMenuItemSheet`

### 13. Add Menu Item Sheet (Bottom Sheet)
- Photo upload (optional)
- Item name, Category dropdown, Base Price
- Description textarea
- Tags (multi-select chips: Bestseller, New, Vegan, Spicy, Gluten-free, Sugar-free)
- Variants section (size label + price, add more via `+`)
- Available toggle + Featured toggle
- Cancel / Add to menu buttons

### 14. Notifications Panel
- Slides in from the right (or top on mobile) when bell is tapped
- List of alert items: colored dot (red=breach, amber=urgent), order ID, message
- Dismissible per item

---

## Dependencies

| Package | Status | Reason |
|---------|--------|--------|
| `http` | ✅ existing | HTTP calls (Firestore REST fallback) |
| `firebase_core` | ✅ existing | Firebase initialisation |
| `firebase_auth` | ✅ existing | Phone OTP authentication |
| `cloud_firestore` | ✅ existing | Database |
| `mockito` | ✅ existing (dev) | Fake implementations for unit tests |
| `build_runner` | ✅ existing (dev) | Code generation for mockito |
| `provider` | ❌ to add | ChangeNotifier injection without boilerplate |
| `qr_flutter` | ❌ to add | Generate QR codes for Table QR Codes screen |
| `shared_preferences` | ❌ to add | Persist auth session across app restarts |

---

## Implementation Order

1. ~~Core theme + routing skeleton~~ ✅ done
2. ~~Landing / Sign In / Register screens~~ ✅ done
3. ~~Spec-first test framework~~ ✅ done (PR #17)
4. AppUser model + AuthService + AuthState + provider wiring (branch: `feature/auth-service-and-state`)
5. Orders screen (most complex — SLA timer, swipe gesture, filter)
6. Menu screen + Add Item sheet
7. Operations hub + Inventory + Menu Stock
8. Members + Add Member wizard
9. Roles & Access + Table QR Codes
10. Completed Orders + Notifications panel
11. Analytics stub + Settings stub
