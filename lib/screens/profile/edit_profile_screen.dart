import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';

import '../../models/user_model.dart';
import '../../services/profile_service.dart';
import '../../providers/auth_provider.dart';
import '../../utils/responsive_utils.dart';
import '../../widgets/custom_app_bar.dart';
import '../../widgets/profile_avatar.dart';
import '../../widgets/custom_text_field.dart';

class EditProfileScreen extends StatefulWidget {
  final UserModel userModel;
  final bool isAdminEdit;

  const EditProfileScreen({
    super.key,
    required this.userModel,
    this.isAdminEdit = false,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _currentPasswordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  File? _selectedImage;
  Uint8List? _selectedImageBytes;
  String? _selectedImageName;
  UserRole _selectedRole = UserRole.user;
  bool _isActive = true;
  bool _isLoading = false;
  bool _showPasswordSection = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _initializeForm();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _currentPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _initializeForm() {
    _nameController.text = widget.userModel.name;
    _selectedRole = widget.userModel.role;
    _isActive = widget.userModel.isActive;
  }

  Future<void> _pickImage() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (kIsWeb) {
            _selectedImageBytes = bytes;
            _selectedImageName = image.name;
            _selectedImage = null;
          } else {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
            _selectedImageName = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
      }
    }
  }

  Future<void> _takePhoto() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        final bytes = await image.readAsBytes();
        setState(() {
          if (kIsWeb) {
            _selectedImageBytes = bytes;
            _selectedImageName = image.name;
            _selectedImage = null;
          } else {
            _selectedImage = File(image.path);
            _selectedImageBytes = null;
            _selectedImageName = null;
          }
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error taking photo: $e')),
        );
      }
    }
  }

  void _showImagePicker() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Select Profile Picture',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildImageOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    _pickImage();
                  },
                ),
                _buildImageOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    _takePhoto();
                  },
                ),
                if (_selectedImage != null || _selectedImageBytes != null || widget.userModel.profilePictureUrl != null)
                  _buildImageOption(
                    icon: Icons.delete,
                    label: 'Remove',
                    onTap: () {
                      Navigator.pop(context);
                      setState(() {
                        _selectedImage = null;
                        _selectedImageBytes = null;
                        _selectedImageName = null;
                      });
                    },
                  ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildImageOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.primary,
              size: 30,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      // Prepare image data for upload
      dynamic imageData;
      if (_selectedImage != null) {
        imageData = _selectedImage;
      } else if (_selectedImageBytes != null) {
        imageData = {
          'bytes': _selectedImageBytes,
          'name': _selectedImageName ?? 'profile_image.jpg',
        };
      }

      // Update profile information
      final success = await ProfileService.updateProfile(
        uid: widget.userModel.uid,
        name: _nameController.text.trim(),
        profileImage: imageData,
        role: widget.isAdminEdit ? _selectedRole : null,
        isActive: widget.isAdminEdit ? _isActive : null,
      );

      if (!success) {
        throw Exception('Failed to update profile');
      }

      // Handle password change if requested
      if (_showPasswordSection && _newPasswordController.text.isNotEmpty) {
        final authProvider = Provider.of<AuthProvider>(context, listen: false);
        final passwordResult = await authProvider.changePassword(
          currentPassword: _currentPasswordController.text,
          newPassword: _newPasswordController.text,
        );

        if (!passwordResult['success']) {
          throw Exception(passwordResult['message']);
        }
      }

      if (mounted) {
        // Refresh auth provider
        // Refresh user data
        await Provider.of<AuthProvider>(context, listen: false).refreshUser();

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile updated successfully'),
            backgroundColor: Colors.green,
          ),
        );

        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString().replaceAll('Exception: ', '')}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contentWidth = ResponsiveUtils.getContentWidth(context);
    final padding = ResponsiveUtils.getPadding(context);

    return Scaffold(
      appBar: CustomAppBar(
        title: widget.isAdminEdit ? 'Edit User Profile' : 'Edit Profile',
        showThemeToggle: true,
      ),
      body: SafeArea(
        child: Container(
          width: double.infinity,
          alignment: Alignment.center,
          child: SizedBox(
            width: contentWidth,
            child: SingleChildScrollView(
              padding: padding,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInDown(
                      duration: const Duration(milliseconds: 600),
                      child: _buildProfileImageSection(theme),
                    ),
                    
                    SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                    
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 200),
                      child: _buildBasicInfoSection(theme),
                    ),

                    if (widget.isAdminEdit) ...[
                      SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: _buildAdminControls(theme),
                      ),
                    ],

                    if (!widget.isAdminEdit) ...[
                      SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 24, tablet: 32, desktop: 40)),
                      FadeInUp(
                        duration: const Duration(milliseconds: 600),
                        delay: const Duration(milliseconds: 400),
                        child: _buildPasswordSection(theme),
                      ),
                    ],

                    SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 32, tablet: 40, desktop: 48)),
                    
                    FadeInUp(
                      duration: const Duration(milliseconds: 600),
                      delay: const Duration(milliseconds: 600),
                      child: _buildActionButtons(theme),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImageSection(ThemeData theme) {
    return Center(
      child: Column(
        children: [
          Text(
            'Profile Picture',
            style: theme.textTheme.titleLarge?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 20, tablet: 22, desktop: 24),
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          GestureDetector(
            onTap: _showImagePicker,
            child: Stack(
              children: [
                Container(
                  width: ResponsiveUtils.getFontSize(context, mobile: 120, tablet: 140, desktop: 160),
                  height: ResponsiveUtils.getFontSize(context, mobile: 120, tablet: 140, desktop: 160),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: theme.colorScheme.outline.withOpacity(0.3),
                      width: 2,
                    ),
                  ),
                  child: ClipOval(
                    child: _buildImageWidget(),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: theme.colorScheme.surface,
                        width: 2,
                      ),
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      color: theme.colorScheme.onPrimary,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 8, tablet: 12, desktop: 16)),
          Text(
            'Tap to change photo',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurface.withOpacity(0.6),
              fontSize: ResponsiveUtils.getFontSize(context, mobile: 14, tablet: 16, desktop: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBasicInfoSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getFontSize(context, mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        
        CustomTextField(
          controller: _nameController,
          label: 'Full Name',
          prefixIcon: Icon(Icons.person),
          validator: (value) {
            if (value == null || value.trim().isEmpty) {
              return 'Please enter your name';
            }
            if (value.trim().length < 2) {
              return 'Name must be at least 2 characters';
            }
            return null;
          },
        ),
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        
        // Email (read-only)
        CustomTextField(
          label: 'Email',
          prefixIcon: Icon(Icons.email),
          enabled: false,
          initialValue: widget.userModel.email,
        ),
      ],
    );
  }

  Widget _buildAdminControls(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Admin Controls',
          style: theme.textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: ResponsiveUtils.getFontSize(context, mobile: 18, tablet: 20, desktop: 22),
          ),
        ),
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        
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
            prefixIcon: Icon(Icons.admin_panel_settings),
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
        
        SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        
        // Active Status
        Row(
          children: [
            Text(
              'Account Status',
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
      ],
    );
  }

  Widget _buildPasswordSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: ResponsiveUtils.getFontSize(context, mobile: 18, tablet: 20, desktop: 22),
              ),
            ),
            const Spacer(),
            Switch(
              value: _showPasswordSection,
              onChanged: (value) {
                setState(() {
                  _showPasswordSection = value;
                  if (!value) {
                    _currentPasswordController.clear();
                    _newPasswordController.clear();
                    _confirmPasswordController.clear();
                  }
                });
              },
            ),
            Text(_showPasswordSection ? 'Change' : 'Keep'),
          ],
        ),
        
        if (_showPasswordSection) ...[
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          CustomTextField(
            controller: _currentPasswordController,
            label: 'Current Password',
            prefixIcon: Icon(Icons.lock_outline),
            obscureText: _obscureCurrentPassword,
            suffixIcon: IconButton(
              icon: Icon(_obscureCurrentPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() => _obscureCurrentPassword = !_obscureCurrentPassword);
              },
            ),
            validator: (value) {
              if (_showPasswordSection && (value == null || value.isEmpty)) {
                return 'Please enter your current password';
              }
              return null;
            },
          ),
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          CustomTextField(
            controller: _newPasswordController,
            label: 'New Password',
            prefixIcon: Icon(Icons.lock),
            obscureText: _obscureNewPassword,
            suffixIcon: IconButton(
              icon: Icon(_obscureNewPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() => _obscureNewPassword = !_obscureNewPassword);
              },
            ),
            validator: (value) {
              if (_showPasswordSection && (value == null || value.isEmpty)) {
                return 'Please enter a new password';
              }
              if (_showPasswordSection && value != null) {
                final validation = ProfileService.validatePassword(value);
                if (!validation['isValid']) {
                  return 'Password must be at least 8 characters with uppercase, lowercase, numbers, and special characters';
                }
              }
              return null;
            },
            onChanged: (value) {
              if (value.isNotEmpty) {
                setState(() {}); // Trigger rebuild for password strength indicator
              }
            },
          ),
          
          if (_newPasswordController.text.isNotEmpty) ...[
            const SizedBox(height: 8),
            _buildPasswordStrengthIndicator(),
          ],
          
          SizedBox(height: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
          
          CustomTextField(
            controller: _confirmPasswordController,
            label: 'Confirm New Password',
            prefixIcon: Icon(Icons.lock_reset),
            obscureText: _obscureConfirmPassword,
            suffixIcon: IconButton(
              icon: Icon(_obscureConfirmPassword ? Icons.visibility : Icons.visibility_off),
              onPressed: () {
                setState(() => _obscureConfirmPassword = !_obscureConfirmPassword);
              },
            ),
            validator: (value) {
              if (_showPasswordSection && (value == null || value.isEmpty)) {
                return 'Please confirm your new password';
              }
              if (_showPasswordSection && value != _newPasswordController.text) {
                return 'Passwords do not match';
              }
              return null;
            },
          ),
        ],
      ],
    );
  }

  Widget _buildPasswordStrengthIndicator() {
    final validation = ProfileService.validatePassword(_newPasswordController.text);
    final score = validation['score'] as int;
    final validations = validation['validations'] as Map<String, bool>;

    Color getStrengthColor() {
      switch (score) {
        case 0:
        case 1:
          return Colors.red;
        case 2:
        case 3:
          return Colors.orange;
        case 4:
          return Colors.blue;
        case 5:
          return Colors.green;
        default:
          return Colors.grey;
      }
    }

    String getStrengthText() {
      switch (score) {
        case 0:
        case 1:
          return 'Very Weak';
        case 2:
          return 'Weak';
        case 3:
          return 'Fair';
        case 4:
          return 'Good';
        case 5:
          return 'Strong';
        default:
          return 'Unknown';
      }
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Password Strength: ',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            Text(
              getStrengthText(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: getStrengthColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        LinearProgressIndicator(
          value: score / 5,
          backgroundColor: Colors.grey.withOpacity(0.3),
          valueColor: AlwaysStoppedAnimation<Color>(getStrengthColor()),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: [
            _buildValidationChip('8+ characters', validations['hasMinLength']!),
            _buildValidationChip('Uppercase', validations['hasUppercase']!),
            _buildValidationChip('Lowercase', validations['hasLowercase']!),
            _buildValidationChip('Numbers', validations['hasNumbers']!),
            _buildValidationChip('Special chars', validations['hasSpecialCharacters']!),
          ],
        ),
      ],
    );
  }

  Widget _buildValidationChip(String label, bool isValid) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isValid ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isValid ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isValid ? Icons.check : Icons.close,
            size: 14,
            color: isValid ? Colors.green : Colors.red,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: isValid ? Colors.green : Colors.red,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(ThemeData theme) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: _isLoading ? null : () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ),
        SizedBox(width: ResponsiveUtils.getSpacing(context, mobile: 16, tablet: 20, desktop: 24)),
        Expanded(
          child: ElevatedButton(
            onPressed: _isLoading ? null : _saveProfile,
            child: _isLoading
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Text('Save Changes'),
          ),
        ),
      ],
    );
  }

  Widget _buildImageWidget() {
    if (_selectedImage != null) {
      // For mobile/desktop platforms
      return Image.file(
        _selectedImage!,
        fit: BoxFit.cover,
      );
    } else if (_selectedImageBytes != null) {
      // For web platform
      return Image.memory(
        _selectedImageBytes!,
        fit: BoxFit.cover,
      );
    } else {
      // Default avatar
      return ProfileAvatar(
        userModel: widget.userModel,
        radius: ResponsiveUtils.getFontSize(context, mobile: 60, tablet: 70, desktop: 80),
      );
    }
  }
}
