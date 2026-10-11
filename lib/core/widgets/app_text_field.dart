import 'package:flutter/material.dart';
import '../theme/app_dimens.dart';

class AppTextField extends StatefulWidget {
  final String labelText;
  final TextEditingController? controller;
  final bool obscureText;
  final bool isPassword;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final ValueChanged<String>? onChanged;
  final String? Function(String?)? validator;

  const AppTextField({
    super.key,
    required this.labelText,
    this.controller,
    this.obscureText = false,
    this.isPassword = false,
    this.keyboardType,
    this.textInputAction,
    this.prefixIcon,
    this.suffixIcon,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late bool _obscureText;

  @override
  void initState() {
    super.initState();
    _obscureText = widget.isPassword ? true : widget.obscureText;
  }

  @override
  void didUpdateWidget(covariant AppTextField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isPassword != oldWidget.isPassword) {
      _obscureText = widget.isPassword ? true : widget.obscureText;
    } else if (!widget.isPassword && oldWidget.obscureText != widget.obscureText) {
      _obscureText = widget.obscureText;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget? effectiveSuffixIcon = widget.suffixIcon;
    if (effectiveSuffixIcon == null && widget.isPassword) {
      effectiveSuffixIcon = IconButton(
        key: const Key('password_visibility_toggle'),
        icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility),
        tooltip: _obscureText ? 'Show password' : 'Hide password',
        onPressed: () => setState(() => _obscureText = !_obscureText),
      );
    }

    return TextFormField(
      controller: widget.controller,
      obscureText: widget.isPassword ? _obscureText : widget.obscureText,
      keyboardType: widget.keyboardType,
      textInputAction: widget.textInputAction,
      onChanged: widget.onChanged,
      validator: widget.validator,
      decoration: InputDecoration(
        labelText: widget.labelText,
        prefixIcon: widget.prefixIcon,
        suffixIcon: effectiveSuffixIcon,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(AppDimens.r8)),
      ),
    );
  }
}

