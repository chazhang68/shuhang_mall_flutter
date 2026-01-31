<template>
	<view :style="colorStyle">
		<view class="agent-top">
			<view style="display: flex;align-items: center;justify-content: space-between;">
				<view class="flex align-center justify-center">
					<image :src="userInfo.avatar" mode="" style="width: 120rpx;height: 120rpx;border-radius: 100%;"></image>
					<view class="flex flex-column  justify-center pl-3" >
						<view class="text-white font-lg" style="font-weight: 500;">{{info.level_name}}</view>
						<view class="text-white mt-1 font-sm" style="font-weight: 500;">
							下一等级：{{info.next_name}}
						</view>
					</view>
				</view>
				<image src="/static/images/xz.png" mode="heightFix" style="height: 100rpx;"></image>
			</view>			
		</view>
		<view class="bg-white m-3 flex align-center" style="height: 260rpx;border-radius: 10rpx;margin-top: -15px;justify-content: space-around;">
			<view class="flex flex-column align-center" style="position: relative;">
			 <l-circularProgress  :lineWidth="5" :boxWidth="80" :boxHeight="80" progressColor="#e93323" fontColor="#e93323" gradualColor="#e93323"
			      :percent="100" :fontShow="false"></l-circularProgress>
				  <view style="position: absolute;top:30px;text-align: center;color: #e93323;">{{info.team_num}}</view>
				  <view class="mt-1">团队总人数</view>
			</view>  
			 <view class="flex flex-column align-center" style="position: relative;">
			  <l-circularProgress  :lineWidth="5" :boxWidth="80" :boxHeight="80" progressColor="#e93323" fontColor="#e93323" gradualColor="#e93323"
			       :percent="100" :fontShow="false"></l-circularProgress>
			 	  <view style="position: absolute;top:30px;text-align: center;color: #e93323;">{{info.bg_team}}</view>
			 	  <view class="mt-1">大区人数</view>
			 </view> 
			 <view class="flex flex-column align-center" style="position: relative;">
			  <l-circularProgress  :lineWidth="5" :boxWidth="80" :boxHeight="80" progressColor="#e93323" fontColor="#e93323" gradualColor="#e93323"
			       :percent="100" :fontShow="false"></l-circularProgress>
			 	  <view style="position: absolute;top:30px;text-align: center;color: #e93323;">{{info.min_team}}</view>
			 	  <view class="mt-1">小区人数</view>
			 </view> 
		</view>
		<view class="bg-white m-3  p-3" style="border-radius: 10rpx;">
			<view class="mb-1" style="position: relative;">
				<view >团队总活跃</view>
				<progress  :percent="info.team_bl" activeColor="#feb52a" :active="true"   stroke-width="15" style="margin: 5px 0px;"  />
				<view class="text-white font-sm nn " style="left:7px;text-align: center;">{{info.team_hy}}</view>
				<view class="text-white font-sm nn" style="right: 7px;text-align: center;">{{info.next_team}}</view>
			</view>
			<view class="mb-1" style="position: relative;">
				<view>小区活跃</view>
				<progress  :percent="info.min_bl" activeColor="#ff0014" :active="true"   stroke-width="15" style="margin: 5px 0px;"  />
				<view class="text-white font-sm nn " style="left:7px;text-align: center;">{{info.min_hy}}</view>
				<view class="text-white font-sm nn" style="right: 7px;text-align: center;">{{info.next_min}}</view>
			</view>
			<view class="mb-1" style="position: relative;">
				<view>有效直推</view>
				<progress  :percent="info.ztbl" activeColor="#ff00dd"  :active="true"  stroke-width="15" style="margin: 5px 0px;"  />
				<view class="text-white font-sm nn " style="left:7px;text-align: center;">{{info.yxzt}}</view>
				<view class="text-white font-sm nn" style="right: 7px;text-align: center;">{{info.next_zt}}</view>
			</view>
		</view>
	</view>
</template>

<script>
	import colors from '@/mixins/color';
	import {getUserInfo,getInfo} from '@/api/user.js'
	export default {
		data() {
			return {
				userInfo:[],
				info:[]
			}
		},
		mixins: [colors],
		onShow() {
			this.getUser()
			this.getInfo()
		},
		methods: {
			getUser(){
				getUserInfo().then(res=>{
					this.userInfo = res.data
				})
			},
			getInfo(){
				uni.showLoading({
					title:"加载中...."
				})
				getInfo().then(res=>{
					uni.hideLoading()
					this.info = res.data
				}).catch(res=>{
					uni.hideLoading()
					uni.showToast({
						title:res,
						icon:"none"
					})
				})
			}
		}
	}
</script>

<style>

	/deep/ .uni-progress-bar {
	    
	    border-radius: 10px !important;
	    overflow: hidden;
	  }
	  
	 /deep/ .uni-progress-inner-bar {  
	      
	      border-radius: 10px !important;
	      overflow: hidden;
	    background:linear-gradient(to right, #ea997c, #ff0019);
	  }

	.nn{
		position: absolute;top: 24px;
	}
.agent-top{
	width: 100%;height:200rpx;background: var(--view-theme);
	border-bottom-left-radius: 10px;
	border-bottom-right-radius:10px ;
	padding: 30rpx;
}

</style>
