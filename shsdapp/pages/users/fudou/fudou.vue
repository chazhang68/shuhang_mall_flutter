<template>
	<view :style="colorStyle">
		<view class='commission-details'>
			<view class='promoterHeader m-2'>
				<view class='headerCon'>
					<view class="acea-row row-between-wrapper" style="padding: 10px 0px;height: 100%;">
						<view class="flex flex-column justify-center" >
							<view class='name'>我的绿色积分</view>
							<view class=' font-weight-bold font-lg' style="color: #EDB451;">{{fudou}}</view>
										
						</view>
					</view>

				</view>
			</view>
			<view class="bg-white pb-2">
			<uni-segmented-control :current="current" :values="items" @clickItem="onClickItem" styleType="text" activeColor="#FFC900"></uni-segmented-control>
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
									<view class='num font-color font-weight-bold' v-if="item.pm == 1">+{{item.num}}</view>
									<view class='num font-weight-bold' v-else>-{{item.num}}</view>
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
		getUserInfo,getFudouList
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
				items: ['全部', '入账', '消费'],
				current: 0,
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
				fudou:''
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
				that.fudou = res.data.fudou
			})
			this.getRecordList()
		},
		methods: {
			onClickItem(e) {
			      if (this.current != e.currentIndex) {
			        this.current = e.currentIndex;
			      }
				  this.loadend = false;
				  this.loading = false;
				  this.recordList = [];
				  this.page = 1;
				  this.getRecordList()
			    },
			gofubao(){
				uni.navigateTo({
					url:"/pages/users/fubao_zhuan/fubao_zhuan"
				})
			},
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
				getFudouList({
					page: page,
					limit: limit,
					pm:that.current
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
