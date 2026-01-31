import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/user_provider.dart';
import '../../theme/theme_colors.dart';
import '../../../widgets/empty_page.dart';

/// 消息中心页面 - 对应 pages/users/message_center/index.vue
class MessagePage extends StatefulWidget {
  const MessagePage({super.key});

  @override
  State<MessagePage> createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage> with SingleTickerProviderStateMixin {
  final UserProvider _userProvider = UserProvider();
  late TabController _tabController;
  final ScrollController _scrollController = ScrollController();

  int currentTab = 0;
  List<Map<String, dynamic>> systemList = [];
  List<Map<String, dynamic>> serviceList = [];
  int page = 1;
  int limit = 20;
  bool loading = false;
  bool finished = false;

  Color get _primaryColor => ThemeColors.red.primary;

  final List<Map<String, String>> tabs = [
    {'key': '0', 'name': '站内消息'},
    {'key': '1', 'name': '客服消息'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_onTabChanged);
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) return;
    setState(() {
      currentTab = _tabController.index;
      page = 1;
      finished = false;
      if (currentTab == 0) {
        systemList.clear();
      } else {
        serviceList.clear();
      }
    });
    _loadData();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 100) {
      _loadData();
    }
  }

  Future<void> _loadData() async {
    if (currentTab == 0) {
      await _getSystemMessages();
    } else {
      await _getServiceMessages();
    }
  }

  /// 获取站内消息
  Future<void> _getSystemMessages() async {
    if (loading || finished) return;
    setState(() {
      loading = true;
    });

    try {
      final response = await _userProvider.messageSystem({'page': page, 'limit': limit});

      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final list = (data['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];

        setState(() {
          systemList.addAll(list);
          finished = list.length < limit;
          page++;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  /// 获取客服消息
  Future<void> _getServiceMessages() async {
    if (loading || finished) return;
    setState(() {
      loading = true;
    });

    try {
      final response = await _userProvider.serviceRecord({'page': page, 'limit': limit});

      if (response.isSuccess && response.data != null) {
        final list = (response.data as List?)?.cast<Map<String, dynamic>>() ?? [];

        setState(() {
          serviceList.addAll(list);
          finished = list.length < limit;
          page++;
          loading = false;
        });
      } else {
        setState(() {
          loading = false;
        });
      }
    } catch (e) {
      setState(() {
        loading = false;
      });
    }
  }

  /// 全部已读
  Future<void> _markAllRead() async {
    try {
      final response = await _userProvider.msgLookDel({
        'id': 0,
        'key': 'look',
        'value': 1,
        'all': 1,
      });

      if (response.isSuccess) {
        setState(() {
          page = 1;
          finished = false;
          if (currentTab == 0) {
            systemList.clear();
          } else {
            serviceList.clear();
          }
        });
        _loadData();
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败');
    }
  }

  /// 删除消息
  Future<void> _deleteMessage(int id, int index) async {
    try {
      final response = await _userProvider.msgLookDel({'id': id, 'key': 'is_del', 'value': 1});

      if (response.isSuccess) {
        setState(() {
          systemList.removeAt(index);
        });
      }
    } catch (e) {
      Get.snackbar('错误', '删除失败');
    }
  }

  /// 标记已读
  Future<void> _markAsRead(int id, int index) async {
    try {
      final response = await _userProvider.msgLookDel({'id': id, 'key': 'look', 'value': 1});

      if (response.isSuccess) {
        setState(() {
          systemList[index]['look'] = 1;
        });
      }
    } catch (e) {
      Get.snackbar('错误', '操作失败');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('消息中心'),
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF333333),
        elevation: 0,
      ),
      body: Column(
        children: [
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildSystemMessageList(), _buildServiceMessageList()],
            ),
          ),
        ],
      ),
    );
  }

  /// Tab栏
  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 10),
      child: Row(
        children: [
          Expanded(
            child: TabBar(
              controller: _tabController,
              tabs: tabs.map((tab) => Tab(text: tab['name'])).toList(),
              labelColor: Colors.white,
              unselectedLabelColor: const Color(0xFF666666),
              indicator: BoxDecoration(
                color: _primaryColor,
                borderRadius: BorderRadius.circular(15),
              ),
              indicatorSize: TabBarIndicatorSize.tab,
              labelStyle: const TextStyle(fontSize: 14),
            ),
          ),
          const SizedBox(width: 15),
          GestureDetector(
            onTap: _markAllRead,
            child: const Text('全部已读', style: TextStyle(fontSize: 12, color: Color(0xFF666666))),
          ),
        ],
      ),
    );
  }

  /// 站内消息列表
  Widget _buildSystemMessageList() {
    if (systemList.isEmpty && !loading) {
      return const EmptyPage(text: '亲、暂无消息记录哟！');
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      itemCount: systemList.length + (loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == systemList.length) {
          return _buildLoadingIndicator();
        }
        return _buildSystemMessageItem(systemList[index], index);
      },
    );
  }

  /// 客服消息列表
  Widget _buildServiceMessageList() {
    if (serviceList.isEmpty && !loading) {
      return const EmptyPage(text: '亲、暂无消息记录哟！');
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(10),
      itemCount: serviceList.length + (loading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == serviceList.length) {
          return _buildLoadingIndicator();
        }
        return _buildServiceMessageItem(serviceList[index]);
      },
    );
  }

  /// 站内消息项
  Widget _buildSystemMessageItem(Map<String, dynamic> item, int index) {
    final isRead = item['look'] == 1;
    final type = item['type'] ?? 1;

    return Dismissible(
      key: Key('${item['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.red,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      confirmDismiss: (direction) async {
        return await Get.dialog<bool>(
          AlertDialog(
            title: const Text('确认删除'),
            content: const Text('确定要删除这条消息吗？'),
            actions: [
              TextButton(onPressed: () => Get.back(result: false), child: const Text('取消')),
              TextButton(onPressed: () => Get.back(result: true), child: const Text('确定')),
            ],
          ),
        );
      },
      onDismissed: (direction) {
        _deleteMessage(item['id'], index);
      },
      child: GestureDetector(
        onTap: () {
          if (!isRead) {
            _markAsRead(item['id'], index);
          }
          Get.toNamed('/message/detail', arguments: {'id': item['id']});
        },
        child: Container(
          margin: const EdgeInsets.only(bottom: 10),
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withAlpha((0.1 * 255).round()),
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Stack(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: type == 1
                          ? _primaryColor.withAlpha((0.1 * 255).round())
                          : Colors.blue.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(22),
                    ),
                    child: Icon(
                      type == 1 ? Icons.campaign : Icons.person,
                      color: type == 1 ? _primaryColor : Colors.blue,
                      size: 24,
                    ),
                  ),
                  if (!isRead)
                    Positioned(
                      right: 0,
                      top: 0,
                      child: Container(
                        width: 9,
                        height: 9,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(5),
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            item['title'] ?? '--',
                            style: const TextStyle(
                              fontSize: 14,
                              color: Color(0xFF333333),
                              fontWeight: FontWeight.w500,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          item['add_time'] ?? '',
                          style: const TextStyle(fontSize: 10, color: Color(0xFFCCCCCC)),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      item['content'] ?? '',
                      style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 客服消息项
  Widget _buildServiceMessageItem(Map<String, dynamic> item) {
    final messageType = item['message_type'] ?? 1;
    String messageContent = '';
    switch (messageType) {
      case 1:
      case 2:
        messageContent = item['message'] ?? '';
        break;
      case 3:
        messageContent = '[图片]';
        break;
      case 4:
        messageContent = '[语音]';
        break;
      case 5:
        messageContent = '[商品]';
        break;
      case 6:
        messageContent = '[订单]';
        break;
      default:
        messageContent = item['message'] ?? '';
    }

    return GestureDetector(
      onTap: () {
        Get.toNamed('/chat', arguments: {'to_uid': item['to_uid'], 'type': 1});
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.1 * 255).round()),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipOval(
              child: Image.network(
                item['avatar'] ?? '',
                width: 44,
                height: 44,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 44,
                  height: 44,
                  color: Colors.grey[300],
                  child: const Icon(Icons.person, color: Colors.white),
                ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          item['nickname'] ?? '',
                          style: const TextStyle(
                            fontSize: 14,
                            color: Color(0xFF333333),
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        item['_update_time'] ?? '',
                        style: const TextStyle(fontSize: 10, color: Color(0xFFCCCCCC)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          messageContent,
                          style: const TextStyle(fontSize: 12, color: Color(0xFF999999)),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      if ((item['mssage_num'] ?? 0) > 0)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _primaryColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            '${item['mssage_num']}',
                            style: const TextStyle(fontSize: 10, color: Colors.white),
                          ),
                        ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 加载指示器
  Widget _buildLoadingIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 15),
      alignment: Alignment.center,
      child: loading
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2, color: _primaryColor),
            )
          : const Text('没有更多了', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
    );
  }
}
