import 'package:get/get.dart';

/// 热门搜索词控制器
/// 对应原 store/modules/hotWords.js
class HotWordsController extends GetxController {
  static HotWordsController get to => Get.find();

  /// 热门搜索词列表
  final _hotWords = <String>[].obs;
  List<String> get hotWords => _hotWords;
  set hotWords(List<String> value) => _hotWords.value = value;

  /// 搜索历史
  final _searchHistory = <String>[].obs;
  List<String> get searchHistory => _searchHistory;
  set searchHistory(List<String> value) => _searchHistory.value = value;

  /// 设置热门搜索词
  void setHotWords(List<String> words) {
    _hotWords.value = words;
  }

  /// 添加搜索历史
  void addSearchHistory(String keyword) {
    if (keyword.isEmpty) return;
    
    // 移除已存在的相同关键词
    _searchHistory.remove(keyword);
    // 添加到开头
    _searchHistory.insert(0, keyword);
    // 最多保留 20 条
    if (_searchHistory.length > 20) {
      _searchHistory.removeLast();
    }
  }

  /// 清空搜索历史
  void clearSearchHistory() {
    _searchHistory.clear();
  }

  /// 删除单条搜索历史
  void removeSearchHistory(String keyword) {
    _searchHistory.remove(keyword);
  }
}
