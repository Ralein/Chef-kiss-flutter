enum AssetApprovalState {
  bundled,
  approved,
  candidate,
  rejected;
}

class IllustrationAsset {
  final String id;
  final String canonicalKey;
  final String displayName;
  final List<String> matchKeywords;
  final int iconCodePoint;
  final String category;
  final AssetApprovalState approvalState;

  const IllustrationAsset({
    required this.id,
    required this.canonicalKey,
    required this.displayName,
    required this.matchKeywords,
    required this.iconCodePoint,
    required this.category,
    this.approvalState = AssetApprovalState.bundled,
  });
}
