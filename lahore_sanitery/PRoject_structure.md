# Sanitary Store App — Project Structure

Full scaffold, ready to unzip into a fresh `flutter create sanitary_store`
project (replace its `lib/`, `pubspec.yaml`, and add the `assets/` folder).

## Folder tree

```
sanitary_store/
  pubspec.yaml                          [Phase 1 - already filled]
  assets/
    categories/README.txt               [Phase 6 - add real photos]
    products/README.txt                 [reference only]
  lib/
    main.dart                           [Phase 1 - done, wired to MainNav]
    models/
      product.dart                      [Phase 1 - DONE]
    services/
      product_repository.dart           [Phase 1 - DONE]
      voice_search_service.dart         [Phase 4 - stub]
    data/
      dummy_products.dart               [Phase 1 - DONE]
    screens/
      home_screen.dart                  [Phase 2 - stub]
      products_screen.dart              [Phase 2 - stub]
      manage_screen.dart                [Phase 2 - stub]
      add_edit_product_screen.dart      [Phase 2/3 - stub]
    widgets/
      main_nav.dart                     [Phase 2 - stub, bottom nav shell]
      mic_button.dart                   [Phase 2 - stub]
      voice_search_sheet.dart           [Phase 2/4 - stub]
      product_card.dart                 [Phase 2 - stub]
      category_tile.dart                [Phase 2 - stub]
```

## Status right now

Everything marked **DONE** is real, working code from Phase 1.
Everything marked **stub** is a compiling placeholder (`Placeholder()`
widget or empty method) with a comment explaining exactly what goes
there and in which phase — the app will run and show a diagonal-line
placeholder box on each unbuilt screen, which is expected.

## Phase → file map (for quick reference as we go)

| Phase | Files touched |
|---|---|
| 1 — Foundation | `models/product.dart`, `services/product_repository.dart`, `data/dummy_products.dart`, `main.dart` |
| 2 — Static UI | `screens/*.dart`, `widgets/main_nav.dart`, `widgets/mic_button.dart`, `widgets/voice_search_sheet.dart` (static only), `widgets/product_card.dart`, `widgets/category_tile.dart` |
| 3 — Core CRUD | `screens/manage_screen.dart`, `screens/add_edit_product_screen.dart` (wire to repository + image_picker) |
| 4 — Voice search | `services/voice_search_service.dart`, `widgets/mic_button.dart` (wire onTap), `widgets/voice_search_sheet.dart` (wire live state) |
| 5 — Typed search + filters | `screens/home_screen.dart` (search bar logic), `screens/products_screen.dart` (category filter logic) |
| 6 — Polish + real data | `assets/categories/*`, real product photos, replace `dummy_products.dart` usage |
| 7 — Client testing | no new files — testing + bugfixes across the above |

## Category color convention (from the Stitch design)

Keep these consistent across `category_tile.dart` usage on Home and
Products screens:

- Pipes — blue
- Nuts & Bolts — dark gray/black
- Taps — teal
- Fittings — orange
- Valves — red
- Tools — purple

## Next step

We're set up through Phase 1. Say the word when you want to start
Phase 2 and we'll build out `home_screen.dart`, `main_nav.dart`, and
the shared widgets together, screen by screen.
