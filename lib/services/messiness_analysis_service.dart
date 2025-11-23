/// Service for analyzing room messiness (ML Kit removed)
/// Returns neutral score since ML Kit is disabled
class MessinessAnalysisService {
  /// Initialize (no-op)
  Future<void> initialize() async {}

  /// Analyze messiness - returns neutral score (ML Kit removed)
  Future<double> analyzeMessiness(String imagePath) async {
    return 5.0; // Neutral score
  }

  /// Dispose (no-op)
  void dispose() {}
}
