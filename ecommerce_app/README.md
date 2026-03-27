# Jenoury Shop - Flutter E-Commerce App

A clean, production-ready mobile shopping experience built entirely with Flutter. This isn't a throwaway demo — it's a real e-commerce app that handles product browsing, cart management, Stripe-powered checkout, and order tracking. Designed with the kind of attention to detail that makes users actually want to come back.

## What This App Does

Think of it as a lightweight Shopify storefront in your pocket. You browse products pulled from a live API, toss items into a persistent cart, pay with a real Stripe payment sheet, and then track every order you've placed. The whole flow works end to end — no fake buttons, no placeholder screens.

### Core Features

- **Product Catalog** — Live product data fetched from [FakeStoreAPI](https://fakestoreapi.com), displayed in a responsive grid with cached images, ratings, and category filtering
- **Search & Sort** — Real-time search across product titles, descriptions, and categories. Sort by price, rating, or name in either direction
- **Shopping Cart** — Persistent cart (survives app restarts) with quantity controls, swipe-to-delete, live price calculations including tax and shipping
- **Stripe Checkout** — Full Stripe payment integration using the official `flutter_stripe` SDK. Creates real PaymentIntents, presents the native Stripe payment sheet, and processes card payments
- **Order History** — Every completed purchase is saved locally with full item details, shipping address, payment reference, and a visual status timeline
- **User Authentication** — Login/register flow with form validation, persisted sessions, and a profile screen with order stats
- **Free Shipping Logic** — Orders over $50 ship free; the cart shows exactly how much more you need to qualify

## Tech Stack

| Layer | Technology |
|-------|-----------|
| **Framework** | Flutter 3.2+ / Dart |
| **State Management** | Provider |
| **Payments** | Stripe (flutter_stripe) |
| **Networking** | http / dio |
| **Local Storage** | SharedPreferences |
| **Image Caching** | cached_network_image |
| **UI Polish** | Shimmer loading, Hero animations, Material 3 |

## Project Structure

```
lib/
├── config/
│   ├── app_config.dart        # Environment variables, constants
│   ├── routes.dart            # Named route definitions
│   └── theme.dart             # App-wide theme, colors, shadows
├── models/
│   ├── product.dart           # Product + ProductRating
│   ├── cart_item.dart         # Cart item with quantity
│   ├── order.dart             # Order, OrderStatus, ShippingAddress
│   └── user.dart              # AppUser model
├── services/
│   ├── api_service.dart       # REST API client (products, categories)
│   ├── stripe_service.dart    # Stripe PaymentIntent + payment sheet
│   ├── auth_service.dart      # Login, register, session management
│   ├── cart_service.dart      # Cart persistence
│   └── order_service.dart     # Order creation and retrieval
├── providers/
│   ├── product_provider.dart  # Product state, filtering, sorting
│   ├── cart_provider.dart     # Cart state, calculations
│   ├── order_provider.dart    # Order state management
│   └── auth_provider.dart     # Auth state, user session
├── screens/
│   ├── home/                  # Main product grid + navigation
│   ├── product_detail/        # Full product view with add-to-cart
│   ├── cart/                  # Cart with summary and checkout
│   ├── checkout/              # Shipping form + Stripe payment
│   ├── orders/                # Order list + order detail
│   ├── auth/                  # Login + Register screens
│   └── profile/               # User profile + settings
├── widgets/
│   ├── product_card.dart      # Product grid card
│   ├── cart_item_tile.dart    # Cart item with swipe delete
│   ├── shimmer_loading.dart   # Loading skeleton grid
│   ├── category_chip.dart     # Category filter pill
│   ├── search_bar_widget.dart # Search input
│   └── sort_bottom_sheet.dart # Sort options modal
├── utils/
│   └── helpers.dart           # Currency formatting, snackbars, dialogs
└── main.dart                  # App entry point
```

## Getting Started

### Prerequisites

- Flutter SDK 3.2 or higher
- Dart SDK
- A Stripe account (for payment testing)
- Android Studio / VS Code with Flutter extension

### Installation

1. **Clone the repository**

```bash
git clone https://github.com/Haris-Ahmed83/Flutter-Jenoury.git
cd Flutter-Jenoury/ecommerce_app
```

2. **Set up environment variables**

```bash
cp .env.example .env
```

Open `.env` and add your Stripe keys:

```
STRIPE_PUBLISHABLE_KEY=pk_test_your_key_here
STRIPE_SECRET_KEY=sk_test_your_key_here
STRIPE_MERCHANT_ID=merchant.com.jenoury.ecommerce
API_BASE_URL=https://fakestoreapi.com
```

> Get your test keys from [Stripe Dashboard](https://dashboard.stripe.com/test/apikeys)

3. **Install dependencies**

```bash
flutter pub get
```

4. **Run the app**

```bash
flutter run
```

### Stripe Test Cards

When testing payments, use these Stripe test card numbers:

| Card Number | Scenario |
|------------|----------|
| `4242 4242 4242 4242` | Successful payment |
| `4000 0000 0000 3220` | 3D Secure authentication |
| `4000 0000 0000 9995` | Declined payment |

Use any future expiry date and any 3-digit CVC.

## Architecture Decisions

**Why Provider over Riverpod/Bloc?** Provider keeps the codebase approachable. There's no boilerplate ceremony — just clean ChangeNotifiers that do exactly what you'd expect. For an app this size, that's the right tradeoff.

**Why SharedPreferences for orders?** This app is designed to work without a backend. In production, you'd swap the persistence layer for your API — the service interfaces are already structured to make that a straightforward change.

**Why FakeStoreAPI?** It gives us real product data with images, categories, and ratings without needing to set up a backend. The `ApiService` class is written so you can point it at your own API by changing one URL in the `.env` file.

## Moving to Production

This app is structured so the jump from "demo" to "production" is a series of small, contained changes:

1. **Backend API** — Swap `ApiService` URLs to your own REST/GraphQL backend
2. **Stripe** — Move PaymentIntent creation to your backend (never use the secret key client-side in production)
3. **Auth** — Replace `AuthService` simulation with your real auth provider (Firebase, Supabase, custom JWT)
4. **Storage** — Replace SharedPreferences with your backend's database for orders and user data
5. **Push Notifications** — Add FCM for order status updates

## License

This project is open-source and available under the [MIT License](LICENSE).

---

Built with Flutter. Payments powered by Stripe.
