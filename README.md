# Bharosa Real Estate 🏠

A complete, production-ready Real Estate Flutter application with Firebase integration.

## Features

- ✅ **Firebase Authentication** (Email/Password)
- ✅ **Firestore Database Integration** for property listings and user profiles
- ✅ **Property Listings** with advanced filtering (Apartment, House, Commercial, Land)
- ✅ **Real-time Search** functionality with filtering
- ✅ **User Profile Management** with profile editing and image upload
- ✅ **Property Details** with image carousel and smooth page indicators
- ✅ **Favorites/Wishlist** system with swipe-to-remove
- ✅ **Agent Directory** and contact features (call, WhatsApp)
- ✅ **Ratings & Reviews** system
- ✅ **Beautiful Material Design UI** with gradient backgrounds
- ✅ **Splash Screen** with branding and animations
- ✅ **Bottom Navigation** (Home, Favorites, Profile)
- ✅ **Sorting and Filtering** options
- ✅ **Property Cards** with shimmer loading effect
- ✅ **Share Property** functionality

## Project Structure

```
lib/
├── main.dart                          # App initialization with Firebase
├── firebase_options.dart              # Firebase configuration (update with your config)
├── models/
│   ├── user_model.dart               # User model with Firestore serialization
│   └── property_model.dart           # Property model with complete details
├── providers/
│   ├── auth_provider.dart            # Authentication & user management
│   └── property_provider.dart        # Property listings, filtering, sorting
└── screens/
    ├── splash_screen.dart            # Animated splash screen
    ├── home_screen.dart              # Main screen with bottom navigation
    ├── favorites_screen.dart         # Favorites/Wishlist screen
    ├── profile_screen.dart           # User profile with editing
    ├── auth/
    │   ├── login_screen.dart         # Email/password login
    │   └── signup_screen.dart        # User registration with type selection
    └── property/
        ├── property_list_screen.dart  # Property list with search & filters
        └── property_detail_screen.dart # Property details with image carousel
```

## Setup Instructions

### 1. Firebase Setup

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Create a new project named `bharosa-real-estate`
3. Enable **Authentication** → Email/Password provider
4. Enable **Firestore Database** (start in test mode initially)
5. Enable **Firebase Storage**

### 2. Add Firebase to your app

**For Android:**
- Download `google-services.json` from Firebase Console
- Place it in `android/app/google-services.json`

**For iOS:**
- Download `GoogleService-Info.plist` from Firebase Console
- Place it in `ios/Runner/GoogleService-Info.plist`

### 3. Update Firebase Options

Run the FlutterFire CLI to auto-generate `firebase_options.dart`:
```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Or manually update `lib/firebase_options.dart` with your Firebase project credentials.

### 4. Install Dependencies

```bash
flutter pub get
```

### 5. Run the App

```bash
flutter run
```

## Firestore Data Structure

### `users` collection
```json
{
  "uid": "user_id",
  "name": "John Doe",
  "email": "john@example.com",
  "phone": "+919876543210",
  "userType": "buyer|seller|agent",
  "profileImageUrl": "https://...",
  "bio": "About me",
  "location": "Mumbai, Maharashtra",
  "favoriteProperties": ["property_id_1", "property_id_2"],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

### `properties` collection
```json
{
  "title": "Luxury 3BHK Apartment",
  "description": "Beautiful apartment...",
  "type": "apartment|house|commercial|land",
  "status": "forSale|forRent|sold|rented",
  "price": 5000000,
  "location": "Bandra West",
  "city": "Mumbai",
  "state": "Maharashtra",
  "bedrooms": 3,
  "bathrooms": 2,
  "area": 1500,
  "imageUrls": ["https://..."],
  "agentId": "agent_user_id",
  "agentName": "Agent Name",
  "agentPhone": "+919876543210",
  "amenities": ["Parking", "Gym", "Swimming Pool"],
  "isFeatured": true,
  "averageRating": 4.5,
  "reviewCount": 12,
  "reviews": [],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

## Dependencies

| Package | Version | Purpose |
|---------|---------|---------|
| firebase_core | ^2.27.0 | Firebase initialization |
| firebase_auth | ^4.17.4 | Authentication |
| cloud_firestore | ^4.15.5 | Database |
| firebase_storage | ^11.6.10 | Image storage |
| provider | ^6.1.2 | State management |
| google_fonts | ^6.2.1 | Typography |
| cached_network_image | ^3.3.1 | Image caching |
| shimmer | ^3.0.0 | Loading skeleton |
| smooth_page_indicator | ^1.1.0 | Carousel indicators |
| flutter_rating_bar | ^4.0.1 | Star ratings |
| image_picker | ^1.0.7 | Image selection |
| url_launcher | ^6.2.6 | Phone/WhatsApp links |
| share_plus | ^9.0.0 | Share property |
| intl | ^0.19.0 | Date formatting |

## Firestore Security Rules

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    match /properties/{propertyId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

---

Built with ❤️ by **Bharosa Real Estate Team** 
