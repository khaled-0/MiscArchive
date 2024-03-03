class AuthorModel {
  String authorPageUrl;
  late String authorPagePrefix;

  String? authorName;
  String? authorAvatar;
  String? authorRole;
  String? authorDescription;

  String? registerDate;
  String? authorWebsite;
  String? authorPostCount;
  String? authorPoints;

  AuthorModel({
    this.authorName,
    this.authorAvatar,
    this.authorRole,
    required this.authorPageUrl,
    this.authorDescription,
    this.registerDate,
    this.authorWebsite,
    this.authorPostCount,
    this.authorPoints,
  }) {
    authorPagePrefix = authorPageUrl.replaceFirst("https://trickbd.com", "");
  }
}
