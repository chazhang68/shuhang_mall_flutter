z<template>
  <view>
    <view class="top" :style="colorStyle">
      <view class="sys-head">
        <view class="sys-bar" :style="{height:sysHeight}"></view>
      </view>
    </view>

<!--    个人信息列表-->
    <view class="mx-2">
      <navigator url="/pages/users/user_info/index" animation-type="fade-in" animation-duration="100" hover-class="none">
        <view class="header-bac align-center flex justify-between px-3" style="padding-top: 15rpx;padding-bottom: 15rpx">
          <image style="width: 120rpx;height: 120rpx;border-radius: 50%" :src="userInfo.avatar"></image>
          <view class="flex align-center">
            <text class="set-person-info-txt mr-2">个人信息</text>
            <uni-icons style="margin-top: 1px" type="right" ></uni-icons>
          </view>
        </view>
      </navigator>

      <view class="mt-2 info-list-center flex flex-column px-3">
        <navigator url="/pages/users/user_account_safe/index" animation-type="fade-in" animation-duration="100" hover-class="none">
          <view class="flex justify-between align-center person-info-list-text" style="padding-top: 34rpx;padding-bottom: 35rpx">
            <text>账户与安全</text>
            <view class="flex align-center">
              <uni-icons style="margin-top: 1px" type="right"></uni-icons>
            </view>
          </view>
        </navigator>

        <view class="set-line"></view>

        <view @click="initData" class="flex justify-between align-center" style="padding-top: 34rpx;padding-bottom: 35rpx">
          <text class="font-weight-nn">清除缓存</text>
          <view class="flex align-center">
            <uni-icons style="margin-top: 1px" type="right" ></uni-icons>
          </view>
        </view>
        <view class="set-line"></view>

        <view @click="updateApp" class="flex justify-between align-center" style="padding-top: 34rpx;padding-bottom: 35rpx">
          <text class="font-weight-nn">检查版本</text>
          <view class="flex align-center">
            <uni-icons style="margin-top: 1px" type="right" ></uni-icons>
          </view>
        </view>
        <view class="set-line"></view>

        <navigator url="/pages/users/about_us/index" hover-class="none" animation-type="fade-in" animation-duration="100">
        <view class="flex justify-between align-center" style="padding-top: 34rpx;padding-bottom: 35rpx">
          <text class="font-weight-nn">关于</text>
          <view class="flex align-center">
            <uni-icons style="margin-top: 1px" type="right" ></uni-icons>
          </view>
        </view>
        </navigator>
		<navigator url="/pages/users/user_cancellation/index" hover-class="none" animation-type="fade-in" animation-duration="100">
		<view class="flex justify-between align-center" style="padding-top: 34rpx;padding-bottom: 35rpx">
		  <text class="font-weight-nn">注销账号</text>
		  <view class="flex align-center">
		    <uni-icons style="margin-top: 1px" type="right" ></uni-icons>
		  </view>
		</view>
		</navigator>
      </view>
      <!-- #ifdef APP-PLUS -->
      <app-update ref="appUpdate" :force="true" :tabbar="false" :getVer='true' @isNew="isNew"></app-update>
      <!-- #endif -->
<!--      退出登陆-->
      <view @click="outLogin" class="header-bac mt-5 flex justify-center align-center logout-text" style="height: 98rpx;">
        退出登陆
      </view>
    </view>
  </view>
</template>

<script>

let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';
import colors from '@/mixins/color';
import contentList from "@/components/contentList/index.vue"
import Cache from '@/utils/cache';
import appUpdate from "@/components/update/app-update.vue";

import {
  getUserInfo,
  userEdit,
  getLogout,
  getLangList,
  getLangJson,
  mpBindingPhone
} from '@/api/user.js';
import {
  toLogin
} from '@/libs/login.js';
import {
  mapGetters
} from "vuex";
export default {
  components: {
    contentList,
    // #ifdef APP-PLUS
    appUpdate
    // #endif
  },
  mixins: [colors],
  data() {
    return {
      sysHeight: sysHeight,
      userInfo: {},
      loginType: 'h5', //app.globalData.loginType
      userIndex: 0,
      switchUserInfo: [],
    }
  },
  computed: mapGetters(['isLogin']),
  watch: {
    isLogin: {
      handler: function (newV, oldV) {
        if (newV) {
          this.getUserInfo();
        }
      },
      deep: true
    }
  },
  onLoad() {
    if (this.isLogin) {
      this.getUserInfo();
      this.getLangList()
      // #ifdef APP-PLUS
      this.formatSize()
      // 获取版本号
      plus.runtime.getProperty(plus.runtime.appid, (inf) => {
        this.version = inf.version;
      });
      // #endif
    } else {
      toLogin();
    }
  },
  methods: {
    navigateBack(){
      uni.navigateBack()
    },
    /**
     * 获取用户详情
     */
    getUserInfo: function () {
      let that = this;
      getUserInfo().then(res => {
        that.$set(that, 'userInfo', res.data);
        let switchUserInfo = res.data.switchUserInfo || [];
        for (let i = 0; i < switchUserInfo.length; i++) {
          if (switchUserInfo[i].uid == that.userInfo.uid) that.userIndex = i;
          // 切割h5用户；user_type状态：h5、routine（小程序）、wechat（公众号）；注：只有h5未注册手机号时，h5才可和小程序或是公众号数据想通；
          //#ifdef H5
          if (
              !that.$wechat.isWeixin() &&
              switchUserInfo[i].user_type != "h5" &&
              switchUserInfo[i].phone === ""
          )
            switchUserInfo.splice(i, 1);
          //#endif
        }
        that.$set(that, "switchUserInfo", switchUserInfo);
      });
    },

    getLangList() {
      getLangList().then(res => {
        this.array = res.data
        this.setLang();
      })
    },

    formatSize() {
      let that = this;
      plus.cache.calculate(function (size) {
        let sizeCache = parseInt(size);
        if (sizeCache == 0) {
          that.fileSizeString = "0B";
        } else if (sizeCache < 1024) {
          that.fileSizeString = sizeCache + "B";
        } else if (sizeCache < 1048576) {
          that.fileSizeString = (sizeCache / 1024).toFixed(2) + "KB";
        } else if (sizeCache < 1073741824) {
          that.fileSizeString = (sizeCache / 1048576).toFixed(2) + "MB";
        } else {
          that.fileSizeString = (sizeCache / 1073741824).toFixed(2) + "GB";
        }
      });
    },
    setLang() {
      this.array.map((item, i) => {
        if (this.$i18n.locale == item.value) {
          this.setIndex = i
        }
      })
    },

    // 清除缓存
    initData() {
      let that = this
      uni.showModal({
        title: this.$t(`清除缓存`),
        content: this.$t(`确定清楚本地缓存数据吗`),
        success: (res) => {
          if (res.confirm) {
            this.clearCache()
            this.formatSize()
          } else if (res.cancel) {
            return that.$util.Tips({
              title: that.$t(`取消`)
            });
          }
        }
      });
    },
    clearCache() {
      let that = this;
      let os = plus.os.name;
      if (os == 'Android') {
        let main = plus.android.runtimeMainActivity();
        let sdRoot = main.getCacheDir();
        let files = plus.android.invoke(sdRoot, "listFiles");
        let len = files.length;
        for (let i = 0; i < len; i++) {
          let filePath = '' + files[i]; // 没有找到合适的方法获取路径，这样写可以转成文件路径
          plus.io.resolveLocalFileSystemURL(filePath, function (entry) {
            if (entry.isDirectory) {
              entry.removeRecursively(function (entry) { //递归删除其下的所有文件及子目录
                uni.showToast({
                  title: that.$t(`缓存清理完成`),
                  duration: 2000
                });
                that.formatSize(); // 重新计算缓存
              }, function (e) {
                console.log(e.message)
              });
            } else {
              entry.remove();
            }
          }, function (e) {
          });
        }
      } else { // ios暂时未找到清理缓存的方法，以下是官方提供的方法，但是无效，会报错
        plus.cache.clear(function () {
          uni.showToast({
            title: that.$t(`缓存清理完成`),
            duration: 2000
          });
          that.formatSize();
        });
      }
    },

    /**
     * 退出登录
     *
     */
    outLogin: function () {
      let that = this;
      if (that.loginType == 'h5') {
        uni.showModal({
          title: that.$t(`提示`),
          content: that.$t(`确认退出登录`),
          success: function (res) {
            if (res.confirm) {
              getLogout()
                  .then(res => {
                    // uni.clearStorage()
                    that.$store.commit("LOGOUT");
                    uni.reLaunch({
                      url: '/pages/index/index'
                    })
                  })
                  .catch(err => {
                  });
            } else if (res.cancel) {
            }
          }
        });
      }
    },
    isNew() {
      this.$util.Tips({
        title: this.$t(`当前为最新版本`)
      });
    },
    updateApp() {
      this.$refs.appUpdate.update(); //调用子组件 检查更新
    },
  }
}
</script>

<style lang="scss">
page {
  font-family: PingFang SC;
}

$set-card-background-color: #FFFFFF;
$set-card-font-color: #000000;
$set-card-border-radius: 15rpx;
$set-font-weight: 500;

.page-title {
  font-weight: 600;
  font-size: 32rpx;
  color: $set-card-font-color;
}

.header-bac {
  width: 710rpx;
  height: 150rpx;
  background: $set-card-background-color;
  border-radius: $set-card-border-radius;

  .set-person-info-txt {
    font-weight: $set-font-weight;
    font-size: 26rpx;
    color: $set-card-font-color;
  }
}

.info-list-center {
  background: $set-card-background-color;
  border-radius: $set-card-border-radius;
}

.set-line {
  width: 650rpx;
  height: 1rpx;
  background: #E6E6E6;
}

.logout-text {
  font-weight: $set-font-weight;
  font-size: 28rpx;
  color: #000000;
}

.person-info-list-text text{
  font-weight: $set-font-weight;
  font-size: 28rpx;
  color: $set-card-font-color;
}
</style>
