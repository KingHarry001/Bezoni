// File: lib/screens/preferences_screen.dart
import 'package:bezoni/themes/theme_extensions.dart';
import 'package:bezoni/services/app_state_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Preferences / Onboarding Screen
class PreferencesScreen extends StatefulWidget {
  const PreferencesScreen({super.key});

  @override
  State<PreferencesScreen> createState() => _PreferencesScreenState();
}

class _PreferencesScreenState extends State<PreferencesScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _addressController = TextEditingController();
  String _selectedFoodType = '';
  final List<String> _selectedAllergies = [];
  bool _isSaving = false;

  final List<String> _foodTypes = const [
    'Local',
    'Fast Food',
    'Vegan',
    'Seafood',
    'Healthy',
    'Desserts',
    'Chinese',
  ];

  final List<String> _allergies = const [
    'Nuts',
    'Dairy',
    'Gluten',
    'Shellfish',
    'Eggs',
    'Soy',
  ];

  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _loadExistingPreferences();
  }

  void _setupAnimations() {
    _anim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeInOut);
    _slide = Tween<Offset>(
      begin: const Offset(0, .08),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _anim, curve: Curves.easeOutCubic));
    _anim.forward();
  }

  Future<void> _loadExistingPreferences() async {
    final appState = AppStateService();
    if (appState.preferences != null) {
      setState(() {
        _addressController.text = appState.preferences!.address;
        _selectedFoodType = appState.preferences!.foodType ?? '';
        _selectedAllergies.addAll(appState.preferences!.allergies);
      });
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _anim.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      // Create preferences object
      final prefs = UserPreferences(
        userId: AppStateService().user?.id ?? '',
        address: _addressController.text.trim(),
        foodType: _selectedFoodType.isEmpty ? null : _selectedFoodType,
        allergies: List<String>.from(_selectedAllergies),
      );

      // Save to app state (this also saves to SharedPreferences)
      await AppStateService().savePreferences(prefs);

      // Haptic feedback
      HapticFeedback.lightImpact();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Preferences saved successfully!'),
          backgroundColor: context.successColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );

      // Navigate to home
      Navigator.pushReplacementNamed(context, '/home');
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error saving preferences: $e'),
          backgroundColor: context.errorColor,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isSmallScreen = MediaQuery.of(context).size.width < 360;

    return Scaffold(
      backgroundColor: context.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: context.textColor),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          // Skip button (only if coming from login/signup)
          TextButton(
            onPressed: () {
              // Skip preferences and go to home
              Navigator.pushReplacementNamed(context, '/home');
            },
            child: Text(
              'Skip',
              style: TextStyle(
                color: context.subtitleColor,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(isSmallScreen ? 16 : 20),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: isSmallScreen ? 4 : 8),
                    Text(
                      "Let's personalize your experience",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 20 : 22,
                        fontWeight: FontWeight.w800,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Set your preferences for faster, better deliveries.",
                      style: TextStyle(
                        fontSize: isSmallScreen ? 13 : 14,
                        color: context.subtitleColor,
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 18 : 22),
                    _sectionTitle("Delivery Address"),
                    const SizedBox(height: 10),
                    _decoratedField(
                      child: TextFormField(
                        controller: _addressController,
                        style: TextStyle(color: context.textColor),
                        maxLines: 2,
                        decoration: InputDecoration(
                          hintText: "Enter your delivery address",
                          hintStyle: TextStyle(
                            color: context.subtitleColor.withOpacity(0.6),
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              Icons.my_location,
                              color: context.primaryColor,
                            ),
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _addressController.text =
                                    "Herbert Macaulay Way, Yaba, Lagos";
                              });
                            },
                            tooltip: 'Use current location',
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your delivery address';
                          }
                          if (v.trim().length < 6) {
                            return 'Address looks too short';
                          }
                          return null;
                        },
                      ),
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 24),
                    _sectionTitle("What type of food do you enjoy?"),
                    const SizedBox(height: 4),
                    Text(
                      _selectedFoodType.isEmpty
                          ? "Select one (optional)"
                          : "Selected: $_selectedFoodType",
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _foodTypes
                          .map(
                            (t) => _choiceChip(
                              label: t,
                              selected: _selectedFoodType == t,
                              onTap: () => setState(() {
                                HapticFeedback.selectionClick();
                                _selectedFoodType =
                                    _selectedFoodType == t ? '' : t;
                              }),
                            ),
                          )
                          .toList(),
                    ),

                    SizedBox(height: isSmallScreen ? 20 : 24),
                    _sectionTitle("Any Allergies?"),
                    const SizedBox(height: 4),
                    Text(
                      _selectedAllergies.isEmpty
                          ? "None selected (optional)"
                          : _selectedAllergies.join(", "),
                      style: TextStyle(
                        fontSize: 12,
                        color: context.subtitleColor,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 10,
                      children: _allergies
                          .map(
                            (a) => _choiceChip(
                              label: a,
                              selected: _selectedAllergies.contains(a),
                              outlined: true,
                              onTap: () => setState(() {
                                HapticFeedback.selectionClick();
                                if (_selectedAllergies.contains(a)) {
                                  _selectedAllergies.remove(a);
                                } else {
                                  _selectedAllergies.add(a);
                                }
                              }),
                            ),
                          )
                          .toList(),
                    ),

                    SizedBox(height: isSmallScreen ? 24 : 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF10B981),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                          disabledBackgroundColor: Colors.grey[300],
                        ),
                        onPressed: _isSaving ? null : _submit,
                        child: _isSaving
                            ? const SizedBox(
                                height: 24,
                                width: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Continue",
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                      ),
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

  Widget _sectionTitle(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w700,
          color: context.textColor,
        ),
      );

  Widget _decoratedField({required Widget child}) {
    return Container(
      decoration: BoxDecoration(
        color: context.cardColor,
        border: Border.all(color: context.dividerColor),
        borderRadius: BorderRadius.circular(12),
      ),
      child: child,
    );
  }

  Widget _choiceChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
    bool outlined = false,
  }) {
    final Color primary = const Color(0xFF10B981);
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: selected && !outlined ? primary : context.cardColor,
          border: Border.all(
            color: selected ? primary : context.dividerColor,
            width: selected ? 2 : 1,
          ),
          borderRadius: BorderRadius.circular(10),
          boxShadow: selected
              ? [
                  BoxShadow(
                    color: primary.withOpacity(0.2),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  )
                ]
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
            color: selected && !outlined ? Colors.white : context.textColor,
          ),
        ),
      ),
    );
  }
}