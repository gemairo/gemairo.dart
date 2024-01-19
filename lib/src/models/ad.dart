part of saaf.models;

class AdRequest {
  List<String> failedClasses;
  List<String> passedClasses;
  List<String> exclude;
  String platform;
  int saafVersion;

  AdRequest({
    this.failedClasses = const [],
    this.passedClasses = const [],
    this.exclude = const [],
    required this.platform,
    required this.saafVersion,
  });

  Map<String, dynamic> toJson() => {
        'failedClasses': this.failedClasses,
        'passedClasses': this.passedClasses,
        'exclude': this.exclude,
        'platform': this.platform,
        'saafVersion': this.saafVersion,
      };
}
