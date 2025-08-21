import 'package:flutter/material.dart';

class ReferralCodeInput extends StatelessWidget {
  final TextEditingController? controller;

  const ReferralCodeInput({super.key, this.controller});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Referral Code (Optional)",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: 'Enter Referral Code',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
          ),
          validator: (value) {
            return null; // optional
          },
        ),
      ],
    );
  }
}

class GenderDropdown extends StatelessWidget {
  final String? value;
  final Function(String?) onChanged;

  const GenderDropdown({
    super.key,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<String> genders = ['Male', 'Female'];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Gender",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        DropdownButtonFormField<String>(
          value: value,
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
          items: genders.map((String category) {
            return DropdownMenuItem<String>(
              value: category,
              child: Text(category),
            );
          }).toList(),
          onChanged: onChanged,
          validator: (value) =>
              value == null ? 'Please select your Gender' : null,
        ),
      ],
    );
  }
}

class BirthdayInput extends StatelessWidget {
  final TextEditingController controller;

  const BirthdayInput({Key? key, required this.controller}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Birthday",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black87,
          ),
        ),
        SizedBox(height: 8),
        TextFormField(
          controller: controller,
          readOnly: true,
          decoration: InputDecoration(
            hintText: 'Select Your Birthday',
            filled: true,
            fillColor: Colors.grey[50],
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            suffixIcon: Icon(Icons.calendar_today, color: Colors.grey[600]),
          ),
          onTap: () async {
            DateTime? pickedDate = await showDatePicker(
              context: context,
              initialDate: DateTime.now(),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (pickedDate != null) {
              controller.text =
                  "${pickedDate.day}/${pickedDate.month}/${pickedDate.year}";
            }
          },
          validator: (value) => value == null || value.isEmpty
              ? 'Please select your birthday'
              : null,
        ),
      ],
    );
  }
}
