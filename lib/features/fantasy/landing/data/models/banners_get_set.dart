class BannersGetSet {
  String? type;
  String? bannerType;
  String? image;
  String? url;
  String? sliderid;

  BannersGetSet({
    this.type,
    this.bannerType,
    this.image,
    this.url,
    this.sliderid,
  });

  factory BannersGetSet.fromJson(Map<String, dynamic> json) => BannersGetSet(
        type: json['type'],
        bannerType: json['bannerType'],
        image: json['image'],
        url: json['url'],
        sliderid: json['sliderid'],
      );
}
