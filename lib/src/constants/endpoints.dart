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
  static String getImageInCLaim(String sessionID) =>
      baseUrl + '/session/$sessionID/all-images';
  // call engine
  static String callEngineAfterTakePhoto =
      baseUrl + '/claimimages/damage-assessment';
  static String runEnginePercent =
      baseUrl + '/claimimages/run_engine_percentage/';
  static String callEngineAfterUserEdit(String imageId) =>
      baseUrl + '/claimimages/$imageId/damage-reassessment';

  // Truyền thông tin từ phía API tới BE
  static String postPTIInformation = baseUrl + '/session/session-info';
}
