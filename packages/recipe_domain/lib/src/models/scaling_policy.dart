/// Policy determining how an ingredient or measurement scales with servings.
enum ScalingPolicy {
  /// Standard proportional scaling (quantity * target / base)
  scale,

  /// Fixed quantity regardless of servings (e.g. 1 pinch of salt, 1 bay leaf)
  fixed,

  /// Author-described "to taste" or qualitative measurement
  toTaste,

  /// Approximate scaling that indicates "~" or requires chef judgment
  approximate;

  static ScalingPolicy fromString(String? val) {
    switch (val?.toLowerCase()) {
      case 'fixed':
        return ScalingPolicy.fixed;
      case 'to_taste':
      case 'totaste':
        return ScalingPolicy.toTaste;
      case 'approximate':
        return ScalingPolicy.approximate;
      case 'scale':
      default:
        return ScalingPolicy.scale;
    }
  }

  String toDbString() {
    switch (this) {
      case ScalingPolicy.scale:
        return 'scale';
      case ScalingPolicy.fixed:
        return 'fixed';
      case ScalingPolicy.toTaste:
        return 'to_taste';
      case ScalingPolicy.approximate:
        return 'approximate';
    }
  }
}
