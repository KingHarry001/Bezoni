import 'package:bezoni/themes/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Data passed from Preferences -> Home
class UserPreferences {
  final String address;
  final String? foodType;
  final List<String> allergies;

  const UserPreferences({
    required this.address,
    this.foodType,
    required this.allergies,
  });
}

/// =====================
/// Preferences / Onboarding
/// =====================
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

  @override
  void dispose() {
    _addressController.dispose();
    _anim.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;

    final prefs = UserPreferences(
      address: _addressController.text.trim(),
      foodType: _selectedFoodType.isEmpty ? null : _selectedFoodType,
      allergies: List<String>.from(_selectedAllergies),
    );

    HapticFeedback.lightImpact();
    Navigator.pushReplacementNamed(
      context,
      '/home',
      arguments: prefs,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.backgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 8),
                    Text(
                      "Let's personalize your experience",
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                        color: context.textColor,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Set your preferences for faster, better deliveries.",
                      style: TextStyle(
                        fontSize: 14,
                        color: context.subtitleColor,
                      ),
                    ),

                    const SizedBox(height: 22),
                    _sectionTitle("Address"),
                    const SizedBox(height: 10),
                    _decoratedField(
                      child: TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          hintText: "Enter your address",
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 14,
                          ),
                          suffixIcon: TextButton(
                            onPressed: () {
                              HapticFeedback.lightImpact();
                              setState(() {
                                _addressController.text =
                                    "Herbert Macaulay Way, Yaba, Lagos";
                              });
                            },
                            child: const Text(
                              "Use Current Location",
                              style: TextStyle(color: Color(0xFF10B981)),
                            ),
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.trim().isEmpty) {
                            return 'Please enter your address';
                          }
                          if (v.trim().length < 6) {
                            return 'Address looks too short';
                          }
                          return null;
                        },
                      ),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("What type of food do you enjoy?"),
                    const SizedBox(height: 4),
                    Text(
                      "Select one",
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
                                _selectedFoodType = _selectedFoodType == t
                                    ? ''
                                    : t;
                              }),
                            ),
                          )
                          .toList(),
                    ),

                    const SizedBox(height: 24),
                    _sectionTitle("Any Allergies"),
                    const SizedBox(height: 4),
                    Text(
                      _selectedAllergies.isEmpty
                          ? "None selected"
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

                    const SizedBox(height: 28),
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
                        ),
                        onPressed: _submit,
                        child: const Text(
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
            color: selected && !outlined
                ? Colors.white
                : context.textColor,
          ),
        ),
      ),
    );
  }
}