class Endpoints {
  Endpoints._();
  static const String baseUrl = 'https://dev-api-insurance.aicycle.ai';
  static const String createClaimFolder = baseUrl + '/claimfolders';
  static String getUploadUrl = baseUrl + '/images/url';

  // summary image
  static const String addSummaryImageToClaim = baseUrl + '/claimimages/summary';
  static String getSummaryImages(String claimID) =>
      baseUrl + '/claimfolders/$claimID/summaries';
  static String deleteSummaryImage(String imageId) =>
      baseUrl + '/claimimages/summary/$imageId';

  // part image
  static String deleteAllImageInClaim(String claimID) =>
      baseUrl + '/claimimages/all/$claimID';
  static String deleteImageInCLaim(String imageID) =>
      baseUrl + '/claimimages/$imageID';
}
