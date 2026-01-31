<template>
	<view>
	
		<view class="px-2 bg-white pb-1" style="position: sticky;z-index:100;top:0;" :style="{'padding-top':sysHeight}">
		  <image src="/static/images/logos.png" style="width: 120px;height: 48px;"></image>
		</view>
		<view class="box-bg px-3" >
		
		
			<view class="w-100" style="height: 188px;">
				<swiper :indicator-dots="true" style="height: 100%;" indicator-active-color="#fff" indicator-color="#fff"  :autoplay="true" :interval="3000" :duration="1000">
					<swiper-item v-for="(item) in banner" @click="goUrl(item.url)">
						<image :src="item.img_url" style="width: 100%;height: 100%;" mode=""></image>
					</swiper-item>
				</swiper>
			</view>

		</view>
		<view class="px-3 mt-2">
			
			<!-- 商品列表 -->
			<view class="flex flex-wrap justify-between mt-2">

				<view class="list-item mb-2" v-for="item in list" @click="godetail(item.id)" style="width: 49%;border-radius: 8px;">
					<image :src="item.image" mode="" style="width: 100%;height: 170px;;border-radius: 8px 8px 0px 0px;vertical-align: bottom;"></image>
					<view class="p-1 bg-white" style="width: 100%;border-radius: 0px 0px 8px 8px;">
						<view class="font-weight-bold text-ellipsis-two mt-1" style="color: #333;font-size: 14px;">{{item.store_name}}</view>
						
						<view class="flex align-center justify-between px-1" style="margin-top: 3px;">
							<view class="flex align-center">
                <view class="price-txt"><text style="font-size: 10px;">SWP</text>{{item.price}}</view>
							</view>
							<view>
                <image src="/static/index-image/shop-card.png" style="width: 48rpx;height: 48rpx;" mode=""></image>
							</view>
						</view>
					</view>
				</view>

				<view class='loadingicon acea-row row-center-wrapper' v-if="list.length">
					<text class='loading iconfont icon-jiazai' :hidden='loading==false'></text>{{loadTitle}}
				</view>
			</view>




			<view class="uni-p-b-98"></view>

		</view>


		<pageFoot></pageFoot>
	</view>
</template>

<script>
	let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';
	import pageFoot from '@/components/pageFooter/index.vue';
	import colors from '@/mixins/color';
	import {
		getIndexData,getProduct
	} from "@/api/public.js";
	export default {
		components:{
			pageFoot
		},
		mixins: [colors],
		data() {
			return {
				sysHeight: sysHeight,
				loading: false,
				loadend: false,
				loadTitle: this.$t(`加载更多`),
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
			gocart(){
				uni.navigateTo({
					url:"/pages/order_addcart/order_addcart",
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			goYaoq(){

			},
			goUrl(url){
				uni.navigateTo({
					url:url,
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			godetail(id){
				uni.navigateTo({
					url: `/pages/goods_details/index?id=${id}`,
					animationDuration:100,
					animationType:"fade-in"
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
				getProduct(2,{
					page:page,
					limit:limit
				}).then(res => {
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
				getIndexData(2).then(res=>{
					uni.stopPullDownRefresh()
					that.banner = res.data.banner
					that.notes = res.data.notes
					that.hot_list =  res.data.hot_list
				})
			},
			clickSeach(){
				uni.navigateTo({
					url:'/pages/goods/goods_search/index',
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			goCart(){
				uni.navigateTo({
					url:'/pages/order_addcart/order_addcart',
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			gokefu(){
				uni.navigateTo({
					url:'/pages/extension/customer_list/chat',
					animationDuration:100,
					animationType:"fade-in"
				})
			}
		},
		onReachBottom() {
			this.getProductlist()
		},
		onPullDownRefresh() {
			this.loadTitle = false;
			this.loadend = false;
			this.list = [];
			this.page = 1;
			this.getProductlist()
			this.indexData()
		}
	}
</script>



<style>
.price-txt {
  font-family: DIN Alternate;
  font-weight: bold;
  font-size: 30rpx;
  color: #FA281D;
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
