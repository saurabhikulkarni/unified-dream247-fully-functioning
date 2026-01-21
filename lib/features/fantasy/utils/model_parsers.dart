class ModelParsers {
  static int? toIntParser(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value);
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }

  static String? toStringParser(dynamic value) {
    if (value == null) return null;
    if (value is String) return value;
    if (value is int) {
      return value.toString();
    }
    if (value is double) {
      return value.toString();
    }
    return null;
  }

  static num? toNumParser(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }

  static bool? toBoolParser(dynamic value) {
    if (value == null) return null;
    if (value is bool) return value;
    if (value is String) {
      String lowerValue = value.trim().toLowerCase();
      if (lowerValue == 'true' || lowerValue == '1') return true;
      if (lowerValue == 'false' || lowerValue == '0') return false;
    }
    if (value is num) return value == 1;
    return null;
  }

  static double? toDoubleParser(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value.trim());
    return null;
  }
}
