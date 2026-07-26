Real product photos go here once Phase 3 (Manage screen + image
picker) is live. During Phase 1-2 development we use network
placeholder images from dummy_products.dart instead — nothing needs
to be added to this folder yet.

Once real product entry starts, images picked via image_picker will
typically be saved to the app's local documents directory at runtime
(not bundled as static assets like categories/), since products are
added dynamically by the shop owner. This folder is here as a
placeholder/reference only.
