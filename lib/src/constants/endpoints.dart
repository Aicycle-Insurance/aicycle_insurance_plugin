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
}
