<template>
	<view>
		<view class='integral-details' :style="colorStyle">
			<view class='header'>
				<view class='currentScore' style="color: #666;">{{$t(`当前消费券`)}}</view>
				<view class="scoreNum" style="color: #666;">{{userInfo.integral}}</view>
				

			</view>
			<view class='wrapper'>
				
				<view class='list' :class="{'bag-white': integralList.length}" >
			
					<view class='item acea-row row-between-wrapper' v-for="(item,index) in integralList" :key="index">
						<view>
							<view class='state'>{{$t(item.title)}}</view>
							<view>{{item.add_time}}</view>
						</view>
						<view class='num font-color' v-if="item.pm">+{{item.number}}</view>
						<view class='num' v-else>-{{item.number}}</view>
					</view>
					<view class='loadingicon acea-row row-center-wrapper' v-if="integralList.length>0">
						<text class='loading iconfont icon-jiazai' :hidden='loading==false'></text>{{loadTitle}}
					</view>
					<view class="no-thing" v-if="integralList.length == 0">
						<emptyPage :title="$t(`暂无消费券记录哦～`)"></emptyPage>
					</view>
				</view>

			</view>
		</view>
		<!-- #ifdef MP -->
		<!-- <authorize @onLoadFun="onLoadFun" :isAuto="isAuto" :isShowAuth="isShowAuth" @authColse="authColse"></authorize> -->
		<!-- #endif -->
	</view>
</template>

<script>
	import {
		postSignUser,
		getIntegralList,
		getUserInfo
	} from '@/api/user.js';
	import dayjs from '@/plugin/dayjs/dayjs.min.js';
	import {
		toLogin
	} from '@/libs/login.js';
	import {
		mapGetters
	} from "vuex";
	// #ifdef MP
	import authorize from '@/components/Authorize';
	// #endif
	import emptyPage from '@/components/emptyPage.vue';
	import colors from '@/mixins/color'
	export default {
		components: {
			// #ifdef MP
			authorize,
			// #endif
			emptyPage
		},
		filters: {
			dateFormat: function(value) {
				return dayjs(value * 1000).format('YYYY-MM-DD');
			}
		},
		mixins: [colors],
		data() {
			return {
				navList: [{
						'name': this.$t(`消费券明细`),
						'icon': 'icon-mingxi'
					},
					{
						'name': this.$t(`获取消费券`),
						'icon': 'icon-tishengfenzhi'
					}
				],
				current: 0,
				page: 1,
				limit: 10,
				integralList: [],
				userInfo: {},
				loadend: false,
				loading: false,
				loadTitle: this.$t(`加载更多`),
				isAuto: false, //没有授权的不会自动授权
				isShowAuth: false, //是否隐藏授权
				isTime: 0
			};
		},
		computed: mapGetters(['isLogin']),
		watch: {
			isLogin: {
				handler: function(newV, oldV) {
					if (newV) {
						this.getUserInfo();
						this.getIntegralList();
					}
				},
				deep: true
			}
		},
		onLoad() {
			if (this.isLogin) {
				this.getUserInfo();
				this.getIntegralList();
			} else {
				toLogin();
			}
		},
		
		/**
		 * 页面上拉触底事件的处理函数
		 */
		onReachBottom: function() {
			this.getIntegralList();
		},
		methods: {
			zhuanzeng(){
				uni.navigateTo({
					url:'/pages/users/zhuanzeng/zhuanzeng'
				})
			},
			/**
			 * 授权回调
			 */
			onLoadFun: function() {
				this.getUserInfo();
				this.getIntegralList();
			},
			// 授权关闭
			authColse: function(e) {
				this.isShowAuth = e
			},
			getUserInfo: function() {
				getUserInfo().then(res=>{
					this.userInfo = res.data
				})
			},

			/**
			 * 获取消费券明细
			 */
			getIntegralList: function() {
				let that = this;
				if (that.loading) return;
				if (that.loadend) return;
				that.loading = true;
				that.loadTitle = '';
				getIntegralList({
					page: that.page,
					limit: that.limit
				}).then(function(res) {
					let list = res.data,
						loadend = list.length < that.limit;
					that.integralList = that.$util.SplitArray(list, that.integralList);
					that.$set(that, 'integralList', that.integralList);
					that.page = that.page + 1;
					that.loading = false;
					that.loadend = loadend;
					that.loadTitle = loadend ? that.$t(`我也是有底线的`) : that.$t(`加载更多`);
				}, function(res) {
					this.loading = false;
					that.loadTitle = that.$t(`加载更多`);
				});
			},
			nav: function(current) {
				this.current = current;
			}
		}
	}
</script>

<style scoped lang="scss">
	.integral-details .header {
		 background-image: url('/static/mall/bg_mine@2x.png');
		background-repeat: no-repeat;
		background-size: 100% 100%;
		width: 100%;
		
		font-size: 72rpx;
		color: #fff;
		padding: 31rpx 0 45rpx 0;
		box-sizing: border-box;
		text-align: center;
		font-family: 'Guildford Pro';
		
	}

	.integral-details .header .currentScore {
		font-size: 26rpx;
		color: rgba(255, 255, 255, 0.8);
		text-align: center;
		margin-bottom: 11rpx;
	}

	.integral-details .header .scoreNum {
		font-family: "Guildford Pro";
	}

	.integral-details .header .line {
		width: 60rpx;
		height: 3rpx;
		background-color: #fff;
		margin: 20rpx auto 0 auto;
	}

	.integral-details .header .nav {
		font-size: 22rpx;
		color: rgba(255, 255, 255, 0.8);
		flex: 1;
		margin-top: 35rpx;
	}

	.integral-details .header .nav .item {
		width: 33.33%;
		text-align: center;
	}

	.integral-details .header .nav .item .num {
		color: #fff;
		font-size: 40rpx;
		margin-bottom: 5rpx;
		font-family: 'Guildford Pro';
	}

	.integral-details .wrapper .nav {
		flex: 1;
		width: 690rpx;
		border-radius: 20rpx 20rpx 0 0;
		margin: -96rpx auto 0 auto;
		background-color: #f7f7f7;
		height: 96rpx;
		font-size: 30rpx;
		color: #bbb;
	}

	.integral-details .wrapper .nav .item {
		text-align: center;
		width: 50%;
	}

	.integral-details .wrapper .nav .item.on {
		background-color: #fff;
		color: var(--view-theme);
		font-weight: bold;
		border-radius: 20rpx 0 0 0;
	}

	.integral-details .wrapper .nav .item:nth-of-type(2).on {
		border-radius: 0 20rpx 0 0;
	}

	.integral-details .wrapper .nav .item .iconfont {
		font-size: 38rpx;
		margin-right: 10rpx;
	}

	.integral-details .wrapper .list {
		padding: 24rpx 30rpx;
	}

	.integral-details .wrapper .list.bag-white {
		background-color: #fff;
	}

	.integral-details .wrapper .list .tip {
		font-size: 25rpx;
		width: 690rpx;
		height: 60rpx;
		border-radius: 50rpx;
		background-color: #fff5e2;
		border: 1rpx solid #ffeac1;
		color: #c8a86b;
		padding: 0 20rpx;
		box-sizing: border-box;
		margin-bottom: 24rpx;
	}

	.integral-details .wrapper .list .tip .iconfont {
		font-size: 35rpx;
		margin-right: 15rpx;
	}

	.integral-details .wrapper .list .item {
		height: 124rpx;
		border-bottom: 1rpx solid #eee;
		font-size: 24rpx;
		color: #999;
	}

	.integral-details .wrapper .list .item .state {
		font-size: 28rpx;
		color: #282828;
		margin-bottom: 8rpx;
	}

	.integral-details .wrapper .list .item .num {
		font-size: 36rpx;
		font-family: 'Guildford Pro';
		color: #16AC57;
	}

	.integral-details .wrapper .list .item .num.font-color {
		color: #E93323 !important;
	}

	.integral-details .wrapper .list2 {
		background-color: #fff;
		padding: 24rpx 0;
	}

	.integral-details .wrapper .list2 .item {
		background-image: linear-gradient(to right, #fff7e7 0%, #fffdf9 100%);
		width: 690rpx;
		height: 180rpx;
		position: relative;
		border-radius: 10rpx;
		margin: 0 auto 20rpx auto;
		padding: 0 25rpx 0 180rpx;
		box-sizing: border-box;
	}

	.integral-details .wrapper .list2 .item .pictrue {
		width: 90rpx;
		height: 150rpx;
		position: absolute;
		bottom: 0;
		left: 45rpx;
	}

	.integral-details .wrapper .list2 .item .pictrue image {
		width: 100%;
		height: 100%;
	}

	.integral-details .wrapper .list2 .item .name {
		width: 285rpx;
		font-size: 30rpx;
		font-weight: bold;
		color: #c8a86b;
	}

	.integral-details .wrapper .list2 .item .earn {
		font-size: 26rpx;
		color: #c8a86b;
		border: 2rpx solid #c8a86b;
		text-align: center;
		line-height: 52rpx;
		height: 52rpx;
		width: 160rpx;
		border-radius: 50rpx;
	}

	.apply {
		top: 52rpx;
		right: 0;
		position: absolute;
		width: max-content;
		height: 56rpx;
		padding: 0 14rpx;
		background-color: #fff1db;
		color: #a56a15;
		font-size: 22rpx;
		border-radius: 30rpx 0 0 30rpx;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.empty-box {
		padding-bottom: 300rpx;
	}
</style>
