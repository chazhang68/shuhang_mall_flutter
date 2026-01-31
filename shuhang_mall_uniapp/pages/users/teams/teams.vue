<template>
	<view class="flex flex-column">
		<view class="bgs">
			<view class="sys-head">
				<view class="sys-bar w-100" :style="{height:sysHeight}" ></view>	
			</view>			
			<view class="flex p-3 justify-between">
				<view class="flex">
					<view class="position-relative">
						<image class="rounded-circle mt-1" :src="userInfo.avatar" style="width: 140rpx;height: 140rpx;"></image>
						
						<view class="flex align-center justify-center position-absolute"  style="bottom: -10px;left: 7px;">
							<image v-if="userInfo.is_sign" src="/static/image/sign.png" style="width: 107rpx;height: 27rpx;"></image>
							<image v-else src="/static/image/no_sign.png" style="width: 107rpx;height: 27rpx;"></image>
						</view>
					</view>
					
					<view class="pl-4 text-left">
						<view class="flex align-center">
							<view class="font-weight-nn" style="font-size: 38rpx;">{{userInfo.is_sign?userInfo.real_name:userInfo.nickname}}</view>
							<image v-if="!userInfo.agent_level" src="/static/image/zhang.png" class="ml-1 mt-1" style="width: 38rpx;height: 46rpx;"></image>
							<image v-if="userInfo.agent_level == 1" src="/static/image/l1.png" class="ml-1 mt-1" style="width: 38rpx;height: 46rpx;"></image>
							<image v-if="userInfo.agent_level == 2" src="/static/image/l2.png" class="ml-1 mt-1" style="width: 38rpx;height: 46rpx;"></image>
							<image v-if="userInfo.agent_level == 3" src="/static/image/l3.png" class="ml-1 mt-1" style="width: 38rpx;height: 46rpx;"></image>
							<image v-if="userInfo.agent_level == 4" src="/static/image/l4.png" class="ml-1 mt-1" style="width: 38rpx;height: 46rpx;"></image>
							<image v-if="userInfo.agent_level == 5" src="/static/image/l5.png" class="ml-1 mt-1" style="width: 38rpx;height: 46rpx;"></image>
							<image v-if="userInfo.agent_level == 6" src="/static/image/l6.png" class="ml-1 mt-1" style="width: 38rpx;height: 46rpx;"></image>
							
						<!-- 	<view class="text-center">
								
								<view class="font-weight-nn" style="font-size: 10px;">普通会员</view>
							</view> -->						
						</view>		
						<view class="font-sm mt-1 flex align-center" style="font-weight: 400;">邀请码：{{userInfo.code}} <text class="iconfont icon-file-copy font-sm ml-1 font-weight-bold" style="color: #FFAA0A;" @click="copy(userInfo.code)" ></text></view>
						<view class="font-sm pt-2" style="font-weight: 400;">邀请人：{{userInfo.spread_code||0}}</view>
					</view>
				</view>
				<view class="flex flex-column justify-center align-center">
					<view class="font-weight-bold " style="font-size: 38rpx;color: #333;">{{info.my_hy}}</view>
					<view class="font-sm">个人活跃度</view>
				</view>
			</view>
			<view class="m-3 flex align-center justify-around" style="height: 170rpx;background: #2C2722;border-radius: 10px;justify-content: space-around;">
				<view class="flex flex-column align-center justify-center">
					<view class="font-weight-bold" style="color: #F3E1C9;font-size: 16px">{{info.all_zt}}</view>
					<view class="font-sm mt-2" style="color: #F3E1C9;">好友人数</view>
				</view>
				<view class="flex flex-column align-center justify-center">
					<view class="font-weight-bold" style="color: #F3E1C9;font-size: 16px">{{info.yxzt}}</view>
					<view class="font-sm mt-2" style="color: #F3E1C9;">有效好友</view>
				</view>
				<view class="flex flex-column align-center justify-center">
					<view class="font-weight-bold" style="color: #F3E1C9;font-size: 16px">{{info.big_hy}}</view>
					<view class="font-sm mt-2" style="color: #F3E1C9;">大区活跃度</view>
				</view>
				<view class="flex flex-column align-center justify-center">
					<view class="font-weight-bold" style="color: #F3E1C9;font-size: 16px">{{info.min_hy}}</view>
					<view class="font-sm mt-2" style="color: #F3E1C9;">小区活跃度</view>
				</view>
			</view>
		</view>
		<view class="bg-white flex-1" style="border-radius: 16px 16px 0px 0px ;height: 300px;">
			
			<view class="flex align-center justify-center pt-2">
				<image src="/static/image/dll.png" style="width: 30px;height: 30px;"></image>
				<view class="font-weight-bold mx-2 mt-2" style="font-size: 16px;#333">我的好友</view>
				<image src="/static/image/dlr.png" style="width: 30px;height: 30px;"></image>
			</view>
			<view class="m-2">
				
					<uni-search-bar :radius="30" textColor="#333" maxlength="11" cancelButton="none" placeholder="请输入手机号或ID查找好友" bgColor="#f3f3f3" @input="search" />
				
				<view class="haoyou p-2">
					<view class="haoyou-item mb-2" v-for="item in list" style="border:1px solid #E2E2E2;height: 250rpx;border-radius: 10px;">
						
						<view class="flex">
							<view class="p-2">
								<view class="position-relative">
									<image :src="item.avatar" class="rounded-circle" style="width: 110rpx;height: 110rpx;" mode=""></image>
									
								</view>
							</view>
							<view class="flex-1 flex align-center justify-between border-bottom  p-2">
								<view class="">
									<view class="flex align-center mb-1">
										<view class="font-weight-nn font mt-2 mr-1" style="overflow:hidden;">{{item.is_sign?item.real_name:item.nickname}}</view>
										<image class="mt-2" src="/static/image/zhang.png" style="width: 38rpx;height: 46rpx;"></image>
									</view>
									<image v-if="item.is_sign" src="/static/image/sign.png" style="width: 107rpx;height: 27rpx;"></image>
									<image v-else src="/static/image/no_sign.png" style="width: 107rpx;height: 27rpx;"></image>
								</view>
								<view class="flex justify-center align-center flex-column">
									<view class="font-weight-bold" style="font-size: 20px;">{{item.team_hy}}</view>
									<view class="font-sm mt-2">团队活跃度</view>
								</view>
								<view class="flex justify-center align-center flex-column">
									<view class="font-weight-bold" style="font-size: 20px;">{{item.hy}}</view>
									<view class="font-sm mt-2">个人活跃度</view>
								</view>
							</view>
						</view>
						<view class="flex align-center justify-end" style="height: 35px;">
							<view class="mr-2 font-weight-bold">{{item.is_lq?'未打卡':"已打卡"}}</view>
							<view class="font-sm mr-1" @click="callPhone(item.tell)" style="text-decoration: underline;">手机号:{{item.phone}}</view>
							<view class="font-sm mr-2">注册日期：{{item.time}}</view>
						</view>
					</view>
						<view class='loadingicon acea-row row-center-wrapper text-center my-2 font-ll' style="color: #666;" v-if="list.length">
							<text class='loading iconfont icon-jiazai ' :hidden='loading==false'></text>{{loadTitle}}
						</view>
						<view style="height: 10rpx;"></view>
					</view>
					<view class="p-2" v-if="list.length < 1 ">
						<emptyPage title='暂无数据'></emptyPage>
					</view>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
	let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';
	import emptyPage from '@/components/emptyPage.vue';
	import {
		newUserInfo,userInfos,get_hy_list
	} from '@/api/user.js';
	export default {
		components:{

			emptyPage
		},
		data() {
			return {
				sysHeight: sysHeight,
				userInfo:[],
				info:[],
				list:[],
				page:1,
				limit:10,
				loading: false,
				loadend: false,
				loadTitle: '加载更多',
				phone:''
			}
		},
	
		onShow() {
			this.getUser()
			this.getInfo()
			this.gethaoyou();
		},
		methods: {
			goGuize(){
				uni.navigateTo({
					url:"/pages/guize/guize",
					animationDuration:100,
					animationType:'fade-in'
				})
			},
			callPhone(phone){
			
				uni.makePhoneCall({
					phoneNumber:String(phone)
					
				})
			},
			search(e){
				
				this.phone = e
				this.page = 1
				this.loading = false
				this.loadend = false
				this.loadTitle = '';
				this.list = []
				this.gethaoyou()
			},
			gethaoyou(){
				let that = this;
				let page = that.page;
				let limit = that.limit;
				if (that.loading) return;
				if (that.loadend) return;
				that.loading = true;
				that.loadTitle = '';
				
				get_hy_list({
					page: page,
					limit: limit,
					phone:that.phone,
				}).then(res => {
					uni.stopPullDownRefresh();
					let loadend = res.data.length < that.limit;
					that.loadend = loadend;
					that.list = this.SplitArray(res.data, that.list);
					that.loadTitle = loadend ?'我也是有底线的' : '加载更多';
					that.page += 1;
					that.loading = false;
				}).catch(err => {
					uni.stopPullDownRefresh();
					that.loading = false;
					that.loadTitle = '加载更多';
				})
			},
			copy(value){
				uni.setClipboardData({
					data:String(value)
				})
			},
			returnBack(){
				uni.switchTab({
					url:"/pages/index/index"
				})
			},
			goTeam(){
				uni.navigateTo({
					url:'/pages/promoter/promoter'
				})
			},
			getUser(){
				newUserInfo().then(res=>{
					this.userInfo = res.data
				})
			},
			getInfo(){
				uni.showLoading({
					title:"加载中...."
				})
				userInfos().then(res=>{
					uni.hideLoading()
					this.info = res.data
					uni.stopPullDownRefresh()
				}).catch(res=>{
					uni.stopPullDownRefresh()
					uni.hideLoading()
					uni.showToast({
						title:res,
						icon:"none"
					})
				})
			},
			SplitArray(list, sp) {
				if (typeof list != 'object') return [];
				if (sp === undefined) sp = [];
				for (var i = 0; i < list.length; i++) {
					sp.push(list[i]);
				}
				return sp;
			}
		},
		onReachBottom: function() {
			this.gethaoyou();
		},

		onPullDownRefresh() {
			this.page = 1
			this.loading = false
			this.loadend = false
			this.loadTitle = '';
			this.list = []
			this.getUser()
			this.getInfo()
			this.gethaoyou()
		}
	}
</script>

<style>
	page{
		background: #F3F3F3;
	}
	.aa{
		width: 28rpx;
		height: 28rpx;
		background: linear-gradient(0deg, #54DC54 0%, #00D900 99%);
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.bgs{
		width: 100%;
		
		background: url('/static/images/haoyou.png');
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	
</style>
