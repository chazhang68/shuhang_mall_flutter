<template>
	<view>
		
			<view class="bg-white" style="position: sticky;z-index: 99" :style="{'top':top}">	<uni-segmented-control :current="current" :values="items" @clickItem="onClickItem" styleType="button" activeColor="#dd524d"></uni-segmented-control></view>
				
		 <view class="content">
			 <view v-show="current === 0">
				 <view class="flex align-center bg-white" style="position: sticky;z-index: 99" :style="{'top':stop}">
					 <view v-for="(item,key) in left_child"  class="child" :class="index == key?'active':''"  @click="change(key)">{{item}}</view>
				 </view>
				 <view class="m-3">
				 <view class="box-item" v-for="(item) in recordList">
				 <view class="flex align-center">
				 	<image :src="item.avatar" mode="" style="width: 60rpx;height: 60rpx;border-radius: 100%;"></image>
				 	<view class="" style="font-size:16px;font-weight: 500;margin-left: 20rpx;">{{item.nickname}}</view>
				 </view>
				 <view style="font-size: 25px;font-weight: bold;margin-top: 20rpx;">
				 	<text class="font" style="margin-right: 15rpx;"></text>{{item.dprice}}
				 </view>
				 <view class="flex align-center" style="justify-content: space-between;">
				 	<view>
				 		<view style="margin-top: 15rpx;">数量：{{item.number}}</view>
				 		<view style="margin-top: 15rpx;" >类型：{{item.type == 1?'消费券':'福豆 '}}</view>
				 	</view>
				 	<view v-if="item.status == 1" class="chushou" style="background: #d79200;" @click="cancel(item.id)"  >取消</view>
					<view v-if="item.status == 2" class="chushou" style="background: #006cd5;" @click="gopay(item.id)">去结算</view>
					<view v-if="item.status == 4" class="chushou" @click="okover(item.id)" >确认完成</view>
					<view v-if="item.status == 5" class="chushou" style="background: unset;color: #dd524d;">互换完成</view>
					<view v-if="item.status == 6" class="chushou" style="background: unset;color: #e11f1a;">互换关闭</view>
				 </view>
				 <view class="flex align-center" style="margin-top: 20rpx;">
				 	<view class="flex align-center" style="margin-right: 10px;" v-if="item.is_bank">
				 		<image src="/static/images/bank.png" mode="widthFix" style="width: 40rpx;" ></image>
				 		<view style="margin-left: 5px;">银行卡</view>
				 	</view>
				 	<view class="flex align-center" style="margin-right: 10px;" v-if="item.is_alipay">
				 		<image src="/static/images/zfb.png" mode="widthFix" style="width: 40rpx;" ></image>
				 		<view style="margin-left: 5px;">支付宝</view>
				 	</view>
				 	<view class="flex align-center" v-if="item.is_wechat">
				 		<image src="/static/images/wx.png" mode="widthFix" style="width: 40rpx;" ></image>
				 		<view style="margin-left: 5px;">微信</view>
				 	</view>
				 </view>
				 <view v-if="item.status == 2" class="flex align-center mt-2">
					 <view class="mr-2" style="color: #dd524d;">付款倒计时</view>
				 	<uni-countdown :font-size="13" :show-day="false" :second="Number(item.time)" color="#FFFFFF" background-color="#dd524d" />
					</view>
		
				 </view>
				 <view class='loadingicon acea-row row-center-wrapper' v-if="recordList.length">
				 	<text class='loading iconfont icon-jiazai' :hidden='loading==false'></text>{{loadTitle}}
				 </view>
				 <view v-if="recordList.length < 1 && page > 1">
				 	<emptyPage :title='$t(`暂无数据~`)'></emptyPage>
				 </view>
				 </view>
				 
			 </view>
			 <view v-show="current === 1">
				 <view class="flex align-center bg-white" style="position: sticky;z-index: 99" :style="{'top':stop}">
				 					 <view v-for="(item,key) in right_child"  class="child" :class="index == key?'active':''"  @click="change(key)">{{item}}</view>
				 				
				 </view>
				<view class="m-3">
				<view class="box-item" v-for="(item) in recordList">
				<view class="flex align-center">
					<image :src="item.avatar" mode="" style="width: 60rpx;height: 60rpx;border-radius: 100%;"></image>
					<view class="" style="font-size:16px;font-weight: 500;margin-left: 20rpx;">{{item.nickname}}</view>
				</view>
				<view style="font-size: 25px;font-weight: bold;margin-top: 20rpx;">
					<text class="font" style="margin-right: 15rpx;"></text>{{item.dprice}}
				</view>
				<view class="flex align-center" style="justify-content: space-between;">
					<view>
						<view style="margin-top: 15rpx;">数量：{{item.number}}</view>
						<view style="margin-top: 15rpx;" >类型：{{item.type == 1?'消费券':'福豆 '}}</view>
					</view>
					<view v-if="item.status == 2" class="chushou" style="background: unset;color: #0b3cd7;" >待收款</view>
					<view v-if="item.status == 3" class="chushou" @click="gopay(item.id)" >结算详情</view>
					<view v-if="item.status == 5" class="chushou" style="background: unset;color: #dd524d;">互换完成</view>
				</view>
				<view class="flex align-center" style="margin-top: 20rpx;">
					<view class="flex align-center" style="margin-right: 10px;" v-if="item.is_bank">
						<image src="/static/images/bank.png" mode="widthFix" style="width: 40rpx;" ></image>
						<view style="margin-left: 5px;">银行卡</view>
					</view>
					<view class="flex align-center" style="margin-right: 10px;" v-if="item.is_alipay">
						<image src="/static/images/zfb.png" mode="widthFix" style="width: 40rpx;" ></image>
						<view style="margin-left: 5px;">支付宝</view>
					</view>
					<view class="flex align-center" v-if="item.is_wechat">
						<image src="/static/images/wx.png" mode="widthFix" style="width: 40rpx;" ></image>
						<view style="margin-left: 5px;">微信</view>
					</view>
				</view>
				</view>
				<view class='loadingicon acea-row row-center-wrapper' v-if="recordList.length">
					<text class='loading iconfont icon-jiazai' :hidden='loading==false'></text>{{loadTitle}}
				</view>
				<view v-if="recordList.length < 1 && page > 1">
					<emptyPage :title='$t(`暂无数据~`)'></emptyPage>
				</view>
				</view>
			 </view>
		 </view>
	</view>
</template>

<script>
	import emptyPage from '@/components/emptyPage.vue'
	import {getMyOtcList,okOver,cancel} from '@/api/user.js'
	export default {
		components: {
			emptyPage
		},
		data() {
			return {
				items: ['我的换入', '我的换出'],
				current: 0,
				index:0,
				left_child:['全部','发布中','待支付','待确认','已完成'],
				right_child:['全部','待收款','待确认','已完成'],
				page: 1,
				limit: 15,
				loading: false,
				loadend: false,
				loadTitle: this.$t(`加载更多`),
				recordList:[],
				top:0,
				stop:0
			}
		},
		onLoad() {
			this.top = uni.getSystemInfoSync().windowTop+'px'
			this.stop =  uni.getSystemInfoSync().windowTop+36+'px'
		},
		onShow() {
			this.loading = false
			this.loadend = false
			this.loadTitle = this.$t(`加载更多`);
			this.page =  1,	
			this.recordList = [],
			this.getRecordList()

		},
		methods: {
			cancel(id){
				let that = this;
				uni.showModal({
					title: '提示',
					content: '确认取消需求订单吗?',
					success: function (res) {
						if (res.confirm) {
							cancel(id).then(res=>{
								uni.showToast({
									title:"取消成功",
									icon:"none"
								})
								setTimeout(function(){
									uni.navigateBack()
								},1000)
							}).catch(res=>{
								uni.showToast({
									title:res,
									icon:"none"
								})
							})
						} else if (res.cancel) {
						
						}
					}
				});
			},
			okover(id){
				let that = this;
				uni.showModal({
					title: '提示',
					content: '确认互换完成吗?',
					success: function (res) {
						if (res.confirm) {
							okOver(id).then(res=>{
								uni.showToast({
									title:"互换完成",
									icon:"none"
								})
								setTimeout(function(){
									uni.navigateBack()
								},1000)
							}).catch(res=>{
								uni.showToast({
									title:res,
									icon:"none"
								})
							})
						} else if (res.cancel) {
						
						}
					}
				});
			},
			gopay(id){
				uni.navigateTo({
					url:"/pages/gopay/gopay?id="+id
				})
			},
			getRecordList: function() {
				let that = this;
				let page = that.page;
				let limit = that.limit;
				let type = that.current?2:1;
				
				if (that.loading) return;
				if (that.loadend) return;
				that.loading = true;
				that.loadTitle = '';
				getMyOtcList({
					page: page,
					limit: limit,
					current:type,
					child:that.index
				}).then(res => {
					
					let loadend = res.data.length < that.limit;
					that.loadend = loadend;
					that.recordList = that.$util.SplitArray(res.data, that.recordList);
					that.$set(that, 'recordList', that.recordList);
					that.loadTitle = loadend ? that.$t(`我也是有底线的`) : that.$t(`加载更多`);
					that.page += 1;
					that.loading = false;
				}).catch(err => {
					that.loading = false;
					that.loadTitle = that.$t(`加载更多`);
				})
			},
			onClickItem(e) {
			  if (this.current != e.currentIndex) {
				this.current = e.currentIndex;
				this.loading = false
				this.loadend = false
				this.loadTitle = this.$t(`加载更多`);
				this.page =  1
				this.index = 0		
				this.recordList = [],
				this.getRecordList();
			  }
			},
			change(key){
				this.index = key
				this.loading = false
				this.loadend = false
				this.loadTitle = this.$t(`加载更多`);
				this.page =  1,
							
				this.recordList = [],
				this.getRecordList();
			}
		}
	}
</script>

<style>
	.chushou{
		width: 150rpx;
		height: 65rpx;
		display: flex;
		align-items: center;
		justify-content: center;
		color: #fff;
		border-radius: 3px;
		background: #dd524d;
	}
	.box-item{
		background: #fff;
		border-radius: 5px;
		padding: 10px;
		margin-bottom: 20rpx;
	}
	.active{
		color: #dd524d;
		border-bottom: 2px solid #dd524d;
	}
	.child{
		flex:1;
		text-align: center;
		padding: 10px 0px;
	}
/deep/ .segmented-control__item--button--first{
	border-top-left-radius:0px!important;
	border-bottom-left-radius:0px!important
}
/deep/ .segmented-control__item--button--last{
	border-top-right-radius:0px;
	border-bottom-right-radius:0px
}
</style>
