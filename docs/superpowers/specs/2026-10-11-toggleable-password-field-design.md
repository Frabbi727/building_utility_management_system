# Specification: Toggleable Password Visibility

## 1. Overview
In the application's login screen, the password input field currently obscures the text unconditionally (`obscureText: true`) with no option to toggle visibility. Users cannot see what they have typed to verify their input before submitting. This specification defines an enhancement to `AppTextField` that introduces a built-in visibility toggle icon button when configured for passwords, and updates `LoginScreen` to use this feature.

## 2. Goals & Non-Goals
- **Goals**:
  - Allow users to toggle visibility between obscured (dots/stars) and plaintext password on `LoginScreen`.
  - Encapsulate visibility toggle functionality directly inside `AppTextField` via an `isPassword` boolean flag for clean reusability across screens.
  - Provide an accessible and intuitive eye icon (`Icons.visibility_off` when hidden, `Icons.visibility` when visible).
  - Maintain 100% backward compatibility for all existing parameters of `AppTextField` (`obscureText`, custom `suffixIcon`, etc.).
- **Non-Goals**:
  - Rewriting existing dialogs like `ChangePasswordDialog` that already have their own custom toggle behavior, unless explicitly needed.

## 3. Architecture & Design

### 3.1 `AppTextField` Component
- Converted from `StatelessWidget` to `StatefulWidget`.
- **New parameter**:
  - `final bool isPassword;` (defaults to `false`).
- **Internal State**:
  - `late bool _obscureText;` initialized in `initState()`:
    - If `widget.isPassword` is `true`, `_obscureText` defaults to `true`.
    - Otherwise, defaults to `widget.obscureText`.
- **Suffix Icon Logic**:
  - When `widget.isPassword` is `true`:
    - If `widget.suffixIcon` is provided, that custom icon takes precedence.
    - Otherwise, renders an `IconButton`:
      - `key: const Key('password_visibility_toggle')`
      - `icon: Icon(_obscureText ? Icons.visibility_off : Icons.visibility)`
      - `tooltip: _obscureText ? 'Show password' : 'Hide password'`
      - `onPressed: () => setState(() => _obscureText = !_obscureText)`
  - When `widget.isPassword` is `false`:
    - Uses `widget.suffixIcon` as passed.
- **Obscure Text in TextFormField**:
  - Configured with `obscureText: widget.isPassword ? _obscureText : widget.obscureText`.

### 3.2 `LoginScreen` Integration
- Replace `obscureText: true` on the password `AppTextField` with `isPassword: true`.
- Keep existing `key: const Key('password_field')` and `controller: controller.passwordController`.

## 4. Error Handling & Edge Cases
- When `isPassword` is true and text is entered, toggling visibility preserves the cursor position and does not clear controller input.
- Backwards compatibility: Existing usages of `AppTextField` passing `obscureText: false` or custom `suffixIcon` continue to function without alteration.

## 5. Testing & Verification
1. **Widget Tests in `test/core/widgets/app_text_field_test.dart`**:
   - `isPassword: true` starts with obscured text and renders `Icons.visibility_off`.
   - Tapping the toggle button reveals the text and switches the icon to `Icons.visibility`.
   - Tapping again obscures the text and switches back to `Icons.visibility_off`.
   - Standard text fields without `isPassword` retain expected default behavior.
2. **Widget Tests in `test/features/auth/presentation/screens/login_screen_test.dart`**:
   - Verify presence of the visibility toggle button on `password_field`.
   - Verify tapping the toggle button on `LoginScreen` toggles password visibility.
   - Verify that login still functions as expected with the entered password.
3. **Flutter Test Suite**:
   - Run `flutter test` across all affected test files.
