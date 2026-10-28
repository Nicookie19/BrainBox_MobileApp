import 'package:flutter/material.dart';

class AppColors {
  // Updated BrainBox UI: deep-blue learning surfaces, with mint progress and
  // coral achievement accents from the supplied product design.
  static const Color bgPrimary = Color(0xFF091032);
  static const Color bgSecondary = Color(0xFF172258);
  static const Color bgTertiary = Color(0xFF3D4880);
  static const Color bgCard = Color(0xFF15236E);
  static const Color bgCardHover = Color(0xFF26377F);

  static const Color accentPrimary = Color(0xFF00EBC4);
  static const Color accentPrimaryLight = Color(0xFF16DEBD);
  static const Color accentPrimaryDark = Color(0xFF008D79);
  static const Color accentPrimarySoft = Color(0xFF123E55);

  static const Color accentSecondary = Color(0xFF6E7ECB);
  static const Color accentSecondaryLight = Color(0xFF9EA9EE);
  static const Color accentSecondaryDark = Color(0xFF404E9B);
  static const Color accentSecondarySoft = Color(0xFF202E71);

  static const Color accentSuccess = Color(0xFF00EBC4);
  static const Color accentSuccessLight = Color(0xFF52F5D8);
  static const Color accentSuccessSoft = Color(0xFF123E55);
  static const Color accentWarning = Color(0xFFDB314E);
  static const Color accentWarningLight = Color(0xFFFF7C92);
  static const Color accentWarningSoft = Color(0xFF5A1C38);
  static const Color accentError = Color(0xFFDB314E);
  static const Color accentErrorSoft = Color(0xFF5A1C38);

  // Text colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFC3C7DA);
  static const Color textMuted = Color(0xFF9A9CAC);
  static const Color textOnAccent = Color(0xFFFFFFFF);

  // Border
  static const Color borderDefault = Color(0x1FFFFFFF);
  static const Color borderMuted = Color(0x12FFFFFF);
  static const Color borderAccent = Color(0xFF00EBC4);

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
  static const Color grey100 = Color(0xFFDDE4FF);
  static const Color grey200 = Color(0xFFAEB8E3);
  static const Color grey300 = Color(0xFF7180B8);
  static const Color grey400 = Color(0xFF45568E);
  static const Color grey500 = Color(0xFF283975);
  static const Color grey600 = Color(0xFF17245A);
  static const Color grey700 = Color(0xFF111E59);
  static const Color grey800 = Color(0xFF0C174A);
  static const Color grey900 = Color(0xFF080F38);

  static const Color success = accentSuccess;
  static const Color warning = accentWarning;
  static const Color error = accentError;
  static const Color info = accentSecondary;

  static const LinearGradient primaryGradient = LinearGradient(
    colors: [accentPrimary, accentWarning],
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
    BoxShadow(color: Color(0x33000000), blurRadius: 16, offset: Offset(0, 4)),
  ];

  static const List<BoxShadow> cardElevated = [
    BoxShadow(color: Color(0x4D000000), blurRadius: 24, offset: Offset(0, 8)),
  ];

  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 4),
    ),
  ];
}
