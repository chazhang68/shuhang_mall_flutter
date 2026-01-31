<template>
	<view>
		<view class="box-bg px-3" style="padding-top: 25px;">
			<view class="flex align-center justify-between">
				<view class="flex bg-white rounded-circle align-center justify-between" style="width: 80%;height: 35px;" @click="clickSeach">
					<view class="flex align-center">	
					<image class="ml-1" src="/static/images/icon_serch@2x.png" style="width: 24px;;height: 24px;" mode=""></image>
					<view class="font-sm ml-1" style="color: #A6A6A6;">输入你想搜索的商品</view>
					</view>
					<view class="mr-2" style="color: #444444;font-size: 13px;">搜索</view>
				</view>
				<view class="flex align-center" style="width: 20%; justify-content: space-evenly;">
					<image src="/static/images/gwc.png" style="width:56rpx;height: 56rpx;" mode="" @click="goCart"></image>
					<image src="/static/images/icon_kefu@2x.png" style="width:56rpx;height: 56rpx;" @click="gokefu" mode=""></image>
				</view>
			</view>
			<view class="w-100 mt-3" style="height: 188px;">
				<swiper :indicator-dots="true" style="height: 100%;" indicator-active-color="#fff" indicator-color="#fff"  :autoplay="true" :interval="3000" :duration="1000">
					<swiper-item v-for="(item) in banner">
						<image :src="item.img_url" style="width: 100%;height: 100%;" mode=""></image>
					</swiper-item>
				</swiper>
			</view>
			<view class="mt-2 flex align-center bg-white rounded" style="height: 32px;">
				<view class="flex align-center pl-1">
				<image src="/static/images/icon_notice@2x.png" style="width: 48rpx;height: 48rpx;" mode=""></image>
				<text class="my-font-text" style="font-size: 13px;color: #333;">公告</text>
				</view>
				 <view class="ml-2" style="width: 1px;height: 13px;background:#DDDDDD;"></view>
				<view class="flex-1 pl-2" style="height: 25px;">
					<uni-notice-bar style="height: 25px;" :speed="50" scrollable single background-color="#fff" color="#666666" :text="notes"></uni-notice-bar>
				</view>
			</view>
		</view>
		<view class="px-3">
			<view class="flex align-center justify-between">
				<view class="nav-left rounded p-3" style="width: 168px;height: 88px;">
					<view class="rl-text mt-1">燃料商城</view>
					<image class="mt-1" src="/static/mall/btn_chakan@2x.png" style="width: 112rpx;height: 40rpx;" mode=""></image>
				</view>
				<view class="nav-right rounded p-3" style="width: 168px;height: 88px;">
					<view class="rl-text mt-1">荣誉商城</view>
					<image class="mt-1" src="/static/mall/btn_chakan@2x(1).png" style="width: 112rpx;height: 40rpx;" mode=""></image>
				</view>
			</view>
			<view class="rounded bg-white mt-2 p-3" style="height: 112px;">
				<scroll-view class="flex" style="white-space: nowrap;" scroll-x="true"  >
					<view class="mx-1" style="width: 72px;height: 82px;position: relative;display: inline-block;" v-for="(item) in nav">
						<image class="rounded" style="width: 100%;height: 100%;" :src="item.img" ></image>
						<text class="nav-text">{{item.text}}</text>
					</view>
				</scroll-view>
			</view>
			<view class="mt-2 yaoqing flex align-center justify-between" style="padding: 0px 17px;" >
				<view class="flex align-center">
					<view class="gift" style="font-size: 11px;font-weight: 600;color: #B16C0C;">
						<text class="pl-3">邀新福利</text>
					</view>
					<view class="pl-1 flex align-center" style="font-size: 14px;color: #B16C0C;font-family: PangMenZhengDao;">邀请好友全场<text style="font-size: 24px;line-height: 20px;">6.5</text>折</view>
				</view>
				<view class="yq">
					立即邀请
				</view>
			</view>
			
			<view class="yx" style="width: 100%;height: 211px;margin-top: 25px;position: relative;">
				<view  class="w-100 flex justify-center" style="position: absolute;top: -15px;" >
					<image class="ml-1" src="/static/mall/title_zxbk@2x.png" style="width: 318px;height: 57px;" mode=""></image>
					
					</view>
					<view class="mt-2 p-3" style="padding-top: 45px;">
						<scroll-view class="flex px-1" style="white-space: nowrap;" scroll-x="true"  >
							<view class="mx-1" style="width: 90px;height: 102px;display: inline-block;" v-for="(item) in hot_list" @click="godetail(item.id)">
								<image style="width: 100%;height: 80px;vertical-align: bottom;border-radius: 8px 8px 0px 0px;" :src="item.image" ></image>
								<view class="text-white font-ll aa">SWP{{item.price}}</view>
								<view class="yx-title text-ellipsis-one">{{item.store_name}}</view>
							</view>
							
						</scroll-view>
					</view>
					
					
			</view>
			<view class="flex justify-between" style="margin-top: 10rpx;">
				<view class="one bg-white p-2" style="border-radius: 8px;">
					<view class="top rounded flex align-center justify-between">
						<view>
							<text class="" style="font-family: PangMenZhengDao;font-size: 15px;color: #333333;">新品秒杀</text>
							<view style="width: 62px;height: 5px;background: linear-gradient( 180deg, rgba(255,220,89,0) 0%, #FFC900 100%);margin-top: -5px;"></view>
						</view>
						<view class="flex align-center">
							<text style="font-size: 11px;color: #999;">更多</text>
							<image src="/static/mall/icon_more@2x.png" style="width: 11px;height: 11px;" mode=""></image>
						</view>
					</view>
					<view class="flex align-center mt-4" style="justify-content: space-evenly;">
						<view class="one-aa flex align-center justify-center">
							<image src="/static/mall/ww.png" style="width: 50px;height: 50px;" mode=""></image>
						</view>
						<view class="one-aa flex align-center justify-center">
							<image src="/static/mall/ww.png" style="width: 50px;height: 50px;" mode=""></image>
						</view>
					</view>
				</view>
				<view class="two bg-white p-2" style="border-radius: 8px;">
					<view class="top rounded flex align-center justify-between">
						<view>
							<text class="" style="font-family: PangMenZhengDao;font-size: 15px;color: #333333;">发现好物</text>
							<view style="width: 62px;height: 5px;background: linear-gradient( 180deg, rgba(255,220,89,0) 0%, #FFC900 100%);margin-top: -5px;"></view>
						</view>
						<view class="flex align-center bb">
							
							<image class="ml-1" src="/static/mall/icon_aixin@2x.png" style="width: 11px;height: 11px;" mode=""></image>
							<text class="text-white font-small ml-1">逛健康好物</text>
						</view>
					</view>
					<view class="flex align-center mt-4" style="justify-content: space-evenly;">
						<view class="two-aa flex align-center justify-center">
							<image src="/static/mall/ww.png" style="width: 50px;height: 50px;" mode=""></image>
						</view>
						<view class="two-aa flex align-center justify-center">
							<image src="/static/mall/ww.png" style="width: 50px;height: 50px;" mode=""></image>
						</view>
					</view>
					
					
				</view>
			</view>
			<!-- 商品列表 -->
			<view class="flex flex-wrap justify-between mt-2">
				
				<view class="list-item mb-2" v-for="item in list" @click="godetail(item.id)" style="width: 168px;border-radius: 8px;">
					<image :src="item.image" mode="" style="width: 100%;height: 124px;;border-radius: 8px 8px 0px 0px;vertical-align: bottom;"></image>
					<view class="p-1 bg-white" style="width: 100%; height: 85px;">
						<view class="font-weight-bold text-ellipsis-two" style="color: #333;font-size: 14px;height: 40px;">{{item.store_name}}</view>
						<view v-if="item.give_gxz > 0 " class="mt-1 flex py-1 align-center" style="min-width: 90;max-width: 110px;height: 16px;background: #FFC900;border-radius: 2px;">
							<view class="pl-1" style="font-size: 10px;color: #333;width: 35px;">赠送</view>
							<view class="bg-white text-center px-1" style="font-size: 10px;#333;height: 14px;margin-right: 2px;">0.39燃料值</view>
						</view>
						<view class="flex align-center justify-between" style="margin-top: 3px;">
							<view class="flex align-center">
								<view class="" style="font-size: 16px;color: #FFBD00;"><text style="font-size: 10px;">SWP</text>{{item.price}}</view>
							<view class="ml-1" style="font-size: 14px;color: #999999;text-decoration: line-through;"><text style="font-size: 12px;">SWP</text>{{item.old_price || 0}}</view>
							</view>
							<view>
								<image src="/static/mall/btn_gouwuche@2x.png" style="width: 48rpx;height: 48rpx;" mode=""></image>
							</view>
						</view>
					</view>
				</view>
				
				
			</view>
			
			
			
			
			<view class="uni-p-b-98"></view>
			
		</view>
		
		
		<pageFoot></pageFoot>
	</view>
</template>

<script>
	import pageFoot from '@/components/pageFooter/index.vue';
	import {
		getIndexData,getProduct
	} from "@/api/public.js";
	export default {
		components:{
			pageFoot
		},
		data() {
			return {
				nav:[
					{
						text:"邮费充值",
						img:"/static/mall/yf.png"
					},{
						text:"酒店民宿",
						img:"/static/mall/img_jdms.png"
					},{
						text:"电影影院",
						img:"/static/mall/img_dyyy.png"
					},
					{
						text:"火车机票",
						img:"/static/mall/img_hcjp.png"
					},
					{
						text:"生活缴费",
						img:"/static/mall/img_shjf.png"
					},
					
				],
				goods:[
					{
						text:"邮费充值",
						price:"10.9",
						img:"/static/mall/cc.jpg"
					},{
						text:"酒店民宿",
						price:"15.9",
						img:"/static/mall/cc.jpg"
					},{
						text:"电影影院",
						price:"29.9",
						img:"/static/mall/cc.jpg"
					},
					{
						text:"火车机票",
						price:"45",
						img:"/static/mall/cc.jpg"
					},
					{
						text:"生活缴费",
						price:"101.9",
						img:"/static/mall/cc.jpg"
					}
					
				],
				banner:[],
				notes:'',
				hot_list:[],
				list:[],
				page:1,
				limit:10
			}
		},
		created() {
			//获取首页数据
			this.indexData()
			this.getProductlist()
		},
		methods: {
			godetail(id){
				uni.navigateTo({
					url: `/pages/goods_details/index?id=${id}`,
				});
			},
			getProductlist(){
				let that = this;
				getProduct(1,{
					page:that.page,
					limit:that.limit
				}).then(res=>{
					let list = res.data;
					let productList = that.$util.SplitArray(list, that.list);
					that.list = productList
				})
			},
			indexData(){//1.消费券商城
			let that = this;
				getIndexData(1).then(res=>{
					that.banner = res.data.banner
					that.notes = res.data.notes
					that.hot_list =  res.data.hot_list
				})
			},
			clickSeach(){
				uni.navigateTo({
					url:'/pages/goods/goods_search/index'
				})
			},
			goCart(){
				uni.switchTab({
					url:'/pages/order_addcart/order_addcart'
				})
			},
			gokefu(){
				uni.navigateTo({
					url:'/pages/extension/customer_list/chat'
				})
			}
		},
		onReachBottom() {
			
		}
	}
</script>

	
	
<style>
	.two-aa{
		width: 58px;
		height: 58px;
		background: linear-gradient( 180deg, rgba(226,255,247,0) 0%, #67D8B9 100%);
		border-radius: 16px;
		opacity: 0.6;		
	}
	.one-aa{
		width: 58px;
		height: 58px;
		background: linear-gradient( 180deg, rgba(226,255,247,0) 0%, #FBC51D 100%);
		border-radius: 16px;
		opacity: 0.6;		
	}
	.bb{
		width: 78px;
		height: 18px;
		background: linear-gradient( 90deg, #67D9B9 0%, #39A3E4 100%);
		border-radius: 63px 2px 43px 63px;
	}
	.top{
		
		
	}
	.two{
		width: 168px;
		height: 122px;
		background: url('/static/mall/bg_fxhw@2x.png');
		background-repeat:no-repeat;
		background-size: 100% 100%;
	}
	.one{
		width: 168px;
		height: 122px;
		background: url('/static/mall/bg_xpms@2x.png');
		background-repeat:no-repeat;
		background-size: 100% 100%;
	}
	.yx-title{
		display: flex;
		align-items: center;
		justify-content: center;
		margin-top: 5px;
		height: 18px;
		font-family: PingFangSC, PingFang SC;
		font-weight: 600;
		font-size: 13px;
		color: #834D02;
		line-height: 18px;
		text-align: left;
		font-style: normal;
	}
	.aa{
		display: flex;
		align-items: center;
		justify-content: center;
		width: 90px;
		height: 22px;
		background: linear-gradient( 180deg, #FDD71C 0%, #FBC51D 100%);
		box-shadow: inset 0px 1px 1px 0px rgba(255,255,255,0.5), inset 0px -1px 1px 0px #E1A305;
		border-radius: 0px 0px 8px 8px;
	}
	.yx_price{
		background: linear-gradient( 180deg, #FDD71C 0%, #FBC51D 100%);
		box-shadow: inset 0px 1px 1px 0px rgba(255,255,255,0.5), inset 0px -1px 1px 0px #E1A305;
		border-radius: 0px 0px 8px 8px;
	}
	.yx{
		background: url('/static/mall/bg_zxbk@2x.png');
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	.gift{
		text-align: center;
		line-height: 30px;
		width: 90px;height: 26px;
		background: url('/static/mall/img_libao@2x.png');
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	.yq{
		display: flex;
		align-items: center;
		justify-content: center;
		
		width: 61px;
		height: 20px;
		background: linear-gradient( 180deg, #FFFFFF 0%, #FFECA8 100%), #D8D8D8;
		border-radius: 10px;
		font-weight: 400;
		font-size: 12px;
		color: #B16C0C;
		line-height: 17px;
		text-align: left;
		font-style: normal;
	}
	.yaoqing{
		width: 100%;
		height: 40px;
		background: url('/static/mall/bg_yqhy@2x.png');
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	.nav-text{
		font-weight: 600;
		font-size: 13px;
		color: #FFFFFF;
		text-shadow: 0px 1px 2px #BF5810;
		font-style: normal;
		position: absolute;
		top: 7px;
		left: 9px;
	}
	.rl-text{
		font-size: 17px;
		font-weight: 600;
		color: #fff;
	}
	.nav-left{
		background: url("/static/mall/bg_rlsc@2x.png");
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	.nav-right{
		background: url("/static/mall/bg_rysc@2x.png");
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	.uni-noticebar{
		padding: 0px;
		margin-bottom: 0px;
	}
	.my-font-text {
	  font-family:'PangMenZhengDao'!important;
	}
	.box-bg{
		width:100%;
		height: 315px;
		background: url("/static/images/bg_homepage.png");
		background-repeat:no-repeat;
		background-size: 100% 100%;
	}
</style>
