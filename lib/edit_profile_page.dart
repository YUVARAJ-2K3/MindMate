import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cached_network_image/cached_network_image.dart';

class EditProfilePage extends StatefulWidget {
  const EditProfilePage({super.key});

  @override
  State<EditProfilePage> createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  static const double scale = 0.75;
  // Controllers for editable fields
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();

  // Dropdown values
  String _ageGroup = 'Teen';
  String _country = 'India';
  final List<String> _ageGroups = ['Child', 'Teen', 'Adult', 'Senior'];
  final List<String> _countries = ['India', 'USA', 'UK', 'Canada'];

  bool _loading = true;
  bool _saving = false;
  User? _currentUser;
  bool _editingName = false;

  @override
  void initState() {
    super.initState();
    _currentUser = FirebaseAuth.instance.currentUser;
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    // Get user data from Firebase Auth first, then fallback to SharedPreferences
    final userName =
        _currentUser?.displayName ?? prefs.getString('profile_name') ?? 'User';
    final userEmail =
        _currentUser?.email ??
        prefs.getString('profile_email') ??
        'user@example.com';
    final userPhotoUrl = _currentUser?.photoURL;

    setState(() {
      _nameController.text = userName;
      _emailController.text = userEmail;
      _phoneController.text =
          prefs.getString('profile_phone') ?? '+91 12345 6789';
      _cityController.text = prefs.getString('profile_city') ?? 'Chennai';
      _ageGroup = prefs.getString('profile_ageGroup') ?? 'Teen';
      _country = prefs.getString('profile_country') ?? 'India';
      _loading = false;
    });
  }

  Future<void> _saveProfile() async {
    setState(() => _saving = true);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('profile_name', _nameController.text);
    await prefs.setString('profile_email', _emailController.text);
    await prefs.setString('profile_phone', _phoneController.text);
    await prefs.setString('profile_city', _cityController.text);
    await prefs.setString('profile_ageGroup', _ageGroup);
    await prefs.setString('profile_country', _country);
    setState(() => _saving = false);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'Profile saved!',
          style: TextStyle(fontFamily: 'Montserrat'),
        ),
        backgroundColor: Color(0xFFEA8C6E),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _cityController.dispose();
    super.dispose();
  }

  Widget _buildProfileImage() {
    final photoUrl = _currentUser?.photoURL;
    if (photoUrl != null && photoUrl.isNotEmpty) {
      return CachedNetworkImage(
        imageUrl: photoUrl,
        width: 60.0 * scale,
        height: 60.0 * scale,
        fit: BoxFit.cover,
        placeholder: (context, url) => Container(
          width: 60.0 * scale,
          height: 60.0 * scale,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 30.0 * scale,
            color: Colors.grey[600],
          ),
        ),
        errorWidget: (context, url, error) => Container(
          width: 60.0 * scale,
          height: 60.0 * scale,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            shape: BoxShape.circle,
          ),
          child: Icon(
            Icons.person,
            size: 30.0 * scale,
            color: Colors.grey[600],
          ),
        ),
      );
    } else {
      // Fallback to default avatar
      return Container(
        width: 60.0 * scale,
        height: 60.0 * scale,
        decoration: BoxDecoration(
          color: Colors.grey[300],
          shape: BoxShape.circle,
        ),
        child: Icon(Icons.person, size: 30.0 * scale, color: Colors.grey[600]),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Compact scaling factors
    // Colors
    const backgroundColor = Color(0xFFFDE7EF);
    const cardColor = Color(0xFFFCF6ED);
    const headerGradient = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [Color(0xFFE7BBAA), Color(0x00E7BBAA)],
      stops: [0.0, 1.0],
    );
    const labelColor = Color(0xFF8B7B9B);
    const borderColor = Color(0xFFE7BBAA);
    const fieldTextColor = Color(0xFF222222);
    const iconColor = Color(0xFFB98B6C);
    const saveTextColor = Color(0xFF222222);
    const nameTextColor = Color(0xFF222222);
    const editIconColor = Color(0xFFB98B6C);
    const fieldFont = 'Montserrat';
    const nameFont = 'Montserrat';
    const countryIcon = Icons.flag_outlined;
    const ageIcon = Icons.badge_outlined;
    const phoneIcon = Icons.phone_outlined;
    // Sizing (scaled down, but with +2px for readability)
    const double cardRadius = 36 * scale;
    const double cardPadding = 32 * scale;
    const double avatarRadius = 60 * scale;
    const double avatarCircleRadius = 80 * scale;
    const double editIconSize = 22 * scale;
    const double nameFontSize = 24 * scale + 8;
    const double fieldFontSize = 16 * scale + 6;
    const double labelFontSize = 10 * scale + 6;
    const double fieldVerticalSpacing = 8 * scale;
    const double saveFontSize = 18 * scale + 6;
    const double headerHeight = 76 * scale;
    const double headerRadius = 36 * scale;
    const double backIconSize = 32 * scale;
    const double topSafeArea = 28 * scale;
    const double cardMargin = 12 * scale;
    const double containerWidth = 320;
    const double containerHeight = 600;

    if (_loading) {
      return const Scaffold(
        backgroundColor: backgroundColor,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: backgroundColor,
      body: Center(
        child: Container(
          width: containerWidth,
          height: containerHeight,
          margin: EdgeInsets.symmetric(
            vertical: cardMargin,
            horizontal: cardMargin,
          ),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(cardRadius),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.07),
                blurRadius: 12 * scale,
                offset: Offset(0, 6 * scale),
              ),
            ],
          ),
          child: Stack(
            children: [
              // Header with gradient and Save button
              Positioned(
                left: 0,
                right: 0,
                top: 0,
                child: Container(
                  height: headerHeight,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(headerRadius),
                      topRight: Radius.circular(headerRadius),
                    ),
                    gradient: headerGradient,
                  ),
                  child: Stack(
                    children: [
                      // Back arrow
                      Positioned(
                        left: 12 * scale,
                        top: topSafeArea,
                        child: GestureDetector(
                          onTap: () => Navigator.of(context).maybePop(),
                          child: Icon(
                            Icons.arrow_back_ios_new_rounded,
                            size: backIconSize,
                            color: fieldTextColor,
                          ),
                        ),
                      ),
                      // Title
                      Positioned.fill(
                        child: Align(
                          alignment: Alignment(0, -0.1),
                          child: Text(
                            'Edit profile',
                            style: TextStyle(
                              fontFamily: nameFont,
                              fontWeight: FontWeight.w600,
                              fontSize: 21 * scale + 4,
                              color: nameTextColor,
                              letterSpacing: 0.2,
                            ),
                          ),
                        ),
                      ),
                      // Save button
                      Positioned(
                        right: 18 * scale,
                        top: topSafeArea,
                        child: GestureDetector(
                          onTap: _saving ? null : _saveProfile,
                          child: _saving
                              ? SizedBox(
                                  width: 22,
                                  height: 22,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2.2,
                                    valueColor: AlwaysStoppedAnimation<Color>(
                                      saveTextColor.withOpacity(0.7),
                                    ),
                                  ),
                                )
                              : Text(
                                  'Save',
                                  style: TextStyle(
                                    fontFamily: nameFont,
                                    fontWeight: FontWeight.w400,
                                    fontSize: saveFontSize,
                                    color: saveTextColor,
                                    letterSpacing: 0.1,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              // Main content
              Positioned.fill(
                top: headerHeight - 8 * scale,
                child: Column(
                  children: [
                    SizedBox(height: 12 * scale),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        // Avatar circle
                        Container(
                          width: avatarCircleRadius,
                          height: avatarCircleRadius,
                          decoration: BoxDecoration(
                            color: const Color(0xFFE7BBAA),
                            shape: BoxShape.circle,
                          ),
                        ),
                        // Profile image
                        ClipOval(child: _buildProfileImage()),
                      ],
                    ),
                    SizedBox(height: 4 * scale),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        !_editingName
                            ? Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    _nameController.text,
                                    style: TextStyle(
                                      fontFamily: nameFont,
                                      fontWeight: FontWeight.w500,
                                      fontSize: nameFontSize - 2,
                                      color: nameTextColor,
                                      letterSpacing: 0.1,
                                    ),
                                  ),
                                  SizedBox(width: 4),
                                  GestureDetector(
                                    onTap: () {
                                      setState(() {
                                        _editingName = true;
                                      });
                                    },
                                    child: Icon(
                                      Icons.edit,
                                      size: editIconSize,
                                      color: editIconColor,
                                    ),
                                  ),
                                ],
                              )
                            : SizedBox(
                                width: 180,
                                child: TextField(
                                  controller: _nameController,
                                  autofocus: true,
                                  style: TextStyle(
                                    fontFamily: nameFont,
                                    fontWeight: FontWeight.w500,
                                    fontSize: nameFontSize - 2,
                                    color: nameTextColor,
                                    letterSpacing: 0.1,
                                  ),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    isDense: true,
                                    contentPadding: EdgeInsets.symmetric(
                                      vertical: 0,
                                      horizontal: 0,
                                    ),
                                  ),
                                  textAlign: TextAlign.center,
                                  onSubmitted: (_) {
                                    setState(() {
                                      _editingName = false;
                                    });
                                  },
                                  onEditingComplete: () {
                                    setState(() {
                                      _editingName = false;
                                    });
                                  },
                                ),
                              ),
                      ],
                    ),
                    SizedBox(height: 4 * scale),
                    // Fields
                    Expanded(
                      child: Padding(
                        padding: EdgeInsets.fromLTRB(
                          cardPadding,
                          0,
                          cardPadding,
                          0,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            // Email
                            _Label('EMAIL', fontSize: labelFontSize),
                            _EditableField(
                              controller: _emailController,
                              fontSize: fieldFontSize,
                              underline: true,
                              textColor: fieldTextColor,
                              borderColor: borderColor,
                              fontFamily: fieldFont,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            SizedBox(height: fieldVerticalSpacing),
                            // Age Group
                            _Label('AGE GROUP', fontSize: labelFontSize),
                            _DropdownField(
                              icon: ageIcon,
                              value: _ageGroup,
                              fontSize: fieldFontSize,
                              textColor: fieldTextColor,
                              borderColor: borderColor,
                              fontFamily: fieldFont,
                              items: _ageGroups,
                              onChanged: (val) =>
                                  setState(() => _ageGroup = val!),
                            ),
                            SizedBox(height: fieldVerticalSpacing),
                            // Phone
                            _Label('PHONE', fontSize: labelFontSize),
                            _IconEditableField(
                              icon: phoneIcon,
                              controller: _phoneController,
                              fontSize: fieldFontSize,
                              textColor: fieldTextColor,
                              borderColor: borderColor,
                              fontFamily: fieldFont,
                              keyboardType: TextInputType.phone,
                            ),
                            SizedBox(height: fieldVerticalSpacing),
                            // City
                            _Label('CITY', fontSize: labelFontSize),
                            _EditableField(
                              controller: _cityController,
                              fontSize: fieldFontSize,
                              underline: true,
                              textColor: fieldTextColor,
                              borderColor: borderColor,
                              fontFamily: fieldFont,
                            ),
                            SizedBox(height: fieldVerticalSpacing),
                            // Country
                            _Label('COUNTRY', fontSize: labelFontSize),
                            _DropdownField(
                              icon: countryIcon,
                              value: _country,
                              fontSize: fieldFontSize,
                              textColor: fieldTextColor,
                              borderColor: borderColor,
                              fontFamily: fieldFont,
                              items: _countries,
                              onChanged: (val) =>
                                  setState(() => _country = val!),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Label extends StatelessWidget {
  final String text;
  final double fontSize;
  const _Label(this.text, {super.key, this.fontSize = 15.5});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2.5),
      child: Text(
        text,
        style: TextStyle(
          fontFamily: 'Montserrat',
          fontWeight: FontWeight.w500,
          fontSize: fontSize,
          color: Color(0xFF8B7B9B),
          letterSpacing: 0.1,
        ),
      ),
    );
  }
}

class _EditableField extends StatelessWidget {
  final TextEditingController controller;
  final double fontSize;
  final bool underline;
  final Color textColor;
  final Color borderColor;
  final String fontFamily;
  final TextInputType? keyboardType;
  const _EditableField({
    required this.controller,
    required this.fontSize,
    required this.underline,
    required this.textColor,
    required this.borderColor,
    required this.fontFamily,
    this.keyboardType,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: controller,
                  style: TextStyle(
                    fontFamily: fontFamily,
                    fontWeight: FontWeight.w400,
                    fontSize: fontSize,
                    color: textColor,
                    letterSpacing: 0.1,
                  ),
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                    isDense: true,
                    contentPadding: EdgeInsets.symmetric(
                      vertical: 0,
                      horizontal: 0,
                    ),
                  ),
                  keyboardType: keyboardType,
                ),
              ),
            ],
          ),
          if (underline)
            Container(
              margin: EdgeInsets.only(top: 2),
              width: double.infinity,
              height: 1.2,
              color: borderColor,
            ),
        ],
      ),
    );
  }
}

class _DropdownField extends StatelessWidget {
  final IconData icon;
  final String value;
  final double fontSize;
  final Color textColor;
  final Color borderColor;
  final String fontFamily;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  const _DropdownField({
    required this.icon,
    required this.value,
    required this.fontSize,
    required this.textColor,
    required this.borderColor,
    required this.fontFamily,
    required this.items,
    required this.onChanged,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xFFB98B6C)),
          const SizedBox(width: 4),
          Expanded(
            child: DropdownButtonFormField<String>(
              value: value,
              items: items
                  .map(
                    (e) => DropdownMenuItem<String>(
                      value: e,
                      child: Text(
                        e,
                        style: TextStyle(
                          fontFamily: fontFamily,
                          fontWeight: FontWeight.w400,
                          fontSize: fontSize,
                          color: textColor,
                          letterSpacing: 0.1,
                        ),
                      ),
                    ),
                  )
                  .toList(),
              onChanged: onChanged,
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 0,
                ),
              ),
              icon: const Icon(
                Icons.expand_more,
                size: 16,
                color: Color(0xFFB98B6C),
              ),
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
                color: textColor,
                letterSpacing: 0.1,
              ),
              dropdownColor: const Color(0xFFFCF6ED),
            ),
          ),
        ],
      ),
    );
  }
}

class _IconEditableField extends StatelessWidget {
  final IconData icon;
  final TextEditingController controller;
  final double fontSize;
  final Color textColor;
  final Color borderColor;
  final String fontFamily;
  final TextInputType? keyboardType;
  const _IconEditableField({
    required this.icon,
    required this.controller,
    required this.fontSize,
    required this.textColor,
    required this.borderColor,
    required this.fontFamily,
    this.keyboardType,
    super.key,
  });
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: borderColor, width: 1.2)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 16, color: Color(0xFFB98B6C)),
          const SizedBox(width: 4),
          Expanded(
            child: TextField(
              controller: controller,
              style: TextStyle(
                fontFamily: fontFamily,
                fontWeight: FontWeight.w400,
                fontSize: fontSize,
                color: textColor,
                letterSpacing: 0.1,
              ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.symmetric(
                  vertical: 0,
                  horizontal: 0,
                ),
              ),
              keyboardType: keyboardType,
            ),
          ),
        ],
      ),
    );
  }
}
