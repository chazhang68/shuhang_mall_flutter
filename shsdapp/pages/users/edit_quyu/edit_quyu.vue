<template>
	<view :style="colorStyle">
		<form @submit="editQuyu">
			<view class="ChangePassword">
				<view class="list">
					<view class="item flex align-center" >
						当前注册区域：{{userInfo.quyu}}
					</view>
					<view class='item acea-row flex align-center'>
								
						<view class='name flex align-center' style="color: grey;" >
							{{$t(`请选择注册区域`)}}</view>
						<view class="address" style="flex:1;"> 
							<picker style="flex:1" mode="multiSelector" @change="bindRegionChange"
								@columnchange="bindMultiPickerColumnChange" :value="valueRegion" :range="multiArray">
								<view class='acea-row' style="flex:1">
									<view class="picker" style="color:grey;flex: 1;text-align: end;">{{region[0]}}{{region[1]}}{{region[2]}}</view>
								
								</view>
							</picker>
						</view>
					</view>
					<view class="font-sm my-2" style="color: red;">备注：修改注册区域将消耗一个福豆</view>
				</view>
				
				<button form-type="submit" class="confirmBnt bg-color">确认修改</button>
			</view>
		</form>

	</view>
</template>

<script>

	import {
		toLogin
	} from '@/libs/login.js';
	import {
		getCity
	} from '@/api/api.js'
	import {getUserInfo,editQuyu} from'@/api/user.js'
	import {
		mapGetters
	} from "vuex";
	// #ifdef MP
	import authorize from '@/components/Authorize';
	// #endif
	import colors from '@/mixins/color.js';
	export default {
		mixins: [colors],
		components: {
			// #ifdef MP
			authorize,
			// #endif
		},
		data() {
			return {
				phone:'',
				captcha:'',
				isAuto: false, //没有授权的不会自动授权
				isShowAuth: false, //是否隐藏授权
				key: '',
				authKey:'',
				type:0,
				cityId: 0,
				userInfo:[],
				multiArray: [],
				regionDval: [this.$t(`浙江省`), this.$t(`杭州市`), this.$t(`滨江区`)],
				region: [this.$t(`点击`), this.$t(`选`), this.$t(`择`)],
				defaultRegion: [this.$t(`广东省`), this.$t(`广州市`), this.$t(`番禺区`)],
				defaultRegionCode: '110101',
				multiIndex: [0, 0, 0],
				valueRegion: [0, 0, 0],
				loading:true
			};
		},
		computed: mapGetters(['isLogin']),
		onLoad(options) {
			if (this.isLogin) {
				this.getUser()
				this.getCityList();
			} else {
				toLogin();
			}
			
		},
		methods: {
			editQuyu(){
				let that = this;
				if(!that.cityId){
					uni.showToast({
						title:"请选择注册区域",
						icon:"none"
					})
					return;
				}
				uni.showModal({
					title: '提示',
					content: '确认消耗1福豆修改注册区域吗?',
					success: function (res) {
						if (res.confirm) {
							if(!that.loading)return;
							that.loading = false;
							uni.showLoading({
								title:"修改中...."
							})
							editQuyu({city_id:that.cityId}).then(res=>{
								uni.hideLoading()
								uni.showToast({
									title:res.msg
								})
								that.loading = true
								that.getUser()
							}).catch(res=>{
								uni.hideLoading()
								uni.showToast({
									title:res,
									icon:"none"
								})
								that.loading = true
							})
						} else if (res.cancel) {
							console.log('用户点击取消');
						}
					}
				});
				
			},
			getCityList: function() {
				let that = this;
				getCity().then(res => {
					this.district = res.data
					that.initialize();
				})
			},
			bindMultiPickerColumnChange: function(e) {
				let that = this,
					column = e.detail.column,
					value = e.detail.value,
					currentCity = this.district[value] || {
						c: []
					},
					multiArray = that.multiArray,
					multiIndex = that.multiIndex;
				multiIndex[column] = value;
				switch (column) {
					case 0:
						let areaList = currentCity.c[0] || {
							c: []
						};
						multiArray[1] = currentCity.c.map((item) => {
							return item.n;
						});
						multiArray[2] = areaList.c.map((item) => {
							return item.n;
						});
						break;
					case 1:
						let cityList = that.district[multiIndex[0]].c[multiIndex[1]].c || [];
						multiArray[2] = cityList.map((item) => {
							return item.n;
						});
						break;
					case 2:
			
						break;
				}
				// #ifdef MP || APP-PLUS
				this.$set(this.multiArray, 0, multiArray[0]);
				this.$set(this.multiArray, 1, multiArray[1]);
				this.$set(this.multiArray, 2, multiArray[2]);
				// #endif
				// #ifdef H5 
				this.multiArray = multiArray;
				// #endif
			
			
			
				this.multiIndex = multiIndex
				// this.setData({ multiArray: multiArray, multiIndex: multiIndex});
			},
			bindRegionChange: function(e) {
				let multiIndex = this.multiIndex,
					province = this.district[multiIndex[0]] || {
						c: []
					},
					city = province.c[multiIndex[1]] || {
						v: 0
					},
					sea = city.c[multiIndex[2]] || {
						v: 0
					},
					multiArray = this.multiArray,
					value = e.detail.value;
			
				this.region = [multiArray[0][value[0]], multiArray[1][value[1]], multiArray[2][value[2]]]
				// this.$set(this.region,0,multiArray[0][value[0]]);
				// this.$set(this.region,1,multiArray[1][value[1]]);
				// this.$set(this.region,2,multiArray[2][value[2]]);
				this.cityId = sea.v
				this.valueRegion = [0, 0, 0]
				this.initialize();
			},
			initialize() {
				let that = this,
					province = [],
					city = [],
					area = [];
				let cityChildren = that.district[0].c || [];
				let areaChildren = cityChildren.length ? (cityChildren[0].c || []) : [];
				that.district.forEach((item, i) => {
					province.push(item.n);
					if (item.n === this.region[0]) {
						this.valueRegion[0] = i
						this.multiIndex[0] = i
					}
				});
				that.district[this.valueRegion[0]].c.forEach((item, i) => {
					if (this.region[1] == item.c) {
						this.valueRegion[1] = i
						this.multiIndex[1] = i
					}
					city.push(item.n);
				});
				that.district[this.valueRegion[0]].c[this.valueRegion[1]].c.forEach((item, i) => {
					if (this.region[2] == item.c) {
						this.valueRegion[2] = i
						this.multiIndex[2] = i
					}
					area.push(item.n);
				});
				this.multiArray = [province, city, area]
			
			},
			getUser(){
				getUserInfo().then(res=>{
					this.userInfo = res.data
				})
			},
			onLoadFun:function(){},
			// 授权关闭
			authColse: function(e) {
				this.isShowAuth = e
			},
	
		}
	}
</script>

<style lang="scss">
	page {
		background-color: #fff !important;
	}

	.ChangePassword .phone {
		font-size: 32rpx;
		font-weight: bold;
		text-align: center;
		margin-top: 55rpx;
	}

	.ChangePassword .list {
		width: 580rpx;
		margin: 53rpx auto 0 auto;
	}

	.ChangePassword .list .item {
		width: 100%;
		height: 110rpx;
		border-bottom: 2rpx solid #f0f0f0;
	}

	.ChangePassword .list .item input {
		width: 100%;
		height: 100%;
		font-size: 32rpx;
	}

	.ChangePassword .list .item .placeholder {
		color: #b9b9bc;
	}

	.ChangePassword .list .item input.codeIput {
		width: 340rpx;
	}

	.ChangePassword .list .item .code {
		font-size: 32rpx;
		background-color: #fff;
	}

	.ChangePassword .list .item .code.on {
		color: #b9b9bc !important;
	}

	.ChangePassword .confirmBnt {
		font-size: 32rpx;
		width: 580rpx;
		height: 90rpx;
		border-radius: 45rpx;
		color: #fff;
		margin: 92rpx auto 0 auto;
		text-align: center;
		line-height: 90rpx;
	}
</style>
