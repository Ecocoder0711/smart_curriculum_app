# Smart Curriculum Activity & Attendance App

A comprehensive Flutter application for managing curriculum activities and student attendance in educational institutions.

## Features

### 🎓 For Teachers
- **Dashboard Overview**: View daily classes, pending activities, student statistics, and attendance analytics
- **Activity Management**: Create, schedule, and manage various types of activities (lectures, practicals, assignments, quizzes, exams)
- **Attendance Tracking**: Mark attendance using QR codes or manual entry
- **Student Analytics**: Monitor individual and class-wide attendance patterns
- **Real-time Updates**: Get instant notifications and updates

### 📚 For Students
- **Personal Dashboard**: View upcoming classes, assignments, and overall attendance
- **QR Code Attendance**: Mark attendance by scanning QR codes
- **Schedule Management**: Access daily and weekly class schedules
- **Attendance Monitoring**: Track personal attendance statistics and identify shortages
- **Assignment Tracking**: View pending assignments and submission deadlines

### 🔐 Authentication & Security
- Role-based access control (Teacher, Student, Admin)
- Secure login with email/password
- Password recovery functionality
- Session management

## Technology Stack

- **Framework**: Flutter 3.8+
- **State Management**: Provider
- **Local Storage**: SQLite, SharedPreferences
- **HTTP Client**: HTTP package
- **UI Components**: Material Design 3
- **Fonts**: Google Fonts (Inter)
- **Charts**: FL Chart
- **QR Code**: QR Code Scanner & Generator
- **Date/Time**: Intl package

## Architecture

```
lib/
├── models/           # Data models (User, Activity, Attendance, etc.)
├── screens/          # UI screens organized by feature
│   ├── auth/         # Authentication screens
│   ├── teacher/      # Teacher-specific screens
│   └── student/      # Student-specific screens
├── services/         # Business logic and API services
├── providers/        # State management with Provider
├── widgets/          # Reusable UI components
└── utils/            # Helper functions and constants
```

## Key Models

### User Management
- **User**: Base user model with role-based inheritance
- **Teacher**: Extended user with department, subjects, and employee ID
- **Student**: Extended user with roll number, class, section, and semester

### Curriculum Management
- **Subject**: Course information with credits, topics, and department
- **Curriculum**: Collection of subjects organized by semester
- **Activity**: Scheduled academic activities with type, status, and participants

### Attendance System
- **Attendance**: Individual attendance records with status and location
- **AttendanceStats**: Aggregated statistics for analytics
- **ClassSession**: Live class sessions with QR codes and real-time tracking

## Features in Detail

### Activity Types
- **Lectures**: Traditional classroom teaching sessions
- **Practicals**: Hands-on lab sessions and workshops
- **Assignments**: Take-home projects and coursework
- **Quizzes**: Short assessments and tests
- **Exams**: Formal examinations
- **Presentations**: Student presentations and seminars

### Attendance Status
- **Present**: Student attended the session
- **Absent**: Student was not present
- **Late**: Student arrived after the scheduled time
- **Excused**: Approved absence with valid reason

### Dashboard Analytics
- **Teachers**: Class statistics, attendance trends, student performance
- **Students**: Personal attendance percentage, upcoming deadlines, schedule

## Getting Started

### Prerequisites
- Flutter SDK 3.8 or higher
- Dart SDK 3.0 or higher
- iOS Simulator or Android Emulator
- VS Code or Android Studio

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd smart_curriculum_app
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

### Demo Login Credentials

For testing purposes, you can use any email/password combination. The app includes demo data with the following sample users:

**Teachers:**
- Dr. John Smith (john.smith@university.edu)
- Prof. Sarah Wilson (sarah.wilson@university.edu)

**Students:**
- Alice Johnson (alice.johnson@student.university.edu)
- Bob Davis (bob.davis@student.university.edu)

## Upcoming Features

### Phase 2
- [ ] Real-time notifications
- [ ] Offline data synchronization
- [ ] Advanced analytics and reporting
- [ ] Parent portal integration
- [ ] Multi-language support

### Phase 3
- [ ] Video conferencing integration
- [ ] Assignment submission portal
- [ ] Grade management system
- [ ] Timetable generation
- [ ] Academic calendar integration

### Phase 4
- [ ] AI-powered insights
- [ ] Predictive analytics for attendance
- [ ] Smart scheduling recommendations
- [ ] Integration with Learning Management Systems

## API Integration

The app is designed to work with a RESTful API backend. Current implementation includes:

- Authentication endpoints (login, register, forgot password)
- User management
- Activity CRUD operations
- Attendance tracking
- Analytics and reporting

## Security Features

- JWT token-based authentication
- Role-based access control
- Secure local storage
- Data encryption for sensitive information
- Session timeout management

## Performance Optimizations

- Lazy loading of large datasets
- Efficient state management with Provider
- Optimized image loading and caching
- Background data synchronization
- Responsive UI for various screen sizes

## Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test/
```

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add some amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under the MIT License - see the LICENSE file for details.

## Support

For support and questions, please contact:
- Email: support@smartcurriculum.com
- Documentation: [Wiki](link-to-wiki)
- Issues: [GitHub Issues](link-to-issues)

---

Built with ❤️ using Flutter for the Smart India Hackathon 2024
