import 'package:flutter/material.dart';

class AppColors {
  // Brilliant-inspired dark theme
  static const Color bgPrimary = Color(0xFF0D1117);
  static const Color bgSecondary = Color(0xFF161B22);
  static const Color bgTertiary = Color(0xFF21262D);
  static const Color bgCard = Color(0xFF161B22);
  static const Color bgCardHover = Color(0xFF1F242B);

  // Accent colors (Brilliant uses purple/blue as primary)
  static const Color accentPrimary = Color(0xFF8B5CF6);
  static const Color accentPrimaryLight = Color(0xFFA78BFA);
  static const Color accentPrimaryDark = Color(0xFF7C3AED);
  static const Color accentPrimarySoft = Color(0xFF2E1B4E);

  static const Color accentSecondary = Color(0xFF06B6D4);
  static const Color accentSecondaryLight = Color(0xFF22D3EE);
  static const Color accentSecondaryDark = Color(0xFF0891B2);
  static const Color accentSecondarySoft = Color(0xFF164E63);

  static const Color accentSuccess = Color(0xFF10B981);
  static const Color accentSuccessLight = Color(0xFF34D399);
  static const Color accentSuccessSoft = Color(0xFF064E3B);
  static const Color accentWarning = Color(0xFFF59E0B);
  static const Color accentWarningLight = Color(0xFFFBBF24);
  static const Color accentWarningSoft = Color(0xFF78350F);
  static const Color accentError = Color(0xFFEF4444);
  static const Color accentErrorSoft = Color(0xFF7F1D1D);

  // Text colors
  static const Color textPrimary = Color(0xFFF0F6FC);
  static const Color textSecondary = Color(0xFF8B949E);
  static const Color textMuted = Color(0xFF6E7681);
  static const Color textOnAccent = Color(0xFF0D1117);

  // Border
  static const Color borderDefault = Color(0xFF30363D);
  static const Color borderMuted = Color(0xFF21262D);
  static const Color borderAccent = Color(0xFF8B5CF6);

  // Legacy aliases for migration
  static const Color aquaBlue = accentSecondary;
  static const Color aquaBlueLight = accentSecondaryLight;
  static const Color aquaBlueDark = accentSecondaryDark;
  static const Color aquaBlueSoft = accentSecondarySoft;

  static const Color coralRed = accentWarning;
  static const Color coralRedLight = Color(0xFFFBBF24);
  static const Color coralRedDark = Color(0xFFB45309);
  static const Color coralRedSoft = accentWarningSoft;

  static const Color ink = textPrimary;
  static const Color paper = bgPrimary;
  static const Color mint = accentSuccess;
  static const Color mintSoft = accentSuccessSoft;
  static const Color orange = accentWarning;
  static const Color orangeSoft = accentWarningSoft;
  static const Color yellowSoft = accentWarningSoft;
  static const Color blue = accentSecondary;
  static const Color blueSoft = accentSecondarySoft;

  static const Color white = Colors.white;
  static const Color black = Colors.black;
  static const Color grey50 = Color(0xFFF0F6FC);
  static const Color grey100 = Color(0xFFE6EDF3);
  static const Color grey200 = Color(0xFF8B949E);
  static const Color grey300 = Color(0xFF6E7681);
  static const Color grey400 = Color(0xFF484F58);
  static const Color grey500 = Color(0xFF30363D);
  static const Color grey600 = Color(0xFF21262D);
  static const Color grey700 = Color(0xFF161B22);
  static const Color grey800 = Color(0xFF0D1117);
  static const Color grey900 = Color(0xFF0D1117);

  static const Color success = accentSuccess;
  static const Color warning = accentWarning;
  static const Color error = accentError;
  static const Color info = accentSecondary;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPrimary, accentSecondary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [bgCard, bgTertiary],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [accentPrimary, accentPrimaryLight],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppSpacing {
  static const double xs = 4;
  static const double sm = 8;
  static const double md = 16;
  static const double lg = 24;
  static const double xl = 32;
  static const double xxl = 48;
}

class AppRadius {
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 20;
  static const double xxl = 28;
  static const double round = 999;
}

class AppShadows {
  static const List<BoxShadow> card = [
    BoxShadow(
      color: Color(0x33000000),
      blurRadius: 16,
      offset: Offset(0, 4),
    ),
  ];

  static const List<BoxShadow> cardElevated = [
    BoxShadow(
      color: Color(0x4D000000),
      blurRadius: 24,
      offset: Offset(0, 8),
    ),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}