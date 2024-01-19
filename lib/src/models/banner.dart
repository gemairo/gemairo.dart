part of saaf.models;

class BannerAd {
  final String id;
  final String title;
  final String subtitle;
  final String description;
  final String image;
  final bool imageOnly;
  final double score;

  BannerAd.fromJson(Map json)
      : id = json["id"],
        title = json["title"],
        subtitle = json["subtitle"],
        description = json["description"],
        image = json["image"],
        imageOnly = json["imageOnly"],
        score = json["score"];
}

class BannerAdStyle {
  final Color backgroundColor;
  final Color primaryColor;
  final Color titleColor;
  final Color textColor;
  final int titleMaxLines;
  final int subtitleMaxLines;

  const BannerAdStyle({
    this.backgroundColor = const Color.fromRGBO(255, 255, 255, 1),
    this.primaryColor = const Color.fromRGBO(79, 70, 229, 1),
    this.titleColor = const Color.fromRGBO(0, 0, 0, 1),
    this.textColor = const Color.fromARGB(255, 32, 32, 32),
    this.titleMaxLines = 2,
    this.subtitleMaxLines = 2,
  });
}

class BannerAdResponse {
  final String requestId;
  final BannerAd banner;

  BannerAdResponse.fromJson(Map json)
      : requestId = json["requestId"],
        banner = BannerAd.fromJson(json["banner"]);
}
