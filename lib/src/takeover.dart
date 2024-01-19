part of saaf;

class TakeoverAd {
  final AdRequest request;
  final TakeoverAdStyle style;
  final Function(AdRequest request)? onLoad;
  final Function(TakeoverAdResponse response)? onImpression;
  final Function(TakeoverAdResponse response)? onClick;
  final Function(TakeoverAdResponse response) onReport;
  final String baseUrl;

  TakeoverAdResponse? adResponse;

  bool get isLoaded => this.adResponse is TakeoverAdResponse;

  TakeoverAd({
    Key? key,
    required this.request,
    this.style = const TakeoverAdStyle(),
    this.onLoad,
    this.onImpression,
    this.onClick,
    required this.onReport,
    this.baseUrl = "https://saaf-api.gemairo.app/api/v1/saaf",
  }) : super();

  Future<TakeoverAdResponse> load() async {
    if (this.onLoad != null) this.onLoad!(this.request);
    print(json.encode(this.request.toJson()));
    final response = await http.post(
      Uri.parse("${this.baseUrl}/takeovers/query"),
      body: json.encode(this.request.toJson()),
      headers: {'Content-Type': 'application/json'},
    );
    if (response.statusCode != 201) {
      print(response.request?.url);
      print(response.body);
      throw new Exception('failed to load ad');
    }
    this.adResponse = TakeoverAdResponse.fromJson(json.decode(response.body));

    return this.adResponse!;
  }

  Future<void> show(context) async {
    if (!this.isLoaded) {
      throw Exception('Takeover not loaded');
    }

    this._impression(adResponse);

    await showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black.withOpacity(.75),
      builder: (_) => TakeoverAdWidget(
        adResponse: this.adResponse!,
        style: this.style,
        onClick: this._click,
        onReport: this.onReport,
      ),
    );
  }

  void _impression(TakeoverAdResponse? adResponse) async {
    if (adResponse == null) return;

    if (this.onImpression != null) this.onImpression!(adResponse);

    await http.post(
      Uri.parse(
          "${this.baseUrl}/impressions/takeovers/${adResponse.requestId}"),
      body: json.encode({
        "app": "statsfm",
        "platform": Platform.operatingSystem,
      }),
      headers: {'Content-Type': 'application/json'},
    );
  }

  void _click(TakeoverAdResponse? adResponse, BuildContext context) async {
    if (adResponse == null) return;

    if (this.onClick != null) this.onClick!(adResponse);

    if (adResponse.takeover.inAppNavigate is! String) {
      launchUrl(
        Uri.parse("${this.baseUrl}/clicks/takeovers/${adResponse.requestId}"),
        mode: LaunchMode.externalApplication,
      );
    } else {
      await http.get(
        Uri.parse("${this.baseUrl}/clicks/takeovers/${adResponse.requestId}"),
      );
    }

    Navigator.of(context).pop();
  }
}

class TakeoverAdWidget extends StatelessWidget {
  final TakeoverAdResponse adResponse;
  final TakeoverAdStyle style;
  final Function(TakeoverAdResponse response, BuildContext context)? onClick;
  final Function(TakeoverAdResponse response) onReport;

  TakeoverAdWidget({
    Key? key,
    required this.adResponse,
    this.style = const TakeoverAdStyle(),
    this.onClick,
    required this.onReport,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Center(
        child: ListView(
          shrinkWrap: true,
          // mainAxisAlignment: MainAxisAlignment.center,
          // crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.symmetric(horizontal: 35, vertical: 15),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: this.style.backgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  SizedBox(height: 10),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 10),
                    child: Text(
                      this.adResponse.takeover.shout,
                      style: Theme.of(context)
                          .textTheme
                          .titleLarge!
                          .copyWith(fontWeight: FontWeight.w600),
                      // style: TextStyle(
                      //   fontWeight: FontWeight.bold,
                      //   fontFamily: "StatsfmSans",
                      //   fontSize: 19,
                      //   color: this.style.titleColor,
                      // ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  SizedBox(height: 25),
                  ConstrainedBox(
                    constraints: BoxConstraints(
                      maxHeight: 500,
                      minHeight: 100,
                      maxWidth: MediaQuery.of(context).size.width - 80,
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: CachedNetworkImage(
                        imageUrl: this.adResponse.takeover.image,
                        // imageUrl:
                        //     'https://media.discordapp.net/attachments/712420469692956712/1170733345567690783/image.png?ex=65b66664&is=65a3f164&hm=92379066355f559721e75a034b4cf512ea4a227c46cfbb816f0c23bae8b3de42&=&format=webp&quality=lossless&width=2152&height=1056',
                        fit: BoxFit.contain,
                        // width: double.infinity,
                        // height: double.infinity,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            color: this.style.primaryColor,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: 20),
                  Text(
                    this.adResponse.takeover.title,
                    style: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(fontWeight: FontWeight.w600, fontSize: 18),
                    // style: TextStyle(
                    //   fontWeight: FontWeight.bold,
                    //   fontFamily: "StatsfmSans",
                    //   fontSize: 18,
                    //   color: this.style.titleColor,
                    // ),
                  ),
                  Text(
                    this.adResponse.takeover.subtitle,
                    style: Theme.of(context).textTheme.bodyLarge,
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () => onClick is Function
                        ? onClick!(adResponse, context)
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: this.style.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(50),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 7.5),
                      child: Text(this.adResponse.takeover.ctaText,
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  color: this.style.backgroundColor,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 16)),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => this.onReport(this.adResponse),
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Container(
                        decoration: BoxDecoration(
                          color: this.style.backgroundColor,
                          borderRadius: BorderRadius.circular(5),
                          boxShadow: [
                            BoxShadow(
                              blurRadius: 5,
                              color: this.style.backgroundColor,
                              offset: Offset(-5, 0),
                            ),
                          ],
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: this.style.primaryColor.withOpacity(.1),
                            borderRadius: BorderRadius.circular(3),
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: 4.5, vertical: 1.4),
                          child: Text(
                            "AD",
                            style: TextStyle(
                              fontSize: 9,
                              color: this.style.primaryColor,
                              fontWeight: FontWeight.bold,
                              fontFamily: "StatsfmSans",
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 10),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Sluit',
                style: Theme.of(context).textTheme.titleLarge!.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
