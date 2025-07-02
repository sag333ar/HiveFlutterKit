 double extractNumber(String value) {
    RegExp regex = RegExp(r'(\d+\.?\d*)');
    Match? match = regex.firstMatch(value);
    if (match != null) {
      return double.parse(match.group(1)!);
    }
    return 0.0;
  }