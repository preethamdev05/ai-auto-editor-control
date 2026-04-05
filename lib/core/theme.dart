import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  static const _cardRadius = 12.0;
  static const _buttonRadius = 10.0;

  static const _primaryColor = Color(0xFF6C5CE7);
  static const _primaryVariant = Color(0xFFA29BFE);
  static const _successColor = Color(0xFF00B894);
  static const _warningColor = Color(0xFFFDCB6E);
  static const _errorColor = Color(0xFFE17055);
  static const _infoColor = Color(0xFF74B9FF);

  static const _surfaceDark = Color(0xFF1E1E2E);
  static const _surfaceDarkElevated = Color(0xFF282840);
  static const _backgroundDark = Color(0xFF13131F);
  static const _textPrimaryDark = Color(0xFFEAEAFF);
  static const _textSecondaryDark = Color(0xFF9595B0);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.dark(
        primary: _primaryColor,
        secondary: _primaryVariant,
        surface: _surfaceDark,
        background: _backgroundDark,
        error: _errorColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: _textPrimaryDark,
        onBackground: _textPrimaryDark,
        onError: Colors.white,
      ),
      scaffoldBackgroundColor: _backgroundDark,
      cardTheme: CardThemeData(
        color: _surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.3),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: _backgroundDark,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: _textPrimaryDark,
          fontSize: 20,
          fontWeight: FontWeight.w600,
          fontFamily: 'Inter',
        ),
        iconTheme: IconThemeData(color: _textPrimaryDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: _primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: _primaryVariant,
          side: const BorderSide(color: _primaryVariant, width: 1.5),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_buttonRadius)),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: _primaryVariant,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: _surfaceDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF353555)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: Color(0xFF353555)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _primaryColor, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: _errorColor),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        labelStyle: const TextStyle(color: _textSecondaryDark),
        hintStyle: const TextStyle(color: _textSecondaryDark, fontSize: 14),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected) ? _primaryColor : _textSecondaryDark,
        ),
        trackColor: WidgetStateProperty.resolveWith(
          (states) => states.contains(WidgetState.selected)
              ? _primaryColor.withOpacity(0.3)
              : Color(0xFF353555),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: _surfaceDark,
        selectedColor: _primaryColor.withOpacity(0.2),
        labelStyle: const TextStyle(color: _textPrimaryDark, fontSize: 13),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: _primaryColor,
        linearTrackColor: Color(0xFF353555),
      ),
      dividerTheme: const DividerThemeData(
        color: Color(0xFF2A2A40),
        thickness: 1,
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: _surfaceDark,
        selectedItemColor: _primaryColor,
        unselectedItemColor: _textSecondaryDark,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500),
        unselectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w400),
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: _surfaceDarkElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(_cardRadius)),
        titleTextStyle: const TextStyle(
          color: _textPrimaryDark,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      snackBarTheme: const SnackBarThemeData(
        backgroundColor: _surfaceDarkElevated,
        contentTextStyle: TextStyle(color: _textPrimaryDark, fontSize: 14),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(8))),
      ),
    );
  }

  static Color get primary => _primaryColor;
  static Color get primaryVariant => _primaryVariant;
  static Color get success => _successColor;
  static Color get warning => _warningColor;
  static Color get error => _errorColor;
  static Color get info => _infoColor;
}
