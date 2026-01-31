import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/user_sign_controller.dart';

class UserSignView extends GetView<UserSignController> {
  const UserSignView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Obx(
        () => Stack(children: [_buildMainContent(context), _buildSignSuccessDialog(context)]),
      ),
    );
  }

  Widget _buildMainContent(BuildContext context) {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          backgroundColor: Theme.of(context).primaryColor,
          expandedHeight: 234,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).colorScheme.primaryContainer,
                  ],
                ),
              ),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 60, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (controller.userInfo != null) ...[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(50),
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Color(0xFFECDDBC), width: 4),
                                  ),
                                  child: CachedNetworkImage(
                                    imageUrl: controller.userInfo!['avatar'] ?? '',
                                    fit: BoxFit.cover,
                                    placeholder: (context, url) =>
                                        Container(color: Colors.grey[300]),
                                    errorWidget: (context, url, error) => Icon(Icons.person),
                                  ),
                                ),
                              ),
                              SizedBox(width: 15),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    controller.userInfo!['nickname'] ?? '',
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 10),
                                  Container(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                                    decoration: BoxDecoration(
                                      color: Color(0xFFFF9000),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      '消费券: ${(controller.userInfo!['integral'] ?? 0).toStringAsFixed(0)}',
                                      style: TextStyle(fontSize: 14, color: Colors.white),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              controller.goToSignRecord();
                            },
                            child: Container(
                              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.only(
                                  topLeft: Radius.circular(0),
                                  topRight: Radius.circular(25),
                                  bottomLeft: Radius.circular(25),
                                  bottomRight: Radius.circular(25),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Icon(Icons.list_alt, size: 18, color: Color(0xFFFF9000)),
                                  SizedBox(width: 5),
                                  Text(
                                    '明细',
                                    style: TextStyle(fontSize: 14, color: Color(0xFFFF9000)),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.symmetric(horizontal: 20),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // 签到系统列表
                    _buildSignSystemList(context),

                    SizedBox(height: 20),

                    // 签到按钮
                    _buildSignButton(context),

                    SizedBox(height: 10),

                    // 底部装饰
                    Container(
                      height: 68,
                      decoration: BoxDecoration(
                        image: DecorationImage(
                          image: AssetImage('assets/images/sign_lock.png'),
                          fit: BoxFit.contain,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Container(
            margin: EdgeInsets.only(top: 15),
            child: Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 73, 20, 20),
                child: Column(
                  children: [
                    Text('已累计签到', style: TextStyle(fontSize: 16, color: Color(0xFF666666))),
                    SizedBox(height: 15),

                    // 累计签到天数
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        for (int i = 0; i < controller.signCount.length; i++)
                          Container(
                            width: 80,
                            height: 116,
                            margin: EdgeInsets.only(
                              right: i == controller.signCount.length - 1 ? 0 : 19,
                            ),
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              image: DecorationImage(
                                image: AssetImage('assets/images/sign_number_bg.png'),
                                fit: BoxFit.cover,
                              ),
                            ),
                            child: Center(
                              child: Text(
                                controller.signCount[i].toString(),
                                style: TextStyle(
                                  fontSize: 72,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        SizedBox(width: 10),
                        Text('天', style: TextStyle(fontSize: 20, color: Color(0xFF232323))),
                      ],
                    ),

                    SizedBox(height: 15),

                    Text(
                      '据说连续签到第${controller.rp(controller.signSystemList.length)}天可获得超额消费券，一定要坚持签到哦~~~',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 15, color: Color(0xFF999999)),
                    ),

                    SizedBox(height: 20),

                    // 签到记录列表
                    _buildSignRecordList(),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSignSystemList(BuildContext context) {
    return SizedBox(
      height: 240,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: controller.signSystemList.length,
        itemBuilder: (context, index) {
          final item = controller.signSystemList[index];
          final dayText = index + 1 == controller.signSystemList.length
              ? '奖励'
              : item['day']?.toString() ?? '${index + 1}';

          return Container(
            width: 100,
            margin: EdgeInsets.symmetric(horizontal: 10),
            child: Column(
              children: [
                Text(
                  dayText,
                  style: TextStyle(
                    fontSize: 16,
                    color: index + 1 <= controller.signIndex
                        ? Color(0xFFFF9000)
                        : Color(0xFF8A8886),
                  ),
                ),
                SizedBox(height: 10),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: index + 1 <= controller.signIndex
                        ? Color(0xFFFF9000)
                        : Color(0xFFCCCCCC),
                    borderRadius: BorderRadius.circular(28),
                  ),
                  child: Center(
                    child: Text(
                      '+${item['sign_num'] ?? 0}',
                      style: TextStyle(
                        fontSize: 16,
                        color: index + 1 <= controller.signIndex ? Colors.white : Color(0xFF999999),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSignButton(BuildContext context) {
    return SizedBox(
      width: 400,
      height: 76,
      child: ElevatedButton(
        onPressed: controller.isSignedToday
            ? null
            : () {
                controller.sign();
              },
        style: ElevatedButton.styleFrom(
          backgroundColor: controller.isSignedToday ? Colors.grey : Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(50)),
        ),
        child: Text(
          controller.isSignedToday ? '已签到' : '立即签到',
          style: TextStyle(fontSize: 18, color: Colors.white),
        ),
      ),
    );
  }

  Widget _buildSignRecordList() {
    return Column(
      children: [
        for (int i = 0; i < controller.signList.length; i++)
          _buildSignRecordItem(controller.signList[i]),

        if (controller.signList.length >= 3)
          GestureDetector(
            onTap: () {
              controller.goToSignRecord();
            },
            child: SizedBox(
              height: 97,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('点击加载更多', style: TextStyle(fontSize: 16, color: Color(0xFF282828))),
                  Icon(Icons.arrow_forward_ios, size: 16, color: Color(0xFF212121)),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSignRecordItem(dynamic item) {
    return Container(
      height: 130,
      padding: EdgeInsets.symmetric(vertical: 15),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFEEEEEE), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  item['title'] ?? '',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(fontSize: 16, color: Color(0xFF232323)),
                ),
                SizedBox(height: 10),
                Text(
                  item['add_time'] ?? '',
                  style: TextStyle(fontSize: 12, color: Color(0xFFBBBBBB)),
                ),
              ],
            ),
          ),
          Text(
            '+${item['number'] ?? 0}',
            style: TextStyle(fontSize: 18, color: Color(0xFFE93323), fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  Widget _buildSignSuccessDialog(BuildContext context) {
    return Obx(
      () => controller.showSignSuccessDialog
          ? Positioned.fill(
              child: Container(
                color: Colors.black.withAlpha((0.5 * 255).round()),
                child: Center(
                  child: Container(
                    width: 644,
                    height: 645,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Image.asset('assets/images/sign_success.png', width: 100, height: 100),
                        SizedBox(height: 20),
                        Text('签到成功', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                        SizedBox(height: 10),
                        Text(
                          '获得 ${(controller.receivedIntegral).toStringAsFixed(0)} 消费券',
                          style: TextStyle(fontSize: 18, color: Color(0xFF666666)),
                        ),
                        SizedBox(height: 30),
                        ElevatedButton(
                          onPressed: () {
                            controller.closeSignSuccessDialog();
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                          ),
                          child: Text('好的', style: TextStyle(fontSize: 16, color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          : SizedBox.shrink(),
    );
  }
}
