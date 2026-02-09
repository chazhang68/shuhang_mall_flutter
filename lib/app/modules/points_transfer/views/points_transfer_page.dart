import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/points_transfer_controller.dart';

/// 积分转赠页面
/// 对应原 uni-app 代码中的积分转赠功能
class PointsTransferPage extends GetView<PointsTransferController> {
  const PointsTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('积分转赠'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.w),
        child: Column(
          children: [
            // 转给
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '转给',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Text(
                        '积分地址',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                      SizedBox(width: 20.w),
                      Expanded(
                        child: TextField(
                          controller: controller.phoneController,
                          keyboardType: TextInputType.number,
                          maxLength: 11,
                          decoration: InputDecoration(
                            hintText: '请输入转入手机号',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            counterText: '',
                          ),
                          textAlign: TextAlign.right,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 12.h),
                  Obx(() => Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '可用积分数量${controller.availablePoints.value.toStringAsFixed(0)}个',
                            style: TextStyle(fontSize: 14.sp),
                          ),
                          GestureDetector(
                            onTap: controller.transferAll,
                            child: Text(
                              '全部转赠',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF377CF5),
                              ),
                            ),
                          ),
                        ],
                      )),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 转出数量
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '转出数量',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: controller.amountController,
                          keyboardType: TextInputType.number,
                          decoration: InputDecoration(
                            hintText: '请输入转出数量',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                        ),
                      ),
                      Text(
                        '个',
                        style: TextStyle(fontSize: 14.sp),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 手续费
            _buildCard(
              child: Row(
                children: [
                  Expanded(
                    child: Row(
                      children: [
                        Text('手续费', style: TextStyle(fontSize: 14.sp)),
                        SizedBox(width: 12.w),
                        Obx(() => Text(
                              '${controller.feeRate.value}%',
                              style: TextStyle(
                                fontSize: 14.sp,
                                color: const Color(0xFF377CF5),
                              ),
                            )),
                      ],
                    ),
                  ),
                  Row(
                    children: [
                      Text('损耗数量', style: TextStyle(fontSize: 14.sp)),
                      SizedBox(width: 12.w),
                      Obx(() => Text(
                            '${controller.feeAmount.value.toStringAsFixed(3)}个',
                            style: TextStyle(
                              fontSize: 14.sp,
                              color: const Color(0xFF377CF5),
                            ),
                          )),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 实际到账数量
            _buildCard(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('实际到账数量', style: TextStyle(fontSize: 14.sp)),
                  Obx(() => Text(
                        '${controller.actualAmount.value.toStringAsFixed(2)}个',
                        style: TextStyle(
                          fontSize: 14.sp,
                          color: const Color(0xFF377CF5),
                        ),
                      )),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 交易密码
            _buildCard(
              child: Row(
                children: [
                  Text('交易密码', style: TextStyle(fontSize: 14.sp)),
                  SizedBox(width: 20.w),
                  Expanded(
                    child: TextField(
                      controller: controller.passwordController,
                      obscureText: true,
                      maxLength: 6,
                      keyboardType: TextInputType.number,
                      decoration: InputDecoration(
                        hintText: '请输入交易密码',
                        hintStyle: TextStyle(
                          color: Colors.grey,
                          fontSize: 14.sp,
                        ),
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16.h),

            // 备注信息
            _buildCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '备注信息',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  SizedBox(height: 16.h),
                  TextField(
                    controller: controller.remarkController,
                    maxLength: 30,
                    decoration: InputDecoration(
                      hintText: '30字以内',
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 14.sp,
                      ),
                      border: InputBorder.none,
                      counterText: '',
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 50.h),

            // 确认转赠按钮
            Obx(() => GestureDetector(
                  onTap: controller.isLoading.value ? null : controller.confirmTransfer,
                  child: Container(
                    width: double.infinity,
                    height: 50.h,
                    decoration: BoxDecoration(
                      color: const Color(0xFF377CF5),
                      borderRadius: BorderRadius.circular(25.r),
                    ),
                    alignment: Alignment.center,
                    child: Text(
                      '确认转赠',
                      style: TextStyle(
                        fontSize: 16.sp,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                )),
            SizedBox(height: 50.h),
          ],
        ),
      ),
    );
  }

  /// 构建卡片
  Widget _buildCard({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8.r),
      ),
      child: child,
    );
  }
}
