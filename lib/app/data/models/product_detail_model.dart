/// 商品详情响应模型
class ProductDetailModel {
  final ProductStoreInfo storeInfo;
  final List<ProductAttr> productAttr;
  final Map<String, ProductSku> productValue;
  final List<ProductReply> reply;
  final int replyCount;
  final List<ProductCoupon> coupons;
  final List<ProductActivity> activity;
  final int routineContactType;

  const ProductDetailModel({
    required this.storeInfo,
    this.productAttr = const <ProductAttr>[],
    this.productValue = const <String, ProductSku>{},
    this.reply = const <ProductReply>[],
    this.replyCount = 0,
    this.coupons = const <ProductCoupon>[],
    this.activity = const <ProductActivity>[],
    this.routineContactType = 0,
  });

  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final storeInfoMap = _asMap(
      _readFirst(json, ['storeInfo', 'store_info', 'productInfo', 'product_info']),
    );
    final productAttr = _asList(
      _readFirst(json, ['productAttr', 'product_attr', 'attrs']),
    ).map((item) => ProductAttr.fromJson(_asMap(item))).toList();

    final productValue = <String, ProductSku>{};
    final productValueRaw = _readFirst(json, [
      'productValue',
      'product_value',
      'attrValue',
      'attr_value',
    ]);
    if (productValueRaw is Map) {
      productValueRaw.forEach((key, value) {
        final mapValue = _asMap(value);
        productValue[key.toString()] = ProductSku.fromJson(mapValue, skuKey: key.toString());
      });
    }

    final replyList = <ProductReply>[];
    final replyRaw = _readFirst(json, ['reply', 'reply_list', 'comment', 'comments']);
    if (replyRaw is List) {
      for (final item in replyRaw) {
        replyList.add(ProductReply.fromJson(_asMap(item)));
      }
    } else if (replyRaw is Map) {
      replyList.add(ProductReply.fromJson(_asMap(replyRaw)));
    }

    final coupons = _asList(
      _readFirst(json, ['coupons', 'coupon', 'coupon_list']),
    ).map((item) => ProductCoupon.fromJson(_asMap(item))).toList();
    final activity = _asList(
      _readFirst(json, ['activity', 'activity_list']),
    ).map((item) => ProductActivity.fromJson(_asMap(item))).toList();

    return ProductDetailModel(
      storeInfo: ProductStoreInfo.fromJson(storeInfoMap),
      productAttr: productAttr,
      productValue: productValue,
      reply: replyList,
      replyCount: _numToInt(
        _readFirst(json, ['replyCount', 'reply_count', 'replyNum', 'reply_num']),
      ),
      coupons: coupons,
      activity: activity,
      routineContactType: _numToInt(json['routine_contact_type']),
    );
  }
}

/// 商品基础信息
class ProductStoreInfo {
  final int id;
  final String storeName;
  final String image;
  final List<String> sliderImage;
  final String videoLink;
  final String description;
  final String price;
  final String otPrice;
  final String vipPrice;
  final int stock;
  final int fsales;
  final int sales;
  final String unitName;
  final int giveIntegral;
  final bool isVip;
  final bool specType;
  final int limitType;
  final int limitNum;
  final bool presale;
  final String presaleStartTime;
  final String presaleEndTime;
  final int presaleDay;
  final bool userCollect;
  final int virtualType;
  final String cateId;

  const ProductStoreInfo({
    this.id = 0,
    this.storeName = '',
    this.image = '',
    this.sliderImage = const <String>[],
    this.videoLink = '',
    this.description = '',
    this.price = '0.00',
    this.otPrice = '',
    this.vipPrice = '0.00',
    this.stock = 0,
    this.fsales = 0,
    this.sales = 0,
    this.unitName = '件',
    this.giveIntegral = 0,
    this.isVip = false,
    this.specType = false,
    this.limitType = 0,
    this.limitNum = 0,
    this.presale = false,
    this.presaleStartTime = '',
    this.presaleEndTime = '',
    this.presaleDay = 0,
    this.userCollect = false,
    this.virtualType = 0,
    this.cateId = '',
  });

  factory ProductStoreInfo.empty() => const ProductStoreInfo();

  factory ProductStoreInfo.fromJson(Map<String, dynamic> json) {
    final description = _readFirst(json, [
      'description',
      'content',
      'store_info',
      'storeInfo',
      'store_description',
    ]);
    return ProductStoreInfo(
      id: _numToInt(json['id']),
      storeName: json['store_name']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      sliderImage: _stringList(json['slider_image']),
      videoLink: json['video_link']?.toString() ?? '',
      description: description?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      otPrice: json['ot_price']?.toString() ?? '',
      vipPrice: json['vip_price']?.toString() ?? '0.00',
      stock: _numToInt(json['stock']),
      fsales: _numToInt(json['fsales']),
      sales: _numToInt(json['sales']),
      unitName: json['unit_name']?.toString() ?? '件',
      giveIntegral: _numToInt(json['give_integral']),
      isVip: _numToBool(json['is_vip']),
      specType: _numToBool(json['spec_type']),
      limitType: _numToInt(json['limit_type']),
      limitNum: _numToInt(json['limit_num']),
      presale: _numToBool(json['presale']),
      presaleStartTime: json['presale_start_time']?.toString() ?? '',
      presaleEndTime: json['presale_end_time']?.toString() ?? '',
      presaleDay: _numToInt(json['presale_day']),
      userCollect: _numToBool(json['userCollect'] ?? json['user_collect']),
      virtualType: _numToInt(json['virtual_type']),
      cateId: json['cate_id']?.toString() ?? '',
    );
  }

  ProductStoreInfo copyWith({bool? userCollect}) {
    return ProductStoreInfo(
      id: id,
      storeName: storeName,
      image: image,
      sliderImage: sliderImage,
      videoLink: videoLink,
      description: description,
      price: price,
      otPrice: otPrice,
      vipPrice: vipPrice,
      stock: stock,
      fsales: fsales,
      sales: sales,
      unitName: unitName,
      giveIntegral: giveIntegral,
      isVip: isVip,
      specType: specType,
      limitType: limitType,
      limitNum: limitNum,
      presale: presale,
      presaleStartTime: presaleStartTime,
      presaleEndTime: presaleEndTime,
      presaleDay: presaleDay,
      userCollect: userCollect ?? this.userCollect,
      virtualType: virtualType,
      cateId: cateId,
    );
  }

  Map<String, dynamic> toSpecMap() {
    return {'id': id, 'store_name': storeName, 'image': image, 'price': price, 'stock': stock};
  }
}

/// 商品规格属性
class ProductAttr {
  final String attrName;
  final List<String> attrValues;

  const ProductAttr({this.attrName = '', this.attrValues = const <String>[]});

  factory ProductAttr.fromJson(Map<String, dynamic> json) {
    return ProductAttr(
      attrName: json['attr_name']?.toString() ?? '',
      attrValues: _stringList(json['attr_values']),
    );
  }

  Map<String, dynamic> toSpecMap() {
    return {'attr_name': attrName, 'attr_values': attrValues};
  }
}

/// 商品SKU
class ProductSku {
  final String unique;
  final String image;
  final String price;
  final int stock;
  final String suk;

  const ProductSku({
    this.unique = '',
    this.image = '',
    this.price = '0.00',
    this.stock = 0,
    this.suk = '',
  });

  factory ProductSku.fromJson(Map<String, dynamic> json, {String? skuKey}) {
    return ProductSku(
      unique: json['unique']?.toString() ?? '',
      image: json['image']?.toString() ?? '',
      price: json['price']?.toString() ?? '0.00',
      stock: _numToInt(json['stock']),
      suk: json['suk']?.toString() ?? skuKey ?? '',
    );
  }

  Map<String, dynamic> toSpecMap(String skuKey) {
    return {'suk': skuKey, 'unique': unique, 'image': image, 'price': price, 'stock': stock};
  }
}

/// 商品评价
class ProductReply {
  final String avatar;
  final String nickname;
  final String comment;
  final List<String> pics;
  final String addTime;
  final int star;
  final String sku;

  const ProductReply({
    this.avatar = '',
    this.nickname = '匿名用户',
    this.comment = '',
    this.pics = const <String>[],
    this.addTime = '',
    this.star = 5,
    this.sku = '',
  });

  factory ProductReply.fromJson(Map<String, dynamic> json) {
    return ProductReply(
      avatar: json['avatar']?.toString() ?? '',
      nickname: json['nickname']?.toString() ?? '匿名用户',
      comment: json['comment']?.toString() ?? '',
      pics: _stringList(json['pics']),
      addTime: json['add_time']?.toString() ?? '',
      star: _numToInt(json['star'], defaultValue: 5),
      sku: json['suk']?.toString() ?? '',
    );
  }
}

/// 优惠券
class ProductCoupon {
  final int id;
  final String couponPrice;
  final String useMinPrice;
  final String couponTitle;
  final int isUse;

  const ProductCoupon({
    this.id = 0,
    this.couponPrice = '0',
    this.useMinPrice = '0',
    this.couponTitle = '',
    this.isUse = 0,
  });

  factory ProductCoupon.fromJson(Map<String, dynamic> json) {
    return ProductCoupon(
      id: _numToInt(json['id']),
      couponPrice: json['coupon_price']?.toString() ?? '0',
      useMinPrice: json['use_min_price']?.toString() ?? '0',
      couponTitle: json['coupon_title']?.toString() ?? '',
      isUse: _numToInt(json['is_use']),
    );
  }

  ProductCoupon copyWith({int? isUse}) {
    return ProductCoupon(
      id: id,
      couponPrice: couponPrice,
      useMinPrice: useMinPrice,
      couponTitle: couponTitle,
      isUse: isUse ?? this.isUse,
    );
  }
}

/// 商品活动
class ProductActivity {
  final String type;
  final int id;
  final dynamic time;

  const ProductActivity({this.type = '', this.id = 0, this.time});

  factory ProductActivity.fromJson(Map<String, dynamic> json) {
    return ProductActivity(
      type: json['type']?.toString() ?? '',
      id: _numToInt(json['id']),
      time: json['time'],
    );
  }
}

int _numToInt(dynamic value, {int defaultValue = 0}) {
  if (value is int) return value;
  if (value is double) return value.toInt();
  if (value is String) return int.tryParse(value) ?? defaultValue;
  return defaultValue;
}

bool _numToBool(dynamic value) {
  if (value is bool) return value;
  if (value is num) return value == 1;
  if (value is String) return value == '1' || value.toLowerCase() == 'true';
  return false;
}

List<String> _stringList(dynamic value) {
  if (value is List) {
    return value.map((item) => item.toString()).toList();
  }
  if (value is String && value.isNotEmpty) {
    return <String>[value];
  }
  return <String>[];
}

List<dynamic> _asList(dynamic value) {
  if (value is List) return value;
  return const <dynamic>[];
}

Map<String, dynamic> _asMap(dynamic value) {
  if (value is Map<String, dynamic>) return value;
  if (value is Map) return Map<String, dynamic>.from(value);
  return <String, dynamic>{};
}

dynamic _readFirst(Map<String, dynamic> json, List<String> keys) {
  for (final key in keys) {
    if (json.containsKey(key) && json[key] != null) {
      return json[key];
    }
  }
  return null;
}
