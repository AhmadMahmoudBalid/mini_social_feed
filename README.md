# 📌 Mini Social Feed (Flutter Project)

Mini Social Feed هو مشروع Flutter متكامل يعتمد على هيكلية **Clean
Architecture** (core + features)، ويقدّم واجهة احترافية لعرض المنشورات
مع دعم كامل للمصادقة، رفع الوسائط، وعرض الملفات بمختلف أنواعها.

يتيح التطبيق للمستخدم: - إنشاء حساب جديد / تسجيل الدخول\
- استخدام **Access + Refresh Tokens** مع Interceptor للـ Token Rotation\
- عرض جميع البوستات\
- حذف البوستات الخاصة بالمستخدم فقط\
- دعم الصور + الفيديو + الملفات بجميع أنواعها\
- تشغيل الفيديو والصوت داخل التطبيق\
- فتح الملفات مباشرة

## 🚀 Features

-   **Authentication**
    -   Sign In / Sign Up
    -   Token Rotation (Access + Refresh)
    -   Dio Interceptor لمعالجة الأخطاء وإعادة المحاولة تلقائيًا
-   **Posts Feed**
    -   عرض جميع البوستات (صور، فيديوهات، ملفات)
    -   عرض معلومات الوسائط (الاسم -- النوع -- الحجم)
    -   حذف البوستات الخاصة بك فقط
    -   تحميل/فتح الملفات المرفقة
-   **Media Support**
    -   Images (Cached)
    -   Videos (video_player + chewie)
    -   Audio files (audioplayers)
    -   Documents & any file type (open_filex)

## 🏛 Architecture

المشروع مبني على: - **core**:\
- error 
- network 

-   **feature**:
    -   auth\
    -   posts
    -   profile
    -   splash

## 🛠 Technologies & Packages Used

### Networking & Auth

    dio: ^5.0.0
    dartz: ^0.10.1
    flutter_secure_storage: ^9.2.4
    get_it: ^9.1.1
    flutter_bloc: ^9.1.1
    equatable:

### Media & Files

    cached_network_image: ^3.4.1
    video_player: ^2.10.1
    chewie: ^1.13.0
    audioplayers: ^6.1.0
    file_picker: ^10.3.7
    permission_handler: ^12.0.1
    open_filex: ^4.4.0
    path: ^1.9.0
    path_provider: ^2.1.4

### Utilities

    cupertino_icons: ^1.0.8
    flutter_lints: ^6.0.0
    url_launcher: ^6.3.0

## 📂 Project Structure

    lib/
     ├─ core/
     │   ├─ network/
     │   │    ├─ api_client.dart
     │   │    ├─ auth_interceptor.dart
     │   ├─ error/
     |   |    ├─ failures.dart
     ├─ features/
     │   ├─ auth/
     │   │    ├─ data/
     │   │    ├─ presentation/
     │   │
     │   ├─ posts/
     │   |    ├─ data/
     │   |    ├─ presentation/
     |   |
     │   ├─ profile/
     │        ├─ data/
     │        ├─ presentation/
     │
     └─ main.dart

