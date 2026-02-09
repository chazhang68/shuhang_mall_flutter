<template>
  <view :style="colorStyle">
    <view style="background: #FF5A5A">
      <view class="sys-head">
        <view class="sys-bar" :style="{height:sysHeight}"></view>
      </view>
    </view>
    <view class='commission-details'>
      <view class="my-account-container position-relative">
        <!--        导航栏-->
        <view class="position-relative flex justify-center align-center">
          <text class="my-account-title">我的账户</text>
          <view class="position-absolute left-0 ml-3" @click="navigateBack">
            <uni-icons type="arrow-left" size="30" color="#FFFFFF"></uni-icons>
          </view>
        </view>
        <!--        金币图-->
       <!-- <view class="gold-price-image position-absolute right-0"></view> -->
        <!--        余额-->
		<view class="flex align-end justify-between">
			<view class="price-text-container flex flex-column justify-center">
			  <text class="price-text">{{ title }}</text>
			  <text class="price-num">{{ number }}</text>
			</view>
			<view class="pr-4">
				<view class="bg-white p-2 rounded font-ll" @click="goUrl('/pages/users/jifendswp/jifendswp')" v-if="current == 1 ||current == 0 ">
					积分兑换消费券
				</view>
				<view class="bg-white p-2 rounded font-ll" @click="goUrl('/pages/users/swpdjifen/swpdjifen')" v-if="current == 2">
					消费券兑换积分
				</view>
			</view>
		</view>
        
      </view>
      <view class="sign-record w-100 select-btn-container">
        <view class="p-4 flex justify-center align-center">
          <view class="select-btn flex align-center justify-center" @click="onClickItem(index)"
                v-for="(item,index) in items" :key="index" :class="{active: index == current}">
            <text>{{ item }}</text>
          </view>
        </view>
      </view>
      <view class='sign-record' style="background: none">
        <view class='list'>
          <view class='item' v-for="(item) in showDataList">
            <view class='listn'>
              <view class='itemn acea-row row-between-wrapper'>
                <view class="title">
                  <view class='name line1 sign-record-title' >{{ item.title.replace('SWP', '消费券') }}</view>
                  <view class="sign-record-date" style="margin-top: 21rpx">时间：{{ item.add_time }}</view>
                </view>
                <view class="flex flex-column justify-center align-end">
                  <view class='sign-record-font' v-if="item.pm == 1">+{{ current == 1 || current == 0 ?item.num :item.number }}</view>
                  <view class='sign-record-font black' v-else>-{{ current == 1 || current == 0 ?item.num :item.number }}</view>
                  <view class="sign-record-date" style="margin-top: 21rpx">{{ item.title.replace('SWP', '消费券') }}</view>
                </view>
              </view>
            </view>
          </view>
        </view>
        <view class='loadingicon acea-row row-center-wrapper' v-if="showDataList.length">
          <text class='loading iconfont icon-jiazai' :hidden='loading==false'></text>
          {{ loadTitle }}
        </view>
        <view v-if="showDataList.length < 1 && page >= 1">
          <emptyPage :title='$t(`暂无数据~`)'></emptyPage>
        </view>
      </view>
    </view>
    <!-- #ifdef H5 -->
    <!--    <home></home>-->
    <!-- #endif -->
  </view>
</template>

<script>
import {
  getUserInfo, getRyzList, getGxzList, getCommissionInfo, getIntegralList,getFudouList
} from '@/api/user.js';
import {
  toLogin
} from '@/libs/login.js';
import {
  mapGetters
} from "vuex";
// #ifdef MP
import authorize from '@/components/Authorize';
// #endif
import emptyPage from '@/components/emptyPage.vue'
import home from '@/components/home';
import colors from '@/mixins/color.js';

let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';

export default {
  components: {
    // #ifdef MP
    authorize,
    // #endif
    emptyPage,
    home
  },
  mixins: [colors],
  data() {
    const currentDate = this.getDate({
      format: true
    })
    return {
      sysHeight: sysHeight,
      currentDate: currentDate,
      items: ['仓库积分','可用积分','消费券'],
      current: 0,
      // 展示出的内容
      showDataList: [],

      name: '',
      userBillList: [],
      type: 0,
      page: 1,
      limit: 15,
      loading: false,
      loadend: false,
      loadTitle: this.$t(`加载更多`),
      recordList: [],
      recordCount: 0,
      extractCount: 0,
      times: [],
      userInfo: [],
      ryz: '',
      // 标题
      title: '',
      // 数字
      number: '',
      // 余额列表
      yueList: [],
      // 积分列表
      fuDouList: [],
    };
  },
  computed: {
    ...mapGetters(['isLogin']),
    // startDate() {
    //   return this.getDate('start');
    // },
    // endDate() {
    //   return this.getDate('end');
    // }
  },
  onLoad(options) {
    if (this.isLogin) {
      this.current = parseInt(options.index)
      getUserInfo().then(res => {
        this.userInfo = res.data
        this.initData()
      })
    } else {
      toLogin();
    }
  },
  onShow: function () {
    if (!this.isLogin) {
      toLogin();
    }
  },
  /**
   * 页面上拉触底事件的处理函数
   */
  onReachBottom: function () {
    switch (this.current) {
      case 0:
        this.getRecordList(getFudouList)
        break;
      case 1:
        this.getRecordList(getFudouList)
        break;
	  case 2:
		this.getRecordList(getCommissionInfo)
	    break;
    }
  },
  onPullDownRefresh() {
    this.yueList = []
    this.fuDouList = []
    this.page = 1
    this.initData()
  },
  methods: {
    initData(){
      this.getAllData(getCommissionInfo, this.yueList)
      this.getAllData(getFudouList, this.fuDouList)
      this.changeShowData()
    },
    onClickItem(index) {
      if (this.current != index) {
        this.current = index;
        this.loadend = false;
        this.loading = false;
        // this.page = 1;
        this.showDataList = []
        this.changeShowData()
      }
    },
    // 切换数据
    changeShowData(){
      let { current, userInfo } = this
      switch (current) {
        case 2:
          this.showDataList = this.yueList
          this.title = '消费券'
          this.number = userInfo.now_money
          break;
        case 0:
          this.showDataList = this.fuDouList
          this.title = '仓库积分'
          this.number = userInfo.fudou
          break;
		case 1:
		  this.showDataList = this.fuDouList
		  this.title = '可用积分'
		  this.number = userInfo.fd_ky
		  break;  
      }
      uni.stopPullDownRefresh()
    },

    getRecordList(callback) {
      console.log('start')
      let page = this.page;
      let limit = this.limit;
      if (this.loading) return;
      if (this.loadend) return;
      this.loading = true;
      this.loadTitle = ''
      console.log('end')
      callback({
        page: page,
        limit: limit,
        pm: 0
      }, 0).then(res => {
        let loadend = res.data.length < this.limit;
        this.loadend = loadend;
        this.showDataList = this.$util.SplitArray(res.data, this.showDataList);
        this.$set(this, `showDataList`, this.showDataList);
        this.loadTitle = loadend ? this.$t(`我也是有底线的`) : this.$t(`加载更多`);
        this.page += 1;
        this.loading = false;
      }).catch(err => {
        this.loading = false;
        this.loadTitle = this.$t(`加载更多`);
      })
    },

    // 获取每个的数据
    getAllData(callback, dataList) {
      let page = this.page;
      let limit = this.limit;
      callback({
        page: page,
        limit: limit,
        pm: 0
      }, 0).then(res => {
        // let loadend = res.data.length < this.limit;
        // this.loadend = loadend;
        dataList = this.$util.SplitArray(res.data, dataList);
        // this.loadTitle = loadend ? this.$t(`我也是有底线的`) : this.$t(`加载更多`);
        this.loadTitle = this.$t(`加载更多`);
        this.page = 2;
      }).catch(err => {
      })
    },

    bindDateChange: function (e) {
      this.currentDate = e.detail.value
    },
    getDate(type) {
      const date = new Date();
      let year = date.getFullYear();
      let month = date.getMonth() + 1;
      if (type === 'start') {
        year = year - 60;
      } else if (type === 'end') {
        year = year + 2;
      }
      month = month > 9 ? month : '0' + month;
      return `${year}-${month}`;
    },

    navigateBack() {
      uni.navigateBack()
    },
    goUrl(url) {
      uni.navigateTo({
        url:url,
      })
    },
  },

}
</script>

<style scoped lang="scss">
$background-color: #FFFFFF;
.commission-details .promoterHeader .headerCon .money {
  font-size: 36rpx;
}

.commission-details .promoterHeader .headerCon .money {
  font-family: 'Guildford Pro';
}

.sign-record .list .item .listn .itemn .name {
  width: 100%;
  // max-width: 100%;
  white-space: break-spaces;
}

.sign-record .list .item .listn .itemn .title {
  padding-right: 30rpx;
  flex: 1;
}

.my-account-container {
  width: 750rpx;
  height: 464rpx;
  background: #FF5A5A;

  .my-account-title {
    font-weight: 600;
    font-size: 32rpx;
    color: #FFFFFF;
  }

  .gold-price-image {
    background-image: url("/static/my-account/gold.png");
    background-size: 100% 100%;
    background-repeat: no-repeat;
    width: 560rpx;
    height: 743rpx;
    top: -100rpx;
  }

  .price-text-container {
    margin-left: 64rpx;
    margin-top: 83rpx;
  }

  .price-text {
    font-weight: 600;
    font-size: 28rpx;
    color: #FFFFFF;
  }

  .price-num {
    padding-top: 45rpx;
    font-family: DIN Alternate;
    font-weight: bold;
    font-size: 58rpx;
    color: #FFFFFF;
  }
}

.sign-record {
  background: $background-color;
}

.select-btn-container {
  height: 151rpx;
  border-radius: 35rpx 35rpx 0 0;
  margin-top: -130rpx;
  position: relative;
  z-index: 99;

  .select-btn {
    width: 180rpx;
    height: 70rpx;
    background: #F6F7F9;
    border-radius: 35rpx;
    margin-left: 15rpx;
    margin-right: 15rpx;

    & text {
      font-weight: 400;
      font-size: 30rpx;
      color: #000000;
    }
  }
}

.years-month-text {
  font-family: PingFang SC;
  font-weight: 500;
  font-size: 28rpx;
  color: #333333;
}

.consume-text text {
  font-family: Adobe Heiti Std;
  font-weight: normal;
  font-size: 24rpx;
  color: #666666;
}

.sign-record-title {
  font-family: PingFang SC;
  font-weight: 600;
  font-size: 28rpx;
  color: #333333;
}

.sign-record-date {
  font-family: PingFang SC;
  font-weight: 400;
  font-size: 24rpx;
  color: #333333;
}

.sign-record-font {
  font-family: DIN Alternate;
  font-weight: bold;
  font-size: 32rpx;
  color: #FF5A5A;
}

.black {
  font-family: DIN Alternate;
  font-weight: bold;
  font-size: 32rpx;
  color: #333333;
}

.active {
  background: #FF5A5A !important;

  & text {
    color: #FFFFFF !important;
  }
}
</style>
