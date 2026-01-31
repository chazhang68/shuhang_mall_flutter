<template>
	<view>

		<view class="px-2 bg-white pb-1" style="position: sticky;z-index:100;top:0;" :style="{'padding-top':sysHeight}">
		  <image src="/static/images/logos.png" style="width: 120px;height: 48px;"></image>
		</view>
		<view class="box-bg px-3 mt-1">
			<view class="w-100 mt-1" style="height: 188px;">
				<swiper :indicator-dots="true" style="height: 100%;" indicator-active-color="#fff" indicator-color="#fff"  :autoplay="true" :interval="3000" :duration="1000">
					<swiper-item v-for="(item) in banner" @click="goUrl(item.url)" class="rounded">
						<image :src="item.img_url" class="rounded" style="width: 100%;height: 100%;" mode=""></image>
					</swiper-item>
				</swiper>
			</view>
			<view class="mt-2 flex align-center bg-white rounded" style="height: 32px;" v-if="notes">
				<view class="flex align-center pl-1">
				<image src="/static/images/icon_notice@2x.png" style="width: 48rpx;height: 48rpx;" mode=""></image>
				<text class="my-font-text" style="font-size: 13px;color: #333;">公告</text>
				</view>
				 <view class="ml-2" style="width: 1px;height: 13px;background:#DDDDDD;"></view>
				<view class="flex-1 pl-2" style="height: 25px;" @click="goNotice" >
					<uni-notice-bar style="height: 25px;" :speed="50" scrollable single background-color="#fff" color="#666666" :text="notes"></uni-notice-bar>
				</view>
			</view>
		</view>
		<view class="px-3 pt-2">
			 <!-- <view class="mb-3 flex " >
					<view class="flex justify-between w-100 align-center" >
					  <image class="small-right "  src="/static/index-image/small-right-top.jpg" @click="shoubiao"></image>
					  <image class="small-right " src="/static/index-image/small-right-bottom.jpg" @click="openMall"></image>
					</view>
			  </view> -->
      <view class="ad-view" style="margin-bottom:15px;border-radius:5px">
            <ad adpid="1300417835" ad-intervals="40" @load="onload" @close="onclose" @error="onerror"></ad>
       </view>
			<view class="flex align-center justify-between">
				<view class="flex bg-white rounded-circle align-center justify-between" style="width: 100%;height: 35px;" @click="clickSeach">
					<view class="flex align-center">
					<image class="ml-1" src="/static/images/icon_serch@2x.png" style="width: 24px;;height: 24px;" mode=""></image>
					<view class="font-sm ml-1" style="color: #A6A6A6;">输入你想搜索的商品</view>
					</view>
					<view class="mr-2" style="color: #444444;font-size: 13px;">搜索</view>
				</view>
				
			</view>

			<!-- 商品列表 -->
			<view class="flex flex-wrap justify-between mt-2">
				<view class="list-item mb-2" v-for="item in list" @click="godetail(item.id)" style="width:49%;border-radius: 8px;">
					<image :src="item.image" mode="" style="width: 100%;height: 169px;border-radius: 8px 8px 0px 0px;vertical-align: bottom;"></image>
					<view class="p-1 bg-white" style="width: 100%;border-radius: 0px 0px 8px 8px;">
						<view class="font-weight-bold mt-1 text-ellipsis-one" style="color: #333;font-size: 30rpx;">{{item.store_name}}</view>
            <view class="shop-desc">{{ item.keyword }}</view>
            <view class="flex align-center justify-start" style="margin-top: 15rpx;padding: 10rpx; ">
              <image style="width: 82rpx;height: 31rpx" src="/static/index-image/xiaofeiquan.png"></image>
			  <view class="price-txt pl-3">{{item.price}}</view>
			
            </view>
				
					</view>
				</view>

				
			</view>
			
			<view class="uni-p-b-98"></view>
		</view>

		<!-- #ifdef APP-PLUS -->
		<app-update  ref="appUpdate" :force="true" :tabbar="false"></app-update>
		<!-- #endif -->

		<pageFoot></pageFoot>
	</view>
</template>

<script>
	let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';
	import pageFoot from '@/components/pageFooter/index.vue';
	import colors from '@/mixins/color';
	import appUpdate from "@/components/update/app-update.vue";
	import popup from "@/components/ge-popup.vue";
	import {
		getIndexData,getProduct
	} from "@/api/public.js";
	export default {
		components:{
			popup,
			pageFoot,
			// #ifdef  APP-PLUS
			appUpdate, //APP更新
			// #endif
		},
		mixins: [colors],
		data() {
			return {
				isMask:true,
				title:"公告",
				loading: false,
				loadend: false,
				sysHeight: sysHeight,
				loadTitle: this.$t(`加载更多`),
				content:"",
				nav:[
					{
						// text:"邮费充值",
            text: "",
						img:"/static/index-image/youfei.png"
					},{
						// text:"酒店民宿",
            text: "",
						img:"/static/index-image/jiudian.png"
					},{
						// text:"电影影院",
            text: "",
						img:"/static/index-image/dianying.png"
					},
					{
						// text:"火车机票",
            text: "",
						img:"/static/index-image/jipiao.png"
					},
					{
						text:"生活缴费",
						img:"/static/mall/img_shjf.png"
					},
				],
				banner:[],
				notes:'',
				hot_list:[],
				list:[],
				page:1,
				limit:10,
				urlid:'',
			}
		},
		  computed: {
		    stickyStyle() {
		      return {
		        position: 'sticky',
		        top: this.sysHeight,
		        zIndex: 100,
		        backgroundColor: 'white'
		      }
		    }
		  },
		created() {
			//获取首页数据
			this.indexData()
			//this.getProductlist()
		},
		methods: {
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
			
			closeMask(){//关闭弹窗
				this.isMask=false;
			},
			shoubiao(){
				uni.switchTab({
					url:"/pages/task/task"
				})
			},
      shengTai(){
        this.$util.Tips({
          title: this.$t(`暂未开放`)
        })
      },
			goNotice(){
				uni.navigateTo({
					url:"/pages/extension/news_details/index?id="+this.urlid,
					animationDuration:100,
					animationType:'fade-in'
				})
			},
			goUrl(url){
				uni.navigateTo({
					url:url,
					animationDuration:100,
					animationType:'fade-in'
				})
			},
			godetail(id){
				uni.navigateTo({
					url: `/pages/goods_details/index?id=${id}`,
					animationDuration:100,
					animationType:'fade-in'
				});
			},
			getProductlist(){
				let that = this;
				let page = that.page;
				let limit = that.limit;
				if (that.loading) return;
				if (that.loadend) return;
				that.loading = true;
				that.loadTitle = '';
				getProduct(1,{
					page:page,
					limit:limit
				},false).then(res => {
					uni.stopPullDownRefresh()
					let loadend = res.data.length < that.limit;
					that.loadend = loadend;
					that.list = that.$util.SplitArray(res.data, that.list);
					that.$set(that, 'list', that.list);
					that.loadTitle = loadend ? that.$t(`我也是有底线的`) : that.$t(`加载更多`);
					that.page += 1;
					that.loading = false;
				}).catch(err => {
					that.loading = false;
					that.loadTitle = that.$t(`加载更多`);
				})
			},
			indexData(){//1.消费券商城
			let that = this;
				getIndexData(1,{},false).then(res=>{
					that.banner = res.data.banner
					that.notes = res.data.notes
					that.list =  res.data.hot_list
					that.urlid = res.data.id
					uni.stopPullDownRefresh()
				})
			},
			clickSeach(){
				uni.navigateTo({
					url:'/pages/goods/goods_search/index',
					animationDuration:100,
					animationType:'fade-in'
				})
			},
			goCart(){
				uni.navigateTo({
					url:'/pages/order_addcart/order_addcart',
					animationDuration:100,
					animationType:'fade-in'
				})
			},
			gokefu(){
				uni.navigateTo({
					url:'/pages/extension/customer_list/chat',
					animationDuration:100,
					animationType:'fade-in'
				})
			}
		},
		onReachBottom() {
			// this.getProductlist()
		},
		onPullDownRefresh() {

			this.loadTitle = false;
			this.loadend = false;
			this.list = [];
			// this.getProductlist()
			this.indexData()
		}
	}
</script>

<style lang="scss">
.price-txt {
  font-family: DIN Alternate;
  font-weight: bold;
  font-size: 30rpx;
  color: #FA281D;
}

.shop-desc {
  font-family: PingFang SC;
  font-weight: 400;
  font-size: 20rpx;
  color: #E9AD00;
  margin-top: 10rpx;
}

.big-left {
  width: 345rpx;
  height: 340rpx;
  margin-right: 20rpx;

  & image {
    width: 100%;
    height: 100%;
    border-radius: 20rpx;
  }
}

.small-right {
  width: 170px;
  height: 160rpx;
	border-radius: 20rpx;
}

.swiper {
  white-space: nowrap;
  height: 100%;
}

.swiper-group {
  //display: inline-block;
  width: 100%;
  white-space: initial;

}

.item {
  height: 100%;
  width: 80%;
  display: inline-block;
  line-height: 200px;
  text-align: center;
  background-color: #ccc;

}

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
		//background: url('/static/mall/bg_yqhy@2x.png');
		//background-repeat: no-repeat;
		//background-size: 100% 100%;
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
		background: url("/static/index-image/ranliao.png");
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	.nav-right{
		background: url("/static/index-image/rongyu.png");
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
		background: url("/static/images/bg_homepage.png");
		background-repeat:no-repeat;
		background-size: 100% 100%;
	}
</style>
