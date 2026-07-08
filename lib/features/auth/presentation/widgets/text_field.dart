import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';

class CustomTextField extends StatelessWidget {
  final String label;
  final String hintText;
  final bool isPassword;
  final TextEditingController? controller;

  const CustomTextField({
    super.key,
    required this.label,
    required this.hintText,
    this.isPassword = false,
    this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            label,
            style: GoogleFonts.nunito(
              fontWeight: FontWeight.w800,
              fontSize: 14,
              color: AppColors.primary,
            ),
          ),
        ),
        TextField(
          controller: controller,
          obscureText: isPassword,
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: GoogleFonts.nunito(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: AppColors.hintText,
            ),
          ),
        ),
      ],
    );
  }
}
