import 'package:shuhang_mall_flutter/constant/app_constant.dart';

/// 首页数据模型
class HomeIndexData {
  final List<HomeBannerItem> banners;
  final String notes;
  final int notesId;
  final List<HomeHotProduct> hotList;

  const HomeIndexData({
    required this.banners,
    required this.notes,
    required this.notesId,
    required this.hotList,
  });

  factory HomeIndexData.fromJson(Map<String, dynamic> json) {
    return HomeIndexData(
      banners: _parseBanners(json['banner']),
      notes: json['notes']?.toString() ?? '',
      notesId: stringToInt(json['id']),
      hotList: _parseHotList(json['hot_list']),
    );
  }

  static List<HomeBannerItem> _parseBanners(dynamic value) {
    if (value is! List) return const <HomeBannerItem>[];
    return value
        .whereType<Map>()
        .map((item) => HomeBannerItem.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }

  static List<HomeHotProduct> _parseHotList(dynamic value) {
    if (value is! List) return const <HomeHotProduct>[];
    return value
        .whereType<Map>()
        .map((item) => HomeHotProduct.fromJson(Map<String, dynamic>.from(item)))
        .toList();
  }
}

/// 首页 Banner
class HomeBannerItem {
  final int id;
  final String imgUrl;
  final String url;
  final String type;

  const HomeBannerItem({
    required this.id,
    required this.imgUrl,
    required this.url,
    required this.type,
  });

  factory HomeBannerItem.fromJson(Map<String, dynamic> json) {
    return HomeBannerItem(
      id: stringToInt(json['id']),
      imgUrl: json['img_url']?.toString() ?? '',
      url: json['url']?.toString() ?? '',
      type: json['type']?.toString() ?? '',
    );
  }
}

/// 首页热卖商品
class HomeHotProduct {
  final int id;
  final String storeName;
  final String image;
  final String keyword;
  final double price;

  const HomeHotProduct({
    required this.id,
    required this.storeName,
    required this.image,
    required this.keyword,
    required this.price,
  });

  factory HomeHotProduct.fromJson(Map<String, dynamic> json) {
    return HomeHotProduct(
      id: stringToInt(json['id']),
      storeName: json['store_name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      keyword: json['keyword']?.toString() ?? '',
      price: stringToDouble(json['price']),
    );
  }
}
