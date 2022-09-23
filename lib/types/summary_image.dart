class SummaryImage {
  SummaryImage({
    this.imageId,
    this.imageName = '',
    this.claimId,
    this.url,
    this.filePath,
    this.localFilePath,
  });

  final int imageId;
  final String imageName;
  final int claimId;
  final String url;
  final String filePath;
  final String localFilePath;

  SummaryImage copyWith({
    int imageId,
    String imageName,
    int claimId,
    String url,
    String filePath,
    String localFilePath,
  }) =>
      SummaryImage(
        imageId: imageId ?? this.imageId,
        imageName: imageName ?? this.imageName,
        claimId: claimId ?? this.claimId,
        url: url ?? this.url,
        filePath: filePath ?? this.filePath,
        localFilePath: localFilePath ?? this.localFilePath,
      );

  factory SummaryImage.fromJson(Map<String, dynamic> json) => SummaryImage(
        imageId: json["imageId"],
        imageName: json["imageName"],
        claimId: json["claimId"],
        url: json["url"],
        filePath: json["filePath"],
        localFilePath: '',
      );

  Map<String, dynamic> toJson() => {
        "imageId": imageId,
        "imageName": imageName,
        "claimId": claimId,
        "url": url,
        "filePath": filePath,
      };
}
