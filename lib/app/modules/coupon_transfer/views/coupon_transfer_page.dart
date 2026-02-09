import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import '../controllers/coupon_transfer_controller.dart';

/// 消费券互转页面
class CouponTransferPage extends GetView<CouponTransferController> {
  const CouponTransferPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F5F5),
      appBar: AppBar(
        title: const Text('消费券互转'),
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
                        '消费券地址',
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
                            filled: false,
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
                            '可用消费券数量${controller.availableBalance.value.toStringAsFixed(2)}个',
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
                          keyboardType: const TextInputType.numberWithOptions(decimal: true),
                          decoration: InputDecoration(
                            hintText: '请输入转出数量',
                            hintStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: 14.sp,
                            ),
                            border: InputBorder.none,
                            filled: false,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
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
                        filled: false,
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
                      filled: false,
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
