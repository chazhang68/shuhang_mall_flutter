import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../controllers/merchant_settlement_controller.dart';

/// 商家入驻页面
/// 对应原 pages/annex/settled/index.vue
class MerchantSettlementView extends GetView<MerchantSettlementController> {
  const MerchantSettlementView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFD3D1D),
      appBar: AppBar(
        backgroundColor: const Color(0xFFFD3D1D),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Text(
          '商家入驻',
          style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(child: CircularProgressIndicator(color: Colors.white));
        }

        // 根据状态显示不同内容
        if (controller.status.value == 0) {
          return _buildSuccessView('恭喜，您的资料提交成功！');
        } else if (controller.status.value == 1) {
          return _buildSuccessView('恭喜，您的资料通过审核！');
        } else if (controller.status.value == 2) {
          return _buildRejectedView();
        } else {
          return _buildFormView(context);
        }
      }),
    );
  }

  /// 构建表单视图
  Widget _buildFormView(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        children: [
          const SizedBox(height: 20),
          // 白色卡片
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
            ),
            padding: const EdgeInsets.symmetric(vertical: 22),
            child: Column(
              children: [
                // 代理商名称
                _buildInputField('代理商名称', '请输入代理商名称', controller.merchantNameController),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // 用户姓名
                _buildInputField('用户姓名', '请输入姓名', controller.operatorNameController),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // 联系电话
                _buildInputField('联系电话', '请输入手机号', controller.phoneController,
                    keyboardType: TextInputType.phone),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // 验证码
                _buildCodeField(),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // 邀请码
                _buildInputField('邀请码', '请输入代理商邀请码', controller.inviteCodeController),
                const Divider(height: 1, color: Color(0xFFEEEEEE)),

                // 上传图片
                _buildUploadSection(),

                // 协议勾选
                _buildAgreementSection(),

                // 提交按钮
                _buildSubmitButton(),
              ],
            ),
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  /// 构建输入框
  Widget _buildInputField(String label, String hint, TextEditingController controller,
      {TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Row(
        children: [
          SizedBox(
            width: 95,
            child: Text(
              label,
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: const TextStyle(color: Color(0xFFB2B2B2), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建验证码输入框
  Widget _buildCodeField() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Row(
        children: [
          const SizedBox(
            width: 95,
            child: Text(
              '验证码',
              style: TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
          ),
          Expanded(
            child: TextField(
              controller: controller.codeController,
              decoration: const InputDecoration(
                hintText: '填写验证码',
                hintStyle: TextStyle(color: Color(0xFFB2B2B2), fontSize: 15),
                border: InputBorder.none,
                isDense: true,
                contentPadding: EdgeInsets.zero,
              ),
              style: const TextStyle(fontSize: 15, color: Color(0xFF333333)),
            ),
          ),
          Obx(() => GestureDetector(
                onTap: controller.codeCountdown.value > 0 ? null : controller.sendVerifyCode,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: controller.codeCountdown.value > 0
                          ? const Color(0xFFBBBBBB)
                          : const Color(0xFFE93323),
                    ),
                    borderRadius: BorderRadius.circular(15),
                    color: controller.codeCountdown.value > 0
                        ? const Color(0xFFBBBBBB)
                        : Colors.transparent,
                  ),
                  child: Text(
                    controller.codeCountdown.value > 0
                        ? '${controller.codeCountdown.value}s'
                        : '获取验证码',
                    style: TextStyle(
                      fontSize: 12,
                      color: controller.codeCountdown.value > 0
                          ? Colors.white
                          : const Color(0xFFE93323),
                    ),
                  ),
                ),
              )),
        ],
      ),
    );
  }

  /// 构建上传图片区域
  Widget _buildUploadSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '请上传营业执照及行业相关资质证明图片',
            style: TextStyle(fontSize: 14, color: Color(0xFF666666)),
          ),
          const SizedBox(height: 4),
          const Text(
            '(图片最多可上传10张,图片格式支持JPG、PNG、JPEG)',
            style: TextStyle(fontSize: 11, color: Color(0xFFB2B2B2)),
          ),
          const SizedBox(height: 12),
          Obx(() => Wrap(
                spacing: 11,
                runSpacing: 12,
                children: [
                  // 已上传的图片
                  ...controller.qualificationImages.asMap().entries.map((entry) {
                    int index = entry.key;
                    String imageUrl = entry.value;
                    return _buildImageItem(imageUrl, () => controller.removeQualificationImage(index));
                  }),
                  // 上传按钮
                  if (controller.qualificationImages.length < 10)
                    GestureDetector(
                      onTap: controller.addQualificationImage,
                      child: Container(
                        width: 65,
                        height: 65,
                        decoration: BoxDecoration(
                          border: Border.all(color: const Color(0xFFDDDDDD), width: 0.5),
                          borderRadius: BorderRadius.circular(1),
                        ),
                        child: const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, size: 24, color: Color(0xFFBBBBBB)),
                            SizedBox(height: 2),
                            Text(
                              '上传图片',
                              style: TextStyle(fontSize: 11, color: Color(0xFFBBBBBB)),
                            ),
                          ],
                        ),
                      ),
                    ),
                ],
              )),
        ],
      ),
    );
  }

  /// 构建图片项
  Widget _buildImageItem(String imageUrl, VoidCallback onDelete) {
    return SizedBox(
      width: 65,
      height: 65,
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(1),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              width: 65,
              height: 65,
              fit: BoxFit.cover,
              placeholder: (context, url) => Container(
                color: const Color(0xFFF5F5F5),
                child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
              ),
              errorWidget: (context, url, error) => Container(
                color: const Color(0xFFF5F5F5),
                child: const Icon(Icons.error, color: Colors.grey),
              ),
            ),
          ),
          Positioned(
            top: -5,
            right: -5,
            child: GestureDetector(
              onTap: onDelete,
              child: Container(
                padding: const EdgeInsets.all(2),
                decoration: const BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.close, color: Colors.white, size: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建协议勾选区域
  Widget _buildAgreementSection() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 15, 20, 0),
      child: Row(
        children: [
          Obx(() => GestureDetector(
                onTap: controller.toggleAgree,
                child: Container(
                  width: 15,
                  height: 15,
                  decoration: BoxDecoration(
                    color: controller.isAgree.value ? const Color(0xFFFD151B) : Colors.transparent,
                    border: Border.all(
                      color: controller.isAgree.value
                          ? const Color(0xFFFD151B)
                          : const Color(0xFFC3C3C3),
                      width: 1,
                    ),
                    borderRadius: BorderRadius.circular(7.5),
                  ),
                  child: controller.isAgree.value
                      ? const Icon(Icons.check, size: 12, color: Colors.white)
                      : null,
                ),
              )),
          const SizedBox(width: 8),
          const Text(
            '已阅读并同意',
            style: TextStyle(fontSize: 12, color: Color(0xFFB2B2B2)),
          ),
          GestureDetector(
            onTap: controller.loadMerchantAgreement,
            child: const Text(
              '《代理商协议》',
              style: TextStyle(fontSize: 12, color: Color(0xFFE93323)),
            ),
          ),
        ],
      ),
    );
  }

  /// 构建提交按钮
  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
      child: Obx(() => SizedBox(
            width: double.infinity,
            height: 43,
            child: ElevatedButton(
              onPressed: controller.isAgree.value ? controller.submitApplication : null,
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    controller.isAgree.value ? const Color(0xFFE93323) : const Color(0xFFE3E3E3),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
                elevation: 0,
                disabledBackgroundColor: const Color(0xFFE3E3E3),
              ),
              child: const Text(
                '提交申请',
                style: TextStyle(fontSize: 15, color: Colors.white),
              ),
            ),
          )),
    );
  }

  /// 构建成功视图
  Widget _buildSuccessView(String title) {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/success.png', width: 189, height: 157),
                const SizedBox(height: 35),
                Text(title,
                    style: const TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: OutlinedButton(
                    onPressed: controller.goHome,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFB4B4B4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                    ),
                    child: const Text('返回首页',
                        style: TextStyle(fontSize: 15, color: Color(0xFF282828))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// 构建拒绝视图
  Widget _buildRejectedView() {
    return Container(
      color: Colors.white,
      child: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 56),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset('assets/images/error.png', width: 189, height: 157),
                const SizedBox(height: 35),
                const Text('您的申请未通过！',
                    style: TextStyle(
                        fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF333333))),
                const SizedBox(height: 9),
                Obx(() => controller.refusalReason.value.isNotEmpty
                    ? Text(controller.refusalReason.value,
                        style: const TextStyle(fontSize: 13, color: Color(0xFF999999)))
                    : const SizedBox()),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: ElevatedButton(
                    onPressed: controller.applyAgain,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE93323),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                      elevation: 0,
                    ),
                    child: const Text('重新申请',
                        style: TextStyle(fontSize: 15, color: Colors.white)),
                  ),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 43,
                  child: OutlinedButton(
                    onPressed: controller.goHome,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFB4B4B4)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(60)),
                    ),
                    child: const Text('返回首页',
                        style: TextStyle(fontSize: 15, color: Color(0xFF282828))),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
