# 🕌 নামাজের সময়সূচী অ্যাপ (Namaz Time App)

ফ্লাটার দিয়ে তৈরি একটি সম্পূর্ণ নামাজের অ্যাপ।

## ফিচারসমূহ

- 📍 লোকেশন অনুযায়ী স্বয়ংক্রিয় ৫ ওয়াক্ত নামাজ + সূর্যোদয়ের সময়
- ⏱️ পরবর্তী নামাজের লাইভ কাউন্টডাউন
- 🧭 কিবলার দিক দেখানোর কম্পাস
- 🔔 আজান রিমাইন্ডার নোটিফিকেশন (প্রতি ওয়াক্তে)
- 📅 মাসিক ক্যালেন্ডার ভিউ (আগে-পরে মাস দেখা যায়)
- 🌙 ডার্ক মোড / লাইট মোড
- ⚙️ সেটিংস স্ক্রিন — নোটিফিকেশন অন/অফ, হিসাব পদ্ধতি (Calculation Method) পরিবর্তন
- 📅 হিজরি ও ইংরেজি তারিখ

## প্রজেক্ট স্ট্রাকচার

```
namaz_app/
├── pubspec.yaml
└── lib/
    ├── main.dart
    ├── models/
    │   └── prayer_time_model.dart
    ├── services/
    │   ├── prayer_service.dart        # Aladhan API (দৈনিক + মাসিক)
    │   └── notification_service.dart  # আজান রিমাইন্ডার
    ├── screens/
    │   ├── main_nav_screen.dart       # নিচের ন্যাভিগেশন বার
    │   ├── home_screen.dart
    │   ├── calendar_screen.dart
    │   ├── qibla_screen.dart
    │   └── settings_screen.dart
    └── utils/
        ├── time_utils.dart
        ├── settings_store.dart        # shared_preferences হেল্পার
        ├── theme_controller.dart      # ডার্ক/লাইট মোড টগল
        └── app_theme.dart             # থিম কালার স্কিম
```

---

## ধাপ ১: প্রজেক্ট সেটআপ

আপনার কম্পিউটারে [Flutter SDK](https://docs.flutter.dev/get-started/install) ইনস্টল থাকতে হবে (`flutter doctor` চালিয়ে চেক করুন সব ঠিক আছে কিনা)। তারপর এই ফোল্ডারে গিয়ে টার্মিনালে:

```bash
flutter create . --org com.yourname
flutter pub get
```

`flutter create .` কমান্ডটি `android/`, `ios/` ইত্যাদি প্ল্যাটফর্ম ফোল্ডার তৈরি করে দেবে (আমি সেগুলো দিইনি, কারণ এগুলো Flutter নিজে থেকেই জেনারেট করে — এতে আপনার লোকাল Flutter ভার্সনের সাথে সামঞ্জস্যপূর্ণ থাকবে)।

## ধাপ ২: পারমিশন যোগ করুন

**Android** — `android/app/src/main/AndroidManifest.xml` ফাইলে `<manifest>` ট্যাগের ভেতরে, `<application>` ট্যাগের বাইরে এই লাইনগুলো যোগ করুন:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.POST_NOTIFICATIONS"/>
<uses-permission android:name="android.permission.SCHEDULE_EXACT_ALARM"/>
<uses-permission android:name="android.permission.USE_EXACT_ALARM"/>
```

এছাড়া `android/app/build.gradle` ফাইলে `minSdkVersion` কমপক্ষে **21** আছে কিনা দেখে নিন (flutter_local_notifications এর জন্য প্রয়োজন)।

**iOS** — `ios/Runner/Info.plist` ফাইলে `<dict>` ট্যাগের ভেতরে যোগ করুন:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>নামাজের সময় ও কিবলা দেখানোর জন্য আপনার লোকেশন প্রয়োজন।</string>
```

---

## ধাপ ৩: মোবাইলে টেস্ট করার উপায় (গুরুত্বপূর্ণ)

### 🅰️ পদ্ধতি ১ — নিজের Android/iPhone সরাসরি USB দিয়ে (সবচেয়ে সহজ ও দ্রুত)

1. **আপনার ফোনে Developer Options চালু করুন:**
   - Settings → About Phone → "Build Number" এ পরপর ৭ বার ট্যাপ করুন।
   - এরপর Settings → System → Developer Options এ গিয়ে **USB Debugging** চালু করুন।

2. **ফোনটি USB কেবল দিয়ে কম্পিউটারে কানেক্ট করুন।** ফোনে একটি পপআপ আসবে "Allow USB debugging?" — Allow চাপুন।

3. **টার্মিনালে চেক করুন ফোনটি ধরা পড়ছে কিনা:**
   ```bash
   flutter devices
   ```
   আপনার ফোনের নাম তালিকায় দেখা গেলে ঠিক আছে।

4. **অ্যাপ চালান:**
   ```bash
   flutter run
   ```
   কয়েক মিনিটের মধ্যে অ্যাপটি বিল্ড হয়ে সরাসরি আপনার ফোনে ইনস্টল ও চালু হয়ে যাবে। কোড পরিবর্তন করলে টার্মিনালে `r` চাপলে **Hot Reload** হয়ে সাথে সাথে পরিবর্তন দেখা যাবে।

   (iPhone এর ক্ষেত্রে Mac + Xcode প্রয়োজন হবে, এবং প্রথমবার একটি ফ্রি Apple ID দিয়ে সাইন করতে হবে।)

### 🅱️ পদ্ধতি ২ — APK ফাইল বানিয়ে সরাসরি ফোনে ইনস্টল (USB ছাড়া, শুধু ফাইল ট্রান্সফার)

```bash
flutter build apk --release
```

এটি `build/app/outputs/flutter-apk/app-release.apk` নামে একটি ফাইল তৈরি করবে। এই APK ফাইলটি WhatsApp, Google Drive, বা USB দিয়ে আপনার Android ফোনে পাঠিয়ে ফাইল ম্যানেজার থেকে ট্যাপ করে ইনস্টল করুন (প্রথমবার "Install from unknown sources" অনুমতি দিতে হতে পারে)।

### 🅲️ পদ্ধতি ৩ — কম্পিউটার/ল্যাপটপ না থাকলে (শুধু ফোন দিয়ে)

- **GitHub + Codemagic (বিনামূল্যে):**
  1. এই কোডটি একটি GitHub রিপোজিটরিতে আপলোড করুন (মোবাইল থেকেও GitHub অ্যাপ বা ওয়েবসাইট দিয়ে করা সম্ভব)।
  2. [codemagic.io](https://codemagic.io) এ গিয়ে ফ্রি অ্যাকাউন্ট খুলুন ও রিপোজিটরি কানেক্ট করুন।
  3. Codemagic স্বয়ংক্রিয়ভাবে Flutter প্রজেক্ট শনাক্ত করে APK বিল্ড করে দেবে — বিল্ড শেষে APK ডাউনলোড লিংক পাবেন, সেটি ফোনে ডাউনলোড করে ইনস্টল করুন।
  - এভাবে কম্পিউটার বা Android Studio ছাড়াই শুধু ফোন দিয়ে পুরো প্রক্রিয়াটি করা সম্ভব।

### এমুলেটর দিয়ে টেস্ট (কম্পিউটারে, ফোন ছাড়া)

Android Studio ইনস্টল করে একটি Virtual Device (AVD) তৈরি করুন, তারপর:
```bash
flutter run
```
স্বয়ংক্রিয়ভাবে এমুলেটরে চলবে। **তবে মনে রাখবেন:** কম্পাস (কিবলা) সেন্সর এমুলেটরে কাজ নাও করতে পারে — এই ফিচারটি আসল ফোনে টেস্ট করাই ভালো।

---

## ব্যবহৃত API

নামাজের সময়সূচী আনা হয়েছে বিনামূল্যের **[Aladhan API](https://aladhan.com/prayer-times-api)** থেকে। সেটিংস স্ক্রিন থেকে হিসাব পদ্ধতি (Karachi, ISNA, Muslim World League ইত্যাদি) পরিবর্তন করা যায়।

## জানা সীমাবদ্ধতা

- নোটিফিকেশন শিডিউল হয় অ্যাপ চালু/রিফ্রেশ করার সময়। প্রতিদিন ব্যাকগ্রাউন্ডে স্বয়ংক্রিয়ভাবে রিশিডিউল করতে `workmanager` প্যাকেজ যোগ করা যেতে পারে।
- কিবলা কম্পাসের নির্ভুলতা ফোনের ম্যাগনেটোমিটার সেন্সরের মানের উপর নির্ভর করে।
