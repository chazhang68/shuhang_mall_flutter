<template>
	<view class="new-users copy-data" :style="{height:pageHeight}">

		<view class="mid" style="flex:1;overflow: hidden;" :style="colorStyle">
			<scroll-view scroll-y="true" style="height: 100%;">
				<view class="head">
					<view class="user-card" :class="member_style==3?'unBg':''">
						<view class="top" :style="colorStyle">
							<!-- #ifdef MP || APP-PLUS -->
							<view class="sys-head">
								<view class="sys-bar" :style="{height:sysHeight}"></view>
							</view>
							<!-- #endif -->
						</view>
						<view class="user-info">
							<view>
								<!-- 注释这个是加的bnt -->
								<!-- #ifdef H5 -->
								<!-- <button class="bntImg" v-if="userInfo.is_complete == 0 && isWeixin"
                  @click="getWechatuserinfo">
                  <image class="avatar" src='/static/images/f.png'></image>
                  <view class="avatarName">{{$t('获取头像')}}</view>
                </button> -->
								<!-- #endif -->
								<view class="avatar-box" :class="{on:userInfo.is_money_level}">
									<view class="avatar flex justify-center"
										style="border-radius: 50%;overflow: hidden;" v-if="userInfo.avatar">
										<image class="avatar" :src='userInfo.avatar' @click="goEdit()">
										</image>
										<!--                    未实名-->
										<view v-if="!userInfo.is_sign" class="no-autonym">
											<text>未实名</text>
										</view>
									</view>
									<image v-else class="avatar" src="/static/images/f.png" mode="" @click="goEdit()">
									</image>
									<!--                   右下角已经实名状态-->
									<view v-if="userInfo.is_sign"
										class="headwear flex justify-center align-center">
										<image src="/static/my-person-image/duihao@2x.png"></image>
									</view>

								</view>
								<!-- #ifdef APP-PLUS -->
								<!--                <view class="avatar-box" :class="{on:userInfo.is_money_level}">-->
								<!--                  <image class="avatar" :src='userInfo.avatar' v-if="userInfo.avatar"-->
								<!--                         @click="goEdit()">-->
								<!--                  </image>-->
								<!--                  <image v-else class="avatar" src="/static/images/f.png" mode="" @click="goEdit()">-->
								<!--                  </image>-->
								<!--                  <view class="headwear" v-if="userInfo.is_shop">-->
								<!--                    <image src="/static/images/headwear.png"></image>-->
								<!--                  </view>-->
								<!--                </view>-->
								<!-- #endif -->
							</view>
							<view class="info">
								<!-- #ifdef MP || APP-PLUS -->
								<view class="name" v-if="!userInfo.uid" @click="openAuto"
									style="height: 100%; display: flex; align-items: center;color: #333;">
									{{ $t('请点击授权') }}
								</view>
								<!-- #endif -->
								<!-- #ifdef H5 -->
								<view class="name" v-if="!userInfo.uid" @click="openAuto"
									style="height: 100%; display: flex; align-items: center;color: #333;">
									{{ $t(isWeixin ? '请点击授权' : '请点击登录') }}
								</view>
								<!-- #endif -->
								<view class="name" v-if="userInfo.uid">
									<text class="line1 nickname"
										style="font-size: 17px;color: #333;font-family: PingFangSC, PingFang SC;font-weight: 600;">
										{{ userInfo.nickname }}
									</text>
									<view class="vip">
										<image class="lg" v-if="userInfo.agent_level > 0" :src="`/static/my-person-image/level${userInfo.agent_level}.png`"></image>
										<image v-else :src="`/static/my-person-image/level0.png`"></image>
									</view>
          <!--                  <image class="live" :src="userInfo.vip_icon" v-if="userInfo.vip_icon"></image>-->
                           <view class="vips ml-2"  v-if="userInfo.is_vip">
								<image style="width: 50px;height: 18px;" src="/static/images/svip.png"></image>
                           </view>
									<!-- vip -->
									
								</view>
								<view class="num" v-if="userInfo.phone" @click="goEdit()">
									<view class="num-txt flex align-center">
										<text style="font-size: 22rpx;font-weight: 500;color: #000000;">邀请码：</text>
										<text style="font-size: 22rpx;font-weight: 500;color: #000000;line-height: 38rpx">{{ userInfo.code }}</text>
										<image @click.stop="copys(userInfo.code)" class="copys"
											src="/static/my-person-image/fuzhi-3@2x.png"></image>
									</view>
								</view>
								<!-- #ifdef MP -->
								<button class="phone" v-if="!userInfo.phone && isLogin" open-type="getPhoneNumber"
									@getphonenumber="getphonenumber">{{ $t(`绑定手机号`) }}
								</button>
								<!-- #endif -->
								<!-- #ifndef MP -->
								<view class="phone" v-if="!userInfo.phone && isLogin" @tap="bindPhone">
									{{ $t('绑定手机号') }}
								</view>
								<!-- #endif -->
							</view>
							<view class="message">
								<navigator v-if="isLogin" url="/pages/users/user_set/index" animation-type="fade-in" animation-duration="100" hover-class="none">
									<image src="/static/mall/icon_set@2x.png" style="width: 36px;height: 36px;" mode="">
									</image>
								</navigator>
							</view>


						</view>
						<view class="flex flex-column align-center">
							<view class="num-wrapper-top mt-5">
								<navigator url="/pages/users/ryz/ryz?index=0"  animation-duration="100" animation-type="fade-in" hover-class="none">
									<view style="height: 75rpx;" class="flex justify-between align-center">
										<view class="my-account flex align-center">
											<image style="width: 30rpx;height: 30rpx; margin-right: 20rpx"
												src="../../static/my-person-image/zhanghuguanli@2x.png"></image>
											<text>我的账户</text>
										</view>
										<image style="width: 14rpx;height: 22rpx;"
											src="/static/my-person-image/xia-3@2x.png"></image>
									</view>
								</navigator>
							</view>
							<view class="num-wrapper">
								<view class="num-item" @click="goMenuPage('/pages/users/ryz/ryz?index=0')">
									<text class="num my-account-number-font">{{ userInfo.fudou }}</text>
									<view class="txt" style="color: #F3E1C9!important;">{{ $t('仓库积分') }}</view>
								</view>
								<view class="num-item" @click="goMenuPage('/pages/users/ryz/ryz?index=1')">
									<text class="num my-account-number-font">{{ userInfo.fd_ky }}</text>
									<view class="txt" style="color: #F3E1C9!important;">{{ $t('可用积分') }}</view>
								</view>
								
								<view class="num-item" @click="goMenuPage('/pages/users/ryz/ryz?index=2')">
									<text class="num my-account-number-font">{{ userInfo.now_money }}</text>
									<view class="txt" style="color: #F3E1C9!important;">{{ $t('消费券') }}</view>
								</view>
							</view>
						</view>
					</view>
					<view class="order-container" style="margin-top: -60rpx;">
						<view class="order-hd flex align-center justify-between m-3">
							<view class="left" style="font-weight: 600;font-size: 34rpx;color: #1E1D26;">
								{{ $t('我的订单') }}</view>
							<view class="flex align-center">
								<navigator class="right flex align-center" animation-duration="100" animation-type="fade-in"
									style="font-weight: 400;font-size: 24rpx;color: #1E1D26;margin-right: 19rpx"
									hover-class="none" url="/pages/goods/order_list/index" open-type="navigate">
									{{ $t('查看全部') }}
								</navigator>
								<text class="iconfont icon-xiangyou"
									style="font-size: 24rpx;color: #1E1D26;padding-top: 1px"></text>
							</view>
						</view>
						<view class="order-wrapper">
							<view class="order-bd">
								<block v-for="(item,index) in orderMenu" :key="index">
									<navigator class="order-item" hover-class="none" animation-duration="100" animation-type="fade-in" :url="item.url">
										<view class="pic">
											<image style="width: 54rpx;height: 54rpx" :src="item.img" mode=""></image>
											<!--                      <text class="iconfont" style="color: #FF5A5A;" :class="item.img"></text>-->
											<text class="order-status-num" v-if="item.num > 0">{{ item.num }}</text>
										</view>
										<view class="txt">{{ $t(item.title) }}</view>
									</navigator>
								</block>
							</view>
						</view>
					</view>


				</view>
				<!-- 轮播 -->
	
				<!-- 会员菜单 -->
				<view class="order-container">
					<view class="order-hd m-3" style="font-weight: 600;font-size: 34rpx;color: #1E1D26;">我的服务</view>
					<view class="user-menus" style="margin-top: 20rpx;">
						<view class="list-box">

							<block v-for="(item, index) in myServers" :key="index">
								<view  class="item" 
									@click="goMenuPage(item.url, item.title)">
									<image :src="item.img"></image>
									<text>{{item.title}}</text>
								</view>
							</block>
						</view>
					</view>

				</view>
	
				<view class="uni-p-b-98"></view>
			</scroll-view>
			<editUserModal :isShow="editModal" @closeEdit="closeEdit" @editSuccess="editSuccess">
			</editUserModal>
		</view>
		
		<tabBar v-if="!is_diy" :pagePath="'/pages/user/index'"></tabBar>
		<pageFooter v-else></pageFooter>
		
	</view>
</template>
<script>
	let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';
	import {
		getMenuList,
		getUserInfo,
		setVisit,
		updateUserInfo,
		mpBindingPhone
	} from '@/api/user.js';
	import {
		wechatAuthV2,
		silenceAuth
	} from '@/api/public.js'
	import {
		toLogin
	} from '@/libs/login.js';
	import {
		mapState,
		mapGetters
	} from "vuex";
	// #ifdef H5
	import Auth from '@/libs/wechat';
	// #endif
	const app = getApp();
	import dayjs from '@/plugin/dayjs/dayjs.min.js';
	import Routine from '@/libs/routine';
	import colors from '@/mixins/color';
	import tabBar from "@/pages/index/visualization/components/tabBar.vue";
	import pageFooter from '@/components/pageFooter/index.vue'
	import {
		getCustomer
	} from '@/utils/index.js'
	import editUserModal from '@/components/eidtUserModal/index.vue'

	export default {
		components: {
			tabBar,
			pageFooter,
			editUserModal
		},
		// computed: mapGetters(['isLogin','cartNum']),
		computed: {
			...mapGetters({
				cartNum: 'cartNum',
				isLogin: 'isLogin'
			})
		},
		filters: {
			coundTime(val) {
				var setTime = val * 1000
				var nowTime = new Date()
				var rest = setTime - nowTime.getTime()
				var day = parseInt(rest / (60 * 60 * 24 * 1000))
				// var hour = parseInt(rest/(60*60*1000)%24) //小时
				return day + this.$t('day')
			},
			dateFormat: function(value) {
				return dayjs(value * 1000).format('YYYY-MM-DD');
			}
		},
		mixins: [colors],
		data() {
			return {
				editModal: false, // 编辑头像信息
				storeMenu: [], // 商家管理
				orderMenu: [
            {
						img: '/static/my-person-image/all@2x.png',
						title: '全部',
						url: '/pages/goods/order_list/index'
						// 会员链接
						// url: '/pages/annex/vip_paid/index'
					}, {
						img: '/static/my-person-image/daifukuan@2x.png',
						title: '待付款',
						url: '/pages/goods/order_list/index?status=0'
					},
					{
						img: '/static/my-person-image/daifahuo@2x.png',
						title: '待发货',
						url: '/pages/goods/order_list/index?status=1'
					},
					{
						img: '/static/my-person-image/daishouho-2@2x.png',
						title: '待收货',
						url: '/pages/goods/order_list/index?status=2'
					},
					{
						img: '/static/my-person-image/yiwancheng-2@2x.png',
						title: '已完成',
						url: '/pages/goods/order_list/index?status=3'
					},

				],
				// 我的服务
				myServers: [
            {
						img: '/static/my-person-image/shimingrenzheng.png',
						title: '实名认证',
						url: '/pages/sign/sign',
						show:true
					}, {
						img: '/static/my-person-image/tuandui3@2x.png',
						title: '邀请好友',
						url: '/pages/users/user_spread_code/index',
						show:true
					}, {
						img: '/static/my-person-image/shanggong.png',
						title: '兑换宝',
						url: 'shuhangshangdao',
						show:true
					}, {
						img: '/static/my-person-image/ditu3@2x.png',
						title: '地址管理',
						url: '/pages/users/user_address_list/index',
						show:true
					},
				
					{
						img: '/static/my-person-image/tuandui3@2x.png',
						title: '我的好友',
						// url: '/pages/users/teams/teams',
						show:true
					}, {
						img: '/static/my-person-image/yijianfankui-2@2x.png',
						title: '意见反馈',
						url: '/pages/user_suggest/index',
						show:true
					}, {
						img: '/static/my-person-image/my-card.png',
						title: '我的信息',
						url: '/pages/users/user_info/index',
						show:true
					// }, {
					// 	img: '/static/my-person-image/my-card.png',
					// 	title: '申请入驻',
					// 	url: '/pages/webview/webview?url='+encodeURIComponent('http://localhost:5173/#/pages/merchant/apply'),
					// 	show:true
					}
				],
				imgUrls: [{
					pic: '/static/my-person-image/banner1.png'
				}, {
					pic: '/static/my-person-image/banner2.png'
				}, ],
				autoplay: true,
				circular: true,
				interval: 3000,
				duration: 500,
				isAuto: false, //没有授权的不会自动授权
				isShowAuth: false, //是否隐藏授权
				orderStatusNum: {},
				userInfo: {},
				MyMenus: [],
				sysHeight: sysHeight,
				mpHeight: 0,
				showStatus: 1,
				activeRouter: '',
				// #ifdef H5 || MP
				pageHeight: '100%',
				routineContact: 0,
				// #endif
				// #ifdef APP-PLUS
				pageHeight: app.globalData.windowHeight,
				// #endif
				// #ifdef H5
				isWeixin: Auth.isWeixin(),
				//#endif
				footerSee: false,
				member_style: 1,
				my_banner_status: 1,
				is_diy: uni.getStorageSync('is_diy'),
				copyRightPic: '/static/images/support.png', //版权图片
			}
		},
		onLoad(option) {
			uni.hideTabBar()
			let that = this;
			// #ifdef MP
			// 小程序静默授权
			if (!this.$store.getters.isLogin) {
				// Routine.getCode()
				// 	.then(code => {
				// 		Routine.silenceAuth(code).then(res => {
				// 			this.onLoadFun();
				// 		})
				// 	})
				// 	.catch(res => {
				// 		uni.hideLoading();
				// 	});
			}
			// #endif

			// #ifdef H5 || APP-PLUS
			if (that.isLogin == false) {
				toLogin()
			}
			//获取用户信息回来后授权
			let cacheCode = this.$Cache.get('snsapi_userinfo_code');
			let res1 = cacheCode ? option.code != cacheCode : true;
			if (this.isWeixin && option.code && res1 && option.scope === 'snsapi_userinfo') {
				this.$Cache.set('snsapi_userinfo_code', option.code);
				Auth.auth(option.code).then(res => {
					this.getUserInfo();
				}).catch(err => {})
			}
			// #endif
			// #ifdef APP-PLUS
			that.$set(that, 'pageHeight', app.globalData.windowHeight);
			// #endif

			let routes = getCurrentPages(); // 获取当前打开过的页面路由数组
			let curRoute = routes[routes.length - 1].route //获取当前页面路由
			this.activeRouter = '/' + curRoute
			this.getCopyRight();
		},
		onReady() {
			let self = this
			// #ifdef MP
			let info = uni.createSelectorQuery().select(".sys-head");
			info.boundingClientRect(function(data) { //data - 各种参数
				self.mpHeight = data.height
			}).exec()
			// #endif
		},
		onShow: function() {
			let that = this;
			// #ifdef APP-PLUS
			uni.getSystemInfo({
				success: function(res) {
					that.pageHeight = res.windowHeight + 'px'
				}
			});
			// #endif
			if (that.isLogin) {
				this.getMyMenus();
				this.getUserInfo();
				this.setVisit();
			}
			this.getCopyRight();
		},
		onPullDownRefresh() {
			this.onLoadFun();
		},
		methods: {
			goCode() {
				uni.navigateTo({
					url: '/pages/users/user_spread_code/index',
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			copys(uid) {
				uni.setClipboardData({
					data: String(uid)
				});
			},
			getWechatuserinfo() {
				//#ifdef H5
				Auth.isWeixin() && Auth.toAuth('snsapi_userinfo', '/pages/user/index');
				//#endif
			},
			getRoutineUserInfo(e) {
				updateUserInfo({
					userInfo: e.detail.userInfo
				}).then(res => {
					this.getUserInfo();
					return this.$util.Tips(this.$t('更新用户信息成功'));
				}).catch(res => {

				})
			},
			editSuccess() {
				this.editModal = false
				this.getUserInfo();
			},
			closeEdit() {
				this.editModal = false
			},
			// 记录会员访问
			setVisit() {
				setVisit({
					url: '/pages/user/index'
				}).then(res => {})
			},
			// 打开授权
			openAuto() {
				toLogin();
			},
			// 授权回调
			onLoadFun() {
				this.getUserInfo();
				this.getMyMenus();
				this.setVisit();
			},
			Setting: function() {
				uni.openSetting({
					success: function(res) {}
				});
			},
			// 授权关闭
			authColse: function(e) {
				this.isShowAuth = e
			},
			// 绑定手机
			bindPhone() {
				uni.navigateTo({
					url: '/pages/users/user_phone/index',
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			getphonenumber(e) {
				if (e.detail.errMsg == 'getPhoneNumber:ok') {
					Routine.getCode()
						.then(code => {
							let data = {
								code,
								iv: e.detail.iv,
								encryptedData: e.detail.encryptedData,
							}
							mpBindingPhone(data).then(res => {
								this.getUserInfo()
								this.$util.Tips({
									title: res.msg,
									icon: 'success'
								});
							}).catch(err => {
								return this.$util.Tips({
									title: err
								});
							})
						})
						.catch(error => {
							uni.hideLoading();
						});
				}
			},
			/**
			 * 获取个人用户信息
			 */
			getUserInfo: function() {
				let that = this;
				getUserInfo().then(res => {
					that.userInfo = res.data
					if(!res.data.h5_open){
						that.myServers[2].show = false
					}else{
						that.myServers[2].show = true
					}
					that.$store.commit("SETUID", res.data.uid);
					that.orderMenu.forEach((item, index) => {
						switch (item.title) {
							case '待付款':
								item.num = res.data.orderStatusNum.unpaid_count
								break
							case '待发货':
								item.num = res.data.orderStatusNum.unshipped_count
								break
							case '待收货':
								item.num = res.data.orderStatusNum.received_count
								break
							case '待评价':
								item.num = res.data.orderStatusNum.evaluated_count
								break
							case '售后/退款':
								item.num = res.data.orderStatusNum.refunding_count
								break
						}
					})
					uni.stopPullDownRefresh();
				});
			},
			//小程序授权api替换 getUserInfo
			getUserProfile() {
				toLogin();
			},
			/**
			 *
			 * 获取个人中心图标
			 */
			// switchTab(order) {
			//   this.orderMenu.forEach((item, index) => {
			//     switch (item.title) {
			//       case '待付款':
			//         item.img = order.dfk
			//         break
			//       case '待发货':
			//         item.img = order.dfh
			//         break
			//       case '待收货':
			//         item.img = order.dsh
			//         break
			//       case '待评价':
			//         item.img = order.dpj
			//         break
			//       case '售后/退款':
			//         item.img = order.sh
			//         break
			//     }
			//   })
			// },
			getMyMenus: function() {
				let that = this;
				// if (this.MyMenus.length) return;
				getMenuList().then(res => {
					let storeMenu = []
					let myMenu = []

					this.member_style = Number(res.data.diy_data.value)
					this.my_banner_status = res.data.diy_data.my_banner_status
					this.imgUrls = res.data.routine_my_banner
					this.routineContact = Number(res.data.routine_contact_type)
					this.myServers = res.data.routine_my_menus.map(item => {
						return {
							img: item.pic,
							title: item.name,
							url: item.url,
							show:true
						}
					})
				});
			},
			// 编辑页面
			goEdit() {
				if (this.isLogin == false) {
					toLogin();
				} else {
					// #ifdef MP
					if (this.userInfo.is_default_avatar) {
						this.editModal = true
						return
					}
					// #endif
					uni.navigateTo({
						url: '/pages/users/user_info/index',
						animationDuration:100,
						animationType:"fade-in"
					})
				}

			},
			// 签到
			goSignIn() {
				uni.navigateTo({
					url: '/pages/users/user_sgin/index',
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			// goMenuPage
			goMenuPage(url, name) {
				if (!url) {
					// uni.showToast({
					// 	title: '请选择要打开的页面',
					// 	icon: 'none'
					// });
					return;
				}
				// if (url.indexOf('/pages/users/ryz/ryz') > -1) {
				// 	return;
				// }
				if (this.isLogin) {
					if (url == 'shuhangshangdao') {
						return this.openMall()
					}
					if (url.indexOf('http') === -1) {
						// #ifdef H5 || APP-PLUS
						if (name && name === '客服接待') {
							// return window.location.href = `${location.origin}${url}`
							return uni.navigateTo({
								url: `/pages/annex/web_view/index?url=${location.origin}${url}`
							});
						} else if (name && name === '联系客服') {
							return getCustomer(url)

						} else if (name === '订单核销') {
							return uni.navigateTo({
								url: url
							});
							// return window.location.href = `${location.origin}${url}`
						}
						// #endif

						// #ifdef MP
						if (name && name === '联系客服') {
							return getCustomer(url)
						}
						if (url != '#' && url == '/pages/users/user_info/index') {
							uni.openSetting({
								success: function(res) {}
							});
						}
						// #endif
						uni.navigateTo({
							url: url,
							animationDuration:100,
							animationType:"fade-in",
							fail(err) {
								uni.switchTab({
									url: url
								})
							}
						})
					} else {
						uni.navigateTo({
							url: `/pages/annex/web_view/index?url=${url}`,
							animationDuration:100,
							animationType:"fade-in"
						});
					}
				} else {
					// #ifdef MP
					this.openAuto()
					// #endif
				}
			},
			openMall() {

				if (plus.os.name == 'Android') {
					if (plus.runtime.isApplicationExist({
							pname: 'com.shsdjiankang.app'
						})) {
						plus.runtime.launchApplication({
								pname: 'com.shsdjiankang.app' //安卓也可以直接跟着包名唤起
							},
							function(e) {
								uni.showToast({
									title: "打开APP失败",
									icon: 'none'
								})
							}
						);
					} else {
						uni.showToast({
							title: '还未下载该APP',
							icon: 'none'
						});
					}
				} else if (plus.os.name == 'iOS') {
					if (plus.runtime.isApplicationExist({
							action: 'zhongzhen://'
						})) {
						plus.runtime.launchApplication({
								action: 'zhongzhen://'
							},
							function(e) {
								uni.showToast({
									title: "打开APP失败",
									icon: 'none'
								})
							}
						);
					} else {
						uni.showToast({
							title: '还未下载该APP',
							icon: 'none'
						});
					}
				}

			},
			goRouter(item) {
				var pages = getCurrentPages();
				var page = (pages[pages.length - 1]).$page.fullPath;
				if (item.link == page) return
				uni.switchTab({
					url: item.link,
					fail(err) {
						uni.redirectTo({
							url: item.link
						})
					}
				})
			},
			getCopyRight() {
				const copyRight = uni.getStorageSync('copyRight')
				if (copyRight.copyrightImage) {
					this.copyRightPic = copyRight.copyrightImage
				}
			}
		}
	}
</script>

<style lang="scss">
	$my-account-font-color: #F3E1C9;

	body {
		height: 100%;
	}

	.aa {
		font-size: 9px;
		padding: 2px 5px;
		background: linear-gradient(135deg, var(--view-bntColor) 0%, var(--view-main-over) 100%);
		border-radius: 3px;
		-webkit-transform: scale(0.9);
		transform: scale(0.9);
		display: flex;
		align-items: center;
		max-width: 10rem;
	}

	.height {
		margin-top: -100rpx !important;
	}

	.unBg {
		background-color: unset !important;

		.user-info {
			.info {
				.name {
					color: #333333 !important;
					font-weight: 600;
				}

				.num {
					color: #333 !important;

					.num-txt {
						height: 38rpx;
						background-color: rgba(51, 51, 51, 0.13);
						padding: 0 12rpx;
						border-radius: 16rpx;
					}
				}
			}
		}

		.num-wrapper {
			color: #333 !important;
			font-weight: 600;

			.num-item {
				.txt {
					color: rgba(51, 51, 51, 0.7) !important;
				}
			}
		}

		.message {
			.iconfont {
				color: #333 !important;
			}

			.num {
				color: #fff !important;
				background-color: var(--view-theme) !important;
			}
		}

		.setting {
			.iconfont {
				color: #333 !important;
			}
		}
	}

	.cardVipB {
		background-color: #343A48;
		width: 100%;
		height: 124rpx;
		border-radius: 16rpx 16rpx 0 0;
		padding: 22rpx 30rpx 0 30rpx;
		margin-top: 16px;

		.left-box {
			.small {
				color: #F8D5A8;
				font-size: 28rpx;
				margin-left: 18rpx;
			}

			.pictrue {
				width: 40rpx;
				height: 45rpx;

				image {
					width: 100%;
					height: 100%;
				}
			}
		}

		.btn {
			color: #BBBBBB;
			font-size: 26rpx;
		}

		.icon-xiangyou {
			margin-top: 6rpx;
		}
	}

	.cardVipA {
		position: absolute;
		background: url('~@/static/images/member.png') no-repeat;
		background-size: 100% 100%;
		width: 750rpx;
		height: 84rpx;
		bottom: -2rpx;
		left: 0;
		padding: 0 56rpx 0 135rpx;

		.left-box {
			font-size: 26rpx;
			color: #905100;
			font-weight: 400;
		}

		.btn {
			color: #905100;
			font-weight: 400;
			font-size: 24rpx;
		}

		.iconfont {
			font-size: 20rpx;
			margin: 4rpx 0 0 4rpx;
		}
	}

	.bg {
		position: absolute;
		left: 0;
		top: 0;
		width: 100px;
		height: 100px;
		background: var(--view-theme);
		background-size: 100% auto;
		background-position: left bottom;
	}

	.new-users {
		display: flex;
		flex-direction: column;
		height: 100%;

		.sys-head {
			position: relative;
			width: 100%;
			// background: linear-gradient(90deg, $bg-star1 0%, $bg-end1 100%);



			.sys-title {
				z-index: 10;
				position: relative;
				height: 43px;
				text-align: center;
				line-height: 43px;
				font-size: 36rpx;
				color: #FFFFFF;
			}
		}

		.head {
			//background: #fff;

			.user-card {
				position: relative;
				width: 100%;

				margin: 0 auto;
				padding: 35rpx 28rpx;
				background-image: url("/static/account_safe/bac_1015@2x.png");
				background-size: 100% auto;
				//background-color: var(--view-theme);

				.user-info {
					z-index: 20;
					position: relative;
					display: flex;

					.headwear {
						position: absolute;
						background: linear-gradient(0deg, #54DC54 0%, #00D900 99%);
						border-radius: 50%;
						right: 10rpx;
						bottom: 3rpx;
						width: 28rpx;
						height: 28rpx;

						image {
							width: 18rpx;
							height: 14rpx;
						}
					}

					.live {
						width: 28rpx;
						height: 28rpx;
						margin-left: 20rpx;
					}

					.bntImg {
						width: 120rpx;
						height: 120rpx;
						border-radius: 50%;
						text-align: center;
						line-height: 120rpx;
						background-color: unset;
						position: relative;

						.avatarName {
							font-size: 16rpx;
							color: #fff;
							text-align: center;
							background-color: rgba(0, 0, 0, 0.6);
							height: 37rpx;
							line-height: 37rpx;
							position: absolute;
							bottom: 0;
							left: 0;
							width: 100%;
						}
					}

					.avatar-box {
						position: relative;
						display: flex;
						align-items: center;
						justify-content: center;
						width: 120rpx;
						height: 120rpx;
						border-radius: 50%;

						&.on {
							.avatar {
								border: 2px solid #FFAC65;
								border-radius: 50%;
								box-sizing: border-box;
							}
						}
					}

					.avatar {
						position: relative;
						width: 120rpx;
						height: 120rpx;
						border-radius: 50%;

					}

					.info {
						flex: 1;
						display: flex;
						flex-direction: column;
						justify-content: space-between;
						margin-left: 20rpx;
						padding: 15rpx 0;

						.name {
							display: flex;
							align-items: center;
							color: #fff;
							font-size: 31rpx;

							.nickname {
								max-width: 8em;
							}

							.vip {
								margin-left: 10rpx;

								image {
									width: 46rpx;
									height: 46rpx;
									display: block;
								}
								.lg {
									width: 46rpx;
									height: 46rpx;
									display: block;
								}
							}
						}

						.num {
							display: flex;
							align-items: center;
							font-size: 26rpx;
							color: black;

							image {
								width: 22rpx;
								height: 23rpx;
								margin-left: 20rpx;
							}
						}
					}
				}

				.message {
					align-self: flex-start;
					position: relative;
					margin-top: 15rpx;
					margin-right: 20rpx;

					.num {
						position: absolute;
						top: -8rpx;
						left: 18rpx;
						padding: 0 6rpx;
						height: 28rpx;
						border-radius: 12rpx;
						background-color: #fff;
						font-size: 18rpx;
						line-height: 28rpx;
						text-align: center;
						color: var(--view-theme);
					}

					.iconfont {
						font-size: 40rpx;
						color: #fff;
					}
				}

				.num-wrapper-top {
					width: 670rpx;
					height: 75rpx;
					background: #363028;
					border-radius: 20rpx 20rpx 0 0;
					padding: 0 30rpx;

					.my-account text {
						font-weight: 400;
						font-size: 24rpx;
						color: $my-account-font-color;
					}
				}

				.num-wrapper {
					margin-top: -1rpx;
					width: 670rpx;
					background: #2C2722;
					z-index: 30;
					position: relative;
					height: 130rpx;
					display: flex;
					align-items: center;
					justify-content: space-between;
					//background: url('/static/mall/bg_zhanshiqu@2x.png');
					//background-repeat: no-repeat;
					//background-size: 100% 100%;
					// padding: 0 47rpx;
					color: #fff;

					.num-item {
						width: 33.33%;
						text-align: center;

						.num {
							font-size: 17px;
							font-weight: bold;
						}

						.txt {
							margin-top: 8rpx;
							font-weight: 400;
							font-size: 26rpx;
							color: $my-account-font-color!important;
						}
					}
				}

				.sign {
					z-index: 200;
					position: absolute;
					right: -12rpx;
					top: 80rpx;
					display: flex;
					align-items: center;
					justify-content: center;
					width: 120rpx;
					height: 60rpx;
					background: linear-gradient(90deg, rgba(255, 225, 87, 1) 0%, rgba(238, 193, 15, 1) 100%);
					border-radius: 29rpx 4rpx 4rpx 29rpx;
					color: #282828;
					font-size: 28rpx;
					font-weight: bold;
				}
			}

			.order-wrapper {
				//margin: 0 30rpx;
				border-radius: 16rpx;
				position: relative;
				margin-top: 10rpx;


				.order-bd {
					display: flex;
					padding: 0 0;

					.order-item {
						display: flex;
						flex-direction: column;
						justify-content: center;
						align-items: center;
						width: 20%;
						height: 140rpx;

						.pic {
							position: relative;
							text-align: center;

							.iconfont {
								font-size: 48rpx;
								color: var(--view-theme);
							}

							image {
								width: 58rpx;
								height: 48rpx;
							}
						}

						.txt {
							font-family: PingFang SC;
							margin-top: 6rpx;
							font-weight: 400;
							font-size: 30rpx;
							color: #333;
						}
					}
				}
			}
		}

		.slider-wrapper {
			margin: 20rpx 30rpx;
			height: 210rpx;

			swiper,
			swiper-item {
				height: 100%;
			}

			image {
				width: 100%;
				height: 130rpx;
				border-radius: 16rpx;
			}
		}

		.user-menus {
			background-color: #fff;
			//margin: 0 30rpx;
			border-radius: 16rpx;

			.menu-title {
				padding: 0rpx 30rpx 40rpx;
				font-size: 30rpx;
				color: #282828;
				font-weight: bold;
			}

			.list-box {
				display: flex;
				flex-wrap: wrap;
				padding: 0;
			}

			.item {
				position: relative;
				display: flex;
				align-items: center;
				justify-content: space-between;
				flex-direction: column;
				width: 25%;
				margin-bottom: 30rpx;
				font-size: 30rpx;
				color: #333333;

				image {
					width: 52rpx;
					height: 52rpx;
					margin-bottom: 18rpx;
				}


				&:last-child::before {
					display: none;
				}
			}

			button {
				font-size: 28rpx;
			}
		}

		.phone {
			color: #fff;
			background-color: #CCC;
			border-radius: 15px;
			width: max-content;
			font-size: 28rpx;
			padding: 0 10px;
		}

		.order-status-num {

			min-width: 12rpx;
			background-color: #fff;
			color: #FF5A5A;
			border-radius: 15px;
			position: absolute;
			right: -14rpx;
			top: -15rpx;
			font-size: 20rpx;
			padding: 0 8rpx;
			border: 1px solid #FF5A5A;
		}

		.support {
			width: 219rpx;
			height: 74rpx;
			margin: 54rpx auto;
			display: block;
		}
	}

	.card-vip {
		display: flex;
		align-items: center;
		justify-content: space-between;
		position: relative;
		width: 690rpx;
		height: 134rpx;
		margin: -72rpx auto 0;
		background: url('~@/static/images/user_vip.png');
		background-size: cover;
		padding-left: 118rpx;
		padding-right: 34rpx;

		.left-box {
			font-size: 24rpx;
			color: #AE5A2A;

			.big {
				font-size: 28rpx;
			}

			.small {
				opacity: 0.8;
				margin-top: 10rpx;
			}
		}

		.btn {
			height: 52rpx;
			line-height: 52rpx;
			padding: 0 10rpx;
			text-align: center;
			background: #fff;
			border-radius: 28rpx;
			font-size: 26rpx;
			color: #AE5A2A;
		}

	}

	.setting {
		margin-top: 15rpx;
		margin-left: 15rpx;
		color: #fff;

		.iconfont {
			font-size: 40rpx;
		}
	}

	.new-users {
		padding-bottom: 0;
		padding-bottom: constant(safe-area-inset-bottom);
		padding-bottom: env(safe-area-inset-bottom);
	}

	.copys {
		width: 21rpx;
		height: 22rpx;
		margin-left: 10rpx;
	}

	.yaoqing {
		background: url('/static/mall/bg_yaoqingma@2x.png');
		background-repeat: no-repeat;
		background-size: 100% 100%;
		margin-top: 10px;
	}

	.my-account-number-font {
		color: $my-account-font-color !important;
		width: 88rpx;
		height: 29rpx;
	}

	.order-container {
		background: #fff;
		margin: 0 30rpx;
		border-radius: 16rpx;

		position: relative;
		z-index: 99;

		.order-hd {
			justify-content: space-between;
			padding-top: 37rpx;
			margin-top: 25rpx;
			font-size: 30rpx;
			color: #282828;

			.left {
				font-weight: bold;
			}

			.right {
				display: flex;
				align-items: center;
				color: #666666;
				font-size: 26rpx;

				.icon-xiangyou {
					margin-left: 5rpx;
					font-size: 26rpx;
				}
			}
		}
	}

	// 未实名
	.no-autonym {
		position: absolute;
		bottom: 0;
		width: 98rpx;
		height: 31rpx;
		background: #DCDCDC;
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.no-autonym text {
		font-family: PingFang SC;
		font-weight: 400;
		font-size: 18rpx;
		color: #000000;
	}
</style>
