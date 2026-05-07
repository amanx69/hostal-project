import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_theme.dart';
import '../providers/post_providers.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _usernameCtrl;
  late final TextEditingController _bioCtrl;
  late final TextEditingController _locationCtrl;
  late final TextEditingController _phoneCtrl;


  File? _newAvatar;
  File? _newCover;
  
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(myProfileProvider).profile;
    _usernameCtrl = TextEditingController(text: profile?.username ?? '');
    _bioCtrl = TextEditingController(text: profile?.bio ?? '');
    _locationCtrl = TextEditingController(text: profile?.location ?? '');
    _phoneCtrl = TextEditingController(text: profile?.phoneNumber ?? '');
    
  }

  @override
  void dispose() {
    _usernameCtrl.dispose();
    _bioCtrl.dispose();
    _locationCtrl.dispose();
    _phoneCtrl.dispose();
;
    super.dispose();
  }

  Future<void> _pickImage(bool isCover) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery, imageQuality: 70);
    if (picked != null) {
      setState(() {
        if (isCover) {
          _newCover = File(picked.path);
        } else {
          _newAvatar = File(picked.path);
        }
      });
    }
  }

  Future<void> _save() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    
    setState(() => _isSaving = true);
    
    final success = await ref.read(myProfileProvider.notifier).updateProfile(
      username: _usernameCtrl.text.trim(),
      bio: _bioCtrl.text.trim(),
      location: _locationCtrl.text.trim(),
      phoneNumber: _phoneCtrl.text.trim(),
 
      profilePicture: _newAvatar,
      coverImage: _newCover,
    );

    if (!mounted) return;
    setState(() => _isSaving = false);

    if (success) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Profile updated successfully'),
          backgroundColor: AppColors.primary,
        ),
      );
    } else {
      final error = ref.read(myProfileProvider).error ?? 'Failed to update profile';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error),
          backgroundColor: AppColors.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final profile = ref.watch(myProfileProvider).profile;
    
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: isDark ? SystemUiOverlayStyle.light : SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
        appBar: AppBar(
          backgroundColor: isDark ? AppColors.surfaceDark : Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.close_rounded, color: isDark ? Colors.white : Colors.black87),
            onPressed: () => context.pop(),
          ),
          title: Text(
            'Edit profile',
            style: TextStyle(
              color: isDark ? Colors.white : Colors.black87,
              fontWeight: FontWeight.w800,
              fontSize: 18,
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
              child: ElevatedButton(
                onPressed: _isSaving ? null : _save,
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDark ? Colors.white : Colors.black,
                  foregroundColor: isDark ? Colors.black : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                ),
                child: _isSaving
                    ? const SizedBox(
                        width: 16, height: 16,
                        child: CircularProgressIndicator(strokeWidth: 2))
                    : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ),
          ],
        ),
        body: profile == null
            ? const Center(child: CircularProgressIndicator())
            : Form(
                key: _formKey,
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      // ── Cover & Avatar Section ──────────────────────────────
                      SizedBox(
                        height: 200,
                        child: Stack(
                          clipBehavior: Clip.none,
                          children: [
                            // Cover Image
                            GestureDetector(
                              onTap: () => _pickImage(true),
                              child: Container(
                                height: 140,
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: isDark ? AppColors.cardDark : Colors.grey.shade200,
                                  image: _newCover != null
                                      ? DecorationImage(image: FileImage(_newCover!), fit: BoxFit.cover)
                                      : (profile.coverImage != null
                                          ? DecorationImage(image: NetworkImage(profile.coverImage!), fit: BoxFit.cover)
                                          : null),
                                ),
                                child: Container(
                                  color: Colors.black.withOpacity(0.3),
                                  alignment: Alignment.center,
                                  child: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 32),
                                ),
                              ),
                            ),
                            // Avatar
                            Positioned(
                              bottom: 10,
                              left: 16,
                              child: GestureDetector(
                                onTap: () => _pickImage(false),
                                child: Container(
                                  padding: const EdgeInsets.all(4),
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: isDark ? AppColors.surfaceDark : Colors.white,
                                  ),
                                  child: Container(
                                    width: 80,
                                    height: 80,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: isDark ? AppColors.cardDark : Colors.grey.shade300,
                                      image: _newAvatar != null
                                          ? DecorationImage(image: FileImage(_newAvatar!), fit: BoxFit.cover)
                                          : (profile.profilePicture != null
                                              ? DecorationImage(image: NetworkImage(profile.profilePicture!), fit: BoxFit.cover)
                                              : null),
                                    ),
                                    child: Container(
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Colors.black.withOpacity(0.3),
                                      ),
                                      alignment: Alignment.center,
                                      child: const Icon(Icons.add_a_photo_outlined, color: Colors.white, size: 28),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      // ── Form Fields ──────────────────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12),
                        child: Column(
                          children: [
                            _buildField('Username', _usernameCtrl, isDark),
                            _buildField('Bio', _bioCtrl, isDark, maxLines: 3),
                            _buildField('Location', _locationCtrl, isDark),
                            _buildField('Phone number', _phoneCtrl, isDark),

                            const SizedBox(height: 40),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildField(String label, TextEditingController controller, bool isDark, {int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: TextFormField(
        controller: controller,
        maxLines: maxLines,
        style: TextStyle(color: isDark ? Colors.white : Colors.black87),
        decoration: InputDecoration(
          labelText: label,
          labelStyle: TextStyle(color: isDark ? Colors.white54 : Colors.black54),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: isDark ? Colors.white24 : Colors.black26),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: AppColors.primary, width: 2),
          ),
          contentPadding: const EdgeInsets.symmetric(vertical: 8),
        ),
      ),
    );
  }
}
