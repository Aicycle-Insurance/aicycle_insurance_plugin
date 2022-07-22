class Endpoints {
  Endpoints._();

  /// API Dev
  static const String baseUrl = 'https://dev-api-insurance.aicycle.ai';

  /// API Prod
  // static const String baseUrl = 'https://api-insurance.aicycle.ai';
  static const String createClaimFolder = baseUrl + '/claimfolders';
  static String getUploadUrl = baseUrl + '/images/url';

  // summary image
  static const String addSummaryImageToClaim = baseUrl + '/claimimages/summary';
  static String getSummaryImages(String sessionId) =>
      baseUrl + '/session/$sessionId/summaries';
  static String deleteSummaryImage(String imageId) =>
      baseUrl + '/claimimages/summary/$imageId';

  // part image
  static String deleteAllImageInClaim(String claimID) =>
      baseUrl + '/claimimages/all/$claimID';
  static String deleteImageInCLaim(String imageID) =>
      baseUrl + '/claimimages/$imageID';
  // call engine
  static String callEngineAfterTakePhoto =
      baseUrl + '/claimimages/damage-assessment';
}
