import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/dashboard_card.dart';
import '../../widgets/activity_card.dart';
import 'combined_qr_scanner_screen.dart';
import '../../models/user.dart';

class StudentDashboard extends StatefulWidget {
  const StudentDashboard({super.key});

  @override
  State<StudentDashboard> createState() => _StudentDashboardState();
}

class _StudentDashboardState extends State<StudentDashboard> {
  int _selectedIndex = 0;

  final List<Widget> _screens = [
    const StudentHomeScreen(),
    const StudentScheduleScreen(),
    const StudentAttendanceScreen(),
    const StudentProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(
            icon: Icon(Icons.schedule),
            label: 'Schedule',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.check_circle),
            label: 'Attendance',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      ),
    );
  }
}

class StudentHomeScreen extends StatelessWidget {
  const StudentHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              // TODO: Navigate to notifications
            },
          ),
          IconButton(
            icon: const Icon(Icons.qr_code_scanner),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (context) => const CombinedQRScannerScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Welcome Section
            Consumer<AuthProvider>(
              builder: (context, authProvider, child) {
                return Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 30,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary,
                          child: Text(
                            authProvider.user?.name
                                    .substring(0, 1)
                                    .toUpperCase() ??
                                'S',
                            style: const TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Welcome back,',
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                              ),
                              Text(
                                authProvider.user?.name ?? 'Student',
                                style: Theme.of(context).textTheme.headlineSmall
                                    ?.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 4),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Theme.of(context).colorScheme.secondary
                                      .withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  'Computer Science • Semester 6',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Theme.of(
                                      context,
                                    ).colorScheme.secondary,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Stats
            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Today\'s Classes',
                    value: '4',
                    icon: Icons.class_,
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Navigate to today's classes
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Assignments Due',
                    value: '3',
                    icon: Icons.assignment_late,
                    color: Colors.orange,
                    onTap: () {
                      // TODO: Navigate to assignments
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: DashboardCard(
                    title: 'Overall Attendance',
                    value: '92%',
                    icon: Icons.trending_up,
                    color: Colors.green,
                    onTap: () {
                      // TODO: Navigate to attendance details
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: DashboardCard(
                    title: 'Current CGPA',
                    value: '8.5',
                    icon: Icons.grade,
                    color: Colors.purple,
                    onTap: () {
                      // TODO: Navigate to grades
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // Upcoming Classes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Upcoming Classes',
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                TextButton(
                  onPressed: () {
                    // TODO: Navigate to full schedule
                  },
                  child: const Text('See All'),
                ),
              ],
            ),

            const SizedBox(height: 16),

            // Class List
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: 3, // Sample data
              itemBuilder: (context, index) {
                return ActivityCard(
                  title: 'Data Structures & Algorithms',
                  subject: 'CSE301',
                  time: '${10 + index}:00 AM - ${11 + index}:00 AM',
                  location: 'Room ${201 + index}',
                  attendanceCount: 45,
                  totalStudents: 50,
                  onTap: () {
                    // TODO: Navigate to class details
                  },
                );
              },
            ),

            const SizedBox(height: 24),

            // Quick Actions
            Text(
              'Quick Actions',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _QuickActionCard(
                    title: 'Mark Attendance',
                    icon: Icons.qr_code_scanner,
                    color: Colors.green,
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (context) => const CombinedQRScannerScreen(),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _QuickActionCard(
                    title: 'View Assignments',
                    icon: Icons.assignment,
                    color: Colors.blue,
                    onTap: () {
                      // TODO: Navigate to assignments
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _QuickActionCard({
    required this.title,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: color, size: 32),
              ),
              const SizedBox(height: 12),
              Text(
                title,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder screens for other tabs
class StudentScheduleScreen extends StatelessWidget {
  const StudentScheduleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Schedule')),
      body: const Center(child: Text('Schedule Screen - Coming Soon')),
    );
  }
}

class StudentAttendanceScreen extends StatelessWidget {
  const StudentAttendanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My Attendance')),
      body: const Center(child: Text('Attendance Screen - Coming Soon')),
    );
  }
}

class StudentProfileScreen extends StatefulWidget {
  const StudentProfileScreen({super.key});

  @override
  State<StudentProfileScreen> createState() => _StudentProfileScreenState();
}

class _StudentProfileScreenState extends State<StudentProfileScreen> {
  bool _isEditing = false;
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _rollNumberController;
  late TextEditingController _classNameController;
  late TextEditingController _sectionController;
  late TextEditingController _departmentController;

  @override
  void initState() {
    super.initState();
    final user = context.read<AuthProvider>().user;
    final student = user is Student ? user : null;
    _nameController = TextEditingController(text: student?.name ?? '');
    _emailController = TextEditingController(text: student?.email ?? '');
    _rollNumberController = TextEditingController(
      text: student?.rollNumber ?? '',
    );
    _classNameController = TextEditingController(
      text: student?.className ?? '',
    );
    _sectionController = TextEditingController(text: student?.section ?? '');
    _departmentController = TextEditingController(
      text: student?.department ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _rollNumberController.dispose();
    _classNameController.dispose();
    _sectionController.dispose();
    _departmentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        final student = authProvider.user is Student
            ? authProvider.user as Student
            : null;
        if (student == null) {
          return const Scaffold(
            body: Center(child: Text('No student data available')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: const Text('Student Profile'),
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            actions: [
              if (_isEditing)
                TextButton(
                  onPressed: _saveProfile,
                  child: const Text(
                    'Save',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              if (!_isEditing)
                IconButton(
                  icon: const Icon(Icons.edit),
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                ),
              Container(
                margin: const EdgeInsets.only(right: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  gradient: LinearGradient(
                    colors: [Colors.red.shade400, Colors.red.shade600],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(8),
                    onTap: _showLogoutDialog,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.logout, color: Colors.white, size: 18),
                          const SizedBox(width: 6),
                          const Text(
                            'Logout',
                            style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  // Profile Picture Section
                  Center(
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 60,
                          backgroundColor: Theme.of(
                            context,
                          ).colorScheme.primary.withValues(alpha: 0.1),
                          child: Icon(
                            Icons.person,
                            size: 80,
                            color: Theme.of(context).colorScheme.primary,
                          ),
                        ),
                        if (_isEditing)
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Theme.of(context).colorScheme.primary,
                                shape: BoxShape.circle,
                              ),
                              child: IconButton(
                                icon: const Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                ),
                                onPressed: _changeProfilePicture,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Personal Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Personal Information',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          if (!_isEditing) ...[
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.blue.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: Colors.blue.withOpacity(0.3),
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.edit,
                                    size: 12,
                                    color: Colors.blue[700],
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    'Tap edit to modify fields',
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.blue[700],
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          const SizedBox(height: 16),
                          _buildProfileField(
                            'Full Name',
                            _nameController,
                            Icons.person,
                            validator: (value) {
                              if (value?.isEmpty ?? true) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 16),
                          _buildProfileField(
                            'Email',
                            _emailController,
                            Icons.email,
                            enabled: false,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Academic Information Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Information',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          _buildProfileField(
                            'Roll Number',
                            _rollNumberController,
                            Icons.badge,
                            enabled: false,
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProfileField(
                                  'Class',
                                  _classNameController,
                                  Icons.class_,
                                  enabled: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildProfileField(
                                  'Section',
                                  _sectionController,
                                  Icons.group,
                                  enabled: false,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildProfileField(
                                  'Semester',
                                  TextEditingController(
                                    text: student.semester.toString(),
                                  ),
                                  Icons.school,
                                  enabled: false,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildProfileField(
                                  'Department',
                                  _departmentController,
                                  Icons.business,
                                  enabled: false,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Academic Performance Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Academic Performance',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 16),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Overall Attendance',
                                  '85%',
                                  Icons.check_circle,
                                  Colors.green,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Current CGPA',
                                  '8.5',
                                  Icons.star,
                                  Colors.orange,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildStatCard(
                                  'Subjects',
                                  '6',
                                  Icons.book,
                                  Colors.blue,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildStatCard(
                                  'Assignments',
                                  '12',
                                  Icons.assignment,
                                  Colors.purple,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Quick Actions Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Quick Actions',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            leading: const Icon(
                              Icons.qr_code_scanner,
                              color: Colors.green,
                            ),
                            title: const Text('Mark Attendance'),
                            subtitle: const Text(
                              'Scan QR code to mark attendance',
                            ),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (context) =>
                                      const CombinedQRScannerScreen(),
                                ),
                              );
                            },
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.calendar_today,
                              color: Colors.blue,
                            ),
                            title: const Text('View Schedule'),
                            subtitle: const Text('Check your class schedule'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _viewSchedule,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.assignment,
                              color: Colors.orange,
                            ),
                            title: const Text('Assignments'),
                            subtitle: const Text('View pending assignments'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _viewAssignments,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.grade,
                              color: Colors.purple,
                            ),
                            title: const Text('Grades'),
                            subtitle: const Text('Check your grades'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _viewGrades,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Settings Card
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Settings',
                            style: Theme.of(context).textTheme.titleLarge
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 12),
                          ListTile(
                            leading: const Icon(Icons.notifications),
                            title: const Text('Notifications'),
                            trailing: Switch(
                              value: true,
                              onChanged: (value) {
                                // TODO: Update notification preferences
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.dark_mode),
                            title: const Text('Dark Mode'),
                            trailing: Switch(
                              value: false,
                              onChanged: (value) {
                                // TODO: Update theme preferences
                              },
                            ),
                          ),
                          ListTile(
                            leading: const Icon(Icons.language),
                            title: const Text('Language'),
                            subtitle: const Text('English'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _changeLanguage,
                          ),
                          ListTile(
                            leading: const Icon(Icons.security),
                            title: const Text('Privacy & Security'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _openPrivacySettings,
                          ),
                          ListTile(
                            leading: const Icon(
                              Icons.logout,
                              color: Colors.red,
                            ),
                            title: const Text(
                              'Logout',
                              style: TextStyle(color: Colors.red),
                            ),
                            subtitle: const Text('Sign out of your account'),
                            trailing: const Icon(Icons.arrow_forward_ios),
                            onTap: _showLogoutDialog,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Logout Button
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _showLogoutDialog,
                      icon: const Icon(Icons.logout),
                      label: const Text('Logout'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.all(16),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          floatingActionButton: !_isEditing
              ? FloatingActionButton.extended(
                  onPressed: () {
                    setState(() {
                      _isEditing = true;
                    });
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('Edit Profile'),
                  backgroundColor: Theme.of(context).colorScheme.primary,
                  foregroundColor: Colors.white,
                )
              : null,
        );
      },
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller,
    IconData icon, {
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    final isFieldEnabled = _isEditing && enabled;

    return TextFormField(
      controller: controller,
      enabled: isFieldEnabled,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: isFieldEnabled ? null : Colors.grey[400]),
        suffixIcon: !isFieldEnabled
            ? Tooltip(
                message: 'Tap the edit button to modify this field',
                child: Icon(
                  Icons.lock_outline,
                  size: 18,
                  color: Colors.grey[400],
                ),
              )
            : null,
        border: const OutlineInputBorder(),
        filled: !isFieldEnabled,
        fillColor: !isFieldEnabled ? Colors.grey[50] : null,
        labelStyle: TextStyle(color: isFieldEnabled ? null : Colors.grey[500]),
      ),
      style: TextStyle(color: isFieldEnabled ? null : Colors.grey[600]),
    );
  }

  Widget _buildStatCard(
    String title,
    String value,
    IconData icon,
    Color color,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.3)),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            title,
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  void _saveProfile() async {
    if (_formKey.currentState!.validate()) {
      try {
        final authProvider = context.read<AuthProvider>();
        final currentUser = authProvider.user;

        if (currentUser is Student) {
          // Create updated student with new name
          final updatedStudent = Student(
            id: currentUser.id,
            name: _nameController.text.trim(),
            email: currentUser.email,
            profileImage: currentUser.profileImage,
            createdAt: currentUser.createdAt,
            updatedAt: DateTime.now(),
            rollNumber: currentUser.rollNumber,
            className: currentUser.className,
            section: currentUser.section,
            semester: currentUser.semester,
            department: currentUser.department,
          );

          // Update the user in AuthProvider
          final success = await authProvider.updateUser(updatedStudent);

          if (success) {
            setState(() {
              _isEditing = false;
            });

            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.white),
                    SizedBox(width: 8),
                    Text('Profile updated successfully!'),
                  ],
                ),
                backgroundColor: Colors.green,
              ),
            );
          } else {
            throw Exception('Failed to update profile');
          }
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.error, color: Colors.white),
                const SizedBox(width: 8),
                Text('Failed to update profile: $e'),
              ],
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _changeProfilePicture() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Change Profile Picture',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement camera functionality
                      },
                      icon: const Icon(Icons.camera_alt, size: 32),
                    ),
                    const Text('Camera'),
                  ],
                ),
                Column(
                  children: [
                    IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Implement gallery functionality
                      },
                      icon: const Icon(Icons.photo_library, size: 32),
                    ),
                    const Text('Gallery'),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _viewSchedule() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Class Schedule')),
          body: const Center(child: Text('Schedule view coming soon!')),
        ),
      ),
    );
  }

  void _viewAssignments() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Assignments')),
          body: const Center(child: Text('Assignments view coming soon!')),
        ),
      ),
    );
  }

  void _viewGrades() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Grades')),
          body: const Center(child: Text('Grades view coming soon!')),
        ),
      ),
    );
  }

  void _changeLanguage() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Select Language'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              title: const Text('English'),
              leading: Radio(
                value: 'en',
                groupValue: 'en',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Hindi'),
              leading: Radio(
                value: 'hi',
                groupValue: 'en',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
            ListTile(
              title: const Text('Spanish'),
              leading: Radio(
                value: 'es',
                groupValue: 'en',
                onChanged: (value) {},
              ),
              onTap: () => Navigator.pop(context),
            ),
          ],
        ),
      ),
    );
  }

  void _openPrivacySettings() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: const Text('Privacy & Security')),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                ListTile(
                  leading: const Icon(Icons.lock),
                  title: const Text('Change Password'),
                  subtitle: const Text('Update your account password'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement change password
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.fingerprint),
                  title: const Text('Biometric Authentication'),
                  subtitle: const Text('Enable fingerprint/face unlock'),
                  trailing: Switch(value: false, onChanged: (value) {}),
                ),
                ListTile(
                  leading: const Icon(Icons.visibility),
                  title: const Text('Profile Visibility'),
                  subtitle: const Text('Control who can see your profile'),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    // TODO: Implement profile visibility settings
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(Icons.logout, color: Colors.red.shade600, size: 24),
            ),
            const SizedBox(width: 12),
            const Text(
              'Logout',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Are you sure you want to logout?',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'You will need to login again to access your account.',
              style: TextStyle(fontSize: 14, color: Colors.grey[600]),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: Colors.grey[600],
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              context.read<AuthProvider>().logout();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              elevation: 2,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.logout, size: 18),
                const SizedBox(width: 6),
                const Text(
                  'Logout',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
