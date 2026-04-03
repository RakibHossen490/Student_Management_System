# 🎓 University Management System

A comprehensive Flutter mobile application for university/college management with Firebase backend integration. Supports dual user roles (Admin & Student) with complete CRUD operations, file management, attendance tracking, and modern UI with dark/light theme support.

![Flutter](https://img.shields.io/badge/Flutter-02569B?style=for-the-badge&logo=flutter&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-039BE5?style=for-the-badge&logo=Firebase&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-0175C2?style=for-the-badge&logo=dart&logoColor=white)
![Material Design](https://img.shields.io/badge/Material%20Design-757575?style=for-the-badge&logo=material-design&logoColor=white)

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Technology Stack](#-technology-stack)
- [Prerequisites](#-prerequisites)
- [Installation](#-installation)
- [Firebase Setup](#-firebase-setup)
- [Configuration](#-configuration)
- [Usage](#-usage)
- [Project Structure](#-project-structure)
- [API Reference](#-api-reference)
- [Contributing](#-contributing)
- [License](#-license)
- [Support](#-support)

## ✨ Features

### 👨‍💼 Admin Panel
- **Authentication**: Secure login with role-based access
- **Student Management**: Add, edit, delete, and view students
- **Attendance Tracking**: Mark and monitor student attendance
- **File Management**: Upload results, syllabus, and routine documents
- **Dashboard**: Comprehensive overview with navigation

### 👨‍🎓 Student Panel
- **Profile Management**: View and update personal information with photo upload
- **Attendance View**: Check personal attendance records and percentages
- **Results Access**: View exam results and download documents
- **Syllabus Access**: Access course materials and class routines

### 🎨 User Experience
- **Dark/Light Theme**: Toggle between themes with persistence
- **Real-time Updates**: Live data synchronization with Firebase
- **File Upload/Download**: Support for PDF, DOCX, and image files
- **Responsive Design**: Optimized for mobile devices
- **Material Design 3**: Modern UI with consistent design language

## 📸 Screenshots

### Authentication
- **Login Screen**: Dual-mode login for Admin and Student
- **Registration**: Admin account creation

### Admin Dashboard
- **Main Dashboard**: Navigation to all admin features
- **Student Management**: Table view with CRUD operations
- **Attendance Entry**: Mark attendance with date selection
- **File Upload**: Upload results and syllabus with file picker

### Student Dashboard
- **Profile Screen**: Personal information with photo upload
- **Attendance History**: View attendance records and percentages
- **Results View**: Access exam results and documents

## 🛠 Technology Stack

### Frontend
- **Framework**: Flutter (Latest Stable)
- **Language**: Dart
- **UI Framework**: Material Design 3
- **State Management**: Provider Pattern
- **Theme System**: Dynamic Dark/Light Mode

### Backend & Services
- **Authentication**: Firebase Auth
- **Database**: Cloud Firestore
- **File Storage**: Firebase Storage
- **Real-time Updates**: StreamBuilder

### Key Dependencies
```yaml
firebase_core: ^3.6.0          # Firebase initialization
firebase_auth: ^5.0.0          # Authentication
cloud_firestore: ^5.0.0        # Database operations
firebase_storage: ^12.0.0      # File uploads/downloads
provider: ^6.0.0               # State management
shared_preferences: ^2.0.0     # Local storage
image_picker: ^1.1.2           # Image selection
file_picker: ^10.3.10          # File selection
```

## 📋 Prerequisites

Before running this application, make sure you have:

- **Flutter SDK**: Latest stable version (3.11.4 or higher)
- **Dart SDK**: Included with Flutter
- **Android Studio / VS Code**: With Flutter extensions
- **Android/iOS Device/Emulator**: For testing
- **Firebase Account**: Google account for Firebase services

### System Requirements
* - **OS**: Windows 10/11, macOS, Linux
- **RAM**: 8GB minimum, 16GB recommended
- **Storage**: 2GB free space for Flutter SDK and project

## 🚀 Installation

### 1. Clone the Repository
```bash
git clone https://github.com/your-username/university-management-system.git
cd university-management-system
```

### 2. Install Flutter Dependencies
```bash
flutter pub get
```

### 3. Check Installation
```bash
flutter doctor
```

### 4. Run the Application
```bash
flutter run
```

## 🔥 Firebase Setup

### 1. Create Firebase Project
1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Create a project" or "Add project"
3. Enter project name: "University Management System"
4. Enable Google Analytics (optional)
5. Choose default account for Firebase

### 2. Enable Required Services
1. **Authentication**:
   - Go to Authentication → Sign-in method
   - Enable "Email/Password" provider

2. **Firestore Database**:
   - Go to Firestore Database → Create database
   - Choose "Start in test mode" (configure security rules later)

3. **Storage**:
   - Go to Storage → Get started
   - Create default bucket

### 3. Add Flutter App
1. Click the Flutter icon to add app
2. Enter app details:
   - Android package name: `com.example.my_app`
   - iOS bundle ID: `com.example.myApp`
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place files in respective directories

### 4. Security Rules

#### Firestore Rules
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users can read/write their own data
    match /users/{userId} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Students collection - read for all authenticated users, write for admins
    match /students/{studentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 0;
    }

    // Attendance - read for all, write for admins
    match /attendance/{attendanceId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 0;
    }

    // Results, Syllabus, Routine - read for all, write for admins
    match /{collectionName}/{documentId} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        get(/databases/$(database)/documents/users/$(request.auth.uid)).data.role == 0;
    }
  }
}
```

#### Storage Rules
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images - users can manage their own
    match /profile_images/{userId}/{allPaths=**} {
      allow read, write: if request.auth != null && request.auth.uid == userId;
    }

    // Other files - read for all authenticated, write for admins
    match /{allPaths=**} {
      allow read: if request.auth != null;
      allow write: if request.auth != null &&
        firestore.exists(/databases/(default)/documents/users/$(request.auth.uid)) &&
        firestore.get(/databases/(default)/documents/users/$(request.auth.uid)).data.role == 0;
    }
  }
}
```

## ⚙️ Configuration

### Environment Variables
Create a `.env` file in the root directory (optional):
```env
FIREBASE_API_KEY=your_api_key
FIREBASE_AUTH_DOMAIN=your_project.firebaseapp.com
FIREBASE_PROJECT_ID=your_project_id
FIREBASE_STORAGE_BUCKET=your_project.appspot.com
FIREBASE_MESSAGING_SENDER_ID=your_sender_id
FIREBASE_APP_ID=your_app_id
```

### Build Configuration
For production builds:
```bash
# Android APK
flutter build apk --release

# Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# iOS
flutter build ios --release
```

## 📱 Usage

### For Administrators

#### First Time Setup
1. **Register Admin Account**:
   - Open the app
   - Click "Register as Admin"
   - Fill in details and create account

2. **Login**:
   - Select "Admin Login"
   - Enter email and password

#### Managing Students
1. **Add Students**:
   - Go to "Student Management"
   - Select department and semester
   - Click "Add Student"
   - Fill in student details

2. **Mark Attendance**:
   - Go to "Attendance"
   - Select department → semester → student
   - Choose month and mark attendance

3. **Upload Files**:
   - Go to "Results" or "Syllabus & Routine"
   - Select department and semester
   - Click "Choose File" and upload

### For Students

#### Registration/Login
1. **Student Login**:
   - Select "Student Login"
   - Enter name, student ID, phone, and department
   - Account created automatically if new

#### Using the App
1. **Update Profile**:
   - Go to "My Profile"
   - Click camera icon to upload photo
   - Information auto-populated

2. **Check Attendance**:
   - Go to "Attendance"
   - View monthly attendance percentages

3. **View Results**:
   - Go to "Results"
   - Download and view exam results

## 📁 Project Structure

```
lib/
├── main.dart                    # App entry point with theme provider
├── firebase_options.dart        # Firebase configuration
├── models/                      # Data models
│   ├── user_model.dart         # User data with roles
│   ├── student.dart            # Student information
│   ├── attendance.dart         # Attendance records
│   ├── result.dart             # Exam results
│   ├── syllabus.dart           # Course syllabus
│   └── routine.dart            # Class routine
├── services/                    # Business logic and API calls
│   ├── auth_service.dart       # Authentication
│   ├── student_service.dart    # Student operations
│   ├── attendance_service.dart # Attendance tracking
│   ├── result_service.dart     # Result management
│   ├── syllabus_service.dart   # Syllabus management
│   ├── routine_service.dart    # Routine management
│   ├── file_storage_service.dart # Firebase Storage
│   └── theme_service.dart      # Theme management
├── screens/                     # UI screens
│   ├── auth/                   # Authentication screens
│   │   ├── auth_wrapper.dart   # Route guard
│   │   ├── login_screen.dart   # Login interface
│   │   └── register_screen.dart # Admin registration
│   ├── admin/                  # Admin panel
│   │   ├── admin_dashboard.dart # Main dashboard
│   │   ├── department_screen.dart
│   │   ├── semester_screen.dart
│   │   ├── student_list_screen.dart
│   │   ├── edit_student_screen.dart
│   │   ├── add_student_screen.dart
│   │   ├── attendance/         # Attendance management
│   │   ├── results/            # Result management
│   │   └── syllabus/           # Syllabus management
│   └── student/                # Student panel
│       ├── student_dashboard.dart
│       ├── student_profile_screen.dart
│       ├── student_attendance_screen.dart
│       ├── student_result_screen.dart
│       └── view_syllabus_screen.dart
└── utils/                      # Helper functions
```

## 🔌 API Reference

### Authentication Service
```dart
// Admin login
Future<UserModel?> adminLogin(String email, String password)

// Student login
Future<UserModel?> studentLogin(String name, String studentId, String phone, String department)

// Register admin
Future<UserModel?> registerAdmin(String name, String email, String password)

// Get current user
Future<UserModel?> getCurrentUserData()

// Logout
Future<void> logout()
```

### Student Service
```dart
// Get students by department and semester
Stream<List<Student>> getStudentsByDeptSem(String department, String semester)

// Add student
Future<void> addStudent(Student student)

// Update student
Future<void> updateStudent(String id, Student student)

// Delete student
Future<void> deleteStudent(String id)
```

### File Storage Service
```dart
// Upload result file
Future<String> uploadResultFile(File file, String semester, String subject, String fileName)

// Upload syllabus file
Future<String> uploadSyllabusFile(File file, String semester, String subject, String fileName)

// Upload routine file
Future<String> uploadRoutineFile(File file, String semester, String fileName)

// Upload profile image
Future<String> uploadProfileImage(File file, String userId)

// Delete file
Future<void> deleteFile(String downloadUrl)
```

## 🤝 Contributing

We welcome contributions! Please follow these steps:

### Development Setup
1. Fork the repository
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes
4. Run tests: `flutter test`
5. Check code quality: `flutter analyze`
6. Commit changes: `git commit -m 'Add some feature'`
7. Push to branch: `git push origin feature/your-feature-name`
8. Submit a pull request

### Code Style Guidelines
- Follow Flutter/Dart best practices
- Use meaningful variable and function names
- Add comprehensive documentation
- Follow SOLID principles
- Use const constructors where possible
- Maintain consistent code formatting

### Testing
```bash
# Run all tests
flutter test

# Run tests with coverage
flutter test --coverage

# Run integration tests
flutter test integration_test/
```

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

### Getting Help
- **Documentation**: Check this README and inline code comments
- **Issues**: Report bugs via GitHub Issues
- **Discussions**: Join community discussions

### Common Issues

#### Firebase Configuration
- Ensure `google-services.json` is in `android/app/`
- Verify Firebase project settings match app configuration
- Check Firestore and Storage security rules

#### Build Issues
```bash
# Clean and rebuild
flutter clean
flutter pub get
flutter run

# Check device connection
flutter devices
```

#### Theme Issues
- Theme preferences are stored locally
- Clear app data to reset theme settings
- Check `shared_preferences` implementation

### Troubleshooting
1. **App won't start**: Check Firebase configuration
2. **Login fails**: Verify user credentials and roles
3. **Files won't upload**: Check Storage permissions and rules
4. **UI issues**: Ensure Material Design dependencies

## 📊 Performance

### Optimization Features
- **Lazy Loading**: Efficient data fetching with pagination
- **Caching**: Local storage for theme preferences
- **Real-time Updates**: StreamBuilder for live data
- **Memory Management**: Proper disposal of resources

### Performance Metrics
- **Startup Time**: < 3 seconds on modern devices
- **Memory Usage**: < 150MB on Android
- **Battery Impact**: Minimal for normal usage

## 🔮 Future Roadmap

### Phase 2 Features
- [ ] Push notifications for important updates
- [ ] Offline data synchronization
- [ ] Advanced analytics dashboard
- [ ] QR code attendance system
- [ ] Parent portal integration
- [ ] Multi-language support
- [ ] Advanced search and filtering

### Technical Improvements
- [ ] State management migration to Riverpod
- [ ] API caching layer implementation
- [ ] Automated testing pipeline
- [ ] CI/CD integration
- [ ] Performance monitoring

## 🙏 Acknowledgments

- **Flutter Team** for the amazing framework
- **Firebase Team** for comprehensive backend services
- **Material Design Team** for design guidelines
- **Open Source Community** for valuable packages

## 📞 Contact

**Project Maintainer**: [MD. Rakib Hossen Howladar]
- **Email**: mdrakibhossenhowladar490@gmail.com
- **GitHub**: [RakibHossen490](https://github.com/RakibHossen490)
- **LinkedIn**: [MD Rakib Hossen Howladar](https://www.linkedin.com/in/md-rakib-hossen-howladar-453309379/)

---

**⭐ Star this repository if you find it helpful!**

Made with ❤️ using Flutter and Firebase
