# Unigo 🧭 – University Marketplace App

Unigo is a Flutter-based mobile application designed to help university students buy, sell, and trade second-hand items within their campus community.

## 🛠 Features

- 🔐 User Registration & Login
- 📦 Item Listing with Image Upload
- 🛍 View Items by Category & Status
- 💬 In-App Messaging between Buyers & Sellers
- 🧭 Location Autofill via GPS
- 📂 SQLite & MySQL Integration
- 🎨 Responsive UI with Theme Support

## 📸 Screenshots

| Login Screen                       | Item Listing                      | Messaging                        |
| ---------------------------------- | --------------------------------- | -------------------------------- |
| ![login](assets/screens/login.png) | ![list](assets/screens/items.png) | ![chat](assets/screens/chat.png) |

## 🧑‍💻 Tech Stack

- **Flutter**: Frontend framework
- **PHP + MySQL**: Backend API & database
- **Geolocator**: Location services
- **Shared Preferences**: Local data storage
- **HTTP**: Network requests

---

## 🚀 Getting Started

### 1. Clone the Repository

```bash
git clone https://github.com/ahmadhanis/FlutterA242.git
cd unigo
```

### 2. Set Up Flutter Environment

Ensure you have Flutter installed:

```bash
flutter doctor
```

### 3. Install Dependencies

```bash
flutter pub get
```

### 4. Update `MyConfig` File

Open `lib/shared/myconfig.dart` and update with your own API base URL:

```dart
class MyConfig {
  static const String myurl = "https://yourdomain.com/";
}
```

### 5. Run the App

```bash
flutter run
```

---

## 🗄 Backend Setup (PHP + MySQL)

1. Import `unigo_db.sql` into your MySQL server.
2. Upload the `php/` folder to your hosting server.
3. Make sure your hosting allows CORS and file upload for profile images and items.
4. Update `php/dbconnect.php` with your actual DB credentials.

---

## 📁 Folder Structure

```
lib/
├── model/              # Data models (User, Item, Message)
├── shared/             # Config, route animations
├── view/               # Screens (Login, Register, MainScreen, etc.)
assets/
├── images/             # Static assets
php/                    # Backend PHP scripts
```

---

## 👥 Credits

Developed by Hanis  
Special thanks to ...

---

## 📃 License

This project is licensed under the MIT License.
