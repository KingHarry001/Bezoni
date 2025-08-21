import 'package:flutter/material.dart';
import 'package:bezoni/components/input.dart';

// Business Signup Screen
class BusinessSignupScreen extends StatefulWidget {
  @override
  _BusinessSignupScreenState createState() => _BusinessSignupScreenState();
}

class _BusinessSignupScreenState extends State<BusinessSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _brandNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedCategory;

  final List<String> _categories = [
    'Restaurant',
    'Grocery Store',
    'Pharmacy',
    'Electronics',
    'Clothing',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: _buildAppBar(),
      body: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(height: 20),
                Text(
                  'Grow Your Business—\nDeliver More with Bezoni!',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                    height: 1.2,
                  ),
                ),
                SizedBox(height: 40),
                _buildInputField(
                  label: 'Brand Name',
                  controller: _brandNameController,
                  placeholder: 'Enter Your Brand Name',
                ),
                SizedBox(height: 24),
                _buildCategoryDropdown(),
                SizedBox(height: 24),
                _buildInputField(
                  label: 'Email Address',
                  controller: _emailController,
                  placeholder: 'Enter Your Email Address',
                  keyboardType: TextInputType.emailAddress,
                ),
                SizedBox(height: 24),
                _buildInputField(
                  label: 'Password',
                  controller: _passwordController,
                  placeholder: 'Enter Your Password',
                  isPassword: true,
                ),
                SizedBox(height: 40),
                _buildSignUpButton(),
                SizedBox(height: 16),
                _buildLoginLink(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: Text("Business Signup", style: TextStyle(color: Colors.black)),
      backgroundColor: Colors.white,
      elevation: 0,
      iconTheme: IconThemeData(color: Colors.black),
    );
  }

  Widget _buildCategoryDropdown() {
    return DropdownButtonFormField<String>(
      value: _selectedCategory,
      hint: Text('Select Category', style: TextStyle(color: Colors.grey[400])),
      decoration: InputDecoration(
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey[300]!),
        ),
      ),
      items: _categories.map((String category) {
        return DropdownMenuItem<String>(value: category, child: Text(category));
      }).toList(),
      onChanged: (String? newValue) {
        setState(() => _selectedCategory = newValue);
      },
      validator: (value) => value == null ? 'Please select a category' : null,
    );
  }

  Widget _buildSignUpButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: () {
          if (_formKey.currentState!.validate()) {
            Navigator.pushNamed(context, '/success');
          }
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          'Sign Up',
          style: TextStyle(color: Colors.white, fontSize: 16),
        ),
      ),
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          "Already have an account? ",
          style: TextStyle(color: Colors.grey[600]),
        ),
        TextButton(
          onPressed: () => Navigator.pushNamed(context, '/business-login'),
          child: Text(
            'Login',
            style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
          ),
        ),
      ],
    );
  }

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            hintStyle: TextStyle(color: Colors.grey[400]),
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'This field is required';
            }
            if (keyboardType == TextInputType.emailAddress &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            if (isPassword && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Customer Signup Screen
class CustomerSignupScreen extends StatefulWidget {
  @override
  _CustomerSignupScreenState createState() => _CustomerSignupScreenState();
}

class _CustomerSignupScreenState extends State<CustomerSignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _birthdayController = TextEditingController();
  String? _selectedGender;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Join the Bezoni Family—\nSign Up for Seamless Deliveries!',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        height: 1.2,
                      ),
                    ),
                    SizedBox(height: 40),
                    _buildInputField(
                      label: 'Full Name',
                      controller: _nameController,
                      placeholder: 'Enter Your Full Name',
                    ),
                    SizedBox(height: 24),
                    _buildInputField(
                      label: 'Email Address',
                      controller: _emailController,
                      placeholder: 'Enter Your Email Address',
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 24),
                    _buildInputField(
                      label: 'Password',
                      controller: _passwordController,
                      placeholder: 'Enter Your Password',
                      isPassword: true,
                    ),
                    SizedBox(height: 24),
                    GenderDropdown(
                      value: _selectedGender,
                      onChanged: (value) {
                        setState(() => _selectedGender = value);
                      },
                    ),
                    SizedBox(height: 24),
                    BirthdayInput(controller: _birthdayController),
                    SizedBox(height: 40),
                    ReferralCodeInput(),
                    SizedBox(height: 40),
                    _buildSignUpButton(),
                    SizedBox(height: 16),
                    _buildLoginLink(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSignUpButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          Navigator.pushNamed(context, '/success');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Sign Up',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );

  Widget _buildLoginLink() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Already have an account?",
        style: TextStyle(color: Colors.grey[600]),
      ),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/delivery-login'),
        child: Text(
          'Login',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (keyboardType == TextInputType.emailAddress &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            if (isPassword && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}

// Delivery Signup Screen
class DeliverySignupScreen extends StatefulWidget {
  @override
  _DeliverySignupScreenState createState() => _DeliverySignupScreenState();
}

class _DeliverySignupScreenState extends State<DeliverySignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  String? _selectedGender;

  final List<String> _gender = ['Male', 'Female'];

  Widget _buildGenderDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender", // 👈 same style as other labels
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: _selectedGender,
          hint: Text(
            'Select Gender',
            style: TextStyle(color: Colors.grey[400]),
          ),
          decoration: InputDecoration(
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          items: _gender.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() => _selectedGender = newValue);
          },
          validator: (value) =>
              value == null ? 'Please select your Gender' : null,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Delivery Signup", style: TextStyle(color: Colors.black)),
        backgroundColor: Colors.white,
        elevation: 0,
        iconTheme: IconThemeData(color: Colors.black),
      ),
      body: Padding(
        padding: EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Ride, Earn, Repeat—Join\nBezoni\'s Delivery Team!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.black,
                  height: 1.2,
                ),
              ),
              SizedBox(height: 40),
              _buildInputField(
                label: 'Name',
                controller: _nameController,
                placeholder: 'Enter Your Full Name',
              ),
              SizedBox(height: 24),
              _buildInputField(
                label: 'Email',
                controller: _emailController,
                placeholder: 'Enter Your Email',
                keyboardType: TextInputType.emailAddress,
              ),
              SizedBox(height: 24),
              _buildInputField(
                label: 'Password',
                controller: _passwordController,
                placeholder: 'Enter Your Password',
                isPassword: true,
              ),
              SizedBox(height: 24),
              _buildGenderDropdown(),
              SizedBox(height: 40),
              _buildSignUpButton(),
              SizedBox(height: 16),
              _buildLoginLink(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSignUpButton() => SizedBox(
    width: double.infinity,
    height: 56,
    child: ElevatedButton(
      onPressed: () {
        if (_formKey.currentState!.validate()) {
          Navigator.pushNamed(context, '/success');
        }
      },
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        'Sign Up',
        style: TextStyle(color: Colors.white, fontSize: 16),
      ),
    ),
  );

  Widget _buildLoginLink() => Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      Text(
        "Already have an account?",
        style: TextStyle(color: Colors.grey[600]),
      ),
      TextButton(
        onPressed: () => Navigator.pushNamed(context, '/delivery-login'),
        child: Text(
          'Login',
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w600),
        ),
      ),
    ],
  );

  Widget _buildInputField({
    required String label,
    required TextEditingController controller,
    required String placeholder,
    TextInputType? keyboardType,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: placeholder,
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          validator: (value) {
            if (value == null || value.isEmpty) return 'This field is required';
            if (keyboardType == TextInputType.emailAddress &&
                !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email';
            }
            if (isPassword && value.length < 6) {
              return 'Password must be at least 6 characters';
            }
            return null;
          },
        ),
      ],
    );
  }
}
