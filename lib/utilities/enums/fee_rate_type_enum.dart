enum FeeRateType { fast, average, slow, custom }

extension FeeRateTypeExt on FeeRateType {
  String get prettyName {
    switch (this) {
      case FeeRateType.fast:
        return "Fast";
      case FeeRateType.average:
        return "Average";
      case FeeRateType.slow:
        return "Slow";
      case FeeRateType.custom:
        return "Custom";
    }
  }
}
