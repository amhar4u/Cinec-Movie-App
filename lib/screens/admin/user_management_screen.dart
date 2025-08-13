import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../constants/app_constants.dart';
import '../../models/user_model.dart';
import '../../services/user_management_service.dart';
import '../../services/admin_verification_service.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/profile_avatar.dart';
import '../profile/edit_profile_screen.dart';

class UserManagementScreen extends StatefulWidget {
  const UserManagementScreen({super.key});

  @override
  State<UserManagementScreen> createState() => _UserManagementScreenState();
}

class _UserManagementScreenState extends State<UserManagementScreen> {
  List<UserModel> _users = [];
  List<UserModel> _filteredUsers = [];
  bool _isLoading = true;
  String _searchQuery = '';
  UserRole? _roleFilter;
  bool? _statusFilter;
  Map<String, int> _userStats = {};

  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _verifyAdminAndLoadData();
  }

  Future<void> _verifyAdminAndLoadData() async {
    try {
      // Verify admin access first
      await AdminVerificationService.verifyAdminAccess();
      
      // If verification passes, load data
      _loadUsers();
      _loadUserStats();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Access denied: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
        // Navigate back if not admin
        Navigator.pop(context);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final users = await UserManagementService.getAllUsers(
        limit: 100,
        roleFilter: _roleFilter,
        activeFilter: _statusFilter,
      );
      setState(() {
        _users = users;
        _applyFilters();
      });
    } catch (e) {
      if (mounted) {
        String errorMessage = 'Error loading users: $e';
        if (e.toString().contains('permission-denied')) {
          errorMessage = 'Permission denied. Please ensure you have admin privileges and Firestore rules are properly configured.';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(errorMessage),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
            action: SnackBarAction(
              label: 'Retry',
              textColor: Colors.white,
              onPressed: _loadUsers,
            ),
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadUserStats() async {
    try {
      final stats = await UserManagementService.getUserStats();
      setState(() => _userStats = stats);
    } catch (e) {
      // If stats fail to load due to permissions, set default values
      if (e.toString().contains('permission-denied')) {
        setState(() => _userStats = {
          'total': 0,
          'active': 0,
          'inactive': 0,
          'admins': 0,
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Unable to load user statistics. Please check your admin permissions.'),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        print('Error loading user stats: $e');
      }
    }
  }

  void _applyFilters() {
    _filteredUsers = _users.where((user) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        final query = _searchQuery.toLowerCase();
        if (!user.name.toLowerCase().contains(query) &&
            !user.email.toLowerCase().contains(query)) {
          return false;
        }
      }
      return true;
    }).toList();
  }

  void _onSearchChanged(String value) {
    setState(() {
      _searchQuery = value;
      _applyFilters();
    });
  }

  void _onRoleFilterChanged(UserRole? role) {
    setState(() => _roleFilter = role);
    _loadUsers();
  }

  void _onStatusFilterChanged(bool? status) {
    setState(() => _statusFilter = status);
    _loadUsers();
  }

  Future<void> _toggleUserStatus(UserModel user) async {
    try {
      await UserManagementService.updateUserStatus(user.uid, !user.isActive);
      _loadUsers();
      _loadUserStats();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              user.isActive 
                ? '${user.name} has been deactivated'
                : '${user.name} has been activated'
            ),
            backgroundColor: user.isActive ? Colors.orange : Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user status: $e')),
        );
      }
    }
  }

  Future<void> _deleteUser(UserModel user) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete User'),
        content: Text('Are you sure you want to delete ${user.name}? This action cannot be undone.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        await UserManagementService.hardDeleteUser(user.uid);
        _loadUsers();
        _loadUserStats();
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.name} has been deleted'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error deleting user: $e')),
          );
        }
      }
    }
  }

  void _showUserDetails(UserModel user) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => UserDetailsBottomSheet(
        user: user,
        onUserUpdated: () {
          _loadUsers();
          _loadUserStats();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final padding = ResponsiveUtils.getPadding(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: 'User Management',
        showThemeToggle: true,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: SizedBox(
            width: contentWidth,
            child: Column(
              children: [
                // Stats Cards
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  child: Container(
                    padding: padding,
                    child: _buildStatsCards(context, theme),
                  ),
                ),
                
                // Filters and Search
                FadeInDown(
                  duration: const Duration(milliseconds: 600),
                  delay: const Duration(milliseconds: 200),
                  child: Container(
                    padding: padding,
                    child: _buildFiltersSection(context, theme),
                  ),
                ),
                
                // Users List
                Expanded(
                  child: FadeInUp(
                    duration: const Duration(milliseconds: 600),
                    delay: const Duration(milliseconds: 400),
                    child: _isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : _filteredUsers.isEmpty
                            ? _buildEmptyState(context, theme)
                            : _buildUsersList(context, theme),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStatsCards(BuildContext context, ThemeData theme) {
    final stats = [
      {
        'title': 'Total Users',
        'value': '${_userStats['total'] ?? 0}',
        'icon': FontAwesomeIcons.users,
        'color': Colors.blue,
      },
      {
        'title': 'Active Users',
        'value': '${_userStats['active'] ?? 0}',
        'icon': FontAwesomeIcons.userCheck,
        'color': Colors.green,
      },
      {
        'title': 'Inactive Users',
        'value': '${_userStats['inactive'] ?? 0}',
        'icon': FontAwesomeIcons.userSlash,
        'color': Colors.orange,
      },
      {
        'title': 'Admins',
        'value': '${_userStats['admins'] ?? 0}',
        'icon': FontAwesomeIcons.userShield,
        'color': Colors.purple,
      },
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: ResponsiveUtils.isDesktop(context) ? 4 : 2,
        crossAxisSpacing: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
        mainAxisSpacing: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
        childAspectRatio: 1.5,
      ),
      itemCount: stats.length,
      itemBuilder: (context, index) {
        final stat = stats[index];
        return Container(
          padding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
            boxShadow: [
              BoxShadow(
                color: theme.shadowColor.withOpacity(0.1),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                stat['icon'] as IconData,
                color: stat['color'] as Color,
                size: ResponsiveUtils.getFontSize(context, mobile: 24, tablet: 28, desktop: 32),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
              Text(
                stat['value'] as String,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: stat['color'] as Color,
                  fontSize: ResponsiveUtils.getFontSize(context, mobile: 18, tablet: 20, desktop: 24),
                ),
              ),
              SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 4, tablet: 6, desktop: 8)),
              Text(
                stat['title'] as String,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontSize: ResponsiveUtils.getFontSize(context, mobile: 10, tablet: 12, desktop: 14),
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildFiltersSection(BuildContext context, ThemeData theme) {
    return Column(
      children: [
        // Search Bar
        Container(
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
            border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search users by name or email...',
              prefixIcon: const Icon(Icons.search),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      onPressed: () {
                        _searchController.clear();
                        _onSearchChanged('');
                      },
                      icon: const Icon(Icons.clear),
                    )
                  : null,
              border: InputBorder.none,
              contentPadding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
            ),
          ),
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        
        // Filter Chips
        Row(
          children: [
            Expanded(
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Role Filter
                  FilterChip(
                    label: Text(_roleFilter == null ? 'All Roles' : _roleFilter.toString().split('.').last.toUpperCase()),
                    selected: _roleFilter != null,
                    onSelected: (selected) {
                      if (selected) {
                        _showRoleFilterDialog();
                      } else {
                        _onRoleFilterChanged(null);
                      }
                    },
                  ),
                  
                  // Status Filter
                  FilterChip(
                    label: Text(_statusFilter == null ? 'All Status' : (_statusFilter! ? 'Active' : 'Inactive')),
                    selected: _statusFilter != null,
                    onSelected: (selected) {
                      if (selected) {
                        _showStatusFilterDialog();
                      } else {
                        _onStatusFilterChanged(null);
                      }
                    },
                  ),
                ],
              ),
            ),
            
            // Refresh Button
            IconButton(
              onPressed: () {
                _loadUsers();
                _loadUserStats();
              },
              icon: const Icon(Icons.refresh),
              tooltip: 'Refresh',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildUsersList(BuildContext context, ThemeData theme) {
    return RefreshIndicator(
      onRefresh: () async {
        await _loadUsers();
        await _loadUserStats();
      },
      child: ListView.builder(
        padding: ResponsiveUtils.getPadding(context),
        itemCount: _filteredUsers.length,
        itemBuilder: (context, index) {
          final user = _filteredUsers[index];
          return SlideInLeft(
            duration: Duration(milliseconds: 600 + (index * 100)),
            child: Container(
              margin: EdgeInsets.only(
                bottom: ResponsiveUtils.getSpacing(context, mobile: 12, tablet: 16, desktop: 20),
              ),
              decoration: BoxDecoration(
                color: theme.colorScheme.surface,
                borderRadius: BorderRadius.circular(AppConstants.radiusMedium),
                border: Border.all(color: theme.colorScheme.outline.withOpacity(0.2)),
                boxShadow: [
                  BoxShadow(
                    color: theme.shadowColor.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ListTile(
                contentPadding: EdgeInsets.all(ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
                leading: ProfileAvatar(
                  userModel: user,
                  radius: ResponsiveUtils.getFontSize(context, mobile: 24, tablet: 28, desktop: 32),
                ),
                title: Row(
                  children: [
                    Expanded(
                      child: Text(
                        user.name,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                          fontSize: ResponsiveUtils.getFontSize(context, mobile: 16, tablet: 18, desktop: 20),
                        ),
                      ),
                    ),
                    if (user.role == UserRole.admin)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: Colors.purple.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(color: Colors.purple.withOpacity(0.3)),
                        ),
                        child: Text(
                          'ADMIN',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.purple,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: user.isActive 
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: user.isActive 
                              ? Colors.green.withOpacity(0.3)
                              : Colors.red.withOpacity(0.3),
                        ),
                      ),
                      child: Text(
                        user.isActive ? 'ACTIVE' : 'INACTIVE',
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: user.isActive ? Colors.green : Colors.red,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 10, desktop: 12)),
                    Text(
                      user.email,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.7),
                        fontSize: ResponsiveUtils.getFontSize(context, mobile: 14, tablet: 16, desktop: 18),
                      ),
                    ),
                    SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 4, tablet: 6, desktop: 8)),
                    Text(
                      'Joined: ${_formatDate(user.createdAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurface.withOpacity(0.5),
                        fontSize: ResponsiveUtils.getFontSize(context, mobile: 12, tablet: 14, desktop: 16),
                      ),
                    ),
                    if (user.lastLoginAt != null) ...[
                      SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 2, tablet: 3, desktop: 4)),
                      Text(
                        'Last login: ${_formatDate(user.lastLoginAt!)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurface.withOpacity(0.5),
                          fontSize: ResponsiveUtils.getFontSize(context, mobile: 12, tablet: 14, desktop: 16),
                        ),
                      ),
                    ],
                  ],
                ),
                trailing: PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'view':
                        _showUserDetails(user);
                        break;
                      case 'edit':
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => EditProfileScreen(
                              userModel: user,
                              isAdminEdit: true,
                            ),
                          ),
                        ).then((_) {
                          // Refresh the user list when returning from edit
                          _loadUsers();
                        });
                        break;
                      case 'toggle_status':
                        _toggleUserStatus(user);
                        break;
                      case 'delete':
                        _deleteUser(user);
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    const PopupMenuItem(
                      value: 'view',
                      child: Row(
                        children: [
                          Icon(Icons.visibility),
                          SizedBox(width: 8),
                          Text('View Details'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'edit',
                      child: Row(
                        children: [
                          Icon(Icons.edit),
                          SizedBox(width: 8),
                          Text('Edit Profile'),
                        ],
                      ),
                    ),
                    PopupMenuItem(
                      value: 'toggle_status',
                      child: Row(
                        children: [
                          Icon(user.isActive ? Icons.block : Icons.check_circle),
                          const SizedBox(width: 8),
                          Text(user.isActive ? 'Deactivate' : 'Activate'),
                        ],
                      ),
                    ),
                    const PopupMenuItem(
                      value: 'delete',
                      child: Row(
                        children: [
                          Icon(Icons.delete, color: Colors.red),
                          SizedBox(width: 8),
                          Text('Delete', style: TextStyle(color: Colors.red)),
                        ],
                      ),
                    ),
                  ],
                ),
                onTap: () => _showUserDetails(user),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context, ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.people_outline,
            size: 80,
            color: theme.colorScheme.onSurface.withOpacity(0.3),
          ),
          const SizedBox(height: 16),
          Text(
            'No users found',
            style: theme.textTheme.headlineSmall?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Try adjusting your search or filters',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.5),
            ),
          ),
        ],
      ),
    );
  }

  void _showRoleFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: UserRole.values.map((role) {
            return RadioListTile<UserRole>(
              title: Text(role.toString().split('.').last.toUpperCase()),
              value: role,
              groupValue: _roleFilter,
              onChanged: (value) {
                Navigator.pop(context);
                _onRoleFilterChanged(value);
              },
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _onRoleFilterChanged(null);
            },
            child: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }

  void _showStatusFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Filter by Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            RadioListTile<bool>(
              title: const Text('Active'),
              value: true,
              groupValue: _statusFilter,
              onChanged: (value) {
                Navigator.pop(context);
                _onStatusFilterChanged(value);
              },
            ),
            RadioListTile<bool>(
              title: const Text('Inactive'),
              value: false,
              groupValue: _statusFilter,
              onChanged: (value) {
                Navigator.pop(context);
                _onStatusFilterChanged(value);
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _onStatusFilterChanged(null);
            },
            child: const Text('Clear Filter'),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 365) {
      return '${(difference.inDays / 365).floor()} year${(difference.inDays / 365).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 30) {
      return '${(difference.inDays / 30).floor()} month${(difference.inDays / 30).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }
}

class UserDetailsBottomSheet extends StatefulWidget {
  final UserModel user;
  final VoidCallback onUserUpdated;

  const UserDetailsBottomSheet({
    super.key,
    required this.user,
    required this.onUserUpdated,
  });

  @override
  State<UserDetailsBottomSheet> createState() => _UserDetailsBottomSheetState();
}

class _UserDetailsBottomSheetState extends State<UserDetailsBottomSheet> {
  late TextEditingController _nameController;
  late UserRole _selectedRole;
  late bool _isActive;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.user.name);
    _selectedRole = widget.user.role;
    _isActive = widget.user.isActive;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _updateUser() async {
    setState(() => _isLoading = true);
    
    try {
      // Update name if changed
      if (_nameController.text != widget.user.name) {
        await UserManagementService.updateUserProfile(
          uid: widget.user.uid,
          name: _nameController.text,
        );
      }
      
      // Update role if changed
      if (_selectedRole != widget.user.role) {
        await UserManagementService.updateUserRole(widget.user.uid, _selectedRole);
      }
      
      // Update status if changed
      if (_isActive != widget.user.isActive) {
        await UserManagementService.updateUserStatus(widget.user.uid, _isActive);
      }
      
      widget.onUserUpdated();
      
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${widget.user.name} updated successfully'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating user: $e')),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: DraggableScrollableSheet(
        initialChildSize: 0.8,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) {
          return SingleChildScrollView(
            controller: scrollController,
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    ProfileAvatar(userModel: widget.user, radius: 30),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.user.name,
                            style: theme.textTheme.headlineSmall?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            widget.user.email,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onSurface.withOpacity(0.7),
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                    ),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // User Details
                Text(
                  'User Details',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Name Field
                TextField(
                  controller: _nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    border: OutlineInputBorder(),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Role Selection
                Text(
                  'Role',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<UserRole>(
                  value: _selectedRole,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                  items: UserRole.values.map((role) {
                    return DropdownMenuItem(
                      value: role,
                      child: Text(role.toString().split('.').last.toUpperCase()),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() => _selectedRole = value!);
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Status Toggle
                Row(
                  children: [
                    Text(
                      'Status',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Spacer(),
                    Switch(
                      value: _isActive,
                      onChanged: (value) {
                        setState(() => _isActive = value);
                      },
                    ),
                    Text(_isActive ? 'Active' : 'Inactive'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // User Info
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Account Information',
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildInfoRow('User ID', widget.user.uid),
                      _buildInfoRow('Email', widget.user.email),
                      _buildInfoRow('Joined', _formatDate(widget.user.createdAt)),
                      if (widget.user.lastLoginAt != null)
                        _buildInfoRow('Last Login', _formatDate(widget.user.lastLoginAt!)),
                    ],
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // Action Buttons
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancel'),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _isLoading ? null : _updateUser,
                        child: _isLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(strokeWidth: 2),
                              )
                            : const Text('Update User'),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 20),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} at ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
  }
}
