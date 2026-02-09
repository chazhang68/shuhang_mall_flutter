<template>
	<view :style="colorStyle">
		<view class='commission-details'>
			<view class='promoterHeader bg-color' style="height: 100px;">
				<view class='headerCon'>
					<view class="acea-row row-between-wrapper" style="padding: 25px 0px;">
					<view>
						<view class='name'>我的福宝</view>
						<view class='money'><text class='num'>{{fubao}}</text></view>
									
					</view>
					<image src="../../../static/images/dd.png" mode="" style="width: 65rpx;height: 65rpx;"></image></view>
					<view style="display: flex;align-items: center; justify-content: center;margin: 10px 0px;">
						<!-- <view style="padding: 5px 10px;margin: auto;border:1px solid #fff;border-radius: 5px;" @click="goUrl()">福豆转赠</view> -->
				<!-- <view style="padding: 5px 10px;margin: auto;border:1px solid #fff;border-radius: 5px;" >兑换福宝</view> -->
					</view>
				</view>
			</view>
			<view class='sign-record'>
					<view class='list'>
						<view class='item' v-for="(item) in recordList ">
							<view class='listn'>
								<view class='itemn acea-row row-between-wrapper'>
									<view class="title">
										<view class='name line1'>{{item.title}}</view>
										<view>{{item.add_time}}</view>
								
									</view>
									<view class='num font-color' v-if="item.pm == 1">+{{item.num}}</view>
									<view class='num' v-else>-{{item.num}}</view>
								</view>
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
		<!-- #ifdef H5 -->
		<home></home>
		<!-- #endif -->
	</view>
</template>

<script>
	import {
		getUserInfo,getFubaoList
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
			return {
				name: '',
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
				userInfo:[],
				fubao:''
			};
		},
		computed: mapGetters(['isLogin']),
		onLoad() {
			if (this.isLogin) {
				
			} else {
				toLogin();
			}
		},
		onShow: function() {
			let that = this;
			getUserInfo().then(res=>{
				that.fubao = res.data.fubao
			})
			this.getRecordList()
		},
		methods: {
			goUrl(){
				uni.navigateTo({
					url:"/pages/users/fudou_zhuan/fudou_zhuan"
				})
			},
			getRecordList: function() {
				let that = this;
				let page = that.page;
				let limit = that.limit;
				if (that.loading) return;
				if (that.loadend) return;
				that.loading = true;
				that.loadTitle = '';
				getFubaoList({
					page: page,
					limit: limit
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
			
		},
		onReachBottom: function() {
			this.getRecordList();
		}
	}
</script>

<style scoped lang="scss">
	.commission-details .promoterHeader .headerCon .money {
		font-size: 36rpx;
	}

	.commission-details .promoterHeader .headerCon .money .num {
		font-family: 'Guildford Pro';
	}
	.sign-record .list .item .listn .itemn .name{
		width: 100%;
		// max-width: 100%;
		white-space: break-spaces;
	}
	.sign-record .list .item .listn .itemn .title {
		padding-right: 30rpx;
		flex: 1;
	}
</style>
