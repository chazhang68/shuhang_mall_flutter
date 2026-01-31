<template>
	<view>
		<view class="bg-white" style="position: sticky;z-index: 99" :style="{'top':top}">
		<uni-segmented-control :current="current" :values="items" @clickItem="onClickItem" styleType="button" activeColor="#dd524d"></uni-segmented-control>
		</view>
		 <view class="content" style="padding: 10px;">
		            <view v-show="current === 0">
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
								<view class="chushou" @click="open(item.id)">互换</view>
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
		            <view v-show="current === 1">
		                <view class="box-item" v-for="(item) in recordList" >
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
								<view style="margin-top: 15rpx;">类型：{{item.type == 1?'消费券':'福豆 '}}</view>
							</view>
							<view class="chushou" @click="open(item.id)">互换</view>
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
		 <view style="height: 55px;"></view>
		 <view class="flex align-center justify-center" style="position: fixed;bottom:0px;left: 0px; right: 0px;background: #fff;height: 55px;" v-if="userInfo.is_shop">
		 	<view class="send" @click="fabu">发布互换</view>
		 </view>	
		<uni-popup ref="popup" type="bottom" :mask-click="false">
			<view class="bg-white tc" >
				<view class="flex align-center" style="padding: 30rpx 30rpx 0px 30rpx;">
					<image :src="info.avatar" mode="" style="width: 45rpx;height: 45rpx;border-radius: 100%;"></image>
					<view class="" style="font-size:14px;font-weight: 500;margin-left: 20rpx;">{{info.nickname}}<text style="color: #dd524d;margin-left: 5px;">提示您：</text></view>
				</view>
				<view  class="flex align-center" style="height: 160rpx;padding: 30rpx;border-bottom: 1px solid #e8e8e8;">
					<image src="@/static/images/xfq.png"  style="width: 95rpx;height: 95rpx;"></image>
					<view class="ml-3" style="">
						<view class="font" style="font-weight:500;">互换{{info.type == 1?'消费券':'福豆 '}}</view>
						<view>单价 <text class="font" style="color: #dd524d;margin-left: 5px;">{{info.dprice}}</text></view>
					</view>
				</view>
				<view class="p-3">
					<view class="flex align-center p-2" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 20rpx;">
						<input style="width: 480rpx;font-size:13px" type="number" placeholder="请输入互换数量" placeholder-style="font-size:13px" v-model="number" :disabled="true">
						<view class="flex flex-1 align-center" style="justify-content:space-between">
							<view style="color: #53586e;">个</view>
							<view style="width: 1px;height: 40rpx;background: #dcdde1;"></view>
							<view style="font-weight: 500;" @click="sendall">全部互换</view>
						</view>
						
					</view>
					<!-- <view class="flex align-center p-2" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
						<input style="width: 480rpx;font-size:13px" v-model="code" type="number" placeholder="请输入短信验证码" placeholder-style="font-size:13px">
						<view class="flex flex-1 align-center" style="justify-content: flex-end;">
							<view style="font-weight: 500;color: #dd524d;" @click="getCheckNum()">{{text}}</view>
						</view>
						
					</view> -->
					<view class="flex align-center pp" >
						<view  style="color: #7d7d7d;">当前可用</view>
						<view  style="font-weight: 500;"> {{info.type == 1?userInfo.integral:userInfo.fudou}}{{info.type == 1?'消费券':'福豆 '}}</view>
					</view>
					<view class="flex align-center pp">
						<view  style="color: #7d7d7d;">互换数量</view>
						<view  style="font-weight: 500;"> {{number}}{{info.type == 1?'消费券':'福豆 '}}</view>
					</view>
					<view class="flex align-center pp" v-if="info.type == 1">
						<view  style="color: #7d7d7d;">换入金额</view>
						<view  style="font-weight: 500;"> {{allPrice}}</view>
					</view>
					<view class="flex align-center pp" v-if="info.type == 2">
						<view  style="color: #7d7d7d;">换入消费券数量</view>
						<view  style="font-weight: 500;"> {{allPrice}}</view>
					</view>
					<view v-if="info.type == 2">
						<view class="uni-px-5 uni-pb-5">
							<uni-data-checkbox mode="list" selectedColor="#dd524d" selectedTextColor="#dd524d" v-model="sxf_type" :localdata="sxf" :map="{text:'name',value:'id'}"></uni-data-checkbox>
						</view>
						<view class="font-sm" style="color: #dd524d;">{{bz}}</view>
						<view class="flex align-center mt-1" >
							<view  style="color: #7d7d7d;" v-if="fd_bl>0">福豆手续费：{{fd_sxf}}</view>
							<view class="ml-3" v-if="xfq_bl>0"  style="color: #7d7d7d;">消费券手续费：{{xfq_sxf}}</view>
						</view>
					</view>
					<view v-if="info.type == 1">
					<view class="flex align-center pp" >
						<view  style="color: #7d7d7d;">换入方式</view>
						<view  style="font-weight: 500;"></view>
					</view>
					<view class="uni-px-5 uni-pb-5">
						<uni-data-checkbox mode="button" selectedColor="#dd524d" selectedTextColor="#dd524d" multiple v-model="pay_type" :localdata="hobby" ></uni-data-checkbox>
					</view>
					</view>
					<view class="flex align-center mt-4" style="justify-content: space-between;">
						<view class="flex align-center justify-center cancel" @click="cancel">取消</view>
						<view class="flex align-center justify-center queren" @click="okjiaoyi(info.id)">确认互换</view>
					</view>
				</view>
				
				
			</view>
		</uni-popup>
	</view>
</template>

<script>
	
	import {getOtcList,otcOrderInfo,getUserInfo,getCodeApi,sendCode,maichuOtc,getSxf} from '@/api/user.js'
	import emptyPage from '@/components/emptyPage.vue'
	export default {
		components: {
			emptyPage
		},
		data() {
			return {
				items: ['消费券互换区', '福豆互换区','结算方式'],
				sxf:[],
				sxf_type:1029,
				page: 1,
				limit: 15,
				loading: false,
				loadend: false,
				loadTitle: this.$t(`加载更多`),
				recordList:[],
				current: 0	,
				top:0,
				number:'',
				info:[],
				text: '获取验证码',
				codeTime: '0',
				userInfo:[],
				keyCode:'',
				allPrice:0,
				is_send:true,
				fd_sxf:0,
				xfq_sxf:0,
				fd_bl:0,
				xfq_bl:0,
				hobby: [{
					text: '银行卡',
					value: 1
				}, {
					text: '支付宝',
					value: 2
				}, {
					text: '微信',
					value: 3
				}],
				pay_type: [],
				code: "",
				index:0,
				allfd:0,
				sxf_index:0,
				bz:''
					
			}
		},
		onNavigationBarButtonTap(res) {
			uni.navigateTo({
				url:"/pages/otc_order/otc_order"
			})
		},
		onLoad(options) {
			this.top = uni.getSystemInfoSync().windowTop+'px'
			this.current = Number(options.id)
		},
		onShow() {
			this.loading = false
			this.loadend = false
			this.loadTitle = this.$t(`加载更多`);
			this.page =  1,	
			this.current = 0
			this.recordList = [],
			this.getRecordList()
			this.getUser()
			this.getSxf()
		},
		watch:{
			number:{
				handler:function(newV,old){
					if(newV == ''){
						this.allPrice = 0
						this.allfd = this.info.number
					}else{
						this.allPrice = (newV*this.info.dprice).toFixed(3)
						
					}
				}
			},
			sxf_type:{
				handler:function(newV,old){
					let that = this;
					this.sxf.forEach(function(item,index){
						if(newV == item.id){
							that.sxf_index = index
						}
					})
					this.sxf_type = newV
					this.fd_bl = this.sxf[this.sxf_index].sxf
					this.xfq_bl = this.sxf[this.sxf_index].xfq
					//计算手续费
					this.fd_sxf = (this.number*this.fd_bl/100).toFixed(3)
					this.xfq_sxf = (this.number*this.xfq_bl/100).toFixed(3)
				}
			}
		},
		methods: {
			getSxf(){
				getSxf().then(res=>{
					this.sxf = res.data.sxf
					this.fd_bl = res.data.sxf[this.sxf_index].sxf
					this.xfq_bl = res.data.sxf[this.sxf_index].xfq
					
					this.bz = res.data.bz
				})
			},
			okjiaoyi(id){
				let that = this;
				if(!that.number){
					uni.showToast({
						title:"请输入售出数量",
						icon:"none"
					})
					return;
				}
				if(this.info.type == 1){
					if(Number(that.number) > Number(that.userInfo.integral)){
						uni.showToast({
							title:"消费券余额不足",
							icon:"none"
						})
						return;
					}
					if(this.pay_type.length == 0 ){
						uni.showToast({
							title:"请选择换入方式",
							icon:"none"
						})
						return;
					}
				}
				if(this.info.type == 2){
					//累计预指出+账户留存
					let allfd = (Number(that.number)+Number(that.fd_sxf)+10)
					if(Number(that.xfq_sxf) > Number(that.userInfo.integral)){
						uni.showToast({
							title:"消费券余额不足",
							icon:"none"
						})
						return;
					}
					if(allfd > Number(that.userInfo.fudou)){
						uni.showToast({
							title:"福豆余额不足",
							icon:"none"
						})
						return;
					}
				}
				// if(!that.code){
				// 	uni.showToast({
				// 		title:"请输入验证码",
				// 		icon:"none"
				// 	})
				// 	return;
				// }
				if(!that.is_send)return;
				that.is_send = false;
				let data = {}
				data.id = id
				data.number = that.number
				// data.code = that.code
				data.pay_type = that.pay_type
				data.sxf_index = that.sxf_index
				uni.showLoading({
					title:"数据提交中...."
				})
				
				maichuOtc(data).then(res=>{
					uni.hideLoading()
					uni.showToast({
						title:"数据提交成功，等待买方打款",
						icon:"none"
					})
					that.$refs.popup.close()
					this.number = '',
					this.code = ''
					that.is_send = true
					this.loading = false
					this.loadend = false
					this.loadTitle = this.$t(`加载更多`);
					this.page =  1,	
					this.recordList = [],
					this.getRecordList()
					this.getUser()
				}).catch(res=>{
					uni.hideLoading()
					uni.showToast({
						title:res,
						icon:"none"
					})
					that.is_send = true
				})
			},
			sendall(){
				this.number = this.info.number
			},
			getUser(){
				getUserInfo().then(res=>{
					this.userInfo = res.data
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
				getOtcList({
					page: page,
					limit: limit,
					type:type
					
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
			fabu(){
				uni.navigateTo({
					url:'/pages/send_otc/send_otc'
				})
			},
			 open(id){
					this.getCodes();
					otcOrderInfo(id).then(res=>{
						this.info = res.data.data
						this.number = res.data.data.number
						this.allfd = res.data.data.number
						this.fd_sxf = (this.number*this.fd_bl/100).toFixed(3)
						this.xfq_sxf = (this.number*this.xfq_bl/100).toFixed(3)
						this.$refs.popup.open('bottom')
					})
			        
			},
			getCodes() {
				getCodeApi().then(res => {
						this.keyCode = res.data.key;
					})
					.catch(res => {
			
						uni.showToast({
							title: res.msg,
							icon: "error"
						})
					});
			},
			getCheckNum(){
				let that = this;
				if (this.codeTime > 0) {
					uni.showToast({
						title: '不能重复获取',
						icon: "none"
					});
					return;
				}
				
				sendCode({
					phone: that.userInfo.phone,
					type: 'login',
					key: that.keyCode,
					captchaType: 'blockPuzzle',
					code: that.code
				}).then(res=>{
					
						if (res.status == 200) {
							uni.showToast({
								title: res.msg,
								icon: "none"
							})
							that.daojishi()
						}
					
				})
			},
			daojishi() {
				this.codeTime = 60
				let timer = setInterval(() => {
					this.codeTime--;
					this.text = this.codeTime + "秒后获取"
					if (this.codeTime < 1) {
						clearInterval(timer);
						this.codeTime = 0,
							this.text = "获取验证码"
					}
				}, 1000)
			},
			cancel(){
				this.$refs.popup.close()
				this.number = '',
				this.code = ''
			},
			onClickItem(e) {
			      if (this.current != e.currentIndex) {
			        this.current = e.currentIndex;
					if(e.currentIndex == 2){
						uni.navigateTo({
							url:"/pages/pay_type/pay_type"
						})
					}
					this.loading = false
					this.loadend = false
					this.loadTitle = this.$t(`加载更多`);
					this.page =  1,
			
					this.recordList = [],
					this.getRecordList();
			      }
			}
		},
		onReachBottom: function() {
			this.getRecordList();
		}
	}
</script>

<style lang="scss">
	.cancel{
		width: 200rpx;
		height: 85rpx;
		background-color: #7d7d7d;
		font-size: 15px;
		border-radius: 3px;
	}
	.queren{
		width: 465rpx;
		height: 85rpx;
		background-color: #dd524d;
		font-size: 15px;
		color: #fff;
		border-radius: 3px;
	}
	.pp{
		justify-content: space-between;margin: 10px 0px;font-size:14px
	}
	.tc{
		height:480px;border-top-left-radius: 10px;border-top-right-radius: 10px;
	}
	.send{
		display: flex;
		align-items: center;
		justify-content: center;
		width: 60%;
		height: 40px;
	
		border-radius:30px;
		background: #dd524d;
		color: #fff;
	}
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

/deep/ .segmented-control__item--button--first{
	border-top-left-radius:0px!important;
	border-bottom-left-radius:0px!important
}
/deep/ .segmented-control__item--button--last{
	border-top-right-radius:0px!important;
	border-bottom-right-radius:0px!important
}




</style>

