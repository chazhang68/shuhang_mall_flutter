import 'package:cached_network_image/cached_network_image.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/user_provider.dart';
import '../../data/providers/store_provider.dart';
import '../../theme/theme_colors.dart';
import '../../routes/app_routes.dart';
// import '../widgets/custom_app_bar.dart'; // 注释掉不存在的导入

/// VIP等级页面 - 对应 pages/users/user_vip/index.vue
class VipPage extends StatefulWidget {
  const VipPage({super.key});

  @override
  State<VipPage> createState() => _VipPageState();
}

class _VipPageState extends State<VipPage> {
  final UserProvider _userProvider = UserProvider();
  final StoreProvider _storeProvider = StoreProvider();
  final PageController _pageController = PageController(viewportFraction: 0.8);

  List<Map<String, dynamic>> vipList = [];
  Map<String, dynamic> levelInfo = {};
  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> taskInfo = {};
  List<Map<String, dynamic>> recommendList = [];
  int swiperIndex = 0;
  bool isLoading = true;
  bool isOpenMember = false;
  bool showGrowthRule = false; // 显示成长规则弹窗
  String growthRuleText = ''; // 成长规则文本内容

  Color get _primaryColor => ThemeColors.red.primary;

  // late UserModel _userModel;

  @override
  void initState() {
    super.initState();
    // _userModel = Get.find<UserModel>(); // 暂时注释掉，因为不需要直接访问_userModel
    _loadData();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _getUserInfo(),
      _getMainInfo(), // 合并获取等级和任务信息
      _checkDetection(),
      _getRecommendList(),
    ]);
    setState(() {
      isLoading = false;
    });
  }

  /// 下拉刷新
  Future<void> _onRefresh() async {
    await _loadData();
  }

  /// 获取用户信息
  Future<void> _getUserInfo() async {
    try {
      final response = await _userProvider.getUserInfo();
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          userInfo = data;
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// 获取主要信息（会员等级和任务信息）
  Future<void> _getMainInfo() async {
    try {
      final response = await _userProvider.userLevelGrade();
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;

        setState(() {
          vipList = (data['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
          levelInfo = data['userInfo'] ?? {};
          isOpenMember = data['open_member'] ?? false;

          // 同时获取任务信息
          final taskData = data['task'];
          if (taskData != null) {
            taskInfo = taskData as Map<String, dynamic>;
          }
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// 获取推荐商品
  Future<void> _getRecommendList() async {
    try {
      // 从原uni-app代码看，这里应该是获取热门商品
      final response = await _storeProvider.getHotProducts(null);
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        setState(() {
          recommendList = (data['list'] as List?)?.cast<Map<String, dynamic>>() ?? [];
        });
      }
    } catch (e) {
      // ignore
    }
  }

  /// 显示成长规则
  void _showGrowthRule() {
    // 根据原uni-app代码，这里应该获取任务说明
    _getGrowthRule();
  }

  /// 获取成长值说明
  Future<void> _getGrowthRule() async {
    try {
      // 根据原uni-app代码，这里应该获取等级任务信息
      final response = await _userProvider.userLevelGrade();
      if (response.isSuccess && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        final taskList = data['task']['task'] as List<dynamic>;

        // 构建成长值说明文本
        StringBuffer buffer = StringBuffer();
        buffer.write('成长值说明：\n');

        for (var task in taskList) {
          if (task is Map<String, dynamic>) {
            final name = task['title'] ?? task['real_name'] ?? '任务';
            final illustrate = task['illustrate'] ?? '完成任务获得成长值';
            buffer.write('$name: $illustrate\n');
          }
        }

        setState(() {
          growthRuleText = buffer.toString();
          showGrowthRule = true;
        });
      }
    } catch (e) {
      setState(() {
        growthRuleText = '成长值说明：通过签到、购买商品、邀请好友等方式可以获得成长值，提升您的会员等级，享受更多优惠。';
        showGrowthRule = true;
      });
    }
  }

  /// 构建成长规则弹窗
  Widget _buildGrowthRuleDialog() {
    return Container(
      width: double.infinity,
      height: double.infinity,
      color: Colors.black.withAlpha((0.5 * 255).round()),
      child: Center(
        child: Container(
          width: Get.width * 0.8,
          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: _primaryColor,
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: const Text(
                  '成长值说明',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(15),
                child: Text(
                  growthRuleText,
                  style: const TextStyle(fontSize: 14, color: Color(0xFF333333)),
                ),
              ),
              Container(
                width: double.infinity,
                height: 45,
                margin: const EdgeInsets.all(15),
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      showGrowthRule = false;
                    });
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primaryColor,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22.5)),
                  ),
                  child: const Text('确定', style: TextStyle(color: Colors.white)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 检测会员等级
  Future<void> _checkDetection() async {
    try {
      await _userProvider.userLevelDetection();
    } catch (e) {
      // ignore
    }
  }

  /// 切换VIP卡片
  void _onPageChanged(int index) {
    setState(() {
      swiperIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      body: Stack(
        children: [
          EasyRefresh(
            header: const ClassicHeader(
              dragText: '下拉刷新',
              armedText: '松手刷新',
              processingText: '刷新中...',
              processedText: '刷新完成',
              failedText: '刷新失败',
            ),
            onRefresh: _onRefresh,
            child: isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    slivers: [
                      SliverToBoxAdapter(child: _buildHeader()),
                      SliverToBoxAdapter(child: _buildPrivileges()),
                      SliverToBoxAdapter(child: _buildSkillSection()),
                      if (recommendList.isNotEmpty)
                        SliverToBoxAdapter(child: _buildRecommendSection()),
                      SliverToBoxAdapter(child: _buildServiceSection()),
                      SliverToBoxAdapter(child: _buildFooterSection()),
                    ],
                  ),
          ),
          if (showGrowthRule) _buildGrowthRuleDialog(),
        ],
      ),
    );
  }

  /// 头部区域
  Widget _buildHeader() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF2C2C2C), Color(0xFF1A1A1A)],
        ),
      ),
      child: SafeArea(child: Column(children: [_buildAppBar(), _buildVipSwiper()])),
    );
  }

  /// AppBar
  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Get.back(),
            child: const Icon(Icons.arrow_back_ios, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            '会员中心',
            style: TextStyle(fontSize: 18, color: Colors.white, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  /// VIP卡片轮播
  Widget _buildVipSwiper() {
    if (vipList.isEmpty) {
      return const SizedBox(height: 200);
    }

    return SizedBox(
      height: 220,
      child: PageView.builder(
        controller: _pageController,
        itemCount: vipList.length,
        onPageChanged: _onPageChanged,
        itemBuilder: (context, index) {
          return _buildVipCard(vipList[index], index);
        },
      ),
    );
  }

  /// VIP卡片
  Widget _buildVipCard(Map<String, dynamic> item, int index) {
    final isActive = swiperIndex == index;
    final isCurrent = item['grade'] == levelInfo['grade'];
    final isLocked =
        (levelInfo['grade'] ?? 0) == 0 || (item['grade'] ?? 0) > (levelInfo['grade'] ?? 0);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      margin: EdgeInsets.symmetric(horizontal: 5, vertical: isActive ? 0 : 15),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        image: item['image'] != null
            ? DecorationImage(image: NetworkImage(item['image']), fit: BoxFit.cover)
            : null,
        gradient: item['image'] == null
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [_primaryColor.withAlpha((0.8 * 255).round()), _primaryColor],
              )
            : null,
      ),
      child: Stack(
        children: [
          // 用户信息
          Positioned(
            top: 20,
            left: 20,
            right: 20,
            child: Row(
              children: [
                ClipOval(
                  child: Image.network(
                    userInfo['avatar'] ?? '',
                    width: 45,
                    height: 45,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 45,
                      height: 45,
                      color: Colors.grey,
                      child: const Icon(Icons.person, color: Colors.white),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        userInfo['nickname'] ?? '',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 3),
                      Text(
                        '商城购物可享 ${item['discount'] ?? 10} 折',
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white.withAlpha((0.2 * 255).round()),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    isCurrent ? '当前等级' : (isLocked ? '未达成' : '已解锁'),
                    style: const TextStyle(fontSize: 10, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
          // 成长值进度
          if (isCurrent)
            Positioned(
              bottom: 60,
              left: 20,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        '今日成长值 ',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                        ),
                      ),
                      Text(
                        '${levelInfo['today_exp'] ?? 0}',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        ' 点',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withAlpha((0.8 * 255).round()),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  _buildProgressBar(item),
                ],
              ),
            ),
          // 等级名称
          Positioned(
            bottom: 20,
            left: 20,
            child: Text(
              item['name'] ?? '',
              style: const TextStyle(
                fontSize: 18,
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          // 锁定状态
          if (isLocked)
            Positioned(
              bottom: 60,
              left: 20,
              child: Row(
                children: [
                  const Icon(Icons.lock_outline, size: 14, color: Colors.white70),
                  const SizedBox(width: 5),
                  Text(
                    '暂未解锁该等级',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withAlpha((0.7 * 255).round()),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  /// 进度条
  Widget _buildProgressBar(Map<String, dynamic> item) {
    final exp = (levelInfo['exp'] ?? 0).toDouble();
    final nextExpNum = (item['next_exp_num'] ?? 1).toDouble();
    var progress = exp / nextExpNum;
    if (progress > 1) progress = 1;

    return Column(
      children: [
        Container(
          height: 6,
          decoration: BoxDecoration(
            color: Colors.white.withAlpha((0.3 * 255).round()),
            borderRadius: BorderRadius.circular(3),
          ),
          child: FractionallySizedBox(
            alignment: Alignment.centerLeft,
            widthFactor: progress,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        const SizedBox(height: 5),
        Text(
          '${levelInfo['exp'] ?? 0}/${item['next_exp_num'] ?? 0}',
          style: const TextStyle(fontSize: 11, color: Colors.white70),
        ),
      ],
    );
  }

  /// 成长特权
  Widget _buildPrivileges() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '我的成长特权',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              if (isOpenMember)
                GestureDetector(
                  onTap: () => Get.toNamed('/vip/paid'),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFFE4B5),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      '立即升级',
                      style: TextStyle(fontSize: 12, color: Color(0xFFB8860B)),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildPrivilegeItem(Icons.shopping_bag, '购物折扣'),
              _buildPrivilegeItem(Icons.military_tech, '专属徽章'),
              _buildPrivilegeItem(Icons.trending_up, '经验累积'),
              _buildPrivilegeItem(Icons.support_agent, '尊享客服'),
            ],
          ),
        ],
      ),
    );
  }

  /// 特权项
  Widget _buildPrivilegeItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: const Color(0xFFFFF8E1),
            borderRadius: BorderRadius.circular(25),
          ),
          child: Icon(icon, color: const Color(0xFFB8860B), size: 24),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
      ],
    );
  }

  /// 快速升级技巧
  Widget _buildSkillSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '快速升级技巧',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF333333),
                ),
              ),
              Row(
                children: [
                  GestureDetector(
                    onTap: () {
                      // 根据原uni-app代码，打开成长值说明
                      _showGrowthRule();
                    },
                    child: const Row(
                      children: [
                        Text('成长值说明', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                        Icon(Icons.info_outline, size: 14, color: Color(0xFF999999)),
                      ],
                    ),
                  ),
                  const SizedBox(width: 15),
                  GestureDetector(
                    onTap: () {
                      // 跳转到成长值记录页面
                      Get.toNamed(AppRoutes.vipExpRecord);
                    },
                    child: const Row(
                      children: [
                        Text('成长值记录', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
                        Icon(Icons.history, size: 14, color: Color(0xFF999999)),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 15),
          _buildSkillItem(
            title: '签到',
            mark: '可获得${taskInfo['sign'] ?? 0}点经验',
            info: '每日签到可获得经验值，已签到${taskInfo['sign_count'] ?? 0}天',
            buttonText: '去签到',
            onTap: () => Get.toNamed('/user/signin'),
          ),
          const Divider(height: 30),
          _buildSkillItem(
            title: '购买商品',
            mark: '+${taskInfo['order'] ?? 0}点经验/元',
            info: '购买商品可获得对应的经验值',
            buttonText: '去购买',
            onTap: () => Get.toNamed('/category'),
          ),
          const Divider(height: 30),
          _buildSkillItem(
            title: '邀请好友',
            mark: '+${taskInfo['invite'] ?? 0}点经验/人',
            info: '邀请好友注册商城可获得经验值',
            buttonText: '去邀请',
            onTap: () => Get.toNamed('/spread/code'),
          ),
        ],
      ),
    );
  }

  /// 推荐商品
  Widget _buildRecommendSection() {
    return Container(
      margin: const EdgeInsets.all(15),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '为您推荐',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 15),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: recommendList.map((item) {
              return _buildRecommendItem(item);
            }).toList(),
          ),
        ],
      ),
    );
  }

  /// 推荐商品项
  Widget _buildRecommendItem(Map<String, dynamic> item) {
    return GestureDetector(
      onTap: () {
        // 跳转到商品详情页
        Get.toNamed('/product/detail', parameters: {'id': item['id'].toString()});
      },
      child: Container(
        width: (Get.width - 50) / 2,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withAlpha((0.1 * 255).round()),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(8)),
              child: CachedNetworkImage(
                imageUrl: item['image'] ?? '',
                width: double.infinity,
                height: 120,
                fit: BoxFit.cover,
                placeholder: (context, url) => Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.image, color: Colors.grey),
                ),
                errorWidget: (context, url, error) => Container(
                  width: double.infinity,
                  height: 120,
                  color: Colors.grey[200],
                  child: const Icon(Icons.broken_image, color: Colors.grey),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item['store_name'] ?? '',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '¥${item['price'] ?? 0}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: _primaryColor,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 会员服务
  Widget _buildServiceSection() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '会员服务',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: Color(0xFF333333)),
          ),
          const SizedBox(height: 15),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildServiceItem(Icons.support_agent, '专属客服'),
              _buildServiceItem(Icons.card_membership, '会员权益'),
              _buildServiceItem(Icons.help_outline, '常见问题'),
              _buildServiceItem(Icons.local_offer, '专属活动'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildServiceItem(IconData icon, String title) {
    return Column(
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: _primaryColor.withAlpha((0.08 * 255).round()),
            borderRadius: BorderRadius.circular(22),
          ),
          child: Icon(icon, size: 22, color: _primaryColor),
        ),
        const SizedBox(height: 8),
        Text(title, style: const TextStyle(fontSize: 12, color: Color(0xFF666666))),
      ],
    );
  }

  /// 底部说明
  Widget _buildFooterSection() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 30, top: 5),
      child: Column(
        children: const [
          Text('会员权益以实际展示为准', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
          SizedBox(height: 6),
          Text('如有疑问请联系专属客服', style: TextStyle(fontSize: 12, color: Color(0xFF999999))),
        ],
      ),
    );
  }

  /// 技巧项
  Widget _buildSkillItem({
    required String title,
    required String mark,
    required String info,
    required String buttonText,
    required VoidCallback onTap,
  }) {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF333333),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _primaryColor.withAlpha((0.1 * 255).round()),
                      borderRadius: BorderRadius.circular(3),
                    ),
                    child: Text(mark, style: TextStyle(fontSize: 10, color: _primaryColor)),
                  ),
                ],
              ),
              const SizedBox(height: 5),
              Text(info, style: const TextStyle(fontSize: 12, color: Color(0xFF999999))),
            ],
          ),
        ),
        GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 6),
            decoration: BoxDecoration(
              border: Border.all(color: _primaryColor),
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(buttonText, style: TextStyle(fontSize: 12, color: _primaryColor)),
          ),
        ),
      ],
    );
  }
}
