import 'package:flutter/material.dart';
import 'package:easy_refresh/easy_refresh.dart';
import 'package:get/get.dart';
import '../controllers/user_sign_record_controller.dart';

class UserSignRecordView extends GetView<UserSignRecordController> {
  const UserSignRecordView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('签到记录'),
        centerTitle: true,
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
      ),
      body: EasyRefresh(
        header: const ClassicHeader(
          dragText: '下拉刷新',
          armedText: '松手刷新',
          processingText: '刷新中...',
          processedText: '刷新完成',
          failedText: '刷新失败',
        ),
        onRefresh: () async {
          await controller.refresh();
        },
        child: Obx(() {
          if (controller.isLoading) {
            return Center(child: CircularProgressIndicator());
          }

          if (controller.signRecords.isEmpty) {
            return ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.event_note, size: 60, color: Colors.grey[400]),
                      SizedBox(height: 16),
                      Text('暂无签到记录', style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView.builder(
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: controller.signRecords.length,
            itemBuilder: (context, index) {
              final record = controller.signRecords[index];
              return _buildSignRecordItem(record);
            },
          );
        }),
      ),
    );
  }

  Widget _buildSignRecordItem(dynamic record) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withAlpha((0.1 * 255).round()),
            blurRadius: 4,
            offset: Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  record['title'] ?? '',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                SizedBox(height: 4),
                Text(
                  record['add_time'] ?? '',
                  style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: Color(0xFFFF9000),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '+${record['number'] ?? 0}',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
