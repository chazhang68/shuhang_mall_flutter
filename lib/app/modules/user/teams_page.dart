import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_toast_pro/flutter_toast_pro.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../data/providers/user_provider.dart';
import '../../controllers/app_controller.dart';

/// 我的好友页面 - 对应 pages/users/teams/teams.vue
class TeamsPage extends StatefulWidget {
  const TeamsPage({super.key});

  @override
  State<TeamsPage> createState() => _TeamsPageState();
}

class _TeamsPageState extends State<TeamsPage> {
  final UserProvider _userProvider = UserProvider();

  Map<String, dynamic> userInfo = {};
  Map<String, dynamic> info = {};
  List<Map<String, dynamic>> list = [];

  int _page = 1;
  final int _limit = 10;
  bool _loading = false;
  bool _loadend = false;
  String _loadTitle = '加载更多';
  String _phone = '';
  bool _isLoading = true;

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 100) {
      _getHaoyou();
    }
  }

  Future<void> _loadData() async {
    await Future.wait([_getUser(), _getInfo(), _getHaoyou()]);
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onRefresh() async {
    _page = 1;
    _loading = false;
    _loadend = false;
    _loadTitle = '';
    list = [];
    await Future.wait([_getUser(), _getInfo(), _getHaoyou()]);
  }

  Future<void> _getUser() async {
    // 优先从全局状态获取用户信息
    final controller = Get.find<AppController>();
    if (controller.userInfo != null) {
      setState(() {
        userInfo = controller.userInfo!.toJson();
      });
      return;
    }
    // 全局没有则请求接口
    final response = await _userProvider.newUserInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        userInfo = response.data!.toJson();
      });
    }
  }

  Future<void> _getInfo() async {
    final response = await _userProvider.getTeamInfo();
    if (response.isSuccess && response.data != null) {
      setState(() {
        info = Map<String, dynamic>.from(response.data);
      });
    }
  }

  Future<void> _getHaoyou() async {
    if (_loading || _loadend) return;
    _loading = true;
    _loadTitle = '';

    try {
      final response = await _userProvider.getHyList({
        'page': _page,
        'limit': _limit,
        'phone': _phone,
      });
      if (response.isSuccess && response.data != null) {
        final data = List<Map<String, dynamic>>.from(response.data);
        setState(() {
          _loadend = data.length < _limit;
          list.addAll(data);
          _loadTitle = _loadend ? '我也是有底线的' : '加载更多';
          _page += 1;
        });
      }
    } catch (_) {
      _loadTitle = '加载更多';
    } finally {
      _loading = false;
    }
  }

  void _search(String value) {
    _phone = value;
    _page = 1;
    _loading = false;
    _loadend = false;
    _loadTitle = '';
    list = [];
    _getHaoyou();
  }

  void _copy(String value) {
    Clipboard.setData(ClipboardData(text: value));
    FlutterToastPro.showMessage('邀请码已复制');
  }

  void _callPhone(String phone) async {
    final uri = Uri(scheme: 'tel', path: phone);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F3F3),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _onRefresh,
              child: CustomScrollView(
                controller: _scrollController,
                slivers: [
                  // 顶部背景区域
                  SliverToBoxAdapter(child: _buildHeader()),
                  // 白色内容区域
                  SliverToBoxAdapter(child: _buildFriendsHeader()),
                  // 搜索栏
                  SliverToBoxAdapter(child: _buildSearchBar()),
                  // 好友列表
                  if (list.isEmpty)
                    SliverToBoxAdapter(child: _buildEmpty())
                  else ...[
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) => _buildFriendItem(list[index]),
                        childCount: list.length,
                      ),
                    ),
                    if (list.isNotEmpty)
                      SliverToBoxAdapter(child: _buildLoadMore()),
                  ],
                  SliverToBoxAdapter(child: SizedBox(height: 20.h)),
                ],
              ),
            ),
    );
  }

  Widget _buildHeader() {
    final avatar = userInfo['avatar'] ?? '';
    final isSigned = userInfo['is_sign'] == true || userInfo['is_sign'] == 1;
    final displayName = userInfo['nickname'] ?? '';
    final code = '${userInfo['code'] ?? ''}';
    final spreadCode = '${userInfo['spread_code'] ?? 0}';
    final myHy = '${info['my_hy'] ?? 0}';

    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/haoyou.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            // 返回按钮
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Get.back(),
                    child: Icon(Icons.arrow_back_ios, color: Colors.white, size: 20.sp),
                  ),
                ],
              ),
            ),
            // 用户信息行
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
              child: Row(
                children: [
                  // 头像
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      ClipOval(
                        child: CachedNetworkImage(
                          imageUrl: avatar,
                          width: 70.w,
                          height: 70.w,
                          fit: BoxFit.cover,
                          errorWidget: (_, __, ___) => Container(
                            width: 70.w,
                            height: 70.w,
                            color: Colors.grey,
                            child: Icon(Icons.person, color: Colors.white, size: 35.sp),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: -5,
                        left: 3.w,
                        child: Image.asset(
                          isSigned
                              ? 'assets/images/sign.png'
                              : 'assets/images/no_sign.png',
                          width: 53.w,
                          height: 14.h,
                          errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(width: 16.w),
                  // 名字、邀请码、邀请人
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 19.sp,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                            SizedBox(width: 4.w),
                            _buildLevelIcon(),
                          ],
                        ),
                        SizedBox(height: 4.h),
                        GestureDetector(
                          onTap: () => _copy(code),
                          child: Row(
                            children: [
                              Text(
                                '邀请码：$code',
                                style: TextStyle(fontSize: 13.sp, color: Colors.white),
                              ),
                              SizedBox(width: 4.w),
                              Icon(Icons.copy, size: 14.sp, color: const Color(0xFFFFAA0A)),
                            ],
                          ),
                        ),
                        SizedBox(height: 4.h),
                        Text(
                          '邀请人：$spreadCode',
                          style: TextStyle(fontSize: 13.sp, color: Colors.white),
                        ),
                      ],
                    ),
                  ),
                  // 个人活跃度
                  Column(
                    children: [
                      Text(
                        myHy,
                        style: TextStyle(
                          fontSize: 19.sp,
                          fontWeight: FontWeight.bold,
                          color: const Color(0xFF333333),
                        ),
                      ),
                      SizedBox(height: 4.h),
                      Text(
                        '个人活跃度',
                        style: TextStyle(fontSize: 12.sp, color: Colors.white),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            // 统计栏
            Container(
              margin: EdgeInsets.all(12.w),
              padding: EdgeInsets.symmetric(vertical: 16.h),
              decoration: BoxDecoration(
                color: const Color(0xFF2C2722),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem('${info['all_zt'] ?? 0}', '好友人数'),
                  _buildStatItem('${info['yxzt'] ?? 0}', '有效好友'),
                  _buildStatItem('${info['teamHy'] ?? 0}', '团队活跃度'),
                  _buildStatItem('${info['min_hy'] ?? 0}', '小区活跃度'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLevelIcon() {
    final level = userInfo['agent_level'];
    String asset;
    if (level == null || level == 0) {
      asset = 'assets/images/zhang.png';
    } else {
      asset = 'assets/images/l$level.png';
    }
    return Image.asset(
      asset,
      width: 19.w,
      height: 23.h,
      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            color: const Color(0xFFF3E1C9),
            fontSize: 16.sp,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 8.h),
        Text(
          label,
          style: TextStyle(color: const Color(0xFFF3E1C9), fontSize: 12.sp),
        ),
      ],
    );
  }

  Widget _buildFriendsHeader() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.only(top: 12.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/dll.png',
            width: 30.w,
            height: 30.w,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 8.w),
            child: Text(
              '我的好友',
              style: TextStyle(
                fontSize: 16.sp,
                fontWeight: FontWeight.bold,
                color: const Color(0xFF333333),
              ),
            ),
          ),
          Image.asset(
            'assets/images/dlr.png',
            width: 30.w,
            height: 30.w,
            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      color: Colors.white,
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 8.h),
      child: TextField(
        controller: _searchController,
        maxLength: 11,
        decoration: InputDecoration(
          hintText: '请输入手机号或ID查找好友',
          hintStyle: TextStyle(fontSize: 14.sp, color: Colors.grey),
          filled: true,
          fillColor: const Color(0xFFF3F3F3),
          counterText: '',
          contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 10.h),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(Icons.search, color: Colors.grey, size: 20.sp),
        ),
        onChanged: _search,
      ),
    );
  }

  Widget _buildFriendItem(Map<String, dynamic> item) {
    final avatar = item['avatar'] ?? '';
    final isSigned = item['is_sign'] == true || item['is_sign'] == 1;
    final displayName = isSigned
        ? (item['real_name'] ?? item['nickname'] ?? '')
        : (item['nickname'] ?? '');
    final teamHy = '${item['team_hy'] ?? 0}';
    final hy = '${item['hy'] ?? 0}';
    final isLq = item['is_lq'] == true || item['is_lq'] == 1;
    final phone = '${item['phone'] ?? ''}';
    final time = '${item['time'] ?? ''}';

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: const Color(0xFFE2E2E2)),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          // 上半部分：头像、名字、活跃度
          Padding(
            padding: EdgeInsets.all(8.w),
            child: Row(
              children: [
                // 头像
                ClipOval(
                  child: CachedNetworkImage(
                    imageUrl: avatar,
                    width: 55.w,
                    height: 55.w,
                    fit: BoxFit.cover,
                    errorWidget: (_, __, ___) => Container(
                      width: 55.w,
                      height: 55.w,
                      color: Colors.grey[300],
                      child: Icon(Icons.person, size: 28.sp),
                    ),
                  ),
                ),
                SizedBox(width: 10.w),
                // 名字和实名状态
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Flexible(
                            child: Text(
                              displayName,
                              style: TextStyle(
                                fontSize: 15.sp,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          SizedBox(width: 4.w),
                          Image.asset(
                            'assets/images/zhang.png',
                            width: 19.w,
                            height: 23.h,
                            errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                          ),
                        ],
                      ),
                      SizedBox(height: 4.h),
                      Image.asset(
                        isSigned
                            ? 'assets/images/sign.png'
                            : 'assets/images/no_sign.png',
                        width: 53.w,
                        height: 14.h,
                        errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
                // 团队活跃度
                Column(
                  children: [
                    Text(
                      teamHy,
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '团队活跃度',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
                SizedBox(width: 16.w),
                // 个人活跃度
                Column(
                  children: [
                    Text(
                      hy,
                      style: TextStyle(fontSize: 20.sp, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4.h),
                    Text(
                      '个人活跃度',
                      style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                    ),
                  ],
                ),
              ],
            ),
          ),
          // 下半部分：打卡状态、手机号、注册日期
          Container(
            padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 6.h),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Text(
                  isLq ? '未打卡' : '已打卡',
                  style: TextStyle(fontSize: 13.sp, fontWeight: FontWeight.bold),
                ),
                SizedBox(width: 8.w),
                GestureDetector(
                  onTap: () => _callPhone(phone),
                  child: Text(
                    '手机号:$phone',
                    style: TextStyle(
                      fontSize: 12.sp,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
                SizedBox(width: 8.w),
                Text(
                  '注册日期：$time',
                  style: TextStyle(fontSize: 12.sp, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadMore() {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 12.h),
      child: Center(
        child: Text(
          _loadTitle,
          style: TextStyle(fontSize: 13.sp, color: const Color(0xFF666666)),
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 60.h),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.people_outline, size: 60.sp, color: Colors.grey[300]),
            SizedBox(height: 12.h),
            Text(
              '暂无数据',
              style: TextStyle(fontSize: 14.sp, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
