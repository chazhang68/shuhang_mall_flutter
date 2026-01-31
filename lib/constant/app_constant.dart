///转换对象时字符串转double类型
double stringToDouble(dynamic value) {
  if (value is double) {
    return value;
  } else if (value is String) {
    return double.tryParse(value) ?? 0.0;
  } else {
    return 0.0;
  }
}

///转换对象时字符串转int类型
int stringToInt(dynamic value) {
  if (value is int) {
    return value;
  } else if (value is String) {
    return int.tryParse(value) ?? 0;
  } else {
    return 0;
  }
}
