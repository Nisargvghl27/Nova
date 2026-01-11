// import 'dart:convert';
// import 'dart:io';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:image_picker/image_picker.dart';
// import 'package:firebase_auth/firebase_auth.dart';
// import '../services/auth_service.dart';

// class EditProfileScreen extends StatefulWidget {
//   final String currentName;
//   final String? currentBase64Photo;
//   final String? currentPhone;
//   final String? currentBio;
//   final String? currentLocation;
//   final String? currentProfession;
//   final String? currentDob;
//   final String? currentUsername;

//   const EditProfileScreen({
//     super.key,
//     required this.currentName,
//     this.currentBase64Photo,
//     this.currentPhone,
//     this.currentBio,
//     this.currentLocation,
//     this.currentProfession,
//     this.currentDob,
//     this.currentUsername,
//   });

//   @override
//   State<EditProfileScreen> createState() => _EditProfileScreenState();
// }

// class _EditProfileScreenState extends State<EditProfileScreen> {
//   final _formKey = GlobalKey<FormState>();
  
//   late TextEditingController _nameController;
//   late TextEditingController _phoneController;
//   late TextEditingController _bioController;
//   late TextEditingController _locationController;
//   late TextEditingController _professionController;
//   late TextEditingController _usernameController;
//   late TextEditingController _dobController;
//   late TextEditingController _emailController;
  
//   bool _isLoading = false;
//   File? _selectedImage;
//   bool _isPhotoRemoved = false;
//   bool _hasChanges = false;

//   @override
//   void initState() {
//     super.initState();
//     final user = FirebaseAuth.instance.currentUser;

//     _nameController = TextEditingController(text: widget.currentName);
//     _phoneController = TextEditingController(text: widget.currentPhone ?? '');
//     _bioController = TextEditingController(text: widget.currentBio ?? '');
//     _locationController = TextEditingController(text: widget.currentLocation ?? '');
//     _professionController = TextEditingController(text: widget.currentProfession ?? '');
//     _usernameController = TextEditingController(text: widget.currentUsername ?? '');
//     _dobController = TextEditingController(text: widget.currentDob ?? '');
//     _emailController = TextEditingController(text: user?.email ?? '');
    
//     void markChanged() {
//       if (!_hasChanges) setState(() => _hasChanges = true);
//     }

//     _nameController.addListener(markChanged);
//     _phoneController.addListener(markChanged);
//     _bioController.addListener(markChanged);
//     _locationController.addListener(markChanged);
//     _professionController.addListener(markChanged);
//     _usernameController.addListener(markChanged);
//     _dobController.addListener(markChanged);
//   }

//   @override
//   void dispose() {
//     _nameController.dispose();
//     _phoneController.dispose();
//     _bioController.dispose();
//     _locationController.dispose();
//     _professionController.dispose();
//     _usernameController.dispose();
//     _dobController.dispose();
//     _emailController.dispose();
//     super.dispose();
//   }
  
//   double _calculateCompletion() {
//     int total = 7; 
//     int filled = 0;
//     if (_nameController.text.trim().isNotEmpty) filled++;
//     if (_phoneController.text.trim().isNotEmpty) filled++;
//     if (_bioController.text.trim().isNotEmpty) filled++;
//     if (_locationController.text.trim().isNotEmpty) filled++;
//     if (_professionController.text.trim().isNotEmpty) filled++;
//     if (_usernameController.text.trim().isNotEmpty) filled++;
//     if (_dobController.text.trim().isNotEmpty) filled++;
//     return filled / total;
//   }

//   Future<void> _pickImage() async {
//     try {
//       final picker = ImagePicker();
//       final pickedFile = await picker.pickImage(
//         source: ImageSource.gallery,
//         maxWidth: 512,
//         maxHeight: 512,
//         imageQuality: 50,
//       );

//       if (pickedFile != null) {
//         setState(() {
//           _selectedImage = File(pickedFile.path);
//           _isPhotoRemoved = false;
//           _hasChanges = true;
//         });
//         HapticFeedback.lightImpact();
//       }
//     } catch (e) {
//       debugPrint("Error picking image: $e");
//     }
//   }

//   void _removePhoto() {
//     setState(() {
//       _selectedImage = null;
//       _isPhotoRemoved = true;
//       _hasChanges = true;
//     });
//     HapticFeedback.mediumImpact();
//   }

//   Future<void> _selectDate(BuildContext context) async {
//     final DateTime? picked = await showDatePicker(
//       context: context,
//       initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), 
//       firstDate: DateTime(1900),
//       lastDate: DateTime.now(),
//       builder: (context, child) {
//         return Theme(
//           data: Theme.of(context).copyWith(
//             colorScheme: const ColorScheme.light(
//               primary: Color(0xFF2575FC),
//               onPrimary: Colors.white,
//               onSurface: Colors.black,
//             ),
//           ),
//           child: child!,
//         );
//       },
//     );
//     if (picked != null) {
//       setState(() {
//         _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
//       });
//     }
//   }

//   Future<bool> _onWillPop() async {
//     if (!_hasChanges) return true;

//     final shouldPop = await showDialog<bool>(
//       context: context,
//       builder: (context) => AlertDialog(
//         title: const Text('Discard Changes?'),
//         content: const Text('You have unsaved changes. Are you sure you want to leave?'),
//         shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
//         actions: [
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(false),
//             child: const Text('Keep Editing'),
//           ),
//           TextButton(
//             onPressed: () => Navigator.of(context).pop(true),
//             style: TextButton.styleFrom(foregroundColor: Colors.red),
//             child: const Text('Discard'),
//           ),
//         ],
//       ),
//     );
//     return shouldPop ?? false;
//   }

//   Future<void> _saveProfile() async {
//     if (!_formKey.currentState!.validate()) return;
    
//     if (_phoneController.text.isNotEmpty && _phoneController.text.length < 10) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(content: Text('Phone number must be at least 10 digits')),
//       );
//       return;
//     }

//     setState(() => _isLoading = true);
//     HapticFeedback.lightImpact();

//     try {
//       final authService = AuthService();
      
//       await authService.updateProfile(
//         name: _nameController.text.trim(),
//         phone: _phoneController.text.trim(),
//         bio: _bioController.text.trim(),
//         location: _locationController.text.trim(),
//         profession: _professionController.text.trim(),
//         username: _usernameController.text.trim(),
//         dob: _dobController.text.trim(),
//       );

//       if (_isPhotoRemoved) {
//         await authService.deleteProfileImage();
//       } else if (_selectedImage != null) {
//         await authService.saveProfileImageAsBase64(_selectedImage!);
//       }

//       if (!mounted) return;

//       ScaffoldMessenger.of(context).showSnackBar(
//         const SnackBar(
//           content: Row(children: [
//             Icon(Icons.check_circle_rounded, color: Colors.white),
//             SizedBox(width: 8),
//             Text('Profile updated successfully')
//           ]),
//           backgroundColor: Color(0xFF2575FC),
//         ),
//       );
      
//       setState(() => _hasChanges = false);
//       Navigator.pop(context);

//     } catch (e) {
//       ScaffoldMessenger.of(context).showSnackBar(
//         SnackBar(content: Text('Error: ${e.toString()}')),
//       );
//     } finally {
//       if (mounted) setState(() => _isLoading = false);
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     final isDark = Theme.of(context).brightness == Brightness.dark;
//     final textColor = isDark ? Colors.white : Colors.black;
//     final user = FirebaseAuth.instance.currentUser;

//     ImageProvider? backgroundImage;
//     bool hasImage = false;
    
//     if (_isPhotoRemoved) {
//       backgroundImage = null; 
//     } else if (_selectedImage != null) {
//       backgroundImage = FileImage(_selectedImage!);
//       hasImage = true;
//     } else if (widget.currentBase64Photo != null && widget.currentBase64Photo!.isNotEmpty) {
//       try {
//         backgroundImage = MemoryImage(base64Decode(widget.currentBase64Photo!));
//         hasImage = true;
//       } catch (e) { debugPrint("$e"); }
//     } else if (user?.photoURL != null) {
//       backgroundImage = NetworkImage(user!.photoURL!);
//       hasImage = true;
//     }

//     double completion = _calculateCompletion();
//     int percent = (completion * 100).toInt();

//     return WillPopScope(
//       onWillPop: _onWillPop,
//       child: GestureDetector(
//         onTap: () => FocusScope.of(context).unfocus(),
//         child: Scaffold(
//           backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//           appBar: AppBar(
//             title: Text('Edit Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
//             centerTitle: true,
//             backgroundColor: Colors.transparent,
//             elevation: 0,
//             leading: IconButton(
//               icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
//               onPressed: () async {
//                  if (await _onWillPop()) Navigator.pop(context);
//               },
//             ),
//           ),
//           body: SingleChildScrollView(
//             padding: const EdgeInsets.all(24),
//             child: Form(
//               key: _formKey,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // --- COMPLETION BAR ---
//                   Container(
//                     padding: const EdgeInsets.all(16),
//                     decoration: BoxDecoration(
//                       color: const Color(0xFF6A11CB).withOpacity(0.1),
//                       borderRadius: BorderRadius.circular(16),
//                     ),
//                     child: Column(
//                       children: [
//                         Row(
//                           mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                           children: [
//                             Text("Profile Completion", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
//                             Text("$percent%", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A11CB))),
//                           ],
//                         ),
//                         const SizedBox(height: 8),
//                         ClipRRect(
//                           borderRadius: BorderRadius.circular(10),
//                           child: LinearProgressIndicator(
//                             value: completion,
//                             backgroundColor: Colors.grey[300],
//                             color: const Color(0xFF6A11CB),
//                             minHeight: 8,
//                           ),
//                         ),
//                         if (percent < 100)
//                           Padding(
//                             padding: const EdgeInsets.only(top: 8),
//                             child: Text(
//                               "Add more details to complete your profile!", 
//                               style: TextStyle(fontSize: 12, color: isDark ? Colors.white60 : Colors.grey[600])
//                             ),
//                           )
//                       ],
//                     ),
//                   ),
//                   const SizedBox(height: 32),

//                   // --- AVATAR ---
//                   Center(
//                     child: Stack(
//                       children: [
//                         Container(
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             border: Border.all(color: Theme.of(context).cardColor, width: 4),
//                             boxShadow: [
//                                BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
//                             ],
//                           ),
//                           child: CircleAvatar(
//                             radius: 60,
//                             backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
//                             backgroundImage: backgroundImage,
//                             child: backgroundImage == null
//                                 ? Icon(Icons.person, size: 60, color: Colors.grey[400])
//                                 : null,
//                           ),
//                         ),
                        
//                         Positioned(
//                           bottom: 0, right: 0,
//                           child: GestureDetector(
//                             onTap: _pickImage,
//                             child: Container(
//                               padding: const EdgeInsets.all(10),
//                               decoration: const BoxDecoration(color: Color(0xFF2575FC), shape: BoxShape.circle),
//                               child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
//                             ),
//                           ),
//                         ),

//                         if (hasImage)
//                           Positioned(
//                             top: 0, right: 0,
//                             child: GestureDetector(
//                               onTap: _removePhoto,
//                               child: Container(
//                                 padding: const EdgeInsets.all(8),
//                                 decoration: BoxDecoration(
//                                   color: Colors.red.withOpacity(0.9), 
//                                   shape: BoxShape.circle,
//                                   border: Border.all(color: Theme.of(context).cardColor, width: 2)
//                                 ),
//                                 child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
//                               ),
//                             ),
//                           ),
//                       ],
//                     ),
//                   ),

//                   const SizedBox(height: 32),
                  
//                   Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF6A11CB))),
//                   const SizedBox(height: 24),

//                   // --- NAME ---
//                   _buildLabel('Full Name', isDark),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _nameController,
//                     hint: 'Enter your name',
//                     icon: Icons.person_outline_rounded,
//                     isDark: isDark,
//                     textCapitalization: TextCapitalization.words, // 🔹 Auto Capitalize
//                     validator: (val) => val!.trim().isEmpty ? 'Name cannot be empty' : null,
//                   ),
//                   const SizedBox(height: 20),
                  
//                   // --- EMAIL ---
//                   _buildLabel('Email Address', isDark),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _emailController,
//                     hint: 'email@example.com',
//                     icon: Icons.email_outlined,
//                     isDark: isDark,
//                     readOnly: true, 
//                   ),
//                   const SizedBox(height: 20),

//                   // --- USERNAME ---
//                   _buildLabel('Username (Handle)', isDark),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _usernameController,
//                     hint: '@username',
//                     icon: Icons.alternate_email_rounded,
//                     isDark: isDark,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
//                     ],
//                   ),
//                   const SizedBox(height: 20),

//                   // --- PHONE ---
//                   _buildLabel('Phone Number', isDark),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _phoneController,
//                     hint: '+91 98765 43210',
//                     icon: Icons.phone_rounded,
//                     isDark: isDark,
//                     keyboardType: TextInputType.phone,
//                     inputFormatters: [
//                       FilteringTextInputFormatter.digitsOnly,
//                       LengthLimitingTextInputFormatter(15), 
//                     ],
//                   ),
//                   const SizedBox(height: 20),
                  
//                   // --- PROFESSION ---
//                   _buildLabel('Profession', isDark),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _professionController,
//                     hint: 'e.g. Designer, Developer',
//                     icon: Icons.work_outline_rounded,
//                     isDark: isDark,
//                     textCapitalization: TextCapitalization.words, // 🔹 Auto Capitalize
//                   ),
//                   const SizedBox(height: 20),

//                   // --- LOCATION ---
//                   _buildLabel('Location', isDark),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _locationController,
//                     hint: 'City, Country',
//                     icon: Icons.location_on_outlined,
//                     isDark: isDark,
//                     textCapitalization: TextCapitalization.words, // 🔹 Auto Capitalize
//                   ),
//                   const SizedBox(height: 20),
                  
//                   // --- DOB ---
//                   _buildLabel('Date of Birth', isDark),
//                   const SizedBox(height: 8),
//                   GestureDetector(
//                     onTap: () => _selectDate(context),
//                     child: AbsorbPointer(
//                       child: _buildTextField(
//                         controller: _dobController,
//                         hint: 'DD/MM/YYYY',
//                         icon: Icons.cake_outlined,
//                         isDark: isDark,
//                       ),
//                     ),
//                   ),
//                   const SizedBox(height: 20),

//                   // --- BIO ---
//                   _buildLabel('Bio / About Me', isDark),
//                   const SizedBox(height: 8),
//                   _buildTextField(
//                     controller: _bioController,
//                     hint: 'Tell us a bit about yourself...',
//                     icon: Icons.info_outline_rounded,
//                     isDark: isDark,
//                     maxLines: 3,
//                     maxLength: 150, // 🔹 Character Limit
//                     textCapitalization: TextCapitalization.sentences, // 🔹 Sentences
//                   ),

//                   const SizedBox(height: 40),

//                   // --- SAVE BUTTON ---
//                   InkWell(
//                     onTap: _isLoading ? null : _saveProfile,
//                     borderRadius: BorderRadius.circular(18),
//                     child: Container(
//                       width: double.infinity,
//                       height: 56,
//                       decoration: BoxDecoration(
//                         gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
//                         borderRadius: BorderRadius.circular(18),
//                         boxShadow: [BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
//                       ),
//                       child: Center(
//                         child: _isLoading
//                             ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
//                             : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
//                       ),
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ),
//       ),
//     );
//   }

//   Widget _buildLabel(String text, bool isDark) {
//     return Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey));
//   }

//   Widget _buildTextField({
//     required TextEditingController controller,
//     required String hint,
//     required IconData icon,
//     required bool isDark,
//     TextInputType? keyboardType,
//     int maxLines = 1,
//     int? maxLength, // 🔹 Added Param
//     String? Function(String?)? validator,
//     List<TextInputFormatter>? inputFormatters,
//     bool readOnly = false,
//     TextCapitalization textCapitalization = TextCapitalization.none, // 🔹 Added Param
//   }) {
//     return TextFormField(
//       controller: controller,
//       style: TextStyle(color: readOnly ? Colors.grey : (isDark ? Colors.white : Colors.black)),
//       keyboardType: keyboardType,
//       maxLines: maxLines,
//       maxLength: maxLength,
//       readOnly: readOnly,
//       inputFormatters: inputFormatters,
//       textCapitalization: textCapitalization,
//       decoration: InputDecoration(
//         hintText: hint,
//         hintStyle: TextStyle(color: Colors.grey[400]),
//         prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.grey[600]),
//         filled: true,
//         fillColor: readOnly 
//             ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100])
//             : Theme.of(context).cardColor,
//         enabledBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
//         ),
//         focusedBorder: OutlineInputBorder(
//           borderRadius: BorderRadius.circular(16),
//           borderSide: const BorderSide(color: Color(0xFF2575FC)),
//         ),
//       ),
//       validator: validator,
//     );
//   }
// }

import 'dart:convert';
import 'dart:io';
import 'dart:async'; // 🔹 Added for Timer/Debouncing
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';

class EditProfileScreen extends StatefulWidget {
  final String currentName;
  final String? currentBase64Photo;
  final String? currentPhone;
  final String? currentBio;
  final String? currentLocation;
  final String? currentProfession;
  final String? currentDob;
  final String? currentUsername;

  const EditProfileScreen({
    super.key,
    required this.currentName,
    this.currentBase64Photo,
    this.currentPhone,
    this.currentBio,
    this.currentLocation,
    this.currentProfession,
    this.currentDob,
    this.currentUsername,
  });

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _bioController;
  late TextEditingController _locationController;
  late TextEditingController _professionController;
  late TextEditingController _usernameController;
  late TextEditingController _dobController;
  late TextEditingController _emailController;
  
  bool _isLoading = false;
  File? _selectedImage;
  bool _isPhotoRemoved = false;
  bool _hasChanges = false;

  // 🔹 Debounce Variables
  Timer? _debounceTimer;
  String _lastQuery = '';

  @override
  void initState() {
    super.initState();
    final user = FirebaseAuth.instance.currentUser;

    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone ?? '');
    _bioController = TextEditingController(text: widget.currentBio ?? '');
    _locationController = TextEditingController(text: widget.currentLocation ?? '');
    _professionController = TextEditingController(text: widget.currentProfession ?? '');
    _usernameController = TextEditingController(text: widget.currentUsername ?? '');
    _dobController = TextEditingController(text: widget.currentDob ?? '');
    _emailController = TextEditingController(text: user?.email ?? '');
    
    void markChanged() {
      if (!_hasChanges) setState(() => _hasChanges = true);
    }

    _nameController.addListener(markChanged);
    _phoneController.addListener(markChanged);
    _bioController.addListener(markChanged);
    _locationController.addListener(markChanged);
    _professionController.addListener(markChanged);
    _usernameController.addListener(markChanged);
    _dobController.addListener(markChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _bioController.dispose();
    _locationController.dispose();
    _professionController.dispose();
    _usernameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    _debounceTimer?.cancel(); // 🔹 Cancel timer on dispose
    super.dispose();
  }

  // 🔹 OPTIMIZED FETCH LOGIC WITH DEBOUNCING
  Future<Iterable<String>> _getLocationSuggestions(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.length < 3) return const Iterable<String>.empty();
    
    // Keep track of the latest query to ignore outdated responses
    _lastQuery = cleanQuery;

    // Wait for the user to stop typing (500ms debounce)
    await Future.delayed(const Duration(milliseconds: 500));

    // If the query has changed since we started waiting, discard this request
    if (cleanQuery != _lastQuery) return const Iterable<String>.empty();
    
    try {
      final encodedQuery = Uri.encodeComponent(cleanQuery);
      final url = Uri.parse('https://nominatim.openstreetmap.org/search?q=$encodedQuery&format=json&limit=5');
      
      final response = await http.get(url, headers: {
        'User-Agent': 'ExpenseTrackerApp/1.0',
        'Accept': 'application/json',
      });
      
      if (response.statusCode == 200) {
        // Re-check if this is still the most recent query before parsing
        if (cleanQuery != _lastQuery) return const Iterable<String>.empty();

        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item['display_name'] as String).toList();
      }
    } catch (e) {
      debugPrint("Location search error: $e");
    }
    return const Iterable<String>.empty();
  }
  
  double _calculateCompletion() {
    int total = 7; 
    int filled = 0;
    if (_nameController.text.trim().isNotEmpty) filled++;
    if (_phoneController.text.trim().isNotEmpty) filled++;
    if (_bioController.text.trim().isNotEmpty) filled++;
    if (_locationController.text.trim().isNotEmpty) filled++;
    if (_professionController.text.trim().isNotEmpty) filled++;
    if (_usernameController.text.trim().isNotEmpty) filled++;
    if (_dobController.text.trim().isNotEmpty) filled++;
    return filled / total;
  }

  Future<void> _pickImage() async {
    try {
      final picker = ImagePicker();
      final pickedFile = await picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 50,
      );

      if (pickedFile != null) {
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isPhotoRemoved = false;
          _hasChanges = true;
        });
        HapticFeedback.lightImpact();
      }
    } catch (e) {
      debugPrint("Error picking image: $e");
    }
  }

  void _removePhoto() {
    setState(() {
      _selectedImage = null;
      _isPhotoRemoved = true;
      _hasChanges = true;
    });
    HapticFeedback.mediumImpact();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now().subtract(const Duration(days: 365 * 18)), 
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF2575FC),
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _dobController.text = "${picked.day.toString().padLeft(2, '0')}/${picked.month.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  Future<bool> _onWillPop() async {
    if (!_hasChanges) return true;

    final shouldPop = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard Changes?'),
        content: const Text('You have unsaved changes. Are you sure you want to leave?'),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Keep Editing'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
    return shouldPop ?? false;
  }

  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    if (_phoneController.text.isNotEmpty && _phoneController.text.length < 10) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Phone number must be at least 10 digits')),
      );
      return;
    }

    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();

    try {
      final authService = AuthService();
      
      await authService.updateProfile(
        name: _nameController.text.trim(),
        phone: _phoneController.text.trim(),
        bio: _bioController.text.trim(),
        location: _locationController.text.trim(),
        profession: _professionController.text.trim(),
        username: _usernameController.text.trim(),
        dob: _dobController.text.trim(),
      );

      if (_isPhotoRemoved) {
        await authService.deleteProfileImage();
      } else if (_selectedImage != null) {
        await authService.saveProfileImageAsBase64(_selectedImage!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Row(children: [
            Icon(Icons.check_circle_rounded, color: Colors.white),
            SizedBox(width: 8),
            Text('Profile updated successfully')
          ]),
          backgroundColor: Color(0xFF2575FC),
        ),
      );
      
      setState(() => _hasChanges = false);
      Navigator.pop(context);

    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: ${e.toString()}')),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black;
    final user = FirebaseAuth.instance.currentUser;

    ImageProvider? backgroundImage;
    bool hasImage = false;
    
    if (_isPhotoRemoved) {
      backgroundImage = null; 
    } else if (_selectedImage != null) {
      backgroundImage = FileImage(_selectedImage!);
      hasImage = true;
    } else if (widget.currentBase64Photo != null && widget.currentBase64Photo!.isNotEmpty) {
      try {
        backgroundImage = MemoryImage(base64Decode(widget.currentBase64Photo!));
        hasImage = true;
      } catch (e) { debugPrint("$e"); }
    } else if (user?.photoURL != null) {
      backgroundImage = NetworkImage(user!.photoURL!);
      hasImage = true;
    }

    double completion = _calculateCompletion();
    int percent = (completion * 100).toInt();

    return WillPopScope(
      onWillPop: _onWillPop,
      child: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            title: Text('Edit Profile', style: TextStyle(color: textColor, fontWeight: FontWeight.bold)),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back_ios_new_rounded, color: textColor),
              onPressed: () async {
                 if (await _onWillPop()) Navigator.pop(context);
              },
            ),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- COMPLETION BAR ---
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(0xFF6A11CB).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text("Profile Completion", style: TextStyle(fontWeight: FontWeight.bold, color: textColor)),
                            Text("$percent%", style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF6A11CB))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: LinearProgressIndicator(
                            value: completion,
                            backgroundColor: Colors.grey[300],
                            color: const Color(0xFF6A11CB),
                            minHeight: 8,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 32),

                  // --- AVATAR ---
                  Center(
                    child: Stack(
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: Theme.of(context).cardColor, width: 4),
                            boxShadow: [
                               BoxShadow(color: Colors.blue.withOpacity(0.3), blurRadius: 20, offset: const Offset(0, 10))
                            ],
                          ),
                          child: CircleAvatar(
                            radius: 60,
                            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                            backgroundImage: backgroundImage,
                            child: backgroundImage == null
                                ? Icon(Icons.person, size: 60, color: Colors.grey[400])
                                : null,
                          ),
                        ),
                        Positioned(
                          bottom: 0, right: 0,
                          child: GestureDetector(
                            onTap: _pickImage,
                            child: Container(
                              padding: const EdgeInsets.all(10),
                              decoration: const BoxDecoration(color: Color(0xFF2575FC), shape: BoxShape.circle),
                              child: const Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                        if (hasImage)
                          Positioned(
                            top: 0, right: 0,
                            child: GestureDetector(
                              onTap: _removePhoto,
                              child: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.red.withOpacity(0.9), 
                                  shape: BoxShape.circle,
                                  border: Border.all(color: Theme.of(context).cardColor, width: 2)
                                ),
                                child: const Icon(Icons.delete_outline, color: Colors.white, size: 16),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 32),
                  Text('Personal Information', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: const Color(0xFF6A11CB))),
                  const SizedBox(height: 24),

                  _buildLabel('Full Name', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _nameController,
                    hint: 'Enter your name',
                    icon: Icons.person_outline_rounded,
                    isDark: isDark,
                    textCapitalization: TextCapitalization.words,
                    validator: (val) => val!.trim().isEmpty ? 'Name cannot be empty' : null,
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Email Address', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _emailController,
                    hint: 'email@example.com',
                    icon: Icons.email_outlined,
                    isDark: isDark,
                    readOnly: true, 
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Username (Handle)', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _usernameController,
                    hint: '@username',
                    icon: Icons.alternate_email_rounded,
                    isDark: isDark,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[a-z0-9._]')),
                    ],
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Phone Number', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _phoneController,
                    hint: '+91 98765 43210',
                    icon: Icons.phone_rounded,
                    isDark: isDark,
                    keyboardType: TextInputType.phone,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(15), 
                    ],
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Profession', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _professionController,
                    hint: 'e.g. Designer, Developer',
                    icon: Icons.work_outline_rounded,
                    isDark: isDark,
                    textCapitalization: TextCapitalization.words,
                  ),
                  const SizedBox(height: 20),

                  // --- LOCATION WITH DEBOUNCED AUTOCOMPLETE ---
                  _buildLabel('Location', isDark),
                  const SizedBox(height: 8),
                  Autocomplete<String>(
                    initialValue: TextEditingValue(text: _locationController.text),
                    optionsBuilder: (TextEditingValue textEditingValue) async {
                      // 🔹 Calls optimized debounced logic
                      return await _getLocationSuggestions(textEditingValue.text);
                    },
                    onSelected: (String selection) {
                      _locationController.text = selection;
                      FocusScope.of(context).unfocus();
                    },
                    fieldViewBuilder: (context, controller, focusNode, onFieldSubmitted) {
                      controller.addListener(() {
                        if (_locationController.text != controller.text) {
                          _locationController.text = controller.text;
                        }
                      });
                      
                      return _buildTextField(
                        controller: controller,
                        focusNode: focusNode,
                        onFieldSubmitted: onFieldSubmitted,
                        hint: 'Search City, Country...',
                        icon: Icons.location_on_outlined,
                        isDark: isDark,
                        textCapitalization: TextCapitalization.words,
                      );
                    },
                    optionsViewBuilder: (context, onSelected, options) {
                      return Align(
                        alignment: Alignment.topLeft,
                        child: Material(
                          elevation: 4.0,
                          borderRadius: BorderRadius.circular(16),
                          color: Theme.of(context).cardColor,
                          child: Container(
                            width: MediaQuery.of(context).size.width - 48,
                            constraints: const BoxConstraints(maxHeight: 200),
                            child: ListView.separated(
                              padding: EdgeInsets.zero,
                              shrinkWrap: true,
                              itemCount: options.length,
                              separatorBuilder: (context, index) => Divider(height: 1, color: isDark ? Colors.white10 : Colors.grey[200]),
                              itemBuilder: (context, index) {
                                final option = options.elementAt(index);
                                return ListTile(
                                  title: Text(option, style: TextStyle(color: isDark ? Colors.white : Colors.black87, fontSize: 13)),
                                  onTap: () => onSelected(option),
                                );
                              },
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  
                  _buildLabel('Date of Birth', isDark),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: () => _selectDate(context),
                    child: AbsorbPointer(
                      child: _buildTextField(
                        controller: _dobController,
                        hint: 'DD/MM/YYYY',
                        icon: Icons.cake_outlined,
                        isDark: isDark,
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _buildLabel('Bio / About Me', isDark),
                  const SizedBox(height: 8),
                  _buildTextField(
                    controller: _bioController,
                    hint: 'Tell us a bit about yourself...',
                    icon: Icons.info_outline_rounded,
                    isDark: isDark,
                    maxLines: 3,
                    maxLength: 150,
                    textCapitalization: TextCapitalization.sentences,
                  ),

                  const SizedBox(height: 40),

                  InkWell(
                    onTap: _isLoading ? null : _saveProfile,
                    borderRadius: BorderRadius.circular(18),
                    child: Container(
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFF6A11CB), Color(0xFF2575FC)]),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: [BoxShadow(color: const Color(0xFF2575FC).withOpacity(0.3), blurRadius: 12, offset: const Offset(0, 6))],
                      ),
                      child: Center(
                        child: _isLoading
                            ? const SizedBox(height: 24, width: 24, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                            : const Text('Save Changes', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLabel(String text, bool isDark) {
    return Text(text, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: isDark ? Colors.white70 : Colors.grey));
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    required bool isDark,
    FocusNode? focusNode,
    VoidCallback? onFieldSubmitted,
    TextInputType? keyboardType,
    int maxLines = 1,
    int? maxLength,
    String? Function(String?)? validator,
    List<TextInputFormatter>? inputFormatters,
    bool readOnly = false,
    TextCapitalization textCapitalization = TextCapitalization.none,
  }) {
    return TextFormField(
      controller: controller,
      focusNode: focusNode,
      onFieldSubmitted: (value) => onFieldSubmitted?.call(),
      style: TextStyle(color: readOnly ? Colors.grey : (isDark ? Colors.white : Colors.black)),
      keyboardType: keyboardType,
      maxLines: maxLines,
      maxLength: maxLength,
      readOnly: readOnly,
      inputFormatters: inputFormatters,
      textCapitalization: textCapitalization,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: Colors.grey[400]),
        prefixIcon: Icon(icon, color: isDark ? Colors.white60 : Colors.grey[600]),
        filled: true,
        fillColor: readOnly 
            ? (isDark ? Colors.white.withOpacity(0.05) : Colors.grey[100])
            : Theme.of(context).cardColor,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide(color: isDark ? Colors.white10 : Colors.grey[200]!),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: Color(0xFF2575FC)),
        ),
      ),
      validator: validator,
    );
  }
}